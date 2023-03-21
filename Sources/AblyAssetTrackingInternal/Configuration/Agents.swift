import Ably
import AblyAssetTrackingCore

public struct Agents {
    private struct Agent {
        public var name: String
        public var version: String?

        init(name: String, version: String?) {
            self.name = name
            self.version = version
        }
    }

    private var agents: [Agent]

    public static let libraryAgents: Agents = .init(agents: [
        .init(name: "ably-asset-tracking-swift", version: Version.libraryVersion)
    ])
}

extension Agents {
    public var ablyCocoaAgentsDictionary: [String: String] {
        agents.reduce(into: [:]) { dict, agent in
            dict[agent.name] = agent.version ?? ARTClientInformationAgentNotVersioned
        }
    }
}
