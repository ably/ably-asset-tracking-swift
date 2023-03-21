import AblyAssetTrackingPublisher

extension RoutingProfile {

    func description() -> String {
        switch self {
        case .driving:
            return "driving"
        case .drivingTraffic:
            return "drivingTraffic"
        case .walking:
            return "walking"
        case .cycling:
            return "cycling"
        }
    }

    static func fromDescription(description: String) -> RoutingProfile {
        if description == "driving" {
            return .driving
        }
        if description == "drivingTraffic" {
            return .drivingTraffic
        }
        if description == "walking" {
            return .walking
        }
        if description == "cycling" {
            return .cycling
        }
        return .driving
    }
}
