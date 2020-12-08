import UIKit

enum ClientType: String, Codable {
    case publisher
    case subscriber
}

class PresenceData: Codable {
    let type: ClientType
    
    init(type: ClientType) {
        self.type = type
    }
}
