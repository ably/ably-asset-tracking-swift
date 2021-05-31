import Ably

/**
 Wrapper enum for `ARTPresenceAction` to avoid using `Ably SDK` classes in Publisher code
 */
enum AblyPresence {
    case absent
    case present
    case enter
    case leave
    case update
    case unknown
}

extension ARTPresenceAction {
    func toAblyPresence() -> AblyPresence {
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
