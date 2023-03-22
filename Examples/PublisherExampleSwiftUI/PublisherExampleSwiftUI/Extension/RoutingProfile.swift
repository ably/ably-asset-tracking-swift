import AblyAssetTrackingPublisher

extension RoutingProfile {
    static var all: [RoutingProfile] = [.driving, .drivingTraffic, .cycling, .walking]

    func asInfo() -> String {
        switch self {
        case .driving:
            return "Driving"
        case .cycling:
            return "Cycling"
        case .walking:
            return "Walking"
        case .drivingTraffic:
            return "Driving (traffic)"
        }
    }
}
