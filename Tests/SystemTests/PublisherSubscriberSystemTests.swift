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

    private var locationChangeTimer: Timer!
    private var locationsData: Locations!
    private var subscriber: AblyAssetTrackingSubscriber.Subscriber!
    private var publisher: Publisher!
    private var stopEmmitingLocations = false

    private let didUpdateEnhancedLocationExpectation = XCTestExpectation(description: "Subscriber Did Finish Updating Enhanced Locations")
    private let locationService = MockLocationService()
    private let routeProvider = MockRouteProvider()
    private let resolutionPolicyFactory = MockResolutionPolicyFactory()
    private let trackableId = "Swift-Trackable_2"// "Trackable ID 1 - \(UUID().uuidString)"
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
        didUpdateEnhancedLocationExpectation.expectedFulfillmentCount = Int(floor(Double(locationsData.locations.count)/2.0))
        publisher.add(trackable: trackable) { [weak self] result in
            guard let self = self else {
                return
            }
            
            switch result {
            case .success:
                self.sendLocationsAsync()
            case .failure(let error):
                XCTFail("\(error)")
                self.didUpdateEnhancedLocationExpectation.fulfill()
            }
            
        }
        
        wait(for: [didUpdateEnhancedLocationExpectation], timeout: 10.0)
        
        stopEmmitingLocations = true
        
        let stopPublisherExpectation = self.expectation(description: "Publisher did call stop completion closure")
        let stopSubscriberExpectation = self.expectation(description: "Subscriber did call stop comppletion closure")
        
        subscriber.stop(completion: { _ in
            stopSubscriberExpectation.fulfill()
        })
        
        publisher.stop(completion: { _ in
            stopPublisherExpectation.fulfill()
        })
        
        wait(for: [stopPublisherExpectation, stopSubscriberExpectation], timeout: 5)
    }
    
    private func sendLocationsAsync() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else {
                return
            }
            
            for location in self.locationsData.locations {
                if self.stopEmmitingLocations {
                    break
                }
                self.locationService.delegate?.locationService(sender: self.locationService, didUpdateEnhancedLocationUpdate: .init(location: location.toCoreLocation()))
                self.delay(1.1)
            }
        }
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
    
    func subscriber(sender: AblyAssetTrackingSubscriber.Subscriber, didUpdateEnhancedLocation location: CLLocation) {
        self.didUpdateEnhancedLocationExpectation.fulfill()
    }
}

extension PublisherAndSubscriberSystemTests: PublisherDelegate {
    func publisher(sender: AblyAssetTrackingPublisher.Publisher, didFailWithError error: ErrorInformation) {}
    
    func publisher(sender: AblyAssetTrackingPublisher.Publisher, didUpdateEnhancedLocation location: CLLocation) {}
    
    func publisher(sender: AblyAssetTrackingPublisher.Publisher, didChangeConnectionState state: ConnectionState, forTrackable trackable: Trackable) {}
    
    func publisher(sender: AblyAssetTrackingPublisher.Publisher, didUpdateResolution resolution: Resolution) {}
}
