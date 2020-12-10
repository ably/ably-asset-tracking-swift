import Foundation
import Ably

/**
 Public wrapper for ARTRealtimeConnectionState, as we don't want to pass it to our clients
 */
public enum AblyConnectionStatus {
    case initialized
    case connecting
    case connected
    case disconnected
    case suspended
    case closing
    case closed
    case failed
}

extension ARTRealtimeConnectionState {
    func toAblyConnectionStatus() -> AblyConnectionStatus {
        switch self {
        case .initialized: return AblyConnectionStatus.initialized
        case .connecting: return AblyConnectionStatus.connecting
        case .connected: return AblyConnectionStatus.connected
        case .disconnected: return AblyConnectionStatus.disconnected
        case .suspended: return AblyConnectionStatus.suspended
        case .closing: return AblyConnectionStatus.closing
        case .closed: return AblyConnectionStatus.closed
        case .failed: return AblyConnectionStatus.failed
        @unknown default: fatalError("Unknown ARTRealtimeConnectionState detected: \(self)")
        }
    }
}
