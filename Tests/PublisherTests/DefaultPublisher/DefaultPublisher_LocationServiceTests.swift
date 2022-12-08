import XCTest
import AblyAssetTrackingCore
import AblyAssetTrackingInternal
@testable import AblyAssetTrackingPublisher
import AblyAssetTrackingCoreTesting
import AblyAssetTrackingInternalTesting

class DefaultPublisher_LocationServiceTests: XCTestCase {
    let publisherHelper = PublisherHelper()
    
    var locationService: MockLocationService!
    var ablyPublisher: MockAblyPublisher!
    var configuration: ConnectionConfiguration!
    var mapboxConfiguration: MapboxConfiguration!
    var resolutionPolicyFactory: MockResolutionPolicyFactory!
    var routeProvider: MockRouteProvider!
    var trackable: Trackable!
    var publisher: DefaultPublisher!
    var delegate: MockPublisherDelegate!
    var waitAsync: WaitAsync!
    var enhancedLocationState: TrackableState<EnhancedLocationUpdate>!
    var rawLocationState: TrackableState<RawLocationUpdate>!
    var logger: MockLogHandler!
    
    override func setUpWithError() throws {
        locationService = MockLocationService()
        configuration = ConnectionConfiguration(apiKey: "API_KEY", clientId: "CLIENT_ID")
        ablyPublisher = MockAblyPublisher(configuration: configuration, mode: .publish)
        mapboxConfiguration = MapboxConfiguration(mapboxKey: "MAPBOX_ACCESS_TOKEN")
        routeProvider = MockRouteProvider()
        resolutionPolicyFactory = MockResolutionPolicyFactory()
        delegate = MockPublisherDelegate()
        waitAsync = WaitAsync()
        enhancedLocationState = TrackableState<EnhancedLocationUpdate>()
        rawLocationState = TrackableState<RawLocationUpdate>()
        logger = MockLogHandler()
        
        trackable = Trackable(
            id: "TrackableId",
            metadata: "TrackableMetadata",
            destination: LocationCoordinate(latitude: 3.1415, longitude: 2.7182)
        )
        
        publisher = DefaultPublisher(
            connectionConfiguration:configuration,
            mapboxConfiguration: mapboxConfiguration,
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
    
    func testLocationService_didFailWithError() throws {
        let errorInformation = ErrorInformation(type: .publisherError(errorMessage: "TestError"))
        let expectation = XCTestExpectation()
        delegate.publisherDidFailWithErrorCallback = { expectation.fulfill() }
        
        // When receiving error from location service
        publisher.locationService(sender: MockLocationService(), didFailWithError: errorInformation)
        
        wait(for: [expectation], timeout: 5.0)
        
        // It should notify delegate
        XCTAssertTrue(delegate.publisherDidFailWithErrorCalled)
        let publisherDidFailWithErrorParamError = try XCTUnwrap(delegate.publisherDidFailWithErrorParamError)
        XCTAssertTrue(publisherDidFailWithErrorParamError.isEqual(to: errorInformation))
    }
    
    func testLocationService_didUpdateEnhancedLocation() {
        let location = Location(coordinate: LocationCoordinate(latitude: 1.234, longitude: 3.45))
        let locationUpdate = EnhancedLocationUpdate(location: location)
        let expectationAddTrackable = XCTestExpectation()
        let expectationUpdateLocation = XCTestExpectation()
        
        ablyPublisher.connectCompletionHandler = { completion in  completion?(.success) }
        
        publisher.add(trackable: trackable) { _ in expectationAddTrackable.fulfill() }
        wait(for: [expectationAddTrackable], timeout: 5.0)
        
        delegate.publisherDidUpdateEnhancedLocationCallback = { expectationUpdateLocation.fulfill() }
        
        // When receiving enhanced position update
        publisher.locationService(sender: MockLocationService(), didUpdateEnhancedLocationUpdate: locationUpdate)
        wait(for: [expectationUpdateLocation], timeout: 5.0)
        
        // It should notify delegate
        XCTAssertTrue(delegate.publisherDidUpdateEnhancedLocationCalled)
        XCTAssertEqual(delegate.publisherDidUpdateEnhancedLocationParamLocation?.location, location)
        
        // It should send row location update to ablyPublisher
        XCTAssertTrue(ablyPublisher.sendEnhancedAssetLocationUpdateCalled)
        XCTAssertEqual(ablyPublisher.sendEnhancedAssetLocationUpdateParamLocationUpdate?.location, location)
        XCTAssertEqual(ablyPublisher.sendEnhancedAssetLocationUpdateParamTrackable, trackable)
    }
    
    func testLocationService_didUpdateEnhancedLocation_resolution() {
        /**
         Distance from location1 to location2 to is about 23.7 meters, and from location1 to location3 about 609.9 meters
         */
        let location1 = Location(coordinate: LocationCoordinate(latitude: 51.50084974160386, longitude: -0.12460883599692132))
        let location2 = Location(coordinate: LocationCoordinate(latitude: 51.50106028620921, longitude: -0.12455871010105721))
        let location3 = Location(coordinate: LocationCoordinate(latitude: 51.50076810088975, longitude: -0.11582583421022277))
        
        var unmarkMessageAsPendingDidCallExpectation = XCTestExpectation(description: "Trackable Unmark Message As Pending Did Call Expectation")
        
        var expectation = XCTestExpectation()
        publisher.add(trackable: trackable) { _ in }
        delegate.publisherDidUpdateEnhancedLocationCallback = { expectation.fulfill() }
        resolutionPolicyFactory.resolutionPolicy?.resolveRequestReturnValue = Resolution(accuracy: .balanced,
                                                                                         desiredInterval: 500,
                                                                                         minimumDisplacement: 500)
        
        /**
         After tracking trackable (to trigger resolution resolve refresh)
         */
        ablyPublisher.connectCompletionHandler = { callback in
            callback?(.success)
            expectation.fulfill()
        }
        
        ablyPublisher.sendEnhancedAssetLocationUpdateParamCompletionHandler = { completion in
            completion?(.success)
        }
        
        publisher.track(trackable: trackable) { _ in }
        
        wait(for: [expectation], timeout: 5.0)
        expectation = XCTestExpectation()
        XCTAssertTrue(resolutionPolicyFactory.resolutionPolicy!.resolveResolutionsCalled)
        
        /**
         When receiving enhanced position update for the first time
         */
        publisher.locationService(sender: MockLocationService(), didUpdateEnhancedLocationUpdate: EnhancedLocationUpdate(location: location1))
        _ = XCTWaiter.wait(for: [expectation, unmarkMessageAsPendingDidCallExpectation], timeout: 1.0)
        
        /**
         It should send row location update to ablyPublisher
         */
        XCTAssertTrue(ablyPublisher.sendEnhancedAssetLocationUpdateCalled)
        
        ablyPublisher.sendEnhancedAssetLocationUpdateCalled = false
        ablyPublisher.sendEnhancedAssetLocationUpdateParamTrackable = nil
        ablyPublisher.sendEnhancedAssetLocationUpdateParamLocationUpdate = nil
        ablyPublisher.sendEnhancedAssetLocationUpdateParamCompletion = nil
        expectation = XCTestExpectation()
        
        /**
         When receiving enhanced position update, and distance is lower than threshold in resolution
         */
        publisher.locationService(sender: MockLocationService(), didUpdateEnhancedLocationUpdate: EnhancedLocationUpdate(location: location2))
        
        /**
         Resolution will discard this locartion update because distance between last location and current one is smaller than `minimumDisplacement: 500`
         which means that `success` callback will never be called. This is  the reason why `unmarkMessageAsPendingDidCallExpectation` is NOT in expectations array below.
         */
        wait(for: [expectation], timeout: 2.0)
        
        /**
         It should NOT send enhanced location update to ablyPublisher because distance between location1 and location2 is to small
         */
        XCTAssertFalse(ablyPublisher.sendEnhancedAssetLocationUpdateCalled)
        
        ablyPublisher.sendEnhancedAssetLocationUpdateCalled = false
        ablyPublisher.sendEnhancedAssetLocationUpdateParamTrackable = nil
        ablyPublisher.sendEnhancedAssetLocationUpdateParamLocationUpdate = nil
        ablyPublisher.sendEnhancedAssetLocationUpdateParamCompletion = nil
        expectation = XCTestExpectation()
        unmarkMessageAsPendingDidCallExpectation = XCTestExpectation(description: "Trackable Unmark Message As Pending Did Call Expectation")
        
        /**
         When receiving enhanced position update, and distance is higher than threshold in resolution
         */
        publisher.locationService(sender: MockLocationService(), didUpdateEnhancedLocationUpdate: EnhancedLocationUpdate(location: location3))
        _ = XCTWaiter.wait(for: [expectation, unmarkMessageAsPendingDidCallExpectation], timeout: 1.0)
        
        /**
         It should send enhanced location update to ablyPublisher
         */
        XCTAssertTrue(ablyPublisher.sendEnhancedAssetLocationUpdateCalled)
    }
    
    func testPublisherWillRetryOnFailureOnSendEnhancedLocationUpdate() {
        /**
         Test that publisher will try to re-send enhanced location update on failure.
         Re-sending is limited to `PublisherTrackableState.Constants.maxRetryCount` per `trackableId`
         Retry counter is reset on `success`
         */
        let location = Location(coordinate: LocationCoordinate(latitude: 1, longitude: 1))
        let locationUpdate = EnhancedLocationUpdate(location: location)
        let trackable = Trackable(id: "Trackable_1")
        let trackableState = TrackableState<EnhancedLocationUpdate>()
        let ablyPublisher = MockAblyPublisher(configuration: configuration, mode: .publish)
        let publisher = PublisherHelper.createPublisher(ablyPublisher: ablyPublisher)
        
        ablyPublisher.connectCompletionHandler = { completion in  completion?(.success) }
        
        publisherHelper.sendLocationUpdate(
            ablyPublisher: ablyPublisher,
            publisher: publisher,
            locationUpdate: locationUpdate,
            trackable: trackable,
            enhancedLocationState: trackableState,
            resultPolicy: .retry
        )
        
        /**
         It means that failed request (counter 1) was retried (counter 2)
         */
        XCTAssertEqual(ablyPublisher.sendEnhancedAssetLocationUpdateCounter, 2)
        
    }
    
    func testPublisherWillAttachSkippedLocationsToNextRequest() {
        let initialLocation = Location(coordinate: LocationCoordinate(latitude: 1, longitude: 1))
        var locationUpdate = EnhancedLocationUpdate(location: initialLocation)
        let trackable = Trackable(id: "Trackable_2")
        let enhancedLocationState = TrackableState<EnhancedLocationUpdate>()
        let ablyPublisher = MockAblyPublisher(configuration: configuration, mode: .publish)
        let delegate = MockPublisherDelegate()
        let publisher = PublisherHelper.createPublisher(
            ablyPublisher: ablyPublisher,
            enhancedLocationState: enhancedLocationState
        )
        publisher.delegate = delegate
        
        let publisherDidFailExpectation = XCTestExpectation(description: "Publisher did fail expectation")
        delegate.publisherDidFailWithErrorCallback = {
            publisherDidFailExpectation.fulfill()
        }
        
        ablyPublisher.connectCompletionHandler = { completion in  completion?(.success) }
        
        publisherHelper.sendLocationUpdate(
            ablyPublisher: ablyPublisher,
            publisher: publisher,
            locationUpdate: locationUpdate,
            trackable: trackable,
            enhancedLocationState: enhancedLocationState,
            resultPolicy: .fail
        )
        
        wait(for: [publisherDidFailExpectation], timeout: 10.0)
        
        XCTAssertGreaterThan(enhancedLocationState.locationsList(for: trackable.id).count, .zero, "Skipped locations state should has at least 1 skipped location")
        
        let newLocation = Location(coordinate: LocationCoordinate(latitude: 1.1, longitude: 1.1))
        locationUpdate = EnhancedLocationUpdate(location: newLocation)
        
        publisherHelper.sendLocationUpdate(
            ablyPublisher: ablyPublisher,
            publisher: publisher,
            locationUpdate: locationUpdate,
            trackable: trackable,
            enhancedLocationState: enhancedLocationState,
            resultPolicy: .success
        )
        
        if let sentLocationUpdate =  ablyPublisher.sendEnhancedAssetLocationUpdateParamLocationUpdate {
            XCTAssertTrue(sentLocationUpdate.skippedLocations.contains(initialLocation))
        } else {
            XCTFail("sendEnhancedAssetLocationUpdateParamLocationUpdate is nil")
        }
    }
    
    func testPublisherSendEnhancedLocationWillAddToWaitingQueuePendingMessage() {
        let initialLocation = Location(coordinate: LocationCoordinate(latitude: 1, longitude: 1))
        let locationUpdate = EnhancedLocationUpdate(location: initialLocation)
        let nextLocation = Location(coordinate: LocationCoordinate(latitude: 2, longitude: 2))
        let nextLocationUpdate = EnhancedLocationUpdate(location: nextLocation)
        let trackable = Trackable(id: "Trackable_2")
        let ablyPublisher = MockAblyPublisher(configuration: configuration, mode: .publish)
        let locationService = MockLocationService()
        let resolutionPolicyFactory = MockResolutionPolicyFactory()
        let publisher = PublisherHelper.createPublisher(
            ablyPublisher: ablyPublisher,
            locationService: locationService
        )
        
        resolutionPolicyFactory.resolutionPolicy?.resolveResolutionsReturnValue = .init(accuracy: .balanced, desiredInterval: 0, minimumDisplacement: 0)
        
        let connectCompletionHandlerExpectation = XCTestExpectation(description: "Track completion handler expectation")
        ablyPublisher.connectCompletionHandler = { callback in
            callback?(.success)
            connectCompletionHandlerExpectation.fulfill()
        }
        publisher.track(trackable: trackable) { _ in }
        wait(for: [connectCompletionHandlerExpectation], timeout: 5.0)
        
        
        let sendLocationCompleteExpectation = XCTestExpectation(description: "Send Location Complete Expectation")
        ablyPublisher.sendEnhancedAssetLocationUpdateParamCompletionHandler = { completion in
            if ablyPublisher.sendEnhancedAssetLocationUpdateCounter == 2 {
                XCTAssertEqual(ablyPublisher.sendEnhancedAssetLocationUpdateParamLocationUpdate, nextLocationUpdate)
                sendLocationCompleteExpectation.fulfill()
            } else {
                XCTAssertEqual(ablyPublisher.sendEnhancedAssetLocationUpdateParamLocationUpdate, locationUpdate)
                completion?(.success)
            }
        }
        
        /**
         Send the same trackable `2` times in row
         */
        publisher.locationService(sender: locationService, didUpdateEnhancedLocationUpdate: locationUpdate)
        publisher.locationService(sender: locationService, didUpdateEnhancedLocationUpdate: nextLocationUpdate)
        
        /**
         Wait for `sendEnhancedAssetLocationUpdateParamCompletionHandler` called `2` times
         */
        wait(for: [sendLocationCompleteExpectation], timeout: 10.0)
    }
    
    func testShouldSendRawMessageIfTheyAreEnabled() {
        ablyPublisher.connectCompletionHandler = { completion in  completion?(.success) }
        
        let publisher = DefaultPublisher(
            connectionConfiguration: configuration,
            mapboxConfiguration: mapboxConfiguration,
            routingProfile: .driving,
            resolutionPolicyFactory: resolutionPolicyFactory,
            ablyPublisher: ablyPublisher,
            locationService: locationService,
            routeProvider: routeProvider,
            areRawLocationsEnabled: true,
            logHandler: logger
        )
        
        let expectationAddTrackable = self.expectation(description: "Add Trackable Expectation")
        publisher.add(trackable: trackable) { _ in expectationAddTrackable.fulfill() }
        
        wait(for: [expectationAddTrackable], timeout: 5.0)
        
        let location = Location(coordinate: LocationCoordinate(latitude: 1, longitude: 2))
        let expectationDidUpdateRawLocation = self.expectation(description: "Did Update Raw Location Expectation")
        
        ablyPublisher.sendRawLocationParamCompletionHandler = { completion in
            completion?(.success)
            expectationDidUpdateRawLocation.fulfill()
        }
        
        publisher.locationService(
            sender: MockLocationService(),
            didUpdateRawLocationUpdate: RawLocationUpdate(location: location)
        )
        wait(for: [expectationDidUpdateRawLocation], timeout: 5.0)
        
        XCTAssertTrue(ablyPublisher.sendRawLocationWasCalled)
    }
    
    func testShouldNotSendRawMessageIfTheyAreDisabled() {
        ablyPublisher.connectCompletionHandler = { completion in  completion?(.success) }
        
        let publisher = DefaultPublisher(
            connectionConfiguration: configuration,
            mapboxConfiguration: mapboxConfiguration,
            routingProfile: .driving,
            resolutionPolicyFactory: resolutionPolicyFactory,
            ablyPublisher: ablyPublisher,
            locationService: locationService,
            routeProvider: routeProvider,
            areRawLocationsEnabled: false,
            logHandler: logger
        )
        
        let expectationAddTrackable = self.expectation(description: "Add Trackable Expectation")
        publisher.add(trackable: trackable) { _ in expectationAddTrackable.fulfill() }
        
        wait(for: [expectationAddTrackable], timeout: 5.0)
        
        let location = Location(coordinate: LocationCoordinate(latitude: 1, longitude: 2))
        let expectationDidUpdateRawLocation = self.expectation(description: "Did Update Raw Location Expectation")
        expectationDidUpdateRawLocation.isInverted = true
        
        ablyPublisher.sendRawLocationParamCompletionHandler = { completion in
            completion?(.success)
            expectationDidUpdateRawLocation.fulfill()
        }
        
        publisher.locationService(
            sender: MockLocationService(),
            didUpdateRawLocationUpdate: RawLocationUpdate(location: location)
        )
        wait(for: [expectationDidUpdateRawLocation], timeout: 5.0)
        
        XCTAssertFalse(ablyPublisher.sendRawLocationWasCalled)
    }
    
    func test_addFirstTrackable_callsStartRecordingLocationOnLocationService() {
        ablyPublisher.connectCompletionHandler = { completion in completion?(.success) }
        
        let addTrackableExpectation = expectation(description: "Trackable added successfully")
        publisher.add(trackable: trackable) { result in
            switch result {
            case .success:
                addTrackableExpectation.fulfill()
            case .failure(let error):
                XCTFail("Failed to add trackable: \(error)")
            }
        }
        
        waitForExpectations(timeout: 10)
        
        XCTAssertTrue(locationService.startRecordingLocationCalled)
    }
    
    func test_addSecondTrackable_doesNotCallStartRecordingLocationOnLocationService() {
        ablyPublisher.connectCompletionHandler = { completion in completion?(.success) }
        
        let addFirstTrackableExpectation = expectation(description: "First trackable added successfully")
        publisher.add(trackable: trackable) { result in
            switch result {
            case .success:
                addFirstTrackableExpectation.fulfill()
            case .failure(let error):
                XCTFail("Failed to add first trackable: \(error)")
            }
        }
        
        waitForExpectations(timeout: 10)
        
        locationService.startRecordingLocationCalled = false
        
        let secondTrackable = Trackable(id: UUID().uuidString)
        let addSecondTrackableExpectation = self.expectation(description: "Second trackable added successfully")
        publisher.add(trackable: secondTrackable) { result in
            switch result {
            case .success:
                addSecondTrackableExpectation.fulfill()
            case .failure(let error):
                XCTFail("Failed to add second trackable: \(error)")
            }
        }
        
        waitForExpectations(timeout: 10)
        
        XCTAssertFalse(locationService.startRecordingLocationCalled)
    }
    
    func test_stop_callsStopRecordingLocationOnLocationService_andWhenThatReturnsALocationRecordingResult_itCallsDidFinishRecordingLocationHistoryDataOnDelegate_andCallsDidFinishRecordingRawMapboxDataOnDelegate_andSuccessfullyStops() {
        ablyPublisher.closeResultCompletionHandler = { completion in
            completion?(.success)
        }
        locationService.stopRecordingLocationCallback = { completion in
            let fileManager = FileManager.default
            let temporaryDirectoryURL = fileManager.temporaryDirectory
            let fileURL = temporaryDirectoryURL.appendingPathComponent(UUID().uuidString)
            do {
                try Data().write(to: fileURL)
            } catch {
                XCTFail("Failed to write temporary file: \(error)")
            }
            
            let recordingResult = LocationRecordingResult(
                locationHistoryData: LocationHistoryData(events: []),
                rawHistoryFile: TemporaryFile(fileURL: fileURL, logHandler: nil)
            )
            
            completion(.success(recordingResult))
        }
        
        let stopExpectation = expectation(description: "Publisher successfully stops")
        publisher.stop { result in
            switch result {
            case .success:
                stopExpectation.fulfill()
            case .failure(let error):
                XCTFail("Failed to stop publisher: \(error)")
            }
        }
        
        waitForExpectations(timeout: 10)
        
        XCTAssertTrue(locationService.stopRecordingLocationCalled)
        XCTAssertTrue(delegate.publisherDidFinishRecordingLocationHistoryDataCalled)
        XCTAssertTrue(delegate.publisherDidFinishRecordingRawMapboxDataToTemporaryFileCalled)
    }
    
    func test_stop_callsStopRecordingLocationOnLocationService_andWhenThatDoesNotReturnALocationRecordingResult_itDoesNotCallDidFinishRecordingLocationHistoryDataOnDelegate_andDoesNotCallDidFinishRecordingRawMapboxDataOnDelegate_butStillSuccessfullyStops() {
        ablyPublisher.closeResultCompletionHandler = { completion in
            completion?(.success)
        }
        locationService.stopRecordingLocationCallback = { completion in
            completion(.success(nil))
        }
        
        let stopExpectation = expectation(description: "Publisher successfully stops")
        publisher.stop { result in
            switch result {
            case .success:
                stopExpectation.fulfill()
            case .failure(let error):
                XCTFail("Failed to stop publisher: \(error)")
            }
        }
        
        waitForExpectations(timeout: 10)
        
        XCTAssertTrue(locationService.stopRecordingLocationCalled)
        XCTAssertFalse(delegate.publisherDidFinishRecordingLocationHistoryDataCalled)
        XCTAssertFalse(delegate.publisherDidFinishRecordingRawMapboxDataToTemporaryFileCalled)
    }
    
    func test_stop_callsStopRecordingLocationOnLocationService_andWhenThatFails_itDoesNotCallDidFinishRecordingLocationHistoryDataOnDelegate_andDoesNotCallDidFinishRecordingRawMapboxDataOnDelegate_butStillSuccessfullyStops() {
        ablyPublisher.closeResultCompletionHandler = { completion in
            completion?(.success)
        }
        locationService.stopRecordingLocationCallback = { completion in
            completion(.failure(.init(type: .commonError(errorMessage: "Example error"))))
        }
        
        let stopExpectation = expectation(description: "Publisher successfully stops")
        publisher.stop { result in
            switch result {
            case .success:
                stopExpectation.fulfill()
            case .failure(let error):
                XCTFail("Failed to stop publisher: \(error)")
            }
        }
        
        waitForExpectations(timeout: 10)
        
        XCTAssertTrue(locationService.stopRecordingLocationCalled)
        XCTAssertFalse(delegate.publisherDidFinishRecordingLocationHistoryDataCalled)
        XCTAssertFalse(delegate.publisherDidFinishRecordingRawMapboxDataToTemporaryFileCalled)
    }
}
