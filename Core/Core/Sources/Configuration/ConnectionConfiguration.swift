import UIKit

public class ConnectionConfiguration: NSObject {
    let apiKey: String
    let clientId: String

    public init(apiKey: String, clientId: String) {
        self.apiKey = apiKey
        self.clientId = clientId
    }
}
