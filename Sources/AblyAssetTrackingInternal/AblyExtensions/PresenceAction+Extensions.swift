import AblyAssetTrackingCore

public extension PresenceAction {
    func toConnectionState() -> ConnectionState {
        switch self {
        case .enter, .present, .update:
            return .online
        default:
            return .offline
        }
    }

    var isLeaveOrAbsent: Bool {
        self == .leave || self == .absent
    }

    var isPresentOrEnter: Bool {
        self == .present || self == .enter
    }
}
