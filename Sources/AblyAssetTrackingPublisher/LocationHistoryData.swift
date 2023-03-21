import Ably
import AblyAssetTrackingInternal
import Foundation
import struct Version.Version

public struct LocationHistoryData: Codable {
    public let events: [GeoJSONMessage]
    @available(*, deprecated, message: "This property should no longer be used. It will be removed in a future version of this library.")
    public let version: Int = 1
    public let agents: String?

    private enum ArchiveVersion: Decodable {
        case version1
        case semantic(Version)

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()

            if let intVersion = try? container.decode(Int.self) {
                if intVersion == 1 {
                    self = .version1
                    return
                } else {
                    throw DecodingError.unsupportedVersion(version: String(intVersion))
                }
            }

            self = .semantic(try container.decode(Version.self))
        }
    }

    private static let archiveSemanticVersion = Version(2, 0, 0)
    public static let archiveVersion = String(describing: archiveSemanticVersion)

    public init(events: [GeoJSONMessage]) {
        self.events = events
        self.agents = ARTClientInformation.agentIdentifier(withAdditionalAgents: Agents.libraryAgents.ablyCocoaAgentsDictionary)
    }

    public enum DecodingError: Error {
        case unsupportedVersion(version: String)
    }

    private enum CodingKeys: CodingKey {
        case events
        case version
        case agents
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let version = try container.decode(ArchiveVersion.self, forKey: .version)

        switch version {
        case .version1:
            try self.init(version1From: decoder)
        case .semantic(let semanticVersion):
            if semanticVersion.major == 2 {
                try self.init(version2From: decoder)
            } else {
                throw DecodingError.unsupportedVersion(version: String(describing: semanticVersion))
            }
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(events, forKey: .events)
        try container.encode(Self.archiveVersion, forKey: .version)
        try container.encode(agents, forKey: .agents)
    }

    private init(version1From decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.events = try container.decode([GeoJSONMessage].self, forKey: .events)
        self.agents = nil
    }

    private init(version2From decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.events = try container.decode([GeoJSONMessage].self, forKey: .events)
        self.agents = try container.decode(String?.self, forKey: .agents)
    }
}
