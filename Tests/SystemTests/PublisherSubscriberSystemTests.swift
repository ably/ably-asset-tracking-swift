import XCTest
import AblyAssetTrackingCore
import AblyAssetTrackingSubscriber
import Ably
import CoreLocation
@testable import AblyAssetTrackingPublisher

class PublisherAndSubscriberSystemTests: XCTestCase {

    private var didUpdateEnhancedLocationExpectation: XCTestExpectation!
    
    private let locationService = MockLocationService()
    private let routeProvider = MockRouteProvider()
    private let resolutionPolicyFactory = MockResolutionPolicyFactory()
    private let trackableId = "Trackable ID 1"
    private let logConfiguration = LogConfiguration()
    private let changedLocation = CLLocation(latitude: 51.509865, longitude: -0.118092)
    private let clientId: String = {
        "Test-Publisher_\(UUID().uuidString)"
    }()
    
    override func setUpWithError() throws { }
    override func tearDownWithError() throws { }

    func testSubscriberReceivesPublisherMessage() throws {
        didUpdateEnhancedLocationExpectation = self.expectation(description: "Subscriber didUpdateEnhancedLocation expectation")
        
        let connectionConfiguration = ConnectionConfiguration(apiKey: Secrets.ablyApiKey, clientId: clientId)
        let resolution = Resolution(accuracy: .balanced, desiredInterval: 5000, minimumDisplacement: 100)
        let subscriber = SubscriberFactory.subscribers()
            .connection(connectionConfiguration)
            .resolution(resolution)
            .log(logConfiguration)
            .delegate(self)
            .trackingId(trackableId)
            .start(completion: { _ in })
        
        subscriber?.resolutionPreference(resolution: resolution) { result in }
        
        let publisher = DefaultPublisher(
            connectionConfiguration: connectionConfiguration,
            mapboxConfiguration: MapboxConfiguration(mapboxKey: Secrets.mapboxAccessToken),
            logConfiguration: logConfiguration,
            routingProfile: .driving,
            resolutionPolicyFactory: resolutionPolicyFactory,
            ablyService: DefaultAblyPublisherService(configuration: connectionConfiguration),
            locationService: locationService,
            routeProvider: routeProvider
        )
        
        let trackable = Trackable(id: trackableId)

        publisher.track(trackable: trackable) { _ in
            self.locationService.delegate?.locationService(
                sender: self.locationService,
                didUpdateEnhancedLocationUpdate: .init(location: self.changedLocation)
            )
        }
            
        wait(for: [didUpdateEnhancedLocationExpectation], timeout: 15.0)
    }
}

extension PublisherAndSubscriberSystemTests: SubscriberDelegate {
    func subscriber(sender: AblyAssetTrackingSubscriber.Subscriber, didFailWithError error: ErrorInformation) {}
    func subscriber(sender: AblyAssetTrackingSubscriber.Subscriber, didChangeAssetConnectionStatus status: ConnectionState) {}
    
    func subscriber(sender: AblyAssetTrackingSubscriber.Subscriber, didUpdateEnhancedLocation location: CLLocation) {
        XCTAssertEqual(location.coordinate, changedLocation.coordinate)
        self.didUpdateEnhancedLocationExpectation.fulfill()
    }
}

extension PublisherAndSubscriberSystemTests: PublisherDelegate {
    func publisher(sender: AblyAssetTrackingPublisher.Publisher, didFailWithError error: ErrorInformation) {
        return
    }
    
    func publisher(sender: AblyAssetTrackingPublisher.Publisher, didUpdateEnhancedLocation location: CLLocation) {
        return
    }
    
    func publisher(sender: AblyAssetTrackingPublisher.Publisher, didChangeConnectionState state: ConnectionState, forTrackable trackable: Trackable) {
        return
    }
    
    func publisher(sender: AblyAssetTrackingPublisher.Publisher, didUpdateResolution resolution: Resolution) {
        return
    }
}
