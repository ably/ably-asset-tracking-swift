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
        return self == .leave || self == .absent
    }

    var isPresentOrEnter: Bool {
        return self == .present || self == .enter
    }
}
