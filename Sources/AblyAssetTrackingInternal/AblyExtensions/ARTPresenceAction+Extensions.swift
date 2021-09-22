import Ably
import AblyAssetTrackingCore

public extension ARTPresenceAction {
    func toPresence() -> Presence {
        switch self {
        case .absent: return .absent
        case .present: return .present
        case .enter: return .enter
        case .leave: return .leave
        case .update: return .update
        @unknown default: return .unknown
        }
    }
}
