import XCTest
import CoreLocation
import Keys
@testable import Publisher

class PublisherIntegrationTests: XCTestCase {
    private var publisher: Publisher!
    private let defaultTimeout: TimeInterval = 5
    
    override func setUpWithError() throws {
        let keys = AblyAssetTrackingKeys.init()
        let connectionConfiguration = ConnectionConfiguration(
            apiKey: keys.ablyApiKey,
            clientId: keys.ablyClientId
        )
        let mapboxConfiguration = MapboxConfiguration(
            mapboxKey: keys.mapboxAccessToken
        )
        let resolution = Resolution(accuracy: .balanced, desiredInterval: 1000, minimumDisplacement: 0)
        let resolutionPolicyFactory = DefaultResolutionPolicyFactory(defaultResolution: resolution)
        
        publisher = try! DefaultPublisherBuilder()
            .connection(connectionConfiguration)
            .mapboxConfiguration(mapboxConfiguration)
            .log(LogConfiguration())
            .routingProfile(.driving)
            .resolutionPolicyFactory(resolutionPolicyFactory)
            .start()
    }
    
    func testPublisher_track_success() {
        var trackableCallback: SuccessHandler? = nil
        let expectation = self.expectation(description: "SuccessHandler called.")
        
        // Given:
        let testTrackable: Trackable = Trackable(id: "trackableid", destination: CLLocationCoordinate2D(latitude: 37.363152386314994, longitude: -122.11786987383525))
        
        // When:
        publisher.track(
            trackable: testTrackable,
            onSuccess: {
                trackableCallback = { }
                expectation.fulfill()
            },
            onError: { error in
                XCTFail("An error occured on adding trackable. Success expected.")
            })
        
        // Then:
        waitForExpectations(timeout: defaultTimeout, handler: nil)
        XCTAssertTrue(trackableCallback != nil, "SuccessHandler called.")
    }
    
    func testPublisher_track_error() {
        let expectation = self.expectation(description: "ErrorHandler called.")
        var expectedError: Error? = nil
        
        // Given:
        let testTrackable: Trackable = Trackable(id: "")
        
        // When:
        publisher.track(
            trackable: testTrackable,
            onSuccess: {
                XCTFail("Trackable added successfully. Error expected.")
            },
            onError: { error in
                expectedError = error
                expectation.fulfill()
            })
        
        waitForExpectations(timeout: defaultTimeout, handler: nil)
        XCTAssertTrue(expectedError != nil, "ErrorHandler called.")
    }
    
    // TODO: test track-stop and stop methods
    
//
//    func testPublisher_stop_success() {
//        let expectation = self.expectation(description: "SuccessHandler called.")
//
//        publisher.stop()
//    }
//
//    func testPublisher_track_stop_success() {
//        var trackableCallback: SuccessHandler? = nil
//        var stopCallback: SuccessHandler? = nil
//        let trackableExpectation = self.expectation(description: "Trackable SuccessHandler called.")
//        let stopExpectation = self.expectation(description: "Stop SuccessHandlerCalled.")
//
//        // Given:
//        let testTrackable: Trackable = Trackable(id: "trackableid", destination: CLLocationCoordinate2D(latitude: 37.363152386314994, longitude: -122.11786987383525))
//
//        // When:
//
//
//    }
}
