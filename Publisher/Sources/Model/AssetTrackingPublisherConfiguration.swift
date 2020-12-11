import UIKit

/**
 Main configuration class used to initialize `AssetTrackingPublisher`
 */
public class AssetTrackingPublisherConfiguration {
    let apiKey: String
    let clientId: String

    /**
     Default constructor.
     - Parameters:
        - apiKey: Ably API key in format: "keyName:keySecret'
        - clientId: Ably client ID
     */
    public init(apiKey: String, clientId: String) {
        self.apiKey = apiKey
        self.clientId = clientId
    }
}
