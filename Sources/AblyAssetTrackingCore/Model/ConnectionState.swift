import Foundation

/**
 Indicates Asset connection status (i.e. if courier is publishing their location)
 */
public enum ConnectionState: Int {
    /**
     Asset is connected to tracking system and we're receiving their position
     */
    case online
    
    /**
     Asset state is publishing when its locations are being published but it is not able to detect subscribers or receive data from them.
     This state allows the asset to be actively tracked, however, its features are limited compared to the online state.
     This state can change to either online, offline or failed.
     */
    case publishing
    
    /**
     Asset is not connected
     */
    case offline
    
    /**
     Connection has failed
     */
    case failed
}

extension ConnectionState {
    var string: String {
        get {
            switch self {
            case .online:
                return "online"
            case .publishing:
                return "publishing"
            case .offline:
                return "offline"
            case .failed:
                return "failed"
            }
        }
    }
    public var description: String {
        "ConnectionState.\(string)"
    }
}

/**
 * A change in state of a connection to the Ably service.
 */
public struct ConnectionStateChange {
    public init(state: ConnectionState, errorInformation: ErrorInformation?) {
        self.state = state
        self.errorInformation = errorInformation
    }
    
    public let state: ConnectionState
    public let errorInformation: ErrorInformation?
}
