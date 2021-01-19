import XCTest
import CoreLocation
@testable import Publisher

class DefaultPublisher_LocationServiceTests: XCTestCase {
    var locationService: MockLocationService!
    var ablyService: MockAblyPublisherService!
    var configuration: ConnectionConfiguration!
    var resolutionPolicyFactory: MockResolutionPolicyFactory!
    var trackable: Trackable!
    var publisher: DefaultPublisher!
    var delegate: MockPublisherDelegate!

    override func setUpWithError() throws {
        locationService = MockLocationService()
        ablyService = MockAblyPublisherService()
        configuration = ConnectionConfiguration(apiKey: "API_KEY", clientId: "CLIENT_ID")
        resolutionPolicyFactory = MockResolutionPolicyFactory()
        delegate = MockPublisherDelegate()
        trackable = Trackable(id: "TrackableId",
                              metadata: "TrackableMetadata",
                              destination: CLLocationCoordinate2D(latitude: 3.1415, longitude: 2.7182))
        publisher = DefaultPublisher(connectionConfiguration: configuration,
                                     logConfiguration: LogConfiguration(),
                                     transportationMode: TransportationMode(),
                                     resolutionPolicyFactory: resolutionPolicyFactory,
                                     ablyService: ablyService,
                                     locationService: locationService)
        publisher.delegate = delegate
    }

    func testLocationService_didFailWithError() {
        let error = AssetTrackingError.publisherError("TestError")
        let expectation = XCTestExpectation()
        delegate.publisherDidFailWithErrorCallback = { expectation.fulfill() }

        // When receiving error from location service
        publisher.locationService(sender: MockLocationService(), didFailWithError: error)

        wait(for: [expectation], timeout: 5.0)

        // It should notify delegate
        XCTAssertTrue(delegate.publisherDidFailWithErrorCalled)
        XCTAssertEqual( delegate.publisherDidFailWithErrorParamError as? AssetTrackingError, error)
    }

    func testLocationService_didUpdateRawLocation() {
        let location = CLLocation(latitude: 1.234, longitude: 3.456)
        let expectation = XCTestExpectation()

        ablyService.trackablesGetValue = [trackable]
        delegate.publisherDidUpdateRawLocationCallback = { expectation.fulfill() }

        // When receiving raw position update
        publisher.locationService(sender: MockLocationService(), didUpdateRawLocation: location)
        wait(for: [expectation], timeout: 5.0)

        // It should notify delegate
        XCTAssertTrue(delegate.publisherDidUpdateRawLocationCalled)
        XCTAssertEqual(delegate.publisherDidUpdateRawLocationParamLocation, location)

        // It should send row location update to AblyService
        XCTAssertTrue(ablyService.sendRawAssetLocationCalled)
        XCTAssertEqual(ablyService.sendRawAssetLocationParamLocation, location)
        XCTAssertEqual(ablyService.sendRawAssetLocationParamTrackable, trackable)
    }

    func testLocationService_didUpdateEnhancedLocation() {
        let location = CLLocation(latitude: 1.234, longitude: 3.456)
        let expectation = XCTestExpectation()

        ablyService.trackablesGetValue = [trackable]
        delegate.publisherDidUpdateEnhancedLocationCallback = { expectation.fulfill() }

        // When receiving enhanced position update
        publisher.locationService(sender: MockLocationService(), didUpdateEnhancedLocation: location)
        wait(for: [expectation], timeout: 5.0)

        // It should notify delegate
        XCTAssertTrue(delegate.publisherDidUpdateEnhancedLocationCalled)
        XCTAssertEqual(delegate.publisherDidUpdateEnhancedLocationParamLocation, location)

        // It should send row location update to AblyService
        XCTAssertTrue(ablyService.sendEnhancedAssetLocationCalled)
        XCTAssertEqual(ablyService.sendEnhancedAssetLocationParamLocation, location)
        XCTAssertEqual(ablyService.sendEnhancedAssetLocationParamTrackable, trackable)
    }

    func testLocationService_didUpdateRawLocation_resolution() {
        // Distance from location1 to location to is about 23.7 meters, and from location1 to location3 about 609.9 meters
        let location1 = CLLocation(latitude: 51.50084974160386, longitude: -0.12460883599692132)
        let location2 = CLLocation(latitude: 51.50106028620921, longitude: -0.12455871010105721)
        let location3 = CLLocation(latitude: 51.50076810088975, longitude: -0.11582583421022277)

        var expectation = XCTestExpectation()
        ablyService.trackablesGetValue = [trackable]
        delegate.publisherDidUpdateRawLocationCallback = { expectation.fulfill() }
        resolutionPolicyFactory.resolutionPolicy?.resolveRequestReturnValue = Resolution(accuracy: .balanced,
                                                                                         desiredInterval: 500,
                                                                                         minimumDisplacement: 500)
        // After tracking trackable (to trigger resolution resolve refresh)
        ablyService.trackCompletionHandler = { callback in
            callback?(nil)
            expectation.fulfill()
        }
        publisher.track(trackable: trackable, onSuccess: { }, onError: { _ in })

        // When receiving raw position update for the first time
        publisher.locationService(sender: MockLocationService(), didUpdateRawLocation: location1)
        wait(for: [expectation], timeout: 5.0)

        // It should send raw location update to AblyService
        XCTAssertTrue(ablyService.sendRawAssetLocationCalled)

        ablyService.sendRawAssetLocationCalled = false
        ablyService.sendRawAssetLocationParamTrackable = nil
        ablyService.sendRawAssetLocationParamLocation = nil
        ablyService.sendRawAssetLocationParamCompletion = nil
        expectation = XCTestExpectation()

        // When receiving raw position update, and distance is lower than threshold in resolution
        publisher.locationService(sender: MockLocationService(), didUpdateRawLocation: location2)
        wait(for: [expectation], timeout: 5.0)

        // It should NOT send raw location update to AblyService
        XCTAssertFalse(ablyService.sendRawAssetLocationCalled)

        ablyService.sendRawAssetLocationCalled = false
        ablyService.sendRawAssetLocationParamTrackable = nil
        ablyService.sendRawAssetLocationParamLocation = nil
        ablyService.sendRawAssetLocationParamCompletion = nil
        expectation = XCTestExpectation()

        // When receiving raw position update, and distance is higher than threshold in resolution
        publisher.locationService(sender: MockLocationService(), didUpdateRawLocation: location3)
        wait(for: [expectation], timeout: 5.0)

        // It should send raw location update to AblyService
        XCTAssertTrue(ablyService.sendRawAssetLocationCalled)
    }

    func testLocationService_didUpdateEnhancedLocation_resolution() {
        // Distance from location1 to location to is about 23.7 meters, and from location1 to location3 about 609.9 meters
        let location1 = CLLocation(latitude: 51.50084974160386, longitude: -0.12460883599692132)
        let location2 = CLLocation(latitude: 51.50106028620921, longitude: -0.12455871010105721)
        let location3 = CLLocation(latitude: 51.50076810088975, longitude: -0.11582583421022277)

        var expectation = XCTestExpectation()
        ablyService.trackablesGetValue = [trackable]
        delegate.publisherDidUpdateEnhancedLocationCallback = { expectation.fulfill() }
        resolutionPolicyFactory.resolutionPolicy?.resolveRequestReturnValue = Resolution(accuracy: .balanced,
                                                                                         desiredInterval: 500,
                                                                                         minimumDisplacement: 500)
        
        // After tracking trackable (to trigger resolution resolve refresh)
        ablyService.trackCompletionHandler = { callback in
            callback?(nil)
            expectation.fulfill()
        }
        publisher.track(trackable: trackable, onSuccess: { }, onError: { _ in })

        wait(for: [expectation], timeout: 5.0)
        expectation = XCTestExpectation()
        XCTAssertTrue(resolutionPolicyFactory.resolutionPolicy!.resolveResolutionsCalled)

        // When receiving enhanced position update for the first time
        publisher.locationService(sender: MockLocationService(), didUpdateEnhancedLocation: location1)
        wait(for: [expectation], timeout: 5.0)

        // It should send row location update to AblyService
        XCTAssertTrue(ablyService.sendEnhancedAssetLocationCalled)

        ablyService.sendEnhancedAssetLocationCalled = false
        ablyService.sendEnhancedAssetLocationParamTrackable = nil
        ablyService.sendEnhancedAssetLocationParamLocation = nil
        ablyService.sendEnhancedAssetLocationParamCompletion = nil
        expectation = XCTestExpectation()

        // When receiving enhanced position update, and distance is lower than threshold in resolution
        publisher.locationService(sender: MockLocationService(), didUpdateEnhancedLocation: location2)
        wait(for: [expectation], timeout: 5.0)

        // It should NOT send enhanced location update to AblyService
        XCTAssertFalse(ablyService.sendEnhancedAssetLocationCalled)

        ablyService.sendEnhancedAssetLocationCalled = false
        ablyService.sendEnhancedAssetLocationParamTrackable = nil
        ablyService.sendEnhancedAssetLocationParamLocation = nil
        ablyService.sendEnhancedAssetLocationParamCompletion = nil
        expectation = XCTestExpectation()

        // When receiving enhanced position update, and distance is higher than threshold in resolution
        publisher.locationService(sender: MockLocationService(), didUpdateEnhancedLocation: location3)
        wait(for: [expectation], timeout: 5.0)

        // It should send enhanced location update to AblyService
        XCTAssertTrue(ablyService.sendEnhancedAssetLocationCalled)
    }
}
