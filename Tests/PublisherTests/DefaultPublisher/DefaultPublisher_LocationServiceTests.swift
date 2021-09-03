import XCTest
import CoreLocation
import AblyAssetTrackingCore
@testable import AblyAssetTrackingPublisher

class DefaultPublisher_LocationServiceTests: XCTestCase {
    var locationService: MockLocationService!
    var ablyService: MockAblyPublisherService!
    var configuration: ConnectionConfiguration!
    var mapboxConfiguration: MapboxConfiguration!
    var resolutionPolicyFactory: MockResolutionPolicyFactory!
    var routeProvider: MockRouteProvider!
    var trackable: Trackable!
    var publisher: DefaultPublisher!
    var delegate: MockPublisherDelegate!
    var waitAsync: WaitAsync!
    var skippedLocationsState: PublisherSkippedLocationsState!
    var trackableState: PublisherTrackableState!

    override func setUpWithError() throws {
        locationService = MockLocationService()
        ablyService = MockAblyPublisherService()
        configuration = ConnectionConfiguration(apiKey: "API_KEY", clientId: "CLIENT_ID")
        mapboxConfiguration = MapboxConfiguration(mapboxKey: "MAPBOX_ACCESS_TOKEN")
        routeProvider = MockRouteProvider()
        resolutionPolicyFactory = MockResolutionPolicyFactory()
        delegate = MockPublisherDelegate()
        waitAsync = WaitAsync()
        trackable = Trackable(
            id: "TrackableId",
            metadata: "TrackableMetadata",
            destination: CLLocationCoordinate2D(latitude: 3.1415, longitude: 2.7182)
        )
        skippedLocationsState = DefaultSkippedLocationsState()
        trackableState = DefaultTrackableState()
        publisher = DefaultPublisher(
            connectionConfiguration:configuration,
            mapboxConfiguration: mapboxConfiguration,
            logConfiguration: LogConfiguration(),
            routingProfile: .driving,
            resolutionPolicyFactory: resolutionPolicyFactory,
            ablyService: ablyService,
            locationService: locationService,
            routeProvider: routeProvider,
            trackableState: trackableState,
            skippedLocationsState: skippedLocationsState
        )
        publisher.delegate = delegate
    }

    func testLocationService_didFailWithError() {
        let errorInformation = ErrorInformation(type: .publisherError(errorMessage: "TestError"))
        let expectation = XCTestExpectation()
        delegate.publisherDidFailWithErrorCallback = { expectation.fulfill() }

        // When receiving error from location service
        publisher.locationService(sender: MockLocationService(), didFailWithError: errorInformation)

        wait(for: [expectation], timeout: 5.0)

        // It should notify delegate
        XCTAssertTrue(delegate.publisherDidFailWithErrorCalled)
        XCTAssertEqual(delegate.publisherDidFailWithErrorParamError, errorInformation)
    }

    func testLocationService_didUpdateEnhancedLocation() {
        let location = CLLocation(latitude: 1.234, longitude: 3.456)
        let locationUpdate = EnhancedLocationUpdate(location: location)
        let expectationAddTrackable = XCTestExpectation()
        let expectationUpdateLocation = XCTestExpectation()

        ablyService.trackCompletionHandler = { completion in completion?(.success(())) }
        publisher.add(trackable: trackable) { _ in expectationAddTrackable.fulfill() }
        wait(for: [expectationAddTrackable], timeout: 5.0)
        
        delegate.publisherDidUpdateEnhancedLocationCallback = { expectationUpdateLocation.fulfill() }

        // When receiving enhanced position update
        publisher.locationService(sender: MockLocationService(), didUpdateEnhancedLocationUpdate: locationUpdate)
        wait(for: [expectationUpdateLocation], timeout: 5.0)

        // It should notify delegate
        XCTAssertTrue(delegate.publisherDidUpdateEnhancedLocationCalled)
        XCTAssertEqual(delegate.publisherDidUpdateEnhancedLocationParamLocation, location)

        // It should send row location update to AblyService
        XCTAssertTrue(ablyService.sendEnhancedAssetLocationUpdateCalled)
        XCTAssertEqual(ablyService.sendEnhancedAssetLocationUpdateParamLocationUpdate?.location, location)
        XCTAssertEqual(ablyService.sendEnhancedAssetLocationUpdateParamTrackable, trackable)
    }

    func testLocationService_didUpdateEnhancedLocation_resolution() {
        // Distance from location1 to location to is about 23.7 meters, and from location1 to location3 about 609.9 meters
        let location1 = CLLocation(latitude: 51.50084974160386, longitude: -0.12460883599692132)
        let location2 = CLLocation(latitude: 51.50106028620921, longitude: -0.12455871010105721)
        let location3 = CLLocation(latitude: 51.50076810088975, longitude: -0.11582583421022277)

        var expectation = XCTestExpectation()
        publisher.add(trackable: trackable) { _ in } 
        delegate.publisherDidUpdateEnhancedLocationCallback = { expectation.fulfill() }
        resolutionPolicyFactory.resolutionPolicy?.resolveRequestReturnValue = Resolution(accuracy: .balanced,
                                                                                         desiredInterval: 500,
                                                                                         minimumDisplacement: 500)
        
        // After tracking trackable (to trigger resolution resolve refresh)
        ablyService.trackCompletionHandler = { callback in
            callback?(.success)
            expectation.fulfill()
        }
        publisher.track(trackable: trackable) { _ in }

        wait(for: [expectation], timeout: 5.0)
        expectation = XCTestExpectation()
        XCTAssertTrue(resolutionPolicyFactory.resolutionPolicy!.resolveResolutionsCalled)

        // When receiving enhanced position update for the first time
        publisher.locationService(sender: MockLocationService(), didUpdateEnhancedLocationUpdate: EnhancedLocationUpdate(location: location1))
        wait(for: [expectation], timeout: 5.0)

        // It should send row location update to AblyService
        XCTAssertTrue(ablyService.sendEnhancedAssetLocationUpdateCalled)

        ablyService.sendEnhancedAssetLocationUpdateCalled = false
        ablyService.sendEnhancedAssetLocationUpdateParamTrackable = nil
        ablyService.sendEnhancedAssetLocationUpdateParamLocationUpdate = nil
        ablyService.sendEnhancedAssetLocationUpdateParamCompletion = nil
        expectation = XCTestExpectation()

        // When receiving enhanced position update, and distance is lower than threshold in resolution
        publisher.locationService(sender: MockLocationService(), didUpdateEnhancedLocationUpdate: EnhancedLocationUpdate(location: location2))
        wait(for: [expectation], timeout: 5.0)

        // It should NOT send enhanced location update to AblyService
        XCTAssertFalse(ablyService.sendEnhancedAssetLocationUpdateCalled)

        ablyService.sendEnhancedAssetLocationUpdateCalled = false
        ablyService.sendEnhancedAssetLocationUpdateParamTrackable = nil
        ablyService.sendEnhancedAssetLocationUpdateParamLocationUpdate = nil
        ablyService.sendEnhancedAssetLocationUpdateParamCompletion = nil
        expectation = XCTestExpectation()

        // When receiving enhanced position update, and distance is higher than threshold in resolution
        publisher.locationService(sender: MockLocationService(), didUpdateEnhancedLocationUpdate: EnhancedLocationUpdate(location: location3))
        wait(for: [expectation], timeout: 5.0)

        // It should send enhanced location update to AblyService
        XCTAssertTrue(ablyService.sendEnhancedAssetLocationUpdateCalled)
    }
    
    func testPublisherWillRetryOnFailureOnSendEnhancedLocationUpdate() {
        /**
         Test that publisher will try to re-send enhanced location update on failure.
         Re-sending is limited to `PublisherTrackableState.Constants.maxRetryCount` per `trackableId`
         Retry counter is reset on `success`
         */
        let publisherHelper = PublisherHelper()
        let location = CLLocation(latitude: 1, longitude: 1)
        let locationUpdate = EnhancedLocationUpdate(location: location)
        let trackable = Trackable(id: "Trackable_1")
        
        publisherHelper.sendLocationUpdate(
            ablyService: ablyService,
            publisher: publisher,
            locationUpdate: locationUpdate,
            trackable: trackable,
            trackableState: trackableState,
            resultPolicy: .retry
        )
                
        /**
         It means that failed request (counter 1) was retried (counter 2)
         */
        XCTAssertEqual(self.ablyService.sendEnhancedAssetLocationUpdateCounter, 2)
        
    }
    
    func testPublisherWillAttachSkippedLocationsToNextRequest() {
        let publisherHelper = PublisherHelper()
        let initialLocation = CLLocation(latitude: 1, longitude: 1)
        var locationUpdate = EnhancedLocationUpdate(location: initialLocation)
        let trackable = Trackable(id: "Trackable_2")
        
        let publisherDidFailExpectation = XCTestExpectation(description: "Publisher did fail expectation")
        delegate.publisherDidFailWithErrorCallback = {
            publisherDidFailExpectation.fulfill()
        }
        
        publisherHelper.sendLocationUpdate(
            ablyService: ablyService,
            publisher: publisher,
            locationUpdate: locationUpdate,
            trackable: trackable,
            trackableState: trackableState,
            resultPolicy: .fail
        )
                
        wait(for: [publisherDidFailExpectation], timeout: 10.0)
        
        XCTAssertGreaterThan(self.skippedLocationsState.list(for: trackable.id).count, .zero, "Skipped locations state should has at least 1 skipped location")
        
        let newLocation = CLLocation(latitude: 1.1, longitude: 1.1)
        locationUpdate = EnhancedLocationUpdate(location: newLocation)
        
        publisherHelper.sendLocationUpdate(
            ablyService: ablyService,
            publisher: publisher,
            locationUpdate: locationUpdate,
            trackable: trackable,
            trackableState: trackableState,
            resultPolicy: .success
        )
                
        if let sentLocationUpdate =  ablyService.sendEnhancedAssetLocationUpdateParamLocationUpdate {
            XCTAssertTrue(sentLocationUpdate.skippedLocations.contains(initialLocation))
        } else {
            XCTFail("sendEnhancedAssetLocationUpdateParamLocationUpdate is nil")
        }
    }
}
