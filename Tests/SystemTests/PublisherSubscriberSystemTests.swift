import XCTest
import AblyAssetTrackingCore
import AblyAssetTrackingInternal
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

    private let didChangeAssetConnectionStatusOnlineExpectation = XCTestExpectation(description: "Asset Connection Status Did Change To Online")
    private let didChangeAssetConnectionStatusOfflineExpectation = XCTestExpectation(description: "Asset Connection Status Did Change To Offline")
    private let didUpdateEnhancedLocationExpectation = XCTestExpectation(description: "Subscriber Did Finish Updating Enhanced Locations")
    private let didUpdateRawLocationExpectation = XCTestExpectation(description: "Subscriber Did Finish Updating Raw Locations")
    private let didUpdateResolutionExpectation = XCTestExpectation(description: "Subscriber Did Finish Updating Resolution")
    private let routeProvider = MockRouteProvider()
    private let resolutionPolicyFactory = MockResolutionPolicyFactory()
    private let trackableId = "Trackable ID 1 - \(UUID().uuidString)"
    private let subscriberClientId: String = {
        "Test-Subscriber_\(UUID().uuidString)"
    }()
    private let publisherClientId: String = {
        "Test-Publisher_\(UUID().uuidString)"
    }()
    
    private let logger = MockLogHandler()
    
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
            .delegate(self)
            .trackingId(trackableId)
            .start(completion: { _ in })!
        
        delay(5)
        
        let defaultLocationService = DefaultLocationService(
            mapboxConfiguration: .init(mapboxKey: Secrets.mapboxAccessToken),
            historyLocation: locationsData.locations.map({ $0.toCoreLocation() }), logHandler: logger
        )
        
        let publisherConnectionConfiguration = ConnectionConfiguration(apiKey: Secrets.ablyApiKey, clientId: publisherClientId)
        
        let defaultAbly = DefaultAbly(
            factory: AblyCocoaSDKRealtimeFactory(),
            configuration: publisherConnectionConfiguration,
            mode: .publish,
            logHandler: logger
        )
        
        publisher = DefaultPublisher(
            connectionConfiguration: publisherConnectionConfiguration,
            mapboxConfiguration: MapboxConfiguration(mapboxKey: Secrets.mapboxAccessToken),
            routingProfile: .driving,
            resolutionPolicyFactory: resolutionPolicyFactory,
            ablyPublisher: defaultAbly,
            locationService: defaultLocationService,
            routeProvider: routeProvider,
            areRawLocationsEnabled: true,
            isSendResolutionEnabled: true,
            logHandler: logger
        )
        
        
        let trackable = Trackable(id: trackableId)
        didUpdateEnhancedLocationExpectation.expectedFulfillmentCount = Int(floor(Double(locationsData.locations.count)/2.0))
        publisher.add(trackable: trackable) { _  in }
        
        wait(for: [didUpdateEnhancedLocationExpectation, didUpdateRawLocationExpectation, didUpdateResolutionExpectation], timeout: 20.0)
                
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
    
    func testSubscriberNotReceivesAssetConnectionStatus() throws {
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
            .delegate(self)
            .trackingId(trackableId)
            .start(completion: { _ in })!
        
        delay(5)
        didChangeAssetConnectionStatusOnlineExpectation.isInverted = true
        didChangeAssetConnectionStatusOfflineExpectation.isInverted = true
        wait(for: [
            didChangeAssetConnectionStatusOnlineExpectation, didChangeAssetConnectionStatusOfflineExpectation
        ], timeout: 0.0)
        
        subscriber.stop(completion: { _ in })
    }
    
    func testSubscriberReceivesAssetConnectionStatus() throws {
        do {
            locationsData = try LocalDataHelper.parseJsonFromResources("test-locations", type: Locations.self)
        } catch {
            XCTFail("Can't find the source of locations `test-locations.json`")
        }
        
        let defaultLocationService = DefaultLocationService(
            mapboxConfiguration: .init(mapboxKey: Secrets.mapboxAccessToken),
            historyLocation: locationsData.locations.map({ $0.toCoreLocation() }), logHandler: logger
        )
        
        let publisherConnectionConfiguration = ConnectionConfiguration(apiKey: Secrets.ablyApiKey, clientId: publisherClientId)
        
        let defaultAbly = DefaultAbly(
            factory: AblyCocoaSDKRealtimeFactory(),
            configuration: publisherConnectionConfiguration,
            mode: .publish,
            logHandler: logger
        )
        
        publisher = DefaultPublisher(
            connectionConfiguration: publisherConnectionConfiguration,
            mapboxConfiguration: MapboxConfiguration(mapboxKey: Secrets.mapboxAccessToken),
            routingProfile: .driving,
            resolutionPolicyFactory: resolutionPolicyFactory,
            ablyPublisher: defaultAbly,
            locationService: defaultLocationService,
            routeProvider: routeProvider,
            areRawLocationsEnabled: true,
            isSendResolutionEnabled: true,
            logHandler: logger
        )
        
        let trackable = Trackable(id: trackableId)
        publisher.add(trackable: trackable) { _  in }
        
        let subscriberConnectionConfiguration = ConnectionConfiguration(apiKey: Secrets.ablyApiKey, clientId: subscriberClientId)
        let resolution = Resolution(accuracy: .balanced, desiredInterval: 500, minimumDisplacement: 100)
        
        subscriber = SubscriberFactory.subscribers()
            .connection(subscriberConnectionConfiguration)
            .resolution(resolution)
            .delegate(self)
            .trackingId(trackableId)
            .start(completion: { _ in })!
        
        wait(for: [didChangeAssetConnectionStatusOnlineExpectation], timeout: 5.0)
        
        let stopPublisherExpectation = self.expectation(description: "Publisher did call stop completion closure")
        publisher.stop(completion: { _ in
            stopPublisherExpectation.fulfill()
        })
        wait(for: [stopPublisherExpectation], timeout: 5)
        
        wait(for: [didChangeAssetConnectionStatusOfflineExpectation], timeout: 5.0)
        
        subscriber.stop(completion: { _ in })
    }
    
    private func delay(_ timeout: TimeInterval) {
        let delayExpectation = XCTestExpectation()
        delayExpectation.isInverted = true
        wait(for: [delayExpectation], timeout: timeout)
    }
}

extension PublisherAndSubscriberSystemTests: SubscriberDelegate {
    func subscriber(sender: AblyAssetTrackingSubscriber.Subscriber, didFailWithError error: ErrorInformation) {}
    
    func subscriber(sender: AblyAssetTrackingSubscriber.Subscriber, didChangeAssetConnectionStatus status: ConnectionState) {
        switch status {
        case .online:
            didChangeAssetConnectionStatusOnlineExpectation.fulfill()
        case .offline:
            didChangeAssetConnectionStatusOfflineExpectation.fulfill()
        case .failed:
            ()
        }
    }
    
    func subscriber(sender: AblyAssetTrackingSubscriber.Subscriber, didUpdateEnhancedLocation locationUpdate: LocationUpdate) {
        didUpdateEnhancedLocationExpectation.fulfill()
    }
    
    func subscriber(sender: AblyAssetTrackingSubscriber.Subscriber, didUpdateRawLocation locationUpdate: LocationUpdate) {
        didUpdateRawLocationExpectation.fulfill()
    }
    
    func subscriber(sender: AblyAssetTrackingSubscriber.Subscriber, didUpdateResolution resolution: Resolution) {
        didUpdateResolutionExpectation.fulfill()
    }
}
