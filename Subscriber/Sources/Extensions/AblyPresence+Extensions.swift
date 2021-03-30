extension AblyPresence {
    func toConnectionState() -> ConnectionState {
        switch self {
        case .enter, .present, .update:
            return .online
        default:
            return .offline
        }
    }
}
