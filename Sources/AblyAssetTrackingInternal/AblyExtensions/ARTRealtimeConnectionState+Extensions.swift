import Ably
import AblyAssetTrackingCore

/**
Wrapper for ARTRealtimeConnectionState, as we don't want to pass it to our clients
 */

extension ARTRealtimeConnectionState {
    // swiftlint:disable:next missing_docs
    public func toConnectionState() -> ConnectionState {
        switch self {
        case .connected:
            return ConnectionState.online
        case .closed:
            return ConnectionState.closed
        case .initialized, .connecting, .disconnected, .suspended, .closing:
            return ConnectionState.offline
        case .failed:
            return ConnectionState.failed
        @unknown default:
            fatalError("Unknown ARTRealtimeConnectionState detected: \(self)")
        }
    }
}
