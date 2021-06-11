import XCTest
import CoreLocation
import Logging
@testable import Publisher

enum ClientConfigError : Error {
    case redefinedConnectionConfiguration
}

class DefaultPublisherTests: XCTestCase {
    var locationService: MockLocationService!
    var ablyService: MockAblyPublisherService!
    var configuration: ConnectionConfiguration!
    var mapboxConfiguration: MapboxConfiguration!
    var routeProvider: MockRouteProvider!
    var resolutionPolicyFactory: MockResolutionPolicyFactory!
    var trackable: Trackable!
    var publisher: DefaultPublisher!

    override func setUpWithError() throws {
        LoggingSystem.bootstrap { label -> LogHandler in
            var handler = StreamLogHandler.standardOutput(label: label)
            handler.logLevel = .debug
            return handler
        }
        
        locationService = MockLocationService()
        ablyService = MockAblyPublisherService()
        mapboxConfiguration = MapboxConfiguration(mapboxKey: "MAPBOX_ACCESS_TOKEN")
        resolutionPolicyFactory = MockResolutionPolicyFactory()
        routeProvider = MockRouteProvider()
        trackable = Trackable(id: "TrackableId",
                              metadata: "TrackableMetadata",
                              destination: CLLocationCoordinate2D(latitude: 3.1415, longitude: 2.7182))
    }
    
    override func tearDownWithError() throws {
        configuration = nil
    }
    
    func setUpUsingAPIKeyWithError() throws {
        if (configuration != nil) {
            throw ClientConfigError.redefinedConnectionConfiguration
        }
        configuration = ConnectionConfiguration(apiKey: "API_KEY", clientId: "CLIENT_ID")
        publisher = DefaultPublisher(connectionConfiguration: configuration,
                                     mapboxConfiguration: mapboxConfiguration,
                                     logConfiguration: LogConfiguration(),
                                     routingProfile: .driving,
                                     resolutionPolicyFactory: resolutionPolicyFactory,
                                     ablyService: ablyService,
                                     locationService: locationService,
                                     routeProvider: routeProvider)
    }
    
    func setUpUsingTokenAuthWithError() throws {
        configuration = ConnectionConfiguration(clientId: "CLIENT_ID", authCallback: { tokenParams, resultHandler in
            // TODO use tokenParams to create tokenRequest
            // Use Ably authenticated with API_KEY to emulate a user creating tokenRequest serverside
            
            let tokenRequest = TokenRequest()
            resultHandler(tokenRequest, nil, nil)
        }
    }
    
    func setUpUsingJWTAuthWithError() throws {
        configuration = ConnectionConfiguration(clientId: "CLIENT_ID", authCallback: { tokenParams, resultHandler in
            let token = "Some fake token which can also be a JWT"
            resultHandler(nil, token, nil)
        }
    }

    // MARK: track
    func testTrack_success() {
        ablyService.trackCompletionHandler = { completion in completion?(.success)}
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
        ablyService.trackCompletionHandler = { completion in completion?(.success)}
        let expectation = XCTestExpectation()

        let destination = CLLocationCoordinate2D(latitude: 12.3456, longitude: 56.789)
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
        XCTAssertEqual(routeProvider.getRouteParamDestination, destination)
    }

    func testTrack_error_duplicate_track() {
        ablyService.trackCompletionHandler = { completion in completion?(.success)}
        var expectation = XCTestExpectation()
        let expectedError = ErrorInformation(type: .trackableAlreadyExist(trackableId: self.trackable.id))

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
        expectation = XCTestExpectation()
        
        // And tracking it once again
        publisher.track(trackable: trackable) { result in
            switch result {
            case .success:
                XCTFail("Success callback shouldn't be called")
            case .failure(let error):
                expectation.fulfill()
                XCTAssertEqual(error.message, expectedError.message)
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func test_trackCalledMultipleTimes_shouldPass() {
        ablyService.trackCompletionHandler = { completion in completion?(.success)}
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
        let errorInformation = ErrorInformation(type: .publisherError(errorMessage: "Test AblyPublisherService error"))
        ablyService.trackCompletionHandler = { completion in completion?(.failure(errorInformation)) }
        let expectation = XCTestExpectation()

        // When tracking a trackable and receive error response from AblyPublisherService
        publisher.track(trackable: trackable) { result in
            switch result {
            case .success:
                XCTFail("Success callback shouldn't be called")
            case .failure(let error):
                // It should call failure callback with received error
                XCTAssertEqual(error, errorInformation)
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 5.0)
    }

    func testTrack_thread() {
        ablyService.trackCompletionHandler = { completion in completion?(.success) }

        var expectation = XCTestExpectation()
        // Both `onSuccess` and `onError` callbacks should be called on main thread
        // Notice - in case of failure it will crash whole test suite
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
        
        expectation = XCTestExpectation()
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
        ablyService.trackCompletionHandler = { completion in completion?(.success) }
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
        ablyService.trackCompletionHandler = { completion in completion?(.success) }
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
        ablyService.trackCompletionHandler = { completion in completion?(.failure(errorInformation)) }
        let expectation = XCTestExpectation()

        // When adding a trackable and receive error response from AblyPublisherService
        publisher.add(trackable: trackable) { result in
            switch result {
            case .success:
                XCTFail("Success callback shouldn't be called")
            case .failure(let error):
                // It should call onError callback with received error
                XCTAssertEqual(error, errorInformation)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }

    func testAdd_success_thread() {
        ablyService.trackCompletionHandler = { completion in completion?(.success) }
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
        let errorInformation = ErrorInformation(type: .publisherError(errorMessage: "Test AblyPublisherService error"))
        ablyService.trackCompletionHandler = { completion in completion?(.failure(errorInformation)) }
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

    // MARK: remove
    func testRemove_success() {
        let wasPresent = true
        var receivedWasPresent: Bool?
        ablyService.stopTrackingResultCompletionHandler = { completion in completion?(.success(wasPresent))}
        ablyService.trackCompletionHandler = { completion in completion?(.success(())) }
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
        ablyService.trackCompletionHandler = { completion in completion?(.success)}
        ablyService.stopTrackingResultCompletionHandler = { handler in handler?(.success(true)) }

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
        ablyService.trackCompletionHandler = { completion in completion?(.success) }
        ablyService.stopTrackingResultCompletionHandler = { handler in handler?(.success(true)) }

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
        let errorInformation = ErrorInformation(type: .publisherError(errorMessage: "Test AblyPublisherService error"))
        ablyService.stopTrackingResultCompletionHandler = { handler in handler?(.failure(errorInformation))}
        let expectation = XCTestExpectation()

        // When removing trackable and receive error from AblyPublisherService
        publisher.remove(trackable: trackable) { result in
            switch result {
            case .success:
                XCTFail("Success callback shouldn't be called")
            case .failure(let receivedError):
                XCTAssertEqual(receivedError, errorInformation)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }


    func testRemove_success_thread() {
        ablyService.stopTrackingResultCompletionHandler = { handler in handler?(.success(true))}
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
        let errorInformation = ErrorInformation(type: .publisherError(errorMessage: "Test AblyPublisherService error"))
        ablyService.stopTrackingResultCompletionHandler = { handler in handler?(.failure(errorInformation))}
        
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
    func testChangeRoutingProfile_called() {
        // Given: Default RoutingProfile set to .driving
        publisher.changeRoutingProfile(profile: .cycling) { result in
            switch result {
            case .success:
                XCTAssertTrue(self.routeProvider.changeRoutingProfileCalled)
                XCTAssertEqual(self.routeProvider.changeRoutingProfileParamRoutingProfile, .cycling)
            case .failure:
                XCTFail("Failure callback shouldn't be called")
            }
        }
    }
    
    func testChangeRoutingProfile_shouldCallGetRouteForDestination() {
        // Given: Default destination set to:
        let expectedDestination = CLLocationCoordinate2D(latitude: 3.1415, longitude: 2.7182)
        
        publisher.changeRoutingProfile(profile: .cycling) { result in
            switch result {
            case .success:
                XCTAssertTrue(self.routeProvider.changeRoutingProfileCalled)
                XCTAssertTrue(self.routeProvider.getRouteCalled)
                XCTAssertEqual(self.routeProvider.getRouteParamDestination, expectedDestination)
            case .failure:
                XCTFail("Failure callback shouldn't be called")
            }
        }
    }
    
    func test_closeConnection_success() {
        let expectation = XCTestExpectation()
        ablyService.closeResultCompletionHandler = { callback in
            callback?(.success)
            expectation.fulfill()
        }
        
        ablyService.close(completion: { _ in })
        wait(for: [expectation], timeout: 5.0)
        
        XCTAssertTrue(ablyService.closeCalled)
        XCTAssertNotNil(ablyService.closeParamCompletion)
    }
    
    func test_closeConnection_failure() {
        let expectation = XCTestExpectation()
        let closeError = ErrorInformation(type: .publisherError(errorMessage: "TestError."))
        ablyService.closeResultCompletionHandler = { callback in
            callback?(.failure(closeError))
            expectation.fulfill()
        }
        
        ablyService.close { result in
            switch result {
            case .success:
                XCTFail("Success not expected.")
            case .failure(let error):
                XCTAssertEqual(error.message, closeError.message)
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        XCTAssertTrue(ablyService.closeCalled)
        XCTAssertNotNil(ablyService.closeParamCompletion)
    }
}
