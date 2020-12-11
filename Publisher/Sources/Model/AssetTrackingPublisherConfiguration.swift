import UIKit

/**
 Main configuration class used to initialize `AssetTrackingPublisher`
 */
public class AssetTrackingPublisherConfiguration {
    let apiKey: String
    let clientId: String

    public init(apiKey: String, clientId: String) {
        self.apiKey = apiKey
        self.clientId = clientId
    }
}
