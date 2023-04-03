import Ably
import AblyAssetTrackingInternal
import AblyAssetTrackingSubscriber
import AblyAssetTrackingSubscriberTesting
import AblyAssetTrackingTesting
import Foundation
import protocol Combine.Publisher
import class Combine.AnyCancellable
import struct Combine.AnyPublisher

extension SubscriberNetworkConnectivityTests {
    /**
     * Monitors Subscriber activity so that we can make assertions about any trackable state
     * transitions expected and ensure side-effects occur.
     */
    final class SubscriberMonitor {
        struct SharedState {
            fileprivate var combineSubscriberDelegate: CombineSubscriberDelegate

            init(combineSubscriberDelegate: CombineSubscriberDelegate) {
                self.combineSubscriberDelegate = combineSubscriberDelegate
            }
        }

        private let sharedState: SharedState
        private let logHandler: InternalLogHandler
        private let subscriber: Subscriber
        private let subscriberClientID: String
        private let label: String
        private let trackableID: String
        private let expectedState: TrackableState
        private let failureStates: Set<TrackableState>
        private let expectedSubscriberPresence: Bool?
        private let expectedPublisherPresence: Bool
        private let expectedLocation: Location?
        private let expectedPublisherResolution: Resolution?
        private let expectedSubscriberResolution: Resolution?
        private let timeout: TimeInterval
        private let ably: ARTRealtime
        private let subscriberResolutionPreferences: AnyPublisher<Resolution, Never>

        private static let assertionsQueue = DispatchQueue(label: "com.ably.tracking.tests.SubscriberMonitor.assertions")
        private static func runAsyncOnAssertionsQueue(logHandler: InternalLogHandler, block: @escaping () -> Void) {
            logHandler.debug(message: "Dispatching block to assertionsQueue", error: nil)
            assertionsQueue.async {
                logHandler.debug(message: "Calling block on assertionsQueue", error: nil)
                block()
                logHandler.debug(message: "Block finished executing on assertionsQueue", error: nil)
            }
        }

        init(sharedState: SharedState, logHandler: InternalLogHandler, subscriber: Subscriber, subscriberClientID: String, label: String, trackableID: String, expectedState: TrackableState, failureStates: Set<TrackableState>, expectedSubscriberPresence: Bool?, expectedPublisherPresence: Bool, expectedLocation: Location?, expectedPublisherResolution: Resolution?, expectedSubscriberResolution: Resolution?, timeout: TimeInterval, subscriberResolutionPreferences: AnyPublisher<Resolution, Never>) {
            self.sharedState = sharedState
            self.logHandler = logHandler.addingSubsystem(.named("SubscriberMonitor(\(label))"))
            self.subscriber = subscriber
            self.subscriberClientID = subscriberClientID
            self.label = label
            self.trackableID = trackableID
            self.expectedState = expectedState
            self.failureStates = failureStates
            self.expectedSubscriberPresence = expectedSubscriberPresence
            self.expectedPublisherPresence = expectedPublisherPresence
            self.expectedLocation = expectedLocation
            self.expectedPublisherResolution = expectedPublisherResolution
            self.expectedSubscriberResolution = expectedSubscriberResolution
            self.timeout = timeout
            self.subscriberResolutionPreferences = subscriberResolutionPreferences

            let clientOptions = ARTClientOptions(key: Secrets.ablyApiKey)
            clientOptions.clientId = "SubscriberMonitor-\(trackableID)"
            clientOptions.logHandler = InternalARTLogHandler(logHandler: self.logHandler)
            clientOptions.logLevel = .verbose
            ably = ARTRealtime(options: clientOptions)
        }

        // MARK: - State transition

        /**
         * Performs the given async operation, then waits for expectations to
         * be delivered (or not) before cleaning up.
         */
        func waitForStateTransition<Success, Failure>( _ asyncOp: (InternalLogHandler, @escaping (Result<Success, Failure>) -> Void) -> Void) throws {
            logHandler.logMessage(level: .debug, message: "waitForStateTransition called; calling asyncOp", error: nil)

            var errors = MultipleErrors()

            /*
             We want the assertions to piggy-back on the same timeout as the "asyncOp and assertions complete" operation. This gives us the same behaviour as Android.

             To achieve this, we need to use a waiter context, since these operations take place on different threads (SubscriberMonitor.assertionsQueue and the main thread respectively).
             */
            let waiterContext = Blocking.WaiterContext(logHandler: logHandler)
            defer { waiterContext.cancel() }

            do {
                try Blocking.run(label: "asyncOp and assertions complete", timeout: timeout, logHandler: logHandler, waiterContext: waiterContext) { (handler: @escaping (Result<Void, Error>) -> Void) in
                    let asyncOpLogHandler = logHandler.addingSubsystem(.named("asyncOp"))

                    asyncOp(asyncOpLogHandler) { [logHandler] result in
                        /*
                         Consider the following sequence of events:

                         1. asyncOp completes by calling `Dispatch.async`-ing its callback to the main queue (e.g. when asyncOp is an AAT operation, since AAT performs all public callbacks on the main queue)
                         2. The subsequent assert* operations wait for various callbacks, some of are generated by ably-cocoa and hence (since DefaultAbly doesn’t specify a custom ARTClientOptions.dispatchQueue) `Dispatch.async`-ed to the main queue.

                         If we were to perform 2 synchronously inside 1, then 2 would never complete since the callbacks which it is waiting for would never get executed (since they need 1 to first end and free up the main queue). Hence we perform 2 on a non-main queue in order to get out of 1’s Dispatch.async main queue callback.
                         */

                        SubscriberMonitor.runAsyncOnAssertionsQueue(logHandler: logHandler) { [weak self] in
                            guard let self else {
                                return
                            }

                            switch result {
                            case .success:
                                logHandler.logMessage(level: .debug, message: "waitForStateTransition’s asyncOp succeeded", error: nil)

                                do {
                                    // These methods all tell Blocking.run to wait indefinitely, but — as mentioned above — since they share a waiter context with the "asyncOp and assertions complete" operation then if that operation’s timeout elapses these methods will fail, which is the behaviour we want.

                                    try self.assertStateTransition(waiterContext: waiterContext)
                                    try self.assertSubscriberPresence(waiterContext: waiterContext)
                                    try self.assertPublisherPresence(waiterContext: waiterContext)
                                    try self.assertLocationUpdated(waiterContext: waiterContext)
                                    try self.assertPublisherResolution(waiterContext: waiterContext)
                                    try self.assertSubscriberPreferredResolution(waiterContext: waiterContext)
                                    handler(.success)
                                } catch {
                                    handler(.failure(error))
                                }
                            case .failure(let error):
                                logHandler.logMessage(level: .error, message: "waitForStateTransition’s asyncOp failed", error: error)
                                handler(.failure(error))
                            }
                        }
                    }
                }
            } catch {
                errors.add(error)
            }

            do {
                try close()
            } catch {
                errors.add(error)
            }

            try errors.check()
        }

        // MARK: - Lifecycle

        /**
         * Close any open resources used by this monitor, in a blocking fashion.
         */
        private func close() throws {
            if ably.connection.state == .closed {
                return
            }

            try Blocking.run(label: "Wait for Ably to close", timeout: 10, logHandler: logHandler) { (handler: @escaping ResultHandler<Void>) in
                ably.connection.once(.closed) { _ in
                    handler(.success)
                }
                ably.close()
            }
        }

        // MARK: - Utility

        @discardableResult
        private func first<Output>(_ publisher: any Publisher<Output, Never>, label: String, waiterContext: Blocking.WaiterContext) throws -> Output {
            var subscriptions: Set<AnyCancellable> = []

            return try withExtendedLifetime(subscriptions) {
                try Blocking.run(label: label, timeout: nil, logHandler: logHandler, waiterContext: waiterContext) { (handler: (@escaping (Result<Output, Error>) -> Void)) in
                    publisher
                        .eraseToAnyPublisher()
                        .first()
                        .sink { handler(.success($0)) }
                        .store(in: &subscriptions)
                }
            }
        }

        // MARK: - Assertions

        private enum AssertionError: Error {
            case generic(message: String)
        }

        private func createGenericAssertionError(message: String) -> AssertionError {
            let taggedMessage = logHandler.tagMessage(message)
            return .generic(message: taggedMessage)
        }

        private func assertStateTransition(waiterContext: Blocking.WaiterContext) throws {
            logHandler.logMessage(level: .debug, message: "Awaiting state transition to \(expectedState)", error: nil)

            let publisher = sharedState.combineSubscriberDelegate.trackableStates
                .compactMap { [failureStates, expectedState, logHandler] state in
                    SubscriberMonitor.receive(
                        state,
                        failureStates: failureStates,
                        expectedState: expectedState,
                        logHandler: logHandler
                    )
                }

            let success = try first(publisher, label: "Wait for state transition to \(expectedState)", waiterContext: waiterContext)
            if !success {
                throw createGenericAssertionError(message: "Wait for state transition to \(expectedState) did not result in success.")
            }
        }

        /**
         * Maps received `TrackableState` to a success/fail/ignore outcome for this test.
         */
        private static func receive(_ state: TrackableState, failureStates: Set<TrackableState>, expectedState: TrackableState, logHandler: InternalLogHandler) -> Bool? {
            if failureStates.contains(state) {
                logHandler.logMessage(level: .error, message: "(FAIL) Got state \(state)", error: nil)
                return false
            }

            if state == expectedState {
                logHandler.logMessage(level: .debug, message: "(SUCCESS) Got state \(state)", error: nil)
                return true
            }

            logHandler.logMessage(level: .debug, message: "(IGNORED) Got state \(state)", error: nil)
            return nil
        }

        private func assertPublisherResolution(waiterContext: Blocking.WaiterContext) throws {
            guard let expectedPublisherResolution else {
                logHandler.debug(message: "(SKIP) expectedPublisherResolution = nil", error: nil)
                return
            }

            logHandler.debug(message: "(WAITING) expectedPublisherResolution = \(expectedPublisherResolution)", error: nil)

            try listenForExpectedPublisherResolution(waiterContext: waiterContext)
        }

        /**
         * Uses the subscribers presence state flow to listen for the expected
         * publisher resolution change.
         *
         * This can happen at any time after the initial trackable state transition,
         * and so we cannot rely on the first state we collect being the "newest" one.
         */
        private func listenForExpectedPublisherResolution(waiterContext: Blocking.WaiterContext) throws {
            let publisher = sharedState.combineSubscriberDelegate.resolutions.filter { [expectedPublisherResolution] in $0 == expectedPublisherResolution }
            try first(publisher, label: "wait for matching publisher resolution", waiterContext: waiterContext)
        }

        private func assertSubscriberPresence(waiterContext: Blocking.WaiterContext) throws {
            guard let expectedSubscriberPresence else {
                // not checking for subscriber presence in this test
                logHandler.debug(message: "(SKIP) expectedSubscriberPresence = nil", error: nil)
                return
            }

            let subscriberPresent = try subscriberIsPresent(waiterContext: waiterContext)
            if subscriberPresent != expectedSubscriberPresence {
                logHandler.logMessage(level: .error, message: "(FAIL) subscriberPresent = \(subscriberPresent)", error: nil)
                throw createGenericAssertionError(message: "Expected subscriberPresence: \(expectedSubscriberPresence) but got \(subscriberPresent)")
            } else {
                logHandler.debug(message: "(PASS) subscriberPresent = \(subscriberPresent)", error: nil)
            }
        }

        /**
         * Perform a request to the Ably API to get a snapshot of the current presence for the channel,
         * and check to see if the Subscriber's clientId is present in that snapshot.
         */
        private func subscriberIsPresent(waiterContext: Blocking.WaiterContext) throws -> Bool {
            let members = try Blocking.run(label: "subscriberIsPresent fetch present members", timeout: nil, logHandler: logHandler, waiterContext: waiterContext) { (handler: @escaping (Result<[ARTPresenceMessage], Error>) -> Void) in
                let channel = ably.channels.get("tracking:\(trackableID)")

                channel.presence.get { members, error in
                    if let error {
                        handler(.failure(error))
                        return
                    }

                    handler(.success(members!))
                }
            }

            logHandler.debug(message: "subscriberIsPresent fetched members \(members)", error: nil)

            return members.contains { $0.clientId == subscriberClientID && $0.action == .present }
        }

        /**
         * Assert that we eventually receive the expected publisher presence.
         *
         * This can happen at any time after the initial trackable state transition,
         * and so we cannot rely on the first state we collect being the "new" one.
         */
        private func assertPublisherPresence(waiterContext: Blocking.WaiterContext) throws {
            logHandler.debug(message: "(WAITING): publisher presence -> \(String(describing: expectedPublisherPresence))", error: nil)

            let publisher = sharedState.combineSubscriberDelegate.publisherPresence.filter { [expectedPublisherPresence] in $0 == expectedPublisherPresence }
            let presence = try first(publisher, label: "assertPublisherPresence wait for publisher presence", waiterContext: waiterContext)

            logHandler.debug(message: "(PASS): publisher presence was \(presence)", error: nil)
        }

        /**
         * Throw an assertion error if expectations about published location updates have not
         * been meet in this test.
         */
        private func assertLocationUpdated(waiterContext: Blocking.WaiterContext) throws {
            guard let expectedLocation else {
                // no expected location set - skip assertion
                logHandler.debug(message: "(SKIP) expectedLocationUpdate = null", error: nil)
                return
            }

            logHandler.debug(message: "(WAITING) expectedLocationUpdate = \(expectedLocation)", error: nil)

            try listenForExpectedLocationUpdate(waiterContext: waiterContext)
        }

        /**
         * Use the subscriber location flow to listen for a location update matching the one we're expecting.
         *
         * These location updates may arrive at any time after the trackable transitions to online, so we therefore
         * cannot rely on the first thing we find being the "newest" state and therefore must wait for a bit.
         */
        private func listenForExpectedLocationUpdate(waiterContext: Blocking.WaiterContext) throws {
            let publisher = sharedState.combineSubscriberDelegate.locations.filter { [expectedLocation] in $0.location == expectedLocation }.map(\.location)

            try first(publisher, label: "Wait for location \(String(describing: expectedLocation)) from subscriber", waiterContext: waiterContext)
        }

        /**
         * Assert that we receive the expected subscriber resolution.
         */
        private func assertSubscriberPreferredResolution(waiterContext: Blocking.WaiterContext) throws {
            guard let expectedSubscriberResolution else {
                logHandler.debug(message: "(SKIPPED) expectedSubscriberResolution = nil", error: nil)
                return
            }

            logHandler.debug(message: "(WAITING) preferredSubscriberResolution = \(expectedSubscriberResolution)", error: nil)

            let publisher = subscriberResolutionPreferences.filter { $0 == expectedSubscriberResolution }
            try first(publisher, label: "Wait for subscriber resolution preference \(expectedSubscriberResolution)", waiterContext: waiterContext)
        }
    }
}
