import Ably
import AblyAssetTrackingCore

extension ConnectionConfiguration {

    public func getClientOptions() -> ARTClientOptions {
        let clientOptions = ARTClientOptions(key: apiKey)
        clientOptions.clientId = clientId
        return clientOptions
    }

}
