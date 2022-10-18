import AblyAssetTrackingPublisher

extension VehicleProfile {
    func description() -> String {
        switch self {
        case .bicycle:
            return "bicycle"
        case .car:
            return "car"
        }
    }
}
