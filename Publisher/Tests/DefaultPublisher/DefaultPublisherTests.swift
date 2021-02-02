import XCTest
import CoreLocation
import Logging
@testable import Publisher

class DefaultPublisherTests: XCTestCase {
    var locationService: MockLocationService!
    var ablyService: MockAblyPublisherService!
    var configuration: ConnectionConfiguration!
    var mapboxConfiguration: MapboxConfiguration!
    var routeProvider: MockRouteProvider!
    var resolutionPolicyFactory: MockResolutionPolicyFactory!
    var trackable: Trackable!
    var publisher: DefaultPublisher!

    override class func setUp() {
        LoggingSystem.bootstrap { label -> LogHandler in
            var handler = StreamLogHandler.standardOutput(label: label)
            handler.logLevel = .debug
            return handler
        }
    }

    override func setUpWithError() throws {
        locationService = MockLocationService()
        ablyService = MockAblyPublisherService()
        configuration = ConnectionConfiguration(apiKey: "API_KEY", clientId: "CLIENT_ID")
        mapboxConfiguration = MapboxConfiguration(mapboxKey: "MAPBOX_ACCESS_TOKEN")
        resolutionPolicyFactory = MockResolutionPolicyFactory()
        routeProvider = MockRouteProvider()
        trackable = Trackable(id: "TrackableId",
                              metadata: "TrackableMetadata",
                              destination: CLLocationCoordinate2D(latitude: 3.1415, longitude: 2.7182))
        publisher = DefaultPublisher(connectionConfiguration: configuration,
                                     mapboxConfiguration: mapboxConfiguration,
                                     logConfiguration: LogConfiguration(),
                                     routingProfile: .driving,
                                     resolutionPolicyFactory: resolutionPolicyFactory,
                                     ablyService: ablyService,
                                     locationService: locationService,
                                     routeProvider: routeProvider)
    }

    // MARK: track
    func testTrack_success() {
        ablyService.trackCompletionHandler = { completion in completion?(nil) }
        let expectation = XCTestExpectation()

        // When tracking a trackable
        publisher.track(trackable: trackable,
                        onSuccess: { expectation.fulfill() },
                        onError: { _ in XCTAssertTrue(false, "onError callback shouldn't be called") })
        wait(for: [expectation], timeout: 5.0)

        // It should set active trackable
        XCTAssertEqual(publisher.activeTrackable, trackable)

        // It should ask ably service to track given trackable
        XCTAssertTrue(ablyService.trackCalled)
        XCTAssertEqual(ablyService.trackParamTrackable, trackable)

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
        ablyService.trackCompletionHandler = { completion in completion?(nil) }
        let expectation = XCTestExpectation()

        let destination = CLLocationCoordinate2D(latitude: 12.3456, longitude: 56.789)
        let trackable = Trackable(id: "TrackableId", destination: destination)

        // When tracking a trackable with given destination
        publisher.track(trackable: trackable,
                        onSuccess: { expectation.fulfill() },
                        onError: { _ in XCTAssertTrue(false, "onError callback shouldn't be called") })
        wait(for: [expectation], timeout: 5.0)

        // It should ask RouteProvider to calculate route to given destination
        XCTAssertTrue(routeProvider.getRouteCalled)
        XCTAssertEqual(routeProvider.getRouteParamDestination, destination)
    }

    func testTrack_error_duplicate_track() {
        ablyService.trackCompletionHandler = { completion in completion?(nil) }
        var expectation = XCTestExpectation()

        // When tracking a trackable
        publisher.track(trackable: trackable,
                        onSuccess: { expectation.fulfill() },
                        onError: { _ in })
        wait(for: [expectation], timeout: 5.0)
        expectation = XCTestExpectation()
        // And tracking it once again
        publisher.track(trackable: Trackable(id: "DuplicateTrackableId"),
                        onSuccess: { XCTAssertTrue(false, "onSuccess callback shouldn't be called") },
                        onError: { error in
                            // It should call onError callback with AssetTrackingError
                            XCTAssertTrue(error is AssetTrackingError)
                            expectation.fulfill()
                        })
        wait(for: [expectation], timeout: 5.0)
    }

    func testTrack_error_ably_service_error() {
        let ablyError = AssetTrackingError.publisherError("Test AblyPublisherService error")
        ablyService.trackCompletionHandler = { completion in completion?(ablyError) }
        let expectation = XCTestExpectation()

        // When tracking a trackable and receive error response from AblyPublisherService
        publisher.track(trackable: trackable,
                        onSuccess: { XCTAssertTrue(false, "onSuccess callback shouldn't be called") },
                        onError: { error in
                            // It should call onError callback with received error
                            XCTAssertEqual(error as? AssetTrackingError, ablyError)
                            expectation.fulfill()
                        })
        wait(for: [expectation], timeout: 5.0)
    }

    func testTrack_thread() {
        ablyService.trackCompletionHandler = { completion in completion?(nil) }

        var expectation = XCTestExpectation()
        // Both `onSuccess` and `onError` callbacks should be called on main thread
        // Notice - in case of failure it will crash whole test suite
        publisher.track(trackable: trackable,
                        onSuccess: {
                            dispatchPrecondition(condition: .onQueue(DispatchQueue.main))
                            expectation.fulfill()
                        },
                        onError: { _ in XCTAssertTrue(false, "onError callback shouldn't be called") })
        wait(for: [expectation], timeout: 5.0)
        
        expectation = XCTestExpectation()
        publisher.track(trackable: trackable,
                        onSuccess: { XCTAssertTrue(false, "onSuccess callback shouldn't be called") },
                        onError: { _ in
                            dispatchPrecondition(condition: .onQueue(DispatchQueue.main))
                            expectation.fulfill()
                        })

        wait(for: [expectation], timeout: 5.0)
    }

    // MARK: add
    func testAdd_success() {
        ablyService.trackCompletionHandler = { completion in completion?(nil) }
        let expectation = XCTestExpectation()

        // When adding a trackable
        publisher.add(trackable: trackable,
                      onSuccess: { expectation.fulfill() },
                      onError: { _ in XCTAssertTrue(false, "onError callback shouldn't be called") })
        wait(for: [expectation], timeout: 5.0)

        // It should NOT set active trackable
        XCTAssertNil(publisher.activeTrackable)

        // It should ask ably service to track given trackable
        XCTAssertTrue(ablyService.trackCalled)
        XCTAssertEqual(ablyService.trackParamTrackable, trackable)

        // It should ask location service to start updating location
        XCTAssertTrue(locationService.startUpdatingLocationCalled)

        // It should notify trackables hook that there is new trackable
        XCTAssertTrue(resolutionPolicyFactory.resolutionPolicy!.trackablesSetListener.onTrackableAddedCalled)
        XCTAssertEqual(resolutionPolicyFactory.resolutionPolicy!.trackablesSetListener.onTrackableAddedParamTrackable, trackable)

        // It should NOT notify trackables hook that there is new active trackable
        XCTAssertFalse(resolutionPolicyFactory.resolutionPolicy!.trackablesSetListener.onActiveTrackableChangedCalled)
    }

    func testAdd_track_success() {
        ablyService.trackCompletionHandler = { completion in completion?(nil) }
        let expectation = XCTestExpectation()
        expectation.expectedFulfillmentCount = 2

        // When tracking a trackable
        publisher.track(trackable: trackable,
                        onSuccess: { expectation.fulfill() },
                        onError: { _ in XCTAssertTrue(false, "onError callback shouldn't be called") })

        // And then adding another trackable
        publisher.add(trackable: Trackable(id: "TestAddedTrackableId1"),
                      onSuccess: { expectation.fulfill() },
                      onError: { _ in XCTAssertTrue(false, "onError callback shouldn't be called") })
        wait(for: [expectation], timeout: 5.0)

        // It should NOT change active trackable
        XCTAssertEqual(publisher.activeTrackable, trackable)
    }

    func testAdd_track_error() {
        let ablyError = AssetTrackingError.publisherError("Test AblyPublisherService error")
        ablyService.trackCompletionHandler = { completion in completion?(ablyError) }
        let expectation = XCTestExpectation()

        // When adding a trackable and receive error response from AblyPublisherService
        publisher.add(trackable: trackable,
                      onSuccess: { XCTAssertTrue(false, "onSuccess callback shouldn't be called") },
                      onError: { error in
                        // It should call onError callback with received error
                        XCTAssertEqual(error as? AssetTrackingError, ablyError)
                        expectation.fulfill()
                      })
        wait(for: [expectation], timeout: 5.0)
    }

    func testAdd_success_thread() {
        ablyService.trackCompletionHandler = { completion in completion?(nil) }
        let expectation = XCTestExpectation()
        // `onSuccess` callback should be called on main thread
        // Notice - in case of failure it will crash whole test suite
        publisher.add(trackable: trackable,
                      onSuccess: {
                        dispatchPrecondition(condition: .onQueue(DispatchQueue.main))
                        expectation.fulfill()
                      },
                      onError: { _ in XCTAssertTrue(false, "onError callback shouldn't be called") })
        wait(for: [expectation], timeout: 5.0)
    }

    func testAdd_error_thread() {
        ablyService.trackCompletionHandler = { completion in completion?(AssetTrackingError.publisherError("TestError")) }
        let expectation = XCTestExpectation()

        // `onError` callback should be called on main thread
        // Notice - in case of failure it will crash whole test suite
        publisher.add(trackable: trackable,
                      onSuccess: { XCTAssertTrue(false, "onSuccess callback shouldn't be called") },
                      onError: { _ in
                        dispatchPrecondition(condition: .onQueue(DispatchQueue.main))
                        expectation.fulfill()
                      })
        wait(for: [expectation], timeout: 5.0)
    }

    // MARK: remove
    func testRemove_success() {
        let wasPresent = true
        var receivedWasPresent: Bool?
        ablyService.stopTrackingOnSuccessCompletionHandler = { handler in handler(wasPresent) }
        ablyService.trackablesGetValue = [Trackable(id: "Trackable1"), Trackable(id: "Trackable2")]

        let expectation = XCTestExpectation()

        // When removing trackable
        publisher.remove(trackable: trackable,
                         onSuccess: { present in
                            receivedWasPresent = present
                            expectation.fulfill()
                         },
                         onError: { _ in XCTAssertTrue(false, "onError callback shouldn't be called") })
        wait(for: [expectation], timeout: 5.0)

        // It should ask ablyService to stop tracking
        XCTAssertTrue(ablyService.stopTrackingCalled)

        // It should ask ablyService to stop tracking given trackable
        XCTAssertEqual(ablyService.stopTrackingParamTrackable, trackable)

        // It should return correct `wasPresent` value in callback
        XCTAssertEqual(receivedWasPresent!, wasPresent)

        // It should NOT ask locationService to stop location updates as there are some tracked trackables
        XCTAssertFalse(locationService.stopUpdatingLocationCalled)

        // It should notify trackables hook that trackable was removed (as it was present in AblyService)
        XCTAssertTrue(resolutionPolicyFactory.resolutionPolicy!.trackablesSetListener.onTrackableRemovedCalled)
        XCTAssertEqual(resolutionPolicyFactory.resolutionPolicy!.trackablesSetListener.onTrackableRemovedParamTrackable, trackable)
    }

    func testRemove_activeTrackable() {
        ablyService.trackCompletionHandler = { completion in completion?(nil) }
        ablyService.stopTrackingOnSuccessCompletionHandler = { handler in handler(true) }
        ablyService.trackablesGetValue = []
        var expectation = XCTestExpectation(description: "Handler for `track` call")
        expectation.expectedFulfillmentCount = 1

        // When removing trackable which was tracked before (so it's set as the activeTrackable)
        publisher.track(trackable: trackable,
                        onSuccess: { expectation.fulfill() },
                        onError: { _ in XCTAssertTrue(false, "onError callback shouldn't be called") })
        wait(for: [expectation], timeout: 5.0)
        XCTAssertEqual(publisher.activeTrackable, trackable)

        expectation = XCTestExpectation(description: "Handler for `remove` call")
        publisher.remove(trackable: publisher.activeTrackable!,
                         onSuccess: { _ in expectation.fulfill() },
                         onError: { _ in XCTAssertTrue(false, "onError callback shouldn't be called") })
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
        ablyService.trackCompletionHandler = { completion in completion?(nil) }
        ablyService.stopTrackingOnSuccessCompletionHandler = { handler in handler(true) }

        var expectation = XCTestExpectation(description: "Handler for `track` call")

        // When removing trackable which was no tracked before (so it's NOT set as the activeTrackable)
        publisher.track(trackable: trackable,
                        onSuccess: { expectation.fulfill() },
                        onError: { _ in XCTAssertTrue(false, "onError callback shouldn't be called") })
        wait(for: [expectation], timeout: 5.0)
        XCTAssertEqual(publisher.activeTrackable, trackable)

        expectation = XCTestExpectation(description: "Handler for `remove` call")
        let removedTrackable = Trackable(id: "AnotherTrackableId")
        publisher.remove(trackable: removedTrackable,
                         onSuccess: { _ in expectation.fulfill() },
                         onError: { _ in XCTAssertTrue(false, "onError callback shouldn't be called") })
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
        let error = AssetTrackingError.publisherError("TestError")
        ablyService.stopTrackingOnErrorCompletionHandler = { handler in handler(error) }
        let expectation = XCTestExpectation()

        // When removing trackable and receive error from AblyPublisherService
        publisher.remove(trackable: trackable,
                         onSuccess: { _ in XCTAssertTrue(false, "onSuccess callback shouldn't be called") },
                         onError: { receivedError in
                            // It should call onError callback with received error
                            XCTAssertEqual(receivedError as? AssetTrackingError, error)
                            expectation.fulfill()
                         })
        wait(for: [expectation], timeout: 5.0)
    }


    func testRemove_success_thread() {
        ablyService.stopTrackingOnSuccessCompletionHandler = { handler in handler(true) }
        let expectation = XCTestExpectation()

        // When removing trackable `onSuccess` callback should be called on main thread
        // Notice - in case of failure it will crash whole test suite
        publisher.remove(trackable: trackable,
                         onSuccess: { present in
                            dispatchPrecondition(condition: .onQueue(DispatchQueue.main))
                            expectation.fulfill()
                         },
                         onError: { _ in XCTAssertTrue(false, "onError callback shouldn't be called") })
        wait(for: [expectation], timeout: 5.0)
    }

    func testRemove_error_thread() {
        ablyService.stopTrackingOnErrorCompletionHandler = { handler in handler(AssetTrackingError.publisherError("TestError")) }
        let expectation = XCTestExpectation()

        // When removing trackable `onError` callback should be called on main thread
        // Notice - in case of failure it will crash whole test suite
        publisher.remove(trackable: trackable,
                         onSuccess: { _ in XCTAssertTrue(false, "onSuccess callback shouldn't be called") },
                         onError: { receivedError in
                            dispatchPrecondition(condition: .onQueue(DispatchQueue.main))
                            expectation.fulfill()
                         })
        wait(for: [expectation], timeout: 5.0)
    }
    
    // MARK: stop
    
    // MARK: ChangeRoutingProfile
    func testChangeRoutingProfile_called() {
        // Given: Default RoutingProfile set to .driving
        publisher.changeRoutingProfile(profile: .cycling, onSuccess: {
            XCTAssertTrue(self.routeProvider.changeRoutingProfileCalled)
            XCTAssertEqual(self.routeProvider.changeRoutingProfileParamRoutingProfile, .cycling)
        }, onError: { error in
            XCTAssertTrue(false, "onError callback shouldn't be called")
        })
    }
    
    func testChangeRoutingProfile_shouldCallGetRouteForDestination() {
        // Given: Default destination set to:
        let expectedDestination = CLLocationCoordinate2D(latitude: 3.1415, longitude: 2.7182)
        
        publisher.changeRoutingProfile(profile: .cycling, onSuccess: {
            XCTAssertTrue(self.routeProvider.changeRoutingProfileCalled)
            XCTAssertTrue(self.routeProvider.getRouteCalled)
            XCTAssertEqual(self.routeProvider.getRouteParamDestination, expectedDestination)
        }, onError: { error in
            XCTAssertTrue(false, "onError callback shouldn't be called")
        })
    }
}
