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
        ablyService.trackCompletionHandler = { completion in
            completion?(nil)
        }

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

    // MARK: add

    // MARK: remove

    // MARK: stop
}
