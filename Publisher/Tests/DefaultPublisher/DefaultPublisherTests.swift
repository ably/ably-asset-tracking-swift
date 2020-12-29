import XCTest
import CoreLocation
import Logging
@testable import Publisher

class DefaultPublisherTests: XCTestCase {
    var locationService: MockLocationService!
    var ablyService: MockAblyPublisherService!
    var configuration: ConnectionConfiguration!
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
        trackable = Trackable(id: "TrackableId",
                              metadata: "TrackableMetadata",
                              destination: CLLocationCoordinate2D(latitude: 3.1415, longitude: 2.7182))
        publisher = DefaultPublisher(connectionConfiguration: configuration,
                                     logConfiguration: LogConfiguration(),
                                     transportationMode: TransportationMode(),
                                     ablyService: ablyService,
                                     locationService: locationService)
    }

    // MARK: track
    func testTrack_success() throws {
        ablyService.trackCompletionHandler = { completion in completion?(nil) }

        let expectation = XCTestExpectation()
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
    }

    func testTrack_error_duplicate_track() {
        ablyService.trackCompletionHandler = { completion in completion?(nil) }

        let expectation = XCTestExpectation()
        publisher.track(trackable: trackable, onSuccess: { }, onError: { _ in })

        publisher.track(trackable: Trackable(id: "DuplicateTrackableId"),
                        onSuccess: { XCTAssertTrue(false, "onSuccess callback shouldn't be called") },
                        onError: { error in
                            XCTAssertTrue(error is AssetTrackingError)
                            expectation.fulfill()
                        })
        wait(for: [expectation], timeout: 5.0)
    }

    func testTrack_error_ably_service_error() {
        let ablyError = AssetTrackingError.publisherError("Test AblyService error")
        ablyService.trackCompletionHandler = { completion in completion?(ablyError) }

        let expectation = XCTestExpectation()
        publisher.track(trackable: trackable,
                        onSuccess: { XCTAssertTrue(false, "onSuccess callback shouldn't be called") },
                        onError: { error in
                            XCTAssertEqual(error as! AssetTrackingError, ablyError)
                            expectation.fulfill()
                        })
        wait(for: [expectation], timeout: 5.0)
    }

    func testTrack_thread() {
        ablyService.trackCompletionHandler = { completion in completion?(nil) }
        let expectation = XCTestExpectation()
        expectation.expectedFulfillmentCount = 2

        // Both `onSuccess` and `onError` callbacks should be called on main thread
        // Notice - in case of failure it will crash whole test suite
        publisher.track(trackable: trackable,
                        onSuccess: {
                            dispatchPrecondition(condition: .onQueue(DispatchQueue.main))
                            expectation.fulfill()
                        },
                        onError: { _ in XCTAssertTrue(false, "onError callback shouldn't be called") })

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
    }

    func testAdd_track_success() {
        ablyService.trackCompletionHandler = { completion in completion?(nil) }

        let expectation = XCTestExpectation()
        expectation.expectedFulfillmentCount = 2

        publisher.track(trackable: trackable,
                        onSuccess: { expectation.fulfill() },
                        onError: { _ in XCTAssertTrue(false, "onError callback shouldn't be called") })

        publisher.add(trackable: Trackable(id: "TestAddedTrackableId1"),
                      onSuccess: { expectation.fulfill() },
                      onError: { _ in XCTAssertTrue(false, "onError callback shouldn't be called") })
        wait(for: [expectation], timeout: 5.0)

        // It should NOT change active trackable
        XCTAssertEqual(publisher.activeTrackable, trackable)
    }

    func testAdd_track_error() {
        let ablyError = AssetTrackingError.publisherError("Test AblyService error")
        ablyService.trackCompletionHandler = { completion in completion?(ablyError) }

        let expectation = XCTestExpectation()
        publisher.add(trackable: trackable,
                      onSuccess: { XCTAssertTrue(false, "onSuccess callback shouldn't be called") },
                      onError: { error in
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
        let wasPresent = false
        var receivedWasPresent: Bool?
        ablyService.stopTrackingOnSuccessCompletionHandler = { handler in handler(wasPresent) }
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
    }

    func testRemove_activeTrackable() {
        ablyService.trackCompletionHandler = { completion in completion?(nil) }
        ablyService.stopTrackingOnSuccessCompletionHandler = { handler in handler(true) }

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
    }

    func testRemove_nonActiveTrackable() {
        ablyService.trackCompletionHandler = { completion in completion?(nil) }
        ablyService.stopTrackingOnSuccessCompletionHandler = { handler in handler(true) }

        var expectation = XCTestExpectation(description: "Handler for `track` call")
        expectation.expectedFulfillmentCount = 1

        // When removing trackable which was no tracked before (so it's NOT set as the activeTrackable)
        publisher.track(trackable: trackable,
                        onSuccess: { expectation.fulfill() },
                        onError: { _ in XCTAssertTrue(false, "onError callback shouldn't be called") })
        wait(for: [expectation], timeout: 5.0)
        XCTAssertEqual(publisher.activeTrackable, trackable)

        expectation = XCTestExpectation(description: "Handler for `remove` call")
        publisher.remove(trackable: Trackable(id: "AnotherTrackableId"),
                         onSuccess: { _ in expectation.fulfill() },
                         onError: { _ in XCTAssertTrue(false, "onError callback shouldn't be called") })
        wait(for: [expectation], timeout: 5.0)

        // It should NOT modify activeTrackable
        XCTAssertEqual(publisher.activeTrackable, trackable)
    }

    // MARK: stop
}
