import Ably
import AblyAssetTrackingCore

/**
Wrapper for ARTRealtimeChannelState, as we don't want to pass it to our clients
 */

extension ARTRealtimeChannelState {
    // swiftlint:disable:next missing_docs
    public func toConnectionState() -> ConnectionState {
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
