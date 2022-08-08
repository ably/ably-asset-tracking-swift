import AblyAssetTrackingCore

public extension ClientType {
    func toPresenceType() -> PresenceType {
        switch self {
        case .subscriber:
            return .subscriber
        case .publisher:
            return .publisher
        }
    }
}
