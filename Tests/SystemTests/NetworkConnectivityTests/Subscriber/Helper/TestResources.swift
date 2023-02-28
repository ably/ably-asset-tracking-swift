import Ably
import AblyAssetTrackingInternal
import AblyAssetTrackingInternalTesting
import AblyAssetTrackingPublisherTesting
@testable import AblyAssetTrackingSubscriber
import AblyAssetTrackingSubscriberTesting
import AblyAssetTrackingTesting
import XCTest
import class Combine.CurrentValueSubject
import struct Combine.AnyPublisher

extension SubscriberNetworkConnectivityTests {
    /// For the convenience of test cases, the methods of this class are blocking, except for those whose name contains `Async`.
    final class TestResources {
        private let proxyClient: SDKTestProxyClient
        let faultSimulation: FaultSimulationDTO
        let trackableID: String
        private var ablyPublishing: AblyPublishing?
        let logHandler: InternalLogHandler
        private let subscriberClientID: String
        private var subscriberTestEnvironment: SubscriberTestEnvironment?

        private struct AblyPublishing {
            var defaultAbly: DefaultAbly
            // To maintain a strong reference to prevent it being deallocated
            private var delegate: AblyPublisherDelegate

            init(defaultAbly: DefaultAbly, delegate: AblyPublisherDelegate) {
                self.defaultAbly = defaultAbly
                self.delegate = delegate
            }
        }

        /// Provides a `Subscriber` instance and any other resources useful for testing it.
        struct SubscriberTestEnvironment {
            /// This subscriber has already been started.
            ///
            /// Its delegate is configured such that ``subscriberMonitorFactory`` can create monitors which can make assertions about delegate events. You should not change the value of its `delegate` property.
            var subscriber: Subscriber

            /// A factory for creating instances of ``SubscriberMonitor`` for the subscriber contained in the ``subscriber`` property.
            var subscriberMonitorFactory: SubscriberMonitorFactory
        }

        private let subscriberResolutionsSubject = CurrentValueSubject<Resolution?, Never>(nil)
        /// Re-publishes the latest received value to each new subscriber, to mimic behaviour of a Kotlin SharedFlow with replay 1. This lets us make the same assertions as in the Android version of these tests.
        let subscriberResolutions: AnyPublisher<Resolution, Never>

        enum TestResourcesError: Error {
            case ablyPublishingDidNotComeOnline
        }

        init(testCase: XCTestCase, proxyClient: SDKTestProxyClient, faultSimulation: FaultSimulationDTO, trackableID: String, logHandler: InternalLogHandler) {
            self.proxyClient = proxyClient
            self.faultSimulation = faultSimulation
            self.trackableID = trackableID
            self.logHandler = logHandler

            logHandler.logMessage(level: .info, message: "Created TestResources", error: nil)

            self.subscriberClientID = "AATNetworkConnectivityTests_Subscriber-\(trackableID)"
            self.subscriberResolutions = subscriberResolutionsSubject.compactMap { $0 }.eraseToAnyPublisher()
        }

        private func runBlocking<Success, Failure>(label: String, timeout: TimeInterval?, _ operation: (@escaping (Result<Success, Failure>) -> Void) -> Void) throws -> Success {
            try Blocking.run(label: label, timeout: timeout, logHandler: logHandler, operation)
        }

        private func shutdownSubscriber() throws {
            guard let subscriberTestEnvironment else {
                return
            }

            defer {
                self.subscriberTestEnvironment = nil
            }

            try runBlocking(label: "Shut down subscriber", timeout: 10) { handler in
                subscriberTestEnvironment.subscriber.stop(completion: handler)
            }
        }

        func tearDown() throws {
            var errors = MultipleErrors()

            do {
                try shutdownSubscriber()
            } catch {
                logHandler.error(message: "tearDown failed to shut down subscriber", error: error)
                errors.add(error)
            }

            do {
                try runBlocking(label: "Shut down Ably publishing in tearDown", timeout: 10) { handler in
                    shutdownAblyPublishingAsync(handler)
                }
            } catch {
                logHandler.error(message: "tearDown failed to shut down Ably publishing", error: error)
                errors.add(error)
            }

            do {
                try runBlocking(label: "Clean up fault simulation \(faultSimulation.id)", timeout: 10) { handler in
                    proxyClient.cleanUpFaultSimulation(withID: faultSimulation.id, handler)
                }
            } catch {
                logHandler.error(message: "tearDown failed to clean up fault simulation \(faultSimulation.id)", error: error)
                errors.add(error)
            }

            try errors.check()
        }

        func enableFault() throws {
            try runBlocking(label: "Enable fault simulation \(faultSimulation.id)", timeout: 10) { proxyClient.enableFaultSimulation(withID: faultSimulation.id, $0) }
        }

        func enableFaultAsync(_ completionHandler: @escaping (Result<Void, Error>) -> Void) {
            proxyClient.enableFaultSimulation(withID: faultSimulation.id, completionHandler)
        }

        func resolveFaultAsync(_ completionHandler: @escaping (Result<Void, Error>) -> Void) {
            proxyClient.resolveFaultSimulation(withID: faultSimulation.id, completionHandler)
        }

        /// Fetches an Ably token suitable for creating a `Subscriber`.
        private func fetchTokenAsync(_ completion: @escaping (Result<TokenDetails, Error>) -> Void) {
            let clientOptions = ARTClientOptions(key: Secrets.ablyApiKey)
            clientOptions.clientId = subscriberClientID
            let rest = ARTRest(options: clientOptions)

            rest.auth.requestToken { tokenDetails, error in
                if let error {
                    completion(.failure(error))
                    return
                }

                let unwrappedTokenDetails = tokenDetails!

                let aatTokenDetails = TokenDetails(
                    token: unwrappedTokenDetails.token,
                    expires: unwrappedTokenDetails.expires!,
                    issued: unwrappedTokenDetails.issued!,
                    capability: unwrappedTokenDetails.capability!,
                    clientId: unwrappedTokenDetails.clientId!
                )

                completion(.success(aatTokenDetails))
            }
        }

        func createSubscriber() throws -> SubscriberTestEnvironment {
            try runBlocking(label: "Create subscriber test environment", timeout: 10) { handler in
                createSubscriberAsync(handler)
            }
        }

        private func createSubscriberAsync(_ completion: @escaping (Result<SubscriberTestEnvironment, Error>) -> Void) {
            if let subscriberTestEnvironment {
                completion(.success(subscriberTestEnvironment))
            }

            fetchTokenAsync { [weak self] result in
                guard let self else {
                    return
                }

                let token: TokenDetails
                switch result {
                case .success(let fetchedToken):
                    token = fetchedToken
                case .failure(let error):
                    completion(.failure(error))
                    return
                }

                let connectionConfiguration = ConnectionConfiguration { _, completion in
                    completion(.success(.tokenDetails(token)))
                }

                let host = Host(
                    realtimeHost: self.proxyClient.baseURL.host!,
                    port: self.faultSimulation.proxy.listenPort,
                    tls: false
                )

                let logHandler = self.logHandler
                    .addingSubsystem(.assetTracking)
                    .addingSubsystem(.named("subscriber"))

                let defaultAbly = DefaultAbly(
                    factory: AblyCocoaSDKRealtimeFactory(),
                    configuration: connectionConfiguration,
                    host: host,
                    mode: .subscribe,
                    logHandler: logHandler
                )

                let resolution = Resolution(accuracy: .balanced, desiredInterval: 1, minimumDisplacement: 0)

                let subscriber = DefaultSubscriber(
                    ablySubscriber: defaultAbly,
                    trackableId: self.trackableID,
                    resolution: resolution,
                    logHandler: logHandler
                )

                let combineSubscriberDelegate = CombineSubscriberDelegate(logHandler: logHandler)
                subscriber.delegate = combineSubscriberDelegate

                let subscriberMonitorFactory = SubscriberMonitorFactory(
                    subscriber: subscriber,
                    combineSubscriberDelegate: combineSubscriberDelegate,
                    logHandler: logHandler,
                    trackableID: self.trackableID,
                    faultType: self.faultSimulation.type,
                    subscriberClientID: self.subscriberClientID,
                    subscriberResolutionPreferences: self.subscriberResolutions
                )

                let testEnvironment = SubscriberTestEnvironment(
                    subscriber: subscriber,
                    subscriberMonitorFactory: subscriberMonitorFactory
                )
                self.subscriberTestEnvironment = testEnvironment

                subscriber.start { result in
                    switch result {
                    case .success:
                        completion(.success(testEnvironment))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            }
        }

        private let ablyPublishingPresenceData = PresenceData(type: .publisher, resolution: .init(accuracy: .balanced, desiredInterval: 1, minimumDisplacement: 0))

        func createAndStartPublishingAblyConnection() throws -> DefaultAbly {
            if let ablyPublishing {
                return ablyPublishing.defaultAbly
            }

            // Configure connection options
            let connectionConfiguration = ConnectionConfiguration(apiKey: Secrets.ablyApiKey, clientId: "AATNetworkConnectivityTests_ablyPublishing-\(trackableID)")

            // Connect to Ably

            let defaultAbly = DefaultAbly(factory: AblyCocoaSDKRealtimeFactory(), configuration: connectionConfiguration, host: nil, mode: .publish, logHandler: logHandler.addingSubsystem(.named("ablyPublishing")))

            let delegateMock = AblyPublisherDelegateMock()
            defaultAbly.publisherDelegate = delegateMock

            ablyPublishing = .init(defaultAbly: defaultAbly, delegate: delegateMock)

            try runBlocking(label: "Connect to Ably", timeout: 10) { handler in
                defaultAbly.connect(trackableId: trackableID, presenceData: ablyPublishingPresenceData, useRewind: true, completion: handler)
            }

            // The Android version of these tests then calls defaultAbly.subscribeForChannelStateChange and waits for that to emit an online state. Given that the above call to `connect` has succeeded, the channel is _already_ in an online state. But Android’s DefaultAbly implementation of subscribeForChannelStateChange re-emits the current channel state, which our implementation does not. So I’ve omitted this channel state change wait in the Swift tests since it would always fail.

            let stateChangeExpectation = XCTestExpectation(description: "Channel state set to online")
            delegateMock.ablyPublisherDidChangeChannelConnectionStateForTrackableClosure = { _, state, _ in
                if state == .online {
                    stateChangeExpectation.fulfill()
                }
            }

            // Listen for presence and resolution updates
            delegateMock.ablyPublisherDidReceivePresenceUpdateForTrackablePresenceDataClientIdClosure = { [subscriberResolutionsSubject, logHandler] _, _, _, presenceData, _ in
                if presenceData.type == .subscriber, let resolution = presenceData.resolution {
                    logHandler.debug(message: "ablyPublishing received subscriber resolution \(resolution), emitting on subscriberResolutions", error: nil)
                    subscriberResolutionsSubject.value = resolution
                }
            }
            defaultAbly.subscribeForPresenceMessages(trackable: .init(id: trackableID))

            return defaultAbly
        }

        /**
         * If the test has started up a publishing connection to the Ably
         * channel, shut it down.
         */
        func shutdownAblyPublishingAsync(_ completionHandler: @escaping (Result<Void, Error>) -> Void) {
            guard let ablyPublishing else {
                completionHandler(.success)
                return
            }

            logHandler.debug(message: "Shutting down Ably publishing connection", error: nil)

            ablyPublishing.defaultAbly.close(presenceData: ablyPublishingPresenceData) { [weak self] result in
                guard let self else {
                    return
                }

                switch result {
                case .success:
                    self.ablyPublishing = nil
                    self.logHandler.debug(message: "Ably publishing connection shutdown", error: nil)
                    completionHandler(.success)
                case .failure(let error):
                    completionHandler(.failure(error))
                }
            }
        }
    }
}
