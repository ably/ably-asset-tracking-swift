import Ably

/**
Wrapper for ARTRealtimeChannelState, as we don't want to pass it to our clients
 */

extension ARTRealtimeChannelState {
    func toConnectionState() -> ConnectionState {
        switch self {
        case .attached:
            return .online
        case .failed:
            return .failed
        default:
            return .offline
        }
    }
}
