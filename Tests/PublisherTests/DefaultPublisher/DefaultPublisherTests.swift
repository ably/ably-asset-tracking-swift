import AblyAssetTrackingCore
import AblyAssetTrackingCoreTesting
import AblyAssetTrackingInternalTesting
@testable import AblyAssetTrackingPublisher
import AblyAssetTrackingPublisherTesting
import XCTest

enum ClientConfigError: Error {
    case cannotRedefineConnectionConfiguration
}

class DefaultPublisherTests: XCTestCase {
    var locationService: MockLocationService!
    var ablyPublisher: MockAblyPublisher!
    var configuration: ConnectionConfiguration!
    var routeProvider: MockRouteProvider!
    var resolutionPolicyFactory: MockResolutionPolicyFactory!
    var trackable: Trackable!
    var publisher: DefaultPublisher!
    var delegate: MockPublisherDelegate!
    var enhancedLocationState: TrackableState<EnhancedLocationUpdate>!

    let logger = InternalLogHandlerMockThreadSafe()
    let waitAsync = WaitAsync()

    override func setUpWithError() throws {
        configuration = ConnectionConfiguration(apiKey: "API_KEY", clientId: "CLIENT_ID")
        locationService = MockLocationService()
        ablyPublisher = MockAblyPublisher(configuration: configuration, mode: .publish)
        resolutionPolicyFactory = MockResolutionPolicyFactory()
        routeProvider = MockRouteProvider()
        trackable = Trackable(
            id: "TrackableId",
            metadata: "TrackableMetadata",
            destination: LocationCoordinate(latitude: 3.1415, longitude: 2.7182)
        )
        delegate = MockPublisherDelegate()
        enhancedLocationState = TrackableState<EnhancedLocationUpdate>()
        publisher = DefaultPublisher(
            routingProfile: .driving,
            resolutionPolicyFactory: resolutionPolicyFactory,
            ablyPublisher: ablyPublisher,
            locationService: locationService,
            routeProvider: routeProvider,
            enhancedLocationState: enhancedLocationState,
            logHandler: logger
        )
        publisher.delegate = delegate
    }

    // MARK: track
    func testTrack_success() {
        ablyPublisher.connectCompletionHandler = { completion in  completion?(.success) }
        let expectation = XCTestExpectation()

        // When tracking a trackable
        publisher.track(trackable: trackable) { result in
            switch result {
            case .success:
                expectation.fulfill()
            case .failure:
                XCTFail("Failure callback shouldn't be called")
            }
        }

        wait(for: [expectation], timeout: 5.0)

        // It should set active trackable
        XCTAssertEqual(publisher.activeTrackable, trackable)

        // It should ask ably publisher to track given trackable
        XCTAssertTrue(ablyPublisher.connectCalled)
        XCTAssertEqual(ablyPublisher.connectTrackableId, trackable.id)

        // It should notify the delegate that the trackables changed
        XCTAssertTrue(delegate.publisherDidChangeTrackablesCalled)
        XCTAssertEqual(delegate.publisherDidChangeTrackablesParamTrackables, [trackable])

        // It should ask location service to start updating location
        XCTAssertTrue(locationService.startUpdatingLocationCalled)

        // It should notify trackables hook that there is new trackable
        XCTAssertTrue(resolutionPolicyFactory.resolutionPolicy!.trackablesSetListener.onTrackableAddedCalled)
        XCTAssertEqual(resolutionPolicyFactory.resolutionPolicy!.trackablesSetListener.onTrackableAddedParamTrackable, trackable)

        // It should notify trackables hook that there is new active trackable
        XCTAssertTrue(resolutionPolicyFactory.resolutionPolicy!.trackablesSetListener.onActiveTrackableChangedCalled)
        XCTAssertEqual(resolutionPolicyFactory.resolutionPolicy!.trackablesSetListener.onActiveTrackableChangedParamTrackable, trackable)
    }

    // MARK: track
    func testTrack_destination() {
        ablyPublisher.connectCompletionHandler = { completion in  completion?(.success) }
        let expectation = XCTestExpectation()

        let destination = LocationCoordinate(latitude: 12.3456, longitude: 56.789)
        let trackable = Trackable(id: "TrackableId", destination: destination)

        // When tracking a trackable with given destination
        publisher.track(trackable: trackable) { result in
            switch result {
            case .success:
                expectation.fulfill()
            case .failure:
                XCTFail("Failure callback shouldn't be called")
            }
        }
        wait(for: [expectation], timeout: 5.0)

        // It should ask RouteProvider to calculate route to given destination
        XCTAssertTrue(routeProvider.getRouteCalled)
        XCTAssertEqual(routeProvider.getRouteParamDestination?.toLocationCoordinate(), destination)
    }
    func testTrack_trackableAddedEarlier() {
        ablyPublisher.connectCompletionHandler = { completion in completion?(.success) }
        var expectation = XCTestExpectation()

        // When adding a new trackable
        publisher.add(trackable: trackable) { result in
            switch result {
            case .success:
                expectation.fulfill()
            case .failure:
                XCTFail("Failure callback shouldn't be called")
            }
        }

        wait(for: [expectation], timeout: 5.0)
        expectation = XCTestExpectation()

        // And then tracking it
        publisher.track(trackable: trackable) { result in
            switch result {
            case .success:
                XCTAssertEqual(self.publisher.activeTrackable, self.trackable)
                expectation.fulfill()
            case .failure:
                XCTFail("Failure callback shouldn't be called")
            }
        }

        wait(for: [expectation], timeout: 5.0)
    }

    func test_trackCalledMultipleTimes_shouldPass() {
        ablyPublisher.connectCompletionHandler = { completion in  completion?(.success) }
        var expectations = [XCTestExpectation]()
        let trackMethodCalls = 5

        for trackableIndex in 0...trackMethodCalls {
            let expectation = XCTestExpectation()
            let trackable = Trackable(id: "\(trackableIndex)")

            publisher.track(trackable: trackable) { result in
                switch result {
                case .success:
                    expectation.fulfill()
                case .failure:
                    XCTFail("Failure callback shouldn't be called")
                }
            }

            expectations.append(expectation)
        }

        wait(for: expectations, timeout: 5.0)
    }

    func testTrack_error_ably_service_error() {
        let errorInformation = ErrorInformation(type: .publisherError(errorMessage: "Test AblyPublisher error"))
        ablyPublisher.connectCompletionHandler = { completion in  completion?(.failure(errorInformation)) }
        let expectation = XCTestExpectation()

        // When tracking a trackable and receive error response from ablyPublisher
        publisher.track(trackable: trackable) { result in
            switch result {
            case .success:
                XCTFail("Success callback shouldn't be called")
            case .failure(let error):
                // It should call failure callback with received error
                XCTAssertTrue(error.isEqual(to: errorInformation))
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 5.0)
    }

    func testTrack_successMainThread() {
        ablyPublisher.connectCompletionHandler = { completion in  completion?(.success) }

        let expectation = XCTestExpectation()
        // onSuccess callback should be called on the main thread
        publisher.track(trackable: trackable) { result in
            switch result {
            case .success:
                dispatchPrecondition(condition: .onQueue(DispatchQueue.main))
                expectation.fulfill()
            case .failure:
                XCTFail("Failure callback shouldn't be called")
            }
        }

        wait(for: [expectation], timeout: 5.0)
    }

    func testTrack_failureMainThread() {
        let errorInformation = ErrorInformation(type: .publisherError(errorMessage: "Test AblyPublisher error"))
        ablyPublisher.connectCompletionHandler = { completion in  completion?(.failure(errorInformation)) }
        let expectation = XCTestExpectation()

        // onError callback should be called on the main thread
        publisher.track(trackable: trackable) { result in
            switch result {
            case .success:
                XCTFail("Success callback shouldn't be called")
            case .failure:
                dispatchPrecondition(condition: .onQueue(DispatchQueue.main))
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 5.0)
    }

    // MARK: add
    func testAdd_success() {
        ablyPublisher.connectCompletionHandler = { completion in  completion?(.success) }
        let expectation = XCTestExpectation()

        // When adding a trackable
        publisher.add(trackable: trackable) { result in
            switch result {
            case .success:
                expectation.fulfill()
            case .failure:
                XCTFail("Failure callback shouldn't be called")
            }
        }
        wait(for: [expectation], timeout: 5.0)

        // It should NOT set active trackable
        XCTAssertNil(publisher.activeTrackable)

        // It should ask ably publisher to track given trackable
        XCTAssertTrue(ablyPublisher.connectCalled)
        XCTAssertEqual(ablyPublisher.connectTrackableId, trackable.id)

        // It should ask location service to start updating location
        XCTAssertTrue(locationService.startUpdatingLocationCalled)

        // It should notify the delegate that the trackables changed
        XCTAssertTrue(delegate.publisherDidChangeTrackablesCalled)
        XCTAssertEqual(delegate.publisherDidChangeTrackablesParamTrackables, [trackable])

        // It should notify trackables hook that there is new trackable
        XCTAssertTrue(resolutionPolicyFactory.resolutionPolicy!.trackablesSetListener.onTrackableAddedCalled)
        XCTAssertEqual(resolutionPolicyFactory.resolutionPolicy!.trackablesSetListener.onTrackableAddedParamTrackable, trackable)

        // It should NOT notify trackables hook that there is new active trackable
        XCTAssertFalse(resolutionPolicyFactory.resolutionPolicy!.trackablesSetListener.onActiveTrackableChangedCalled)
    }

    func testAdd_track_success() {
        ablyPublisher.connectCompletionHandler = { completion in  completion?(.success) }
        let expectation = XCTestExpectation()
        expectation.expectedFulfillmentCount = 2

        // When tracking a trackable
        publisher.track(trackable: trackable) { result in
            switch result {
            case .success:
                expectation.fulfill()
            case .failure:
                XCTFail("Failure callback shouldn't be called")
            }
        }
        // And then adding another trackable
        publisher.add(trackable: Trackable(id: "TestAddedTrackableId1")) { result in
            switch result {
            case .success:
                expectation.fulfill()
            case .failure:
                XCTFail("Failure callback shouldn't be called")
            }
        }
        wait(for: [expectation], timeout: 5.0)

        // It should NOT change active trackable
        XCTAssertEqual(publisher.activeTrackable, trackable)
    }

    func testAdd_track_error() {
        let errorInformation = ErrorInformation(type: .publisherError(errorMessage: "Test AblyPublisherService error"))
        ablyPublisher.connectCompletionHandler = { completion in  completion?(.failure(errorInformation)) }
        let expectation = XCTestExpectation()

        // When adding a trackable and receive error response from ablyPublisher
        publisher.add(trackable: trackable) { [weak self] result in
            guard let self
            else {
                XCTFail("self shouldn't be nil")
                return
            }
            switch result {
            case .success:
                XCTFail("Success callback shouldn't be called")
            case .failure(let error):
                // It should call onError callback with received error
                XCTAssertTrue(error.isEqual(to: errorInformation))

                // It should not notify the delegate that the trackables changed
                XCTAssertFalse(self.delegate.publisherDidChangeTrackablesCalled)
                XCTAssertNil(self.delegate.publisherDidChangeTrackablesParamTrackables)
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 5.0)
    }

    func testAdd_success_thread() {
        ablyPublisher.connectCompletionHandler = { completion in  completion?(.success) }
        let expectation = XCTestExpectation()
        // `onSuccess` callback should be called on main thread
        // Notice - in case of failure it will crash whole test suite
        publisher.add(trackable: trackable) { result in
            switch result {
            case .success:
                dispatchPrecondition(condition: .onQueue(DispatchQueue.main))
                expectation.fulfill()
            case .failure:
                XCTFail("Failure callback shouldn't be called")
            }
        }

        wait(for: [expectation], timeout: 5.0)
    }

    func testAdd_error_thread() {
        let errorInformation = ErrorInformation(type: .publisherError(errorMessage: "Test AblyPublisher error"))
        ablyPublisher.connectCompletionHandler = { completion in  completion?(.failure(errorInformation)) }
        let expectation = XCTestExpectation()

        // `onError` callback should be called on main thread
        // Notice - in case of failure it will crash whole test suite
        publisher.add(trackable: trackable) { result in
            switch result {
            case .success:
                XCTFail("Success callback shouldn't be called")
            case .failure:
                dispatchPrecondition(condition: .onQueue(DispatchQueue.main))
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 5.0)
    }

    func testAdd_whenTrackableWithSameIdIsCurrentlyBeingAdded_itWaitsForTheFirstAddToComplete_andWhenTheFirstAddSucceeds_theSecondAddSucceedsToo() {
        var numberOfTimesConnectCalled = 0
        let synchronizationQueue = DispatchQueue(label: #function)
        var connectCompletion: ResultHandler<Void>?
        let connectCalledExpectation = expectation(description: "ablyPublisher’s connect method is called")
        ablyPublisher.connectCompletionHandler = { completion in
            synchronizationQueue.async {
                numberOfTimesConnectCalled += 1
            }
            connectCompletion = completion
            connectCalledExpectation.fulfill()
        }

        let anotherTrackableWithSameId = Trackable(
            id: trackable.id,
            metadata: "SomeOtherTrackableMetadata",
            destination: LocationCoordinate(latitude: 10.42, longitude: 7.82)
        )

        let trackableAddExpectation = expectation(description: "Add of trackable completes successfully")
        publisher.add(trackable: trackable) { result in
            switch result {
            case let .failure(error):
                XCTFail("Add of trackable unexpectedly failed: \(error)")
            case .success:
                trackableAddExpectation.fulfill()
            }
        }

        let anotherTrackableAddExpectation = expectation(description: "Add of anotherTrackable completes successfully")
        publisher.add(trackable: anotherTrackableWithSameId) { result in
            switch result {
            case let .failure(error):
                XCTFail("Add of anotherTrackable unexpectedly failed: \(error)")
            case .success:
                anotherTrackableAddExpectation.fulfill()
            }
        }

        wait(for: [connectCalledExpectation], timeout: 5.0)
        connectCompletion!(.success)

        wait(for: [trackableAddExpectation, anotherTrackableAddExpectation], timeout: 5.0)

        synchronizationQueue.async {
            XCTAssertEqual(numberOfTimesConnectCalled, 1)
        }
    }

    func testAdd_whenTrackableWithSameIdIsCurrentlyBeingAdded_itWaitsForTheFirstAddToComplete_andWhenTheFirstAddFails_theSecondAddFailsWithTheSameError() {
        var numberOfTimesConnectCalled = 0
        let synchronizationQueue = DispatchQueue(label: #function)
        var connectCompletion: ResultHandler<Void>?
        let connectCalledExpectation = expectation(description: "ablyPublisher’s connect method is called")
        ablyPublisher.connectCompletionHandler = { completion in
            synchronizationQueue.async {
                numberOfTimesConnectCalled += 1
            }
            connectCompletion = completion
            connectCalledExpectation.fulfill()
        }

        let anotherTrackableWithSameId = Trackable(
            id: trackable.id,
            metadata: "SomeOtherTrackableMetadata",
            destination: LocationCoordinate(latitude: 10.42, longitude: 7.82)
        )

        let trackableAddExpectation = expectation(description: "Add of trackable completes successfully")
        publisher.add(trackable: trackable) { result in
            switch result {
            case let .failure(error):
                XCTAssertEqual(error.code, 12345)
                trackableAddExpectation.fulfill()
            case .success:
                XCTFail("Add of trackable unexpectedly succeeded")
            }
        }

        let anotherTrackableAddExpectation = expectation(description: "Add of anotherTrackable completes successfully")
        publisher.add(trackable: anotherTrackableWithSameId) { result in
            switch result {
            case let .failure(error):
                XCTAssertEqual(error.code, 12345)
                anotherTrackableAddExpectation.fulfill()
            case .success:
                XCTFail("Add of anotherTrackable unexpectedly succeeded")
            }
        }

        wait(for: [connectCalledExpectation], timeout: 5.0)
        connectCompletion!(.failure(.init(code: 12345, statusCode: 0, message: "", cause: nil, href: nil)))

        wait(for: [trackableAddExpectation, anotherTrackableAddExpectation], timeout: 5.0)

        synchronizationQueue.async {
            XCTAssertEqual(numberOfTimesConnectCalled, 1)
        }
    }

    // MARK: remove
    func testRemove_success() {
        let wasPresent = true
        var receivedWasPresent: Bool?

        ablyPublisher.disconnectResultCompletionHandler = { completion in completion?(.success(wasPresent)) }
        ablyPublisher.connectCompletionHandler = { completion in  completion?(.success) }

        publisher.add(trackable: Trackable(id: "Trackable1")) { _ in }
        publisher.add(trackable: Trackable(id: "Trackable2")) { _ in }

        let expectation = XCTestExpectation()

        // When removing trackable
        publisher.remove(trackable: trackable) { result in
            switch result {
            case .success(let present):
                receivedWasPresent = present
                expectation.fulfill()
            case .failure:
                XCTFail("Failure callback shouldn't be called")
            }
        }

        wait(for: [expectation], timeout: 5.0)

        // It should ask ablyPublisher to stop tracking
        XCTAssertTrue(ablyPublisher.disconnectCalled)

        // It should ask ablyPublisher to stop tracking given trackable
        XCTAssertEqual(ablyPublisher.disconnectParamTrackableId, trackable.id)

        // It should return correct `wasPresent` value in callback
        XCTAssertEqual(receivedWasPresent!, wasPresent)

        // It should NOT ask locationService to stop location updates as there are some tracked trackables
        XCTAssertFalse(locationService.stopUpdatingLocationCalled)

        // It should notify the delegate that the trackables changed
        XCTAssertTrue(delegate.publisherDidChangeTrackablesCalled)
        XCTAssertEqual(delegate.publisherDidChangeTrackablesParamTrackables?.count, 2)

        // It should notify trackables hook that trackable was removed (as it was present in ablyPublisher)
        XCTAssertTrue(resolutionPolicyFactory.resolutionPolicy!.trackablesSetListener.onTrackableRemovedCalled)
        XCTAssertEqual(resolutionPolicyFactory.resolutionPolicy!.trackablesSetListener.onTrackableRemovedParamTrackable, trackable)
    }

    func testRemove_activeTrackable() {
        ablyPublisher.connectCompletionHandler = { completion in completion?(.success) }
        ablyPublisher.disconnectResultCompletionHandler = { handler in handler?(.success(true)) }

        var expectation = XCTestExpectation(description: "Handler for `track` call")
        expectation.expectedFulfillmentCount = 1

        // When removing trackable which was tracked before (so it's set as the activeTrackable)
        publisher.track(trackable: trackable) { result in
            switch result {
            case .success:
                expectation.fulfill()
            case .failure:
                XCTFail("Failure callback shouldn't be called")
            }
        }

        wait(for: [expectation], timeout: 5.0)
        XCTAssertEqual(publisher.activeTrackable, trackable)

        expectation = XCTestExpectation(description: "Handler for `remove` call")
        publisher.remove(trackable: publisher.activeTrackable!) { result in
            switch result {
            case .success:
                expectation.fulfill()
            case .failure:
                XCTFail("Failure callback shouldn't be called")
            }
        }

        wait(for: [expectation], timeout: 5.0)

        // It should clear activeTrackable
        XCTAssertNil(publisher.activeTrackable)

        // It should ask locationService to stop location updates as there are none tracked trackables
        XCTAssertTrue(locationService.stopUpdatingLocationCalled)

        // It should notify trackables hook that there is trackable removed
        XCTAssertTrue(resolutionPolicyFactory.resolutionPolicy!.trackablesSetListener.onTrackableRemovedCalled)
        XCTAssertEqual(resolutionPolicyFactory.resolutionPolicy!.trackablesSetListener.onTrackableRemovedParamTrackable, trackable)

        // It should notify trackables hook that there is active trackable changed with nil value
        XCTAssertTrue(resolutionPolicyFactory.resolutionPolicy!.trackablesSetListener.onActiveTrackableChangedCalled)
        XCTAssertNil(resolutionPolicyFactory.resolutionPolicy!.trackablesSetListener.onActiveTrackableChangedParamTrackable)
    }

    func testRemove_nonActiveTrackable() {
        ablyPublisher.connectCompletionHandler = { completion in  completion?(.success) }
        ablyPublisher.disconnectResultCompletionHandler = { handler in handler?(.success(true)) }

        var expectation = XCTestExpectation(description: "Handler for `track` call")

        // When removing trackable which was no tracked before (so it's NOT set as the activeTrackable)
        publisher.track(trackable: trackable) { result in
            switch result {
            case .success:
                expectation.fulfill()
            case .failure:
                XCTFail("Failure callback shouldn't be called")
            }
        }
        wait(for: [expectation], timeout: 5.0)
        XCTAssertEqual(publisher.activeTrackable, trackable)

        expectation = XCTestExpectation(description: "Handler for `remove` call")
        let removedTrackable = Trackable(id: "AnotherTrackableId")
        publisher.remove(trackable: removedTrackable) { result in
            switch result {
            case .success:
                expectation.fulfill()
            case .failure:
                XCTFail("Failure callback shouldn't be called")
            }
        }
        wait(for: [expectation], timeout: 5.0)

        // It should NOT modify activeTrackable
        XCTAssertEqual(publisher.activeTrackable, trackable)

        // It should notify trackables hook that there is trackable removed
        XCTAssertTrue(resolutionPolicyFactory.resolutionPolicy!.trackablesSetListener.onTrackableRemovedCalled)
        XCTAssertEqual(resolutionPolicyFactory.resolutionPolicy!.trackablesSetListener.onTrackableRemovedParamTrackable, removedTrackable)

        // It should NOT notify trackables hook that there is active trackable changed
        XCTAssertTrue(resolutionPolicyFactory.resolutionPolicy!.trackablesSetListener.onActiveTrackableChangedCalled)
    }

    func testRemove_error() {
        let errorInformation = ErrorInformation(type: .publisherError(errorMessage: "Test AblyPublisher error"))
        ablyPublisher.disconnectResultCompletionHandler = { handler in handler?(.failure(errorInformation)) }
        let expectation = XCTestExpectation()

        // When removing trackable and receive error from ablyPublisher
        publisher.remove(trackable: trackable) { result in
            switch result {
            case .success:
                XCTFail("Success callback shouldn't be called")
            case .failure(let receivedError):
                XCTAssertTrue(receivedError.isEqual(to: errorInformation))
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 5.0)
    }

    func testRemove_success_thread() {
        ablyPublisher.disconnectResultCompletionHandler = { handler in handler?(.success(true)) }
        let expectation = XCTestExpectation()

        // When removing trackable `onSuccess` callback should be called on main thread
        // Notice - in case of failure it will crash whole test suite
        publisher.remove(trackable: trackable) { result in
            switch result {
            case .success:
                dispatchPrecondition(condition: .onQueue(DispatchQueue.main))
                expectation.fulfill()
            case .failure:
                XCTFail("Failure callback shouldn't be called")
            }
        }

        wait(for: [expectation], timeout: 5.0)
    }

    func testRemove_error_thread() {
        let errorInformation = ErrorInformation(type: .publisherError(errorMessage: "Test AblyPublisher error"))
        ablyPublisher.disconnectResultCompletionHandler = { handler in handler?(.failure(errorInformation)) }

        let expectation = XCTestExpectation()

        // When removing trackable `onError` callback should be called on main thread
        // Notice - in case of failure it will crash whole test suite
        publisher.remove(trackable: trackable) { result in
            switch result {
            case .success:
                XCTFail("Success callback shouldn't be called")
            case .failure:
                dispatchPrecondition(condition: .onQueue(DispatchQueue.main))
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 5.0)
    }

    // MARK: stop

    // MARK: ChangeRoutingProfile
    func testChangeRoutingProfile_withNoActiveTrackable_updatesRoutingProfile_andCallsCallbackWithSuccess() {
        let expectation = expectation(description: "changeRoutingProfile completes successfully")

        // Given: Default RoutingProfile set to .driving
        publisher.changeRoutingProfile(profile: .cycling) { result in
            switch result {
            case .success:
                XCTAssertFalse(self.routeProvider.getRouteCalled)
                XCTAssertEqual(self.publisher.routingProfile, .cycling)
                expectation.fulfill()
            case let .failure(error):
                XCTFail("changeRoutingProfile failed with unexpected error: \(error)")
            }
        }

        waitForExpectations(timeout: 10)
    }

    func testChangeRoutingProfile_withActiveTrackableWithoutDestination_updatesRoutingProfile_andCallsCallbackWithSuccess() {
        ablyPublisher.connectCompletionHandler = { completion in  completion?(.success) }

        let trackExpectation = expectation(description: "track completes successfully")

        publisher.track(trackable: .init(id: UUID().uuidString)) { result in
            switch result {
            case .success:
                trackExpectation.fulfill()
            case let .failure(error):
                XCTFail("changeRoutingProfile failed with unexpected error: \(error)")
            }
        }

        waitForExpectations(timeout: 10)

        let changeRoutingProfileExpectation = expectation(description: "changeRoutingProfile completes successfully")

        // Given: Default RoutingProfile set to .driving
        publisher.changeRoutingProfile(profile: .cycling) { result in
            switch result {
            case .success:
                XCTAssertFalse(self.routeProvider.getRouteCalled)
                XCTAssertEqual(self.publisher.routingProfile, .cycling)
                changeRoutingProfileExpectation.fulfill()
            case .failure:
                XCTFail("Failure callback shouldn't be called")
            }
        }

        waitForExpectations(timeout: 10)
    }

    func testChangeRoutingProfile_withActiveTrackableWithDestination_callsGetRouteOnRouteProvider_andWhenThatSucceeds_itUpdatesRoutingProfile_andCallsCallbackWithSuccess() {
        ablyPublisher.connectCompletionHandler = { completion in  completion?(.success) }
        routeProvider.getRouteBody = { handler in handler(.success(.init(legs: [], shape: nil, distance: .infinity, expectedTravelTime: 0))) }

        let trackExpectation = expectation(description: "track completes successfully")

        let destination = LocationCoordinate(latitude: 3.1415, longitude: 2.7182)

        publisher.track(trackable: .init(id: UUID().uuidString, destination: destination)) { result in
            switch result {
            case .success:
                trackExpectation.fulfill()
            case let .failure(error):
                XCTFail("track failed with unexpected error: \(error)")
            }
        }

        waitForExpectations(timeout: 10)

        let changeRoutingProfileExpectation = expectation(description: "changeRoutingProfile completes successfully")

        // Given: Default RoutingProfile set to .driving
        publisher.changeRoutingProfile(profile: .cycling) { result in
            switch result {
            case .success:
                XCTAssertTrue(self.routeProvider.getRouteCalled)
                XCTAssertEqual(self.routeProvider.getRouteParamDestination, destination.toCoreLocationCoordinate2d())
                XCTAssertEqual(self.routeProvider.getRouteParamRoutingProfile, .cycling)
                XCTAssertEqual(self.publisher.routingProfile, .cycling)
                changeRoutingProfileExpectation.fulfill()
            case .failure(let error):
                XCTFail("changeRoutingProfile failed with unexpected error: \(error)")
            }
        }

        waitForExpectations(timeout: 10)
    }

    func test_closeConnection_success() {
        let expectation = XCTestExpectation()
        ablyPublisher.closeResultCompletionHandler = { callback in
            callback?(.success)
            expectation.fulfill()
        }

        ablyPublisher.close(presenceData: .init(type: .publisher)) { _ in }
        wait(for: [expectation], timeout: 5.0)

        XCTAssertTrue(ablyPublisher.closeCalled)
        XCTAssertNotNil(ablyPublisher.closeCompletion)
    }

    func test_closeConnection_failure() {
        let expectation = XCTestExpectation()
        let closeError = ErrorInformation(type: .publisherError(errorMessage: "TestError."))
        ablyPublisher.closeResultCompletionHandler = { callback in
            callback?(.failure(closeError))
            expectation.fulfill()
        }

        ablyPublisher.close(presenceData: .init(type: .publisher)) { result in
            switch result {
            case .success:
                XCTFail("Success not expected.")
            case .failure(let error):
                XCTAssertEqual(error.message, closeError.message)
            }
        }

        wait(for: [expectation], timeout: 5.0)

        XCTAssertTrue(ablyPublisher.closeCalled)
        XCTAssertNotNil(ablyPublisher.closeCompletion)
    }

    func testDefaultTrackableStateRetry() {
        let trackableId = "trackable_1"
        let otherTrackableId = "trackable_2"
        let state = TrackableState<EnhancedLocationUpdate>()

        /**
         The `shouldRetry` method wraps few functionalities:
         
         1. It adding new `key` (trackableId) to dictionary if it not exists with `value` `0`
         2. It checking if `value` for `key` (trackableId) is lower than `maxRetryCount`
         */

        XCTAssertTrue(state.shouldRetry(trackableId: trackableId), "The retry counter for `trackableId` should be < `maxRetryCount` so it should be able to retry")
        state.incrementRetryCounter(for: trackableId) // counter == 1

        XCTAssertFalse(state.shouldRetry(trackableId: trackableId), "The counter for `trackableId` should be >= `maxRetryCount` so it shouldn't be able to retry")
        XCTAssertEqual(state.getRetryCounter(for: trackableId), 1)

        state.resetRetryCounter(for: trackableId)
        XCTAssertEqual(state.getRetryCounter(for: trackableId), 0)

        XCTAssertTrue(state.shouldRetry(trackableId: otherTrackableId), "The retry counter for `otherTrackableId` should be < `maxRetryCount` so it should be able to retry")
        state.incrementRetryCounter(for: otherTrackableId) // counter == 1

        XCTAssertFalse(state.shouldRetry(trackableId: otherTrackableId), "The counter for `otherTrackableId` should be >= `maxRetryCount` so it shouldn't be able to retry")
        state.incrementRetryCounter(for: otherTrackableId) // counter == 2

        XCTAssertFalse(state.shouldRetry(trackableId: otherTrackableId), "The counter for `otherTrackableId` should be >= `maxRetryCount` so it shouldn't be able to retry")

        XCTAssertEqual(state.getRetryCounter(for: otherTrackableId), 2)
        XCTAssertEqual(state.getRetryCounter(for: trackableId), 0)
    }

    func testDefaultTrackableStateWaiting() {
        let trackableId = "trackable_1"
        let locationUpdate = EnhancedLocationUpdate(location: Location(coordinate: LocationCoordinate(latitude: 1, longitude: 1)))
        let anotherLocationUpdate = EnhancedLocationUpdate(location: Location(coordinate: LocationCoordinate(latitude: 2, longitude: 2)))
        let state = TrackableState<EnhancedLocationUpdate>()

        /**
         Add two location updates
         */
        state.addToWaiting(locationUpdate: locationUpdate, for: trackableId)
        state.addToWaiting(locationUpdate: anotherLocationUpdate, for: trackableId)

        /**
         Ensure that  location returning by `nextWaiting` is location on index `0` (FIFO).
         */
        if let nextLocationUpdate = state.nextWaitingLocation(for: trackableId) {
            XCTAssertEqual(nextLocationUpdate, locationUpdate)
        } else {
            XCTFail("No location update for \(trackableId)")
        }

        /**
         Call `nextWainting` second time to pop last location for `trackableId`
         */
        _ = state.nextWaitingLocation(for: trackableId)

        /**
         Ensure that there is no more waiting locations  for `trackableId`
         */
        XCTAssertNil(state.nextWaitingLocation(for: trackableId))
    }

    func testDefaultTrackableStatePending() {
        let trackableId = "trackable_1"
        let state = TrackableState<EnhancedLocationUpdate>()

        XCTAssertFalse(state.hasPendingMessage(for: trackableId))

        state.markMessageAsPending(for: trackableId)

        XCTAssertTrue(state.hasPendingMessage(for: trackableId))

        state.unmarkMessageAsPending(for: trackableId)

        XCTAssertFalse(state.hasPendingMessage(for: trackableId))
    }

    func testDefaultTrackableStateRemove() {
        let trackableId = "trackable_1"
        let trackableId2 = "trackable_2"
        let locationUpdate = EnhancedLocationUpdate(location: Location(coordinate: LocationCoordinate(latitude: 1, longitude: 1)))
        let state = TrackableState<EnhancedLocationUpdate>()

        state.markMessageAsPending(for: trackableId)
        state.markMessageAsPending(for: trackableId2)

        state.addToWaiting(locationUpdate: locationUpdate, for: trackableId)
        state.addToWaiting(locationUpdate: locationUpdate, for: trackableId2)

        _ = state.shouldRetry(trackableId: trackableId)
        _ = state.shouldRetry(trackableId: trackableId2)

        state.incrementRetryCounter(for: trackableId)
        state.incrementRetryCounter(for: trackableId2)

        state.remove(trackableId: trackableId)

        XCTAssertFalse(state.hasPendingMessage(for: trackableId))
        XCTAssertTrue(state.hasPendingMessage(for: trackableId2))

        XCTAssertNil(state.nextWaitingLocation(for: trackableId))
        XCTAssertNotNil(state.nextWaitingLocation(for: trackableId2))

        XCTAssertEqual(state.getRetryCounter(for: trackableId), 0)
        XCTAssertEqual(state.getRetryCounter(for: trackableId2), 1)

        state.removeAll()

        XCTAssertFalse(state.hasPendingMessage(for: trackableId2))
        XCTAssertNil(state.nextWaitingLocation(for: trackableId2))
        XCTAssertEqual(state.getRetryCounter(for: trackableId2), 0)
    }

    func testDefaultSkippedLocationsStateAddAndRemove() {
        let location = Location(coordinate: LocationCoordinate(latitude: 1, longitude: 1))
        let locationUpdate = EnhancedLocationUpdate(location: location)
        let trackableId = "Trackable_1"

        let location2 = Location(coordinate: LocationCoordinate(latitude: 2, longitude: 2))
        let locationUpdate2 = EnhancedLocationUpdate(location: location2)
        let trackableId2 = "Trackable_2"

        let state = createSkippedLocationState()

        XCTAssertEqual(state.locationsList(for: trackableId).count, .zero)

        /**
         Add `location` for `trackableId`
         Add `location2` for `trackableId2`
         */
        state.addLocation(for: trackableId, location: locationUpdate)
        state.addLocation(for: trackableId2, location: locationUpdate2)

        /**
         Check if `location` for `trackableId` EXISTS in state
         */
        XCTAssertEqual(state.locationsList(for: trackableId).count, 1)
        XCTAssertEqual(state.locationsList(for: trackableId)[0].location, location)

        /**
         Clear `location` for `trackableId`
         */
        state.clearLocation(for: trackableId)

        /**
         Check if `list` for `trackableId` IS EMPTY
         */
        XCTAssertEqual(state.locationsList(for: trackableId).count, .zero)

        /**
         Check if `list2` for `trackableId2` IS NOT EMPTY after removing `trackableId` locations
         */

        XCTAssertEqual(state.locationsList(for: trackableId2).count, 1)
        XCTAssertEqual(state.locationsList(for: trackableId2)[0].location, location2)
    }

    func testDefaultSkippedLocationsStateClearAll() {
        let state = createSkippedLocationState(
            with: [
                "Trackable_1": [Location(coordinate: LocationCoordinate(latitude: 1, longitude: 1))],
                "Trackable_2": [Location(coordinate: LocationCoordinate(latitude: 2, longitude: 2))]
            ]
        )

        state.removeAll()

        XCTAssertEqual(state.locationsList(for: "Trackable_1").count, .zero)
        XCTAssertEqual(state.locationsList(for: "Trackable_2").count, .zero)
    }

    func testDefaultSkippedLocationsStateCapacityOverflow() {
        let trackableId = "Trackable_1"
        let state = createSkippedLocationState()

        for i in 0..<state.maxSkippedLocationsSize {
            let location = Location(coordinate: LocationCoordinate(latitude: Double(i), longitude: Double(i)))
            let locationUpdate = EnhancedLocationUpdate(location: location)
            state.addLocation(for: trackableId, location: locationUpdate)
        }

        XCTAssertEqual(state.locationsList(for: trackableId).count, state.maxSkippedLocationsSize)

        let overflowLocation = Location(coordinate: LocationCoordinate(latitude: 1.2345, longitude: 1.2345))
        let overflowLocationUpdate = EnhancedLocationUpdate(location: overflowLocation)
        state.addLocation(for: trackableId, location: overflowLocationUpdate)

        XCTAssertEqual(state.locationsList(for: trackableId).count, state.maxSkippedLocationsSize)
        /**
         It should drop oldest (first index) location on overflofw - first location from loop above had `CLLocationCoordinate2D(latitude: 0, longitude: 0)`
         so next one should has `CLLocationCoordinate2D(latitude: 1, longitude: 1)`
         */
        XCTAssertEqual(state.locationsList(for: trackableId)[0].location.coordinate, LocationCoordinate(latitude: 1, longitude: 1))
        /**
         additionally last location should be equal to `overflowLocation`
         */
        XCTAssertEqual(state.locationsList(for: trackableId).last!.location, overflowLocation)
    }

    private func createSkippedLocationState(with data: [String: [Location]] = [:], capacity: Int = 10) -> TrackableState<EnhancedLocationUpdate> {
        let state = TrackableState<EnhancedLocationUpdate>(maxSkippedLocationsSize: capacity)
        for (trackableId, locations) in data {
            locations.map(EnhancedLocationUpdate.init).forEach { enhancedLocationUpdate in
                state.addLocation(for: trackableId, location: enhancedLocationUpdate)
            }
        }

        return state
    }

    func testStopEventCauseImpossibilityOfEnqueueOtherEvents() {
        ablyPublisher.connectCompletionHandler = { completion in  completion?(.success) }
        ablyPublisher.closeResultCompletionHandler = { completion in completion?(.success) }
        locationService.stopRecordingLocationCallback = { completion in completion(.success(nil)) }

        let publisher = DefaultPublisher(
            routingProfile: .driving,
            resolutionPolicyFactory: resolutionPolicyFactory,
            ablyPublisher: ablyPublisher,
            locationService: locationService,
            routeProvider: routeProvider,
            logHandler: logger
        )

        let connectCompletionExpectation = self.expectation(description: "Track completion expectation")
        publisher.track(trackable: trackable) { _ in
            connectCompletionExpectation.fulfill()
        }
        waitForExpectations(timeout: 10.0).self

        let publisherStopExpectation = self.expectation(description: "Publisher stop expectation")
        publisher.stop { result in
            switch result {
            case .success:
                ()
            case .failure(let error):
                XCTFail("Publisher stop failed with error: \(error)")
            }

            publisherStopExpectation.fulfill()
        }
        waitForExpectations(timeout: 10.0)

        let trackAfterStopCompletionExpectation = self.expectation(description: "Track after stop event completion expectation")
        publisher.track(trackable: trackable) { result in
            switch result {
            case .success:
                XCTFail("Track success shouldn't occur when publisher is stopped")
            case .failure:
                ()
            }

            trackAfterStopCompletionExpectation.fulfill()
        }
        waitForExpectations(timeout: 10.0)
    }
}
