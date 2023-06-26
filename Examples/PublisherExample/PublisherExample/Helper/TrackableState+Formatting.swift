import AblyAssetTrackingCore

extension TrackableState {
    func asInfo() -> String {
        switch self {
        case .online:
            return "Online"
        case .offline:
            return "Offline"
        case .failed:
            return "Failed"
        }
    }
}
