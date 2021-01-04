import Ably

enum AblyPublisherPresence {
    case absent
    case present
    case enter
    case leave
    case update
    case unknown
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
