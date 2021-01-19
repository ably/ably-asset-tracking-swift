import UIKit

public enum ClientType: String, Codable {
    case publisher
    case subscriber
}

public class PresenceData: Codable {
    public let type: ClientType
    public let resolution: Resolution?

    public init(type: ClientType) {
        self.type = type
        self.resolution = nil
    }

    init(type: ClientType, resolution: Resolution?) {
        self.type = type
        self.resolution = resolution
    }
}
