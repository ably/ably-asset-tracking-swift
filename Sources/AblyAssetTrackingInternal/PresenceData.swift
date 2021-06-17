import UIKit
import AblyAssetTrackingCore

public enum ClientType: String, Codable {
    case publisher = "PUBLISHER"
    case subscriber = "SUBSCRIBER"
}

public class PresenceData: Codable {
    public let type: ClientType
    public let resolution: Resolution?

    public init(type: ClientType) {
        self.type = type
        self.resolution = nil
    }

    public init(type: ClientType, resolution: Resolution?) {
        self.type = type
        self.resolution = resolution
    }
}
