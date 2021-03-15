public class ConnectionConfiguration: NSObject {
    public let apiKey: String
    public let clientId: String

    @objc
    public init(apiKey: String, clientId: String) {
        self.apiKey = apiKey
        self.clientId = clientId
    }
}
