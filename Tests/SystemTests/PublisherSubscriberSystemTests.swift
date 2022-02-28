import XCTest
import AblyAssetTrackingCore
import AblyAssetTrackingInternal
import AblyAssetTrackingSubscriber
import Ably
import Logging
import CoreLocation
@testable import AblyAssetTrackingPublisher

struct Locations: Codable {
    let locations: [GeoJSONMessage]
}

class PublisherAndSubscriberSystemTests: XCTestCase {

    private var locationChangeTimer: Timer!
    private var locationsData: Locations!
    private var subscriber: AblyAssetTrackingSubscriber.Subscriber!
    private var publisher: Publisher!

    private let didUpdateEnhancedLocationExpectation = XCTestExpectation(description: "Subscriber Did Finish Updating Enhanced Locations")
    private let routeProvider = MockRouteProvider()
    private let resolutionPolicyFactory = MockResolutionPolicyFactory()
    private let trackableId = "Trackable ID 1 - \(UUID().uuidString)"
    private let logConfiguration = LogConfiguration()
    private let subscriberClientId: String = {
        "Test-Subscriber_\(UUID().uuidString)"
    }()
    private let publisherClientId: String = {
        "Test-Publisher_\(UUID().uuidString)"
    }()
    
    override func setUpWithError() throws { }
    override func tearDownWithError() throws { }

    func testSubscriberReceivesPublisherMessage() throws {
        do {
            locationsData = try LocalDataHelper.parseJsonFromResources("test-locations", type: Locations.self)
        } catch {
            XCTFail("Can't find the source of locations `test-locations.json`")
        }
                
        let subscriberConnectionConfiguration = ConnectionConfiguration(apiKey: Secrets.ablyApiKey, clientId: subscriberClientId)
        let resolution = Resolution(accuracy: .balanced, desiredInterval: 500, minimumDisplacement: 100)
        
        subscriber = SubscriberFactory.subscribers()
            .connection(subscriberConnectionConfiguration)
            .resolution(resolution)
            .log(logConfiguration)
            .delegate(self)
            .trackingId(trackableId)
            .start(completion: { _ in })!
        
        delay(5)
        
        let defaultLocationService = DefaultLocationService(
            mapboxConfiguration: .init(mapboxKey: Secrets.mapboxAccessToken),
            historyLocation: locationsData.locations.map({ $0.toCoreLocation() })
        )
        
        let publisherConnectionConfiguration = ConnectionConfiguration(apiKey: Secrets.ablyApiKey, clientId: publisherClientId)
        
        let defaultAbly = DefaultAbly(
            configuration: publisherConnectionConfiguration,
            mode: .publish,
            logger: .init(label: "com.ably.tracking.SystemTests")
        )
        
        publisher = DefaultPublisher(
            connectionConfiguration: publisherConnectionConfiguration,
            mapboxConfiguration: MapboxConfiguration(mapboxKey: Secrets.mapboxAccessToken),
            logConfiguration: logConfiguration,
            routingProfile: .driving,
            resolutionPolicyFactory: resolutionPolicyFactory,
            ablyPublisher: defaultAbly,
            locationService: defaultLocationService,
            routeProvider: routeProvider
        )
        
        
        let trackable = Trackable(id: trackableId)
        didUpdateEnhancedLocationExpectation.expectedFulfillmentCount = Int(floor(Double(locationsData.locations.count)/2.0))
        publisher.add(trackable: trackable) { _  in }
        
        wait(for: [didUpdateEnhancedLocationExpectation], timeout: 20.0)
                
        let stopPublisherExpectation = self.expectation(description: "Publisher did call stop completion closure")
        let stopSubscriberExpectation = self.expectation(description: "Subscriber did call stop completion closure")
        
        subscriber.stop(completion: { _ in
            stopSubscriberExpectation.fulfill()
        })
        
        publisher.stop(completion: { _ in
            stopPublisherExpectation.fulfill()
        })
        
        wait(for: [stopPublisherExpectation, stopSubscriberExpectation], timeout: 5)
    }
    
    private func delay(_ timeout: TimeInterval) {
        let delayExpectation = XCTestExpectation()
        delayExpectation.isInverted = true
        wait(for: [delayExpectation], timeout: timeout)
    }
}

extension PublisherAndSubscriberSystemTests: SubscriberDelegate {
    func subscriber(sender: AblyAssetTrackingSubscriber.Subscriber, didFailWithError error: ErrorInformation) {}
    
    func subscriber(sender: AblyAssetTrackingSubscriber.Subscriber, didChangeAssetConnectionStatus status: ConnectionState) {}
    
    func subscriber(sender: AblyAssetTrackingSubscriber.Subscriber, didUpdateEnhancedLocation location: Location) {
        didUpdateEnhancedLocationExpectation.fulfill()
    }
}

extension PublisherAndSubscriberSystemTests: PublisherDelegate {
    func publisher(sender: AblyAssetTrackingPublisher.Publisher, didFailWithError error: ErrorInformation) {}
    
    func publisher(sender: AblyAssetTrackingPublisher.Publisher, didUpdateEnhancedLocation location: EnhancedLocationUpdate) {}
    
    func publisher(sender: AblyAssetTrackingPublisher.Publisher, didChangeConnectionState state: ConnectionState, forTrackable trackable: Trackable) {}
    
    func publisher(sender: AblyAssetTrackingPublisher.Publisher, didUpdateResolution resolution: Resolution) {}
}
