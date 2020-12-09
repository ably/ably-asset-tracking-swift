import Foundation

/**
 Main configuration class used to initialize `AssetTrackingSubscriber`
 */
public class AssetTrackingSubscriberConfiguration {
    let apiKey: String
    let clientId: String
    let resolution: Double
    let trackingId: String
    
    public init(apiKey: String, clientId: String, resolution: Double, trackingId: String) {
        self.apiKey = apiKey
        self.clientId = clientId
        self.resolution = resolution
        self.trackingId = trackingId
    }
}
