import AblyAssetTrackingCore

extension ConnectionState {
    func asInfo() -> String {
        switch self {
        case .online:
            return "Online"
        case .offline:
            return "Offline"
        case .publishing:
            return "Publishing"
        case .failed:
            return "Failed"
        }
    }
}
