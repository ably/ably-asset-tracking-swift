import AblyAssetTrackingCore

public extension PresenceAction {
    // swiftlint:disable:next missing_docs
    func toConnectionState() -> ConnectionState {
        switch self {
        case .enter, .present, .update:
            return .online
        default:
            return .offline
        }
    }

    // swiftlint:disable:next missing_docs
    var isLeaveOrAbsent: Bool {
        self == .leave || self == .absent
    }

    // swiftlint:disable:next missing_docs
    var isPresentOrEnter: Bool {
        self == .present || self == .enter
    }
}
