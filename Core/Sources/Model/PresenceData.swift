import UIKit

public enum ClientType: String, Codable {
    case publisher
    case subscriber
}

public class PresenceData: Codable {
    public let type: ClientType

    public init(type: ClientType) {
        self.type = type
    }
}
