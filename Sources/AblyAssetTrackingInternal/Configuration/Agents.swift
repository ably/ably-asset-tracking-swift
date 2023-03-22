import Ably
import AblyAssetTrackingCore

// swiftlint:disable:next missing_docs
public struct Agents {
    private struct Agent {
        fileprivate var name: String
        fileprivate var version: String?

        init(name: String, version: String?) {
            self.name = name
            self.version = version
        }
    }

    private var agents: [Agent]

    // swiftlint:disable:next missing_docs
    public static let libraryAgents: Agents = .init(agents: [
        .init(name: "ably-asset-tracking-swift", version: Version.libraryVersion)
    ])
}

extension Agents {
    // swiftlint:disable:next missing_docs
    public var ablyCocoaAgentsDictionary: [String: String] {
        agents.reduce(into: [:]) { dict, agent in
            dict[agent.name] = agent.version ?? ARTClientInformationAgentNotVersioned
        }
    }
}
