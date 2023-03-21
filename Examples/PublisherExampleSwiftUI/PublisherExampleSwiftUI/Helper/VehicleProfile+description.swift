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

    static func fromDescription(description: String) -> VehicleProfile {
        if description == "car" {
            return .car
        }
        if description == "bicycle" {
            return .bicycle
        }

        return .car
    }
}
