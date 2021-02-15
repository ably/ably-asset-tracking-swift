import Foundation
import Ably

/**
 Public wrapper for ARTRealtimeConnectionState, as we don't want to pass it to our clients
 */

extension ARTRealtimeConnectionState {
    func toConnectionState() -> ConnectionState {
        switch self {
        case .connected: return ConnectionState.online
        case .initialized, .connecting, .disconnected, .suspended, .closing, .closed: return ConnectionState.offline
        case .failed: return ConnectionState.failed
        @unknown default: fatalError("Unknown ARTRealtimeConnectionState detected: \(self)")
        }
    }
}
