import UIKit

/**
 Main configuration class used to initialize `AblyAssetTrackingPublisher`
 */
public class AssetTrackingPublisherConfiguration {
    let apiKey: String
    let clientId: String
    
    public init(apiKey: String, clientId: String) {
        self.apiKey = apiKey
        self.clientId = clientId
    }
}
