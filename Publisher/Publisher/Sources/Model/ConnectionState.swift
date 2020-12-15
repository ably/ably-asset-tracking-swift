import Foundation
import Ably

/**
 Public wrapper for ARTRealtimeConnectionState, as we don't want to pass it to our clients
 */
public enum ConnectionState {
    // swiftlint:disable missing_docs
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
    func toConnectionState() -> ConnectionState {
        switch self {
        case .initialized: return ConnectionState.initialized
        case .connecting: return ConnectionState.connecting
        case .connected: return ConnectionState.connected
        case .disconnected: return ConnectionState.disconnected
        case .suspended: return ConnectionState.suspended
        case .closing: return ConnectionState.closing
        case .closed: return ConnectionState.closed
        case .failed: return ConnectionState.failed
        @unknown default: fatalError("Unknown ARTRealtimeConnectionState detected: \(self)")
        }
    }
}
