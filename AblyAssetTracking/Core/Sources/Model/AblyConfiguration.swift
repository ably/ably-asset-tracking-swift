import UIKit

public class AblyConfiguration: NSObject {
    let apiKey: String
    let clientId: String
    
    public init(apiKey: String, clientId: String) {
        self.apiKey = apiKey
        self.clientId = clientId
    }
}
