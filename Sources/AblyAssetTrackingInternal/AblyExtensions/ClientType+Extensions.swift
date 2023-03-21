import AblyAssetTrackingCore

public extension ClientType {
    // swiftlint:disable:next missing_docs
    func toPresenceType() -> PresenceType {
        switch self {
        case .subscriber:
            return .subscriber
        case .publisher:
            return .publisher
        }
    }
}
