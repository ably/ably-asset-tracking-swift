import UIKit
import AblyAssetTrackingCore

public struct PresenceData: Codable {
    public let type: ClientType
    public let resolution: Resolution?
    public let rawLocations: Bool?

    public init(type: ClientType, rawLocations: Bool? = nil) {
        self.type = type
        self.resolution = nil
        self.rawLocations = rawLocations
    }

    public init(type: ClientType, resolution: Resolution?, rawLocations: Bool? = nil) {
        self.type = type
        self.resolution = resolution
        self.rawLocations = rawLocations
    }
}
