import AblyAssetTrackingInternal
import AblyAssetTrackingInternalTesting
@testable import AblyAssetTrackingSubscriber
import AblyAssetTrackingSubscriberTesting
import XCTest

class SubscriberWorkerQueuePropertiesTests: XCTestCase {
    private var subscriberProperties: SubscriberWorkerQueueProperties!

    private let configuration = ConnectionConfiguration(apiKey: "API_KEY", clientId: "CLIENT_ID")
    private let subscriberDelegate = SubscriberDelegateMock()
    private var subscriber: Subscriber!
    private var ablySubscriber: MockAblySubscriber!
    private var trackableId: String!
    private let logger = InternalLogHandlerMockThreadSafe()

    override func setUp() async throws {
        trackableId = "Trackable-\(UUID().uuidString)"
        ablySubscriber = MockAblySubscriber(configuration: configuration, mode: .subscribe)

        subscriber = DefaultSubscriber(
            ablySubscriber: ablySubscriber,
            trackableId: trackableId,
            resolution: nil,
            logHandler: logger
        )
        subscriberProperties = SubscriberWorkerQueueProperties(initialResolution: nil, subscriber: subscriber)
    }

    func test_subscriberProperties_updateForConnectionStateChangeAndThenDelegateStateEventsIfRequired_changes_lastConnectionStateChange() {
        // Given
        let connectionStateChange = ConnectionStateChange(state: .online, errorInformation: nil)
        XCTAssertEqual(subscriberProperties.lastConnectionStateChange.state, .offline)

        // When
        subscriberProperties.updateForConnectionStateChangeAndThenDelegateStateEventsIfRequired(stateChange: connectionStateChange, logHandler: logger)

        // Then
        XCTAssertEqual(subscriberProperties.lastConnectionStateChange.state, .online)
    }

    func test_subscriberProperties_updateForChannelConnectionStateChangeAndThenDelegateStateEventsIfRequired_changes_lastChannelConnectionState() {
        // Given
        let connectionStateChange = ConnectionStateChange(state: .online, errorInformation: nil)
        XCTAssertEqual(subscriberProperties.lastConnectionStateChange.state, .offline)

        // When
        subscriberProperties.updateForChannelConnectionStateChangeAndThenDelegateStateEventsIfRequired(stateChange: connectionStateChange, logHandler: logger)

        // Then
        XCTAssertEqual(subscriberProperties.lastChannelConnectionStateChange.state, .online)
    }

    func test_subscriberProperties_updateForPresenceMessagesAndThenDelegateStateEventsIfRequired_withPresenceEnter_adds_presentPublisherMemberKey() {
        // Given
        let testMemberKey = "testMemberKey"
        let presenceData = PresenceData(type: .publisher, resolution: .default)
        let presenceEnter = Presence(action: .enter, data: presenceData, memberKey: testMemberKey)
        XCTAssertTrue(subscriberProperties.presentPublisherMemberKeys.isEmpty)

        // When
        subscriberProperties.updateForPresenceMessagesAndThenDelegateStateEventsIfRequired(presenceMessages: [presenceEnter], logHandler: logger)

        // Then
        XCTAssertEqual(subscriberProperties.presentPublisherMemberKeys.count, 1)
        XCTAssertEqual(subscriberProperties.presentPublisherMemberKeys.first, testMemberKey)
    }

    func test_subscriberProperties_updateForPresenceMessagesAndThenDelegateStateEventsIfRequired_withPresenceLeave_removes_presentPublisherMemberKey() {
        // Given
        let testMemberKey = "testMemberKey"
        let presenceData = PresenceData(type: .publisher, resolution: .default)
        let presenceEnter = Presence(action: .enter, data: presenceData, memberKey: testMemberKey)
        let presenceLeave = Presence(action: .leave, data: presenceData, memberKey: testMemberKey)
        subscriberProperties.updateForPresenceMessagesAndThenDelegateStateEventsIfRequired(presenceMessages: [presenceEnter], logHandler: logger)

        // When
        subscriberProperties.updateForPresenceMessagesAndThenDelegateStateEventsIfRequired(presenceMessages: [presenceLeave], logHandler: logger)

        // Then
        XCTAssertTrue(subscriberProperties.presentPublisherMemberKeys.isEmpty)
    }

    func test_subscriberProperties_notifyEnhancedLocationUpdated_calls_didUpdateEnhancedLocation_delegate() {
        subscriber.delegate = subscriberDelegate

        let location = Location(coordinate: LocationCoordinate(latitude: 0.5, longitude: 0.5))
        let locationUpdate = EnhancedLocationUpdate(location: location)

        let delegateDidUpdateEnhancedLocationExpectation = expectation(description: "Subscriber's delegate receives didUpdateEnhancedLocation")
        subscriberDelegate.subscriberSenderDidUpdateEnhancedLocationClosure = { _, locationUpdate in
            XCTAssertEqual(locationUpdate.location.coordinate.latitude, 0.5)
            XCTAssertEqual(locationUpdate.location.coordinate.longitude, 0.5)
            delegateDidUpdateEnhancedLocationExpectation.fulfill()
        }

        subscriberProperties.notifyEnhancedLocationUpdated(locationUpdate: locationUpdate, logHandler: logger)

        XCTAssertEqual(subscriberProperties.enhancedLocation?.location.coordinate.longitude, 0.5)
        waitForExpectations(timeout: 10)
    }

    func test_subscriberProperties_notifyRawLocationUpdated_calls_didUpdateRawLocation_delegate() {
        subscriber.delegate = subscriberDelegate

        let location = Location(coordinate: LocationCoordinate(latitude: 0.5, longitude: 0.5))
        let locationUpdate = RawLocationUpdate(location: location)

        let delegateDidUpdateRawLocationExpectation = expectation(description: "Subscriber's delegate receives didUpdateRawLocation")
        subscriberDelegate.subscriberSenderDidUpdateRawLocationClosure = { _, locationUpdate in
            XCTAssertEqual(locationUpdate.location.coordinate.latitude, 0.5)
            XCTAssertEqual(locationUpdate.location.coordinate.longitude, 0.5)
            delegateDidUpdateRawLocationExpectation.fulfill()
        }

        subscriberProperties.notifyRawLocationUpdated(locationUpdate: locationUpdate, logHandler: logger)

        XCTAssertEqual(subscriberProperties.rawLocation?.location.coordinate.longitude, 0.5)
        waitForExpectations(timeout: 10)
    }

    func test_subscriberProperties_notifyPublisherPresenceUpdated_calls_didUpdatePublisherPresence_delegate() {
        subscriber.delegate = subscriberDelegate

        let delegateDidUpdatePublisherPresenceExpectation = expectation(description: "Subscriber's delegate receives didUpdatePublisherPresence")
        subscriberDelegate.subscriberSenderDidUpdatePublisherPresenceClosure = { _, isPresent in
            XCTAssertTrue(isPresent)
            delegateDidUpdatePublisherPresenceExpectation.fulfill()
        }

        subscriberProperties.notifyPublisherPresenceUpdated(isPublisherPresent: true, logHandler: logger)

        XCTAssertTrue(subscriberProperties.publisherPresence)
        waitForExpectations(timeout: 10)
    }

    func test_subscriberProperties_notifyTrackableStateUpdated_calls_didChangeAssetConnectionStatus_delegate() {
        subscriber.delegate = subscriberDelegate

        let delegateDidChangeAssetConnectionStatusExpectation = expectation(description: "Subscriber's delegate receives didChangeAssetConnectionStatus")
        subscriberDelegate.subscriberSenderDidChangeAssetConnectionStatusClosure = { _, connectionState  in
            XCTAssertEqual(connectionState, .online)
            delegateDidChangeAssetConnectionStatusExpectation.fulfill()
        }

        subscriberProperties.notifyTrackableStateUpdated(trackableState: .online, logHandler: logger)

        XCTAssertEqual(subscriberProperties.trackableState, .online)
        waitForExpectations(timeout: 10)
    }

    func test_subscriberProperties_notifyDidFailWithError_calls_didFailWithError_delegate() {
        subscriber.delegate = subscriberDelegate

        let error = ErrorInformation(type: ErrorInformationType.commonError(errorMessage: "testErrorMessage"))

        let delegateDidFailWithErrorExpectation = expectation(description: "Subscriber's delegate receives didFailWithError")
        subscriberDelegate.subscriberSenderDidFailWithErrorClosure = { _, errorInfo in
            XCTAssertEqual(errorInfo.message, "Error: testErrorMessage")
            delegateDidFailWithErrorExpectation.fulfill()
        }

        subscriberProperties.notifyDidFailWithError(error: error, logHandler: logger)
        waitForExpectations(timeout: 10)
    }

    func test_subscriberProperties_notifyResolutionsChanged_calls_delegate_methods() {
        subscriber.delegate = subscriberDelegate

        let resolution = Resolution(accuracy: .balanced, desiredInterval: 10.2, minimumDisplacement: 10.2)
        let delegateDidUpdateResolutionExpectation = expectation(description: "Subscriber's delegate receives didUpdateResolution")
        subscriberDelegate.subscriberSenderDidUpdateResolutionClosure = { _, resolution in
            XCTAssertEqual(resolution.accuracy, .balanced)
            XCTAssertEqual(resolution.desiredInterval, 10.2)
            XCTAssertEqual(resolution.minimumDisplacement, 10.2)
            delegateDidUpdateResolutionExpectation.fulfill()
        }

        let delegateDidUpdateDesiredIntervalExpectation = expectation(description: "Subscriber's delegate receives didUpdateDesiredInterval")
        subscriberDelegate.subscriberSenderDidUpdateDesiredIntervalClosure = { _, desiredInterval in
            XCTAssertEqual(desiredInterval, 10.2)
            delegateDidUpdateDesiredIntervalExpectation.fulfill()
        }

        subscriberProperties.notifyResolutionsChanged(resolutions: [resolution], logHandler: logger)

        XCTAssertEqual(subscriberProperties.resolution?.minimumDisplacement, 10.2)
        XCTAssertEqual(subscriberProperties.resolution?.desiredInterval, 10.2)
        waitForExpectations(timeout: 10)
    }

    func test_subscriberProperties_delegatesEvents() {
        let delegateDidChangeAssetConnectionStatusExpectation = expectation(description: "Subscriber’s delegate receives didChangeAssetConnectionStatus")
        subscriberDelegate.subscriberSenderDidChangeAssetConnectionStatusClosure = { _, status in
            XCTAssertEqual(status, .online)
            delegateDidChangeAssetConnectionStatusExpectation.fulfill()
        }

        let delegateDidUpdatePresence = expectation(description: "Subscriber's delegate receives didUpdatePublisherPresence")
        subscriberDelegate.subscriberSenderDidUpdatePublisherPresenceClosure = { [weak self] _, isPresent in
            guard let callsCount = self?.subscriberDelegate.subscriberSenderDidUpdatePublisherPresenceCallsCount
            else { return }

            // isPresent in first call should be false, since it's called with lastChannelConnectionStateChange being nil as a result of SubscriberProperties.updateForConnectionStateChangeAndThenDelegateStateEventsIfRequired
            if callsCount <= 1 {
                XCTAssertFalse(isPresent)
            } else {
                XCTAssertTrue(isPresent)
                delegateDidUpdatePresence.fulfill()
            }
        }

        subscriber.delegate = subscriberDelegate
        let connectionStateChange = ConnectionStateChange(state: .online, errorInformation: nil)

        subscriberProperties.updateForConnectionStateChangeAndThenDelegateStateEventsIfRequired(stateChange: connectionStateChange, logHandler: logger)
        subscriberProperties.updateForChannelConnectionStateChangeAndThenDelegateStateEventsIfRequired(stateChange: connectionStateChange, logHandler: logger)
        subscriberProperties.updateForPresenceMessagesAndThenDelegateStateEventsIfRequired(presenceMessages: [Presence(action: .enter, data: PresenceData(type: .publisher, resolution: .default), memberKey: "testMemberKey")], logHandler: logger)

        waitForExpectations(timeout: 10)
    }
}
