import AblyAssetTrackingCore
import UIKit

// swiftlint:disable missing_docs

public struct PresenceData: Codable, Equatable {
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

public extension PresenceData {
    func copy(with newResolution: Resolution) -> PresenceData {
        .init(type: type, resolution: newResolution, rawLocations: rawLocations)
    }
}
