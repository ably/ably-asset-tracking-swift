import Ably

/**
 Wrapper enum for `ARTPresenceAction` to avoid using `Ably SDK` classes in Publisher code
 */
enum AblyPublisherPresence {
    case absent
    case present
    case enter
    case leave
    case update
    case unknown
    
    func toConnectionState() -> ConnectionState {
        switch self {
        case .enter, .present, .update:
            return .online
        default:
            return .offline
        }
    }
}

extension ARTPresenceAction {
    func toAblyPublisherPresence() -> AblyPublisherPresence {
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
