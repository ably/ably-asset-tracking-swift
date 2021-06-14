import Ably

public class ConnectionConfiguration: NSObject {
    public let apiKey: String
    public let clientId: String

    @objc
    public init(apiKey: String, clientId: String) {
        self.apiKey = apiKey
        self.clientId = clientId
    }
    
    public func getClientOptions() -> ARTClientOptions {
        let clientOptions = ARTClientOptions(key: apiKey)
        clientOptions.clientId = clientId
        return clientOptions
    }
}
