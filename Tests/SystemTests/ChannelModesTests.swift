import XCTest
import CoreLocation
import AblyAssetTrackingInternal
import AblyAssetTrackingSubscriber
@testable import AblyAssetTrackingPublisher

class ChannelModesTests: XCTestCase {
    private let defaultDelayTime: TimeInterval = 10.0
    private let didUpdateEnhancedLocationExpectation = XCTestExpectation(description: "Subscriber Did Finish Updating Enhanced Locations")
    let logger = MockLogHandler()
    
    func testShouldCreateOnlyOnePublisherAndOneSubscriberConnection() throws {
        let subscriberClientId = "Test-Subscriber_\(UUID().uuidString)"
        let publisherClientId = "Test-Publisher_\(UUID().uuidString)"
        let trackableId = "Trackable-\(UUID().uuidString)"
        let ablyApiKey = Secrets.ablyApiKey
        
        /**
         Create `Subscriber` and wait.
         */
        let subscriber = createSubscriber(trackableId: trackableId, clientId: subscriberClientId, ablyApiKey: ablyApiKey)
        delay(5.0)
        
        /**
         Create `Publisher`
         */
        let publisher = try createPublisher(clientId: publisherClientId, ablyApiKey: ablyApiKey)
        let trackable = Trackable(id: trackableId)
        
        /**
         Add `Trackable` and wait for `Subscriber` delegate method calling
         */
        publisher.add(trackable: trackable) { _ in }
        wait(for: [didUpdateEnhancedLocationExpectation], timeout: defaultDelayTime)
        
        let metricsData = try XCTUnwrap(getChannelMetrics(trackableId: trackableId, ablyApiKey: ablyApiKey))
        
        /**
         Only `1` registered `Publisher`
         Only `1` registered `Subscriber`
         */
        XCTAssertEqual(metricsData.status.occupancy.metrics.publishers, 1)
        XCTAssertEqual(metricsData.status.occupancy.metrics.subscribers, 1)
        
        /**
         Stop `Publisher` and `Subscriber`
         */
        let stopPublisherExpectation = self.expectation(description: "Publisher did call stop completion closure")
        let stopSubscriberExpectation = self.expectation(description: "Subscriber did call stop completion closure")
        
        subscriber.stop(completion: { _ in
            stopSubscriberExpectation.fulfill()
        })
        
        publisher.stop(completion: { _ in
            stopPublisherExpectation.fulfill()
        })
        
        wait(for: [stopPublisherExpectation, stopSubscriberExpectation], timeout: defaultDelayTime)
    }
    
    private func createPublisher(clientId: String, ablyApiKey: String) throws -> Publisher  {
        let locationsData = try LocalDataHelper.parseJsonFromResources("test-locations", type: Locations.self)
        
        let defaultLocationService = DefaultLocationService(
            mapboxConfiguration: .init(mapboxKey: Secrets.mapboxAccessToken),
            historyLocation: locationsData.locations.map({ $0.toCoreLocation() }),
            logHandler: logger,
            vehicleProfile: VehicleProfile.Car
        )
        let publisherConnectionConfiguration = ConnectionConfiguration(apiKey: ablyApiKey, clientId: clientId)
        
        let defaultAbly = DefaultAbly(
            factory: AblyCocoaSDKRealtimeFactory(),
            configuration: publisherConnectionConfiguration,
            mode: .publish,
            logHandler: logger
        )
        
        return DefaultPublisher(
            connectionConfiguration: publisherConnectionConfiguration,
            mapboxConfiguration: MapboxConfiguration(mapboxKey: Secrets.mapboxAccessToken),
            routingProfile: .driving,
            resolutionPolicyFactory: MockResolutionPolicyFactory(),
            ablyPublisher: defaultAbly,
            locationService: defaultLocationService,
            routeProvider: MockRouteProvider(),
            logHandler: logger
        )
        
    }
    
    private func createSubscriber(trackableId: String, clientId: String, ablyApiKey: String) -> AblyAssetTrackingSubscriber.Subscriber {
        let subscriberConnectionConfiguration = ConnectionConfiguration(apiKey: ablyApiKey, clientId: clientId)
        let resolution = Resolution(accuracy: .balanced, desiredInterval: 500, minimumDisplacement: 100)
        
        return SubscriberFactory.subscribers()
            .connection(subscriberConnectionConfiguration)
            .resolution(resolution)
            .delegate(self)
            .trackingId(trackableId)
            .start(completion: { _ in })!
    }
    
    private func getChannelMetrics(trackableId: String, ablyApiKey: String) throws -> ChannelMetrics? {
        let apiKeyParts = ablyApiKey.split(separator: ":")
        
        guard apiKeyParts.count == 2 else {
            XCTFail("Invalid number of api key parts. Expected 2, got \(apiKeyParts.count)")
            return nil
        }
        
        let auth = try XCTUnwrap((apiKeyParts[0] + ":" + apiKeyParts[1]).data(using: .utf8)?.base64EncodedString())
        let credentials = "Basic \(auth)"
        let url = try XCTUnwrap(URL(string: "https://rest.ably.io/channels/tracking:\(trackableId)"))
        
        var request = URLRequest(url: url)
        request.addValue(credentials, forHTTPHeaderField: "Authorization")
        
        let didFinishDataTaskExpectation = self.expectation(description: "Get Channel Metrics Request - did finished")
        var channelMetricsObject: ChannelMetrics?
        
        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                XCTFail("Get Channel Metrics Request Failed with error: \(error)")
                didFinishDataTaskExpectation.fulfill()
                return
            }
            
            guard let data = data else {
                XCTFail("Get Channel Metrics Request `data` is `nil`")
                didFinishDataTaskExpectation.fulfill()
                return
            }
                        
            do {
                channelMetricsObject = try JSONDecoder().decode(ChannelMetrics.self, from: data)
            } catch {
                XCTFail("Get Channel Metrics Request - JSON Decode failed with error: \(error)")
            }
            
            didFinishDataTaskExpectation.fulfill()
        }
    
        task.resume()
        
        wait(for: [didFinishDataTaskExpectation], timeout: defaultDelayTime)
        
        return channelMetricsObject
    }
    
    private func delay(_ timeout: TimeInterval) {
        let delayExpectation = XCTestExpectation()
        delayExpectation.isInverted = true
        wait(for: [delayExpectation], timeout: timeout)
    }
}

extension ChannelModesTests: SubscriberDelegate {
    func subscriber(sender: AblyAssetTrackingSubscriber.Subscriber, didFailWithError error: ErrorInformation) {}
    
    func subscriber(sender: AblyAssetTrackingSubscriber.Subscriber, didChangeAssetConnectionStatus status: ConnectionState) {}
    
    func subscriber(sender: AblyAssetTrackingSubscriber.Subscriber, didUpdateEnhancedLocation locationUpdate: LocationUpdate) {
        didUpdateEnhancedLocationExpectation.fulfill()
    }
}

fileprivate struct ChannelMetrics: Codable {
    
    struct Status: Codable {
        
        struct Occupancy: Codable {
            
            struct Metrics: Codable {
                let publishers: Int
                let subscribers: Int
            }
            
            let metrics: Metrics
        }
        
        let occupancy: Occupancy
    }
    
    let status: Status
}
