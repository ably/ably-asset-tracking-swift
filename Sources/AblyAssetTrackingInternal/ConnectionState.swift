import AblyAssetTrackingCore
import Foundation

/**
 The state of connectivity to the Ably service.
 */
public enum ConnectionState: Int {
    case online
    case offline

    /**
     Connection has failed
     */
    case failed

    /**
     Connection has closed
     */
    case closed
}

extension ConnectionState {
    var string: String {
        switch self {
        case .online:
            return "online"
        case .offline:
            return "offline"
        case .failed:
            return "failed"
        case .closed:
            return "closed"
        }
    }

    // swiftlint:disable:next missing_docs
    public var description: String {
        "ConnectionState.\(string)"
    }
}

/**
 A change in state of a connection to the Ably service.
 */
public struct ConnectionStateChange {
    // swiftlint:disable:next missing_docs
    public init(state: ConnectionState, errorInformation: ErrorInformation?) {
        self.state = state
        self.errorInformation = errorInformation
    }

    /**
    The new state, which is now current.
     */
    public let state: ConnectionState

    /**
    Information about what went wrong, if state is `failed` or failing in some way.
     */
    public let errorInformation: ErrorInformation?
}
