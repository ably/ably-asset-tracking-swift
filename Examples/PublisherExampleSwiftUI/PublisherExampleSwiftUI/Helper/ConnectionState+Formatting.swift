import AblyAssetTrackingCore

extension ConnectionState {
    func asInfo() -> String {
        switch self {
        case .online:
            return "Online"
        case .offline:
            return "Offline"
        case .closed:
            return "Closed"
        case .failed:
            return "Failed"
        }
    }
}
