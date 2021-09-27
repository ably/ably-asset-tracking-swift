import Ably
import AblyAssetTrackingCore

extension ConnectionConfiguration {

    public func getClientOptions() -> ARTClientOptions {
        let clientOptions = ARTClientOptions(key: apiKey)
        clientOptions.addAgent("ably-asset-tracking-swift", version: Version.currentVersion())
        clientOptions.clientId = clientId
        return clientOptions
    }

}
