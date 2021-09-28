import XCTest
import AblyAssetTrackingCore
import AblyAssetTrackingSubscriber
import Ably
import CoreLocation
@testable import AblyAssetTrackingPublisher

struct Locations: Codable {
    let locations: [GeoJSONMessage]
}

class PublisherAndSubscriberSystemTests: XCTestCase {

    private var didUpdateEnhancedLocationCounter = 0
    private var locationsData: Locations!
    private var subscriber: AblyAssetTrackingSubscriber.Subscriber!
    private var publisher: Publisher!

    private let didUpdateEnhancedLocationExpectation = XCTestExpectation(description: "Subscriber Did Finish Updating Enhanced Locations")
    private let locationService = MockLocationService()
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
            print(error)
        }
        
        let subscriberConnectionConfiguration = ConnectionConfiguration(apiKey: Secrets.ablyApiKey, clientId: subscriberClientId)
        let resolution = Resolution(accuracy: .balanced, desiredInterval: 1000, minimumDisplacement: 100)
        
        subscriber = SubscriberFactory.subscribers()
            .connection(subscriberConnectionConfiguration)
            .resolution(resolution)
            .log(logConfiguration)
            .delegate(self)
            .trackingId(trackableId)
            .start { _ in }!
        
        // Delay 3 seconds - subscriber needs a while to connect to ably servers
        //
        _ = XCTWaiter.wait(for: [XCTestExpectation()], timeout: 3.0)

        let publisherConnectionConfiguration = ConnectionConfiguration(apiKey: Secrets.ablyApiKey, clientId: publisherClientId)
        publisher = DefaultPublisher(
            connectionConfiguration: publisherConnectionConfiguration,
            mapboxConfiguration: MapboxConfiguration(mapboxKey: Secrets.mapboxAccessToken),
            logConfiguration: logConfiguration,
            routingProfile: .driving,
            resolutionPolicyFactory: resolutionPolicyFactory,
            ablyService: DefaultAblyPublisherService(configuration: publisherConnectionConfiguration),
            locationService: locationService,
            routeProvider: routeProvider
        )
        
        let trackable = Trackable(id: trackableId)
        publisher.add(trackable: trackable) { _ in
            for location in self.locationsData.locations {
                self.locationService.delegate?.locationService(sender: self.locationService, didUpdateEnhancedLocationUpdate: .init(location: location.toCoreLocation()))
            }
        }
        
        wait(for: [didUpdateEnhancedLocationExpectation], timeout: 10.0)
        
        let publisherStopExpecatation = XCTestExpectation(description: "Publisher Stop Expectation")
        
        publisher.stop { _ in
            publisherStopExpecatation.fulfill()
        }
        
        wait(for: [publisherStopExpecatation], timeout: 5.0)
    }
}

extension PublisherAndSubscriberSystemTests: SubscriberDelegate {
    func subscriber(sender: AblyAssetTrackingSubscriber.Subscriber, didFailWithError error: ErrorInformation) {}
    
    func subscriber(sender: AblyAssetTrackingSubscriber.Subscriber, didChangeAssetConnectionStatus status: ConnectionState) {}
    
    func subscriber(sender: AblyAssetTrackingSubscriber.Subscriber, didUpdateEnhancedLocation location: CLLocation) {
        guard didUpdateEnhancedLocationCounter < locationsData.locations.count / 2 else {
            subscriber.delegate = nil
            didUpdateEnhancedLocationExpectation.fulfill()
            return
        }
        let coordinates = self.locationsData.locations.map { $0.toCoreLocation().coordinate }
        XCTAssertTrue(coordinates.contains(location.coordinate))
        
        didUpdateEnhancedLocationCounter += 1
    }
}

extension PublisherAndSubscriberSystemTests: PublisherDelegate {
    func publisher(sender: AblyAssetTrackingPublisher.Publisher, didFailWithError error: ErrorInformation) {}
    
    func publisher(sender: AblyAssetTrackingPublisher.Publisher, didUpdateEnhancedLocation location: CLLocation) {}
    
    func publisher(sender: AblyAssetTrackingPublisher.Publisher, didChangeConnectionState state: ConnectionState, forTrackable trackable: Trackable) {}
    
    func publisher(sender: AblyAssetTrackingPublisher.Publisher, didUpdateResolution resolution: Resolution) {}
}
