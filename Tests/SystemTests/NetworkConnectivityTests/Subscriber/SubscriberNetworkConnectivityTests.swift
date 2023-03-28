import AblyAssetTrackingCore
import AblyAssetTrackingInternal
@testable import AblyAssetTrackingSubscriber
import AblyAssetTrackingTesting
import XCTest

final class SubscriberNetworkConnectivityTests: ParameterizedTestCase<SubscriberNetworkConnectivityTestsParam> {
    // Implementation of required `ParameterizedTestCase` method.
    override class func fetchParams(_ completion: @escaping (Result<[SubscriberNetworkConnectivityTestsParam], Error>) -> Void) {
        SubscriberNetworkConnectivityTestsParam.fetchParams(completion)
    }

    private var _testResources: TestResources!
    /// Convenience non-optional getter, to be used within test cases.
    private var testResources: TestResources {
        _testResources
    }

    override func setUpWithError() throws {
        guard !currentParam.isSkipped else {
            throw XCTSkip("Subscriber tests are skipped for fault \(currentParam.faultName)")
        }

        let trackableID = UUID().uuidString

        // Just log the first component of the UUID, for the sake of logs’ readability.
        let truncatedTrackableID = trackableID.components(separatedBy: "-")[0]
        let logHandler = TestLogging.sharedInternalLogHandler.addingSubsystem(.named("test-\(truncatedTrackableID)"))
        let proxyClient = SDKTestProxyClient(logHandler: logHandler)

        let setUpLogHandler = logHandler.addingSubsystem(.named("setUp"))
        let faultSimulation = try Blocking.run(label: "Create fault simulation \(currentParam.faultName)", timeout: 10, logHandler: setUpLogHandler) { handler in
            proxyClient.createFaultSimulation(withName: currentParam.faultName, handler)
        }

        _testResources = TestResources(
            testCase: self,
            proxyClient: proxyClient,
            faultSimulation: faultSimulation,
            trackableID: trackableID,
            logHandler: logHandler
        )
    }

    override func tearDownWithError() throws {
        try _testResources?.tearDown()
    }

    /**
     * Test that Subscriber can handle the given fault occurring before a user
     * starts the subscriber.
     *
     * We expect the subscriber to not throw an error.
     */
    func parameterizedTest_faultBeforeStartingSubscriber() throws {
        try testResources.enableFault()

        let subscriberTestEnvironment = try testResources.createSubscriber()
        let defaultAbly = try testResources.createAndStartPublishingAblyConnection()

        let subscriber = subscriberTestEnvironment.subscriber
        let subscriberMonitorFactory = subscriberTestEnvironment.subscriberMonitorFactory

        let locationUpdate = Location(coordinate: .init(latitude: 2, longitude: 2))
        let publisherResolution = Resolution(accuracy: .minimum, desiredInterval: 100, minimumDisplacement: 0)
        let subscriberResolution = Resolution(accuracy: .maximum, desiredInterval: 2, minimumDisplacement: 0)

        try subscriberMonitorFactory.forActiveFault(
            label: "[fault active] subscriber",
            locationUpdate: nil,
            publisherResolution: nil,
            subscriberResolution: subscriberResolution
        )
        .waitForStateTransition { [testResources] (logHandler, handler: @escaping (Result<Void, Error>) -> Void) in
            // Connect up a publisher to do publisher things

            defaultAbly.updatePresenceData(
                trackableId: testResources.trackableID,
                presenceData: .init(type: .publisher, resolution: publisherResolution)
            ) { result in
                switch result {
                case .success:
                    defaultAbly.sendEnhancedLocation(
                        locationUpdate: .init(location: locationUpdate),
                        trackable: Trackable(id: testResources.trackableID)
                    ) { result in
                        switch result {
                        case .success:
                            logHandler.debug(message: "Sent enhanced location update on Ably channel", error: nil)
                            // While we're offline-ish, change the subscribers preferred resolutions

                            // The Android version of this test uses the fire-and-forget sendResolutionPreference (which deprecates sendResolutionPreference but which we have not yet implemented in AAT Swift).
                            subscriber.resolutionPreference(resolution: subscriberResolution) { result in
                                switch result {
                                case .success:
                                    handler(.success)
                                case .failure(let error):
                                    handler(.failure(error))
                                }
                            }
                        case .failure(let error):
                            handler(.failure(error))
                        }
                    }
                case .failure(let error):
                    handler(.failure(error))
                }
            }
        }

        // Resolve the fault and make sure everything comes through
        try subscriberMonitorFactory.forResolvedFault(
            label: "[fault resolved] subscriber",
            locationUpdate: locationUpdate,
            publisherResolution: publisherResolution,
            subscriberResolution: subscriberResolution
        )
        .waitForStateTransition { _, handler in
            testResources.resolveFaultAsync(handler)
        }
    }

    /**
     * Test that Subscriber can handle the given fault occurring after a user
     * starts the subscriber and then proceeds to stop it.
     *
     * We expect the subscriber to stop cleanly, with no thrown errors.
     */
    func parameterizedTest_faultBeforeStoppingSubscriber() throws {
        let subscriberTestEnvironment = try testResources.createSubscriber()
        let defaultAbly = try testResources.createAndStartPublishingAblyConnection()

        let subscriber = subscriberTestEnvironment.subscriber
        let subscriberMonitorFactory = subscriberTestEnvironment.subscriberMonitorFactory

        // Assert the subscriber goes online
        let locationUpdate = Location(coordinate: .init(latitude: 2, longitude: 2))
        let publisherResolution = Resolution(accuracy: .balanced, desiredInterval: 1, minimumDisplacement: 0)
        let subscriberResolution = Resolution(accuracy: .balanced, desiredInterval: 1, minimumDisplacement: 0)

        try subscriberMonitorFactory.onlineWithoutFail(
            label: "[no fault] subscriber online",
            timeout: 10,
            subscriberResolution: subscriberResolution,
            locationUpdate: locationUpdate,
            publisherResolution: publisherResolution
        )
        .waitForStateTransition { (logHandler, handler: @escaping (Result<Void, Error>) -> Void) in
            defaultAbly.sendEnhancedLocation(
                locationUpdate: .init(location: locationUpdate),
                trackable: .init(id: testResources.trackableID)
            ) { result in
                switch result {
                case .success:
                    logHandler.debug(message: "Sent enhanced location update on Ably channel", error: nil)
                    handler(.success)
                case .failure(let error):
                    handler(.failure(error))
                }
            }
        }

        // Enable the fault, shutdown the subscriber
        try subscriberMonitorFactory.forActiveFaultWhenShuttingDownSubscriber(
            label: "[fault active] subscriber",
            publisherResolution: publisherResolution,
            subscriberResolution: subscriberResolution
        )
        .waitForStateTransition { (_, handler: @escaping (Result<Void, Error>) -> Void) in
            testResources.enableFaultAsync { result in
                switch result {
                case .success:
                    subscriber.stop { result in
                        switch result {
                        case .success:
                            handler(.success)
                        case .failure(let error):
                            handler(.failure(error))
                        }
                    }
                case .failure(let error):
                    handler(.failure(error))
                }
            }
        }

        // Resolve the fault
        try subscriberMonitorFactory.forResolvedFaultWithSubscriberStopped(
            label: "[fault resolved] subscriber",
            publisherResolution: publisherResolution,
            subscriberResolution: subscriberResolution
        )
        .waitForStateTransition { _, handler in
            testResources.resolveFaultAsync(handler)
        }
    }

    /**
     * Test that Subscriber can handle the given fault occurring whilst tracking.
     *
     * We expect that upon the resolution of the fault, location updates sent in
     * the meantime will be received by the subscriber.
     */
    func parameterizedTest_faultWhilstTracking() throws {
        let subscriberTestEnvironment = try testResources.createSubscriber()

        let subscriber = subscriberTestEnvironment.subscriber
        let subscriberMonitorFactory = subscriberTestEnvironment.subscriberMonitorFactory

        // Bring a publisher online and send a location update
        let defaultAbly = try testResources.createAndStartPublishingAblyConnection()
        let locationUpdate = Location(coordinate: .init(latitude: 2, longitude: 2))
        let publisherResolution = Resolution(accuracy: .balanced, desiredInterval: 1, minimumDisplacement: 0)
        let subscriberResolution = Resolution(accuracy: .balanced, desiredInterval: 1, minimumDisplacement: 0)

        try subscriberMonitorFactory.onlineWithoutFail(
            label: "[no fault] subscriber online",
            timeout: 10,
            subscriberResolution: subscriberResolution,
            locationUpdate: locationUpdate,
            publisherResolution: publisherResolution
        )
        .waitForStateTransition { (logHandler, handler: @escaping (Result<Void, Error>) -> Void) in
            defaultAbly.sendEnhancedLocation(
                locationUpdate: .init(location: locationUpdate),
                trackable: .init(id: testResources.trackableID)
            ) { result in
                switch result {
                case .success:
                    logHandler.debug(message: "Sent enhanced location update on Ably channel", error: nil)
                    handler(.success)
                case .failure(let error):
                    handler(.failure(error))
                }
            }
        }

        // Add an active trackable while fault active
        let secondLocationUpdate = Location(coordinate: .init(latitude: 3, longitude: 3))
        let secondPublisherResolution = Resolution(accuracy: .minimum, desiredInterval: 100, minimumDisplacement: 0)
        let secondSubscriberResolution = Resolution(accuracy: .maximum, desiredInterval: 2, minimumDisplacement: 0)

        let activeFaultExpectedLocationUpdate: Location
        switch testResources.faultSimulation.type {
        case .nonfatal:
            activeFaultExpectedLocationUpdate = secondLocationUpdate
        case .fatal, .nonfatalWhenResolved:
            activeFaultExpectedLocationUpdate = locationUpdate
        }

        let activeFaultExpectedPublisherResolution: Resolution
        switch testResources.faultSimulation.type {
        case .nonfatal:
            activeFaultExpectedPublisherResolution = secondPublisherResolution
        case .fatal, .nonfatalWhenResolved:
            activeFaultExpectedPublisherResolution = publisherResolution
        }

        let activeFaultExpectedSubscriberResolution: Resolution
        switch testResources.faultSimulation.type {
        case .nonfatal:
            activeFaultExpectedSubscriberResolution = secondSubscriberResolution
        case .fatal, .nonfatalWhenResolved:
            activeFaultExpectedSubscriberResolution = subscriberResolution
        }

        try subscriberMonitorFactory.forActiveFault(
            label: "[fault active] subscriber",
            locationUpdate: activeFaultExpectedLocationUpdate,
            publisherResolution: activeFaultExpectedPublisherResolution,
            subscriberResolution: activeFaultExpectedSubscriberResolution
        )
        .waitForStateTransition { (logHandler, handler: @escaping (Result<Void, Error>) -> Void) in
            // Start the fault
            testResources.enableFaultAsync { [testResources] result in
                switch result {
                case .success:
                    // Connect up a publisher to do publisher things

                    defaultAbly.updatePresenceData(
                        trackableId: testResources.trackableID,
                        presenceData: .init(type: .publisher, resolution: secondPublisherResolution)
                    ) { result in
                        switch result {
                        case .success:
                            defaultAbly.sendEnhancedLocation(
                                locationUpdate: .init(location: secondLocationUpdate),
                                trackable: .init(id: testResources.trackableID)
                            ) { result in
                                switch result {
                                case .success:
                                    logHandler.debug(message: "Sent second enhanced location update on Ably channel", error: nil)

                                    // While we're offline-ish, change the subscribers preferred resolution

                                    // The Android version of this test uses the fire-and-forget sendResolutionPreference (which deprecates sendResolutionPreference but which we have not yet implemented in AAT Swift).
                                    subscriber.resolutionPreference(resolution: secondSubscriberResolution) { result in
                                        switch result {
                                        case .success:
                                            handler(.success)
                                        case .failure(let error):
                                            handler(.failure(error))
                                        }
                                    }
                                case .failure(let error):
                                    handler(.failure(error))
                                }
                            }
                        case .failure(let error):
                            handler(.failure(error))
                        }
                    }
                case .failure(let error):
                    handler(.failure(error))
                }
            }
        }

        // Resolve the fault, wait for Trackable to move to expected state

        let thirdLocationUpdate = Location(coordinate: .init(latitude: 4, longitude: 4))
        let thirdPublisherResolution = Resolution(accuracy: .maximum, desiredInterval: 3, minimumDisplacement: 0)

        try subscriberMonitorFactory.forResolvedFault(
            label: "[fault resolved] subscriber",
            locationUpdate: thirdLocationUpdate,
            publisherResolution: thirdPublisherResolution,
            subscriberResolution: secondSubscriberResolution
        )
        .waitForStateTransition { (logHandler, handler: @escaping (Result<Void, Error>) -> Void) in
            defaultAbly.updatePresenceData(
                trackableId: testResources.trackableID,
                presenceData: .init(type: .publisher, resolution: thirdPublisherResolution)
            ) { [testResources] result in
                switch result {
                case .success:
                    defaultAbly.sendEnhancedLocation(
                        locationUpdate: .init(location: thirdLocationUpdate),
                        trackable: .init(id: testResources.trackableID)
                    ) { result in
                        switch result {
                        case .success:
                            logHandler.debug(message: "Sent third enhanced location update on Ably channel", error: nil)

                            // Resolve the problem
                            testResources.resolveFaultAsync(handler)
                        case .failure(let error):
                            handler(.failure(error))
                        }
                    }
                case .failure(let error):
                    handler(.failure(error))
                }
            }
        }

        // Restart the fault to simulate the publisher going away whilst we're offline

        try subscriberMonitorFactory.forActiveFault(
            label: "[fault active] publisher shutdown for disconnect test",
            locationUpdate: thirdLocationUpdate,
            publisherResolution: thirdPublisherResolution,
            publisherDisconnected: true,
            subscriberResolution: secondSubscriberResolution
        )
        .waitForStateTransition { (_, handler: @escaping (Result<Void, Error>) -> Void) in
            // Start the fault
            testResources.enableFaultAsync { [testResources] result in
                switch result {
                case .success:
                    // Disconnect the publisher
                    testResources.shutdownAblyPublishingAsync(handler)
                case .failure(let error):
                    handler(.failure(error))
                }
            }
        }

        // Resolve the fault one last time and check that the publisher is offline

        try subscriberMonitorFactory.forResolvedFault(
            label: "[fault resolved] subscriber publisher disconnect test",
            locationUpdate: thirdLocationUpdate,
            expectedPublisherPresence: false,
            subscriberResolution: secondSubscriberResolution
        )
        .waitForStateTransition { _, handler in
            // Resolve the problem
            testResources.resolveFaultAsync(handler)
        }
    }
}
