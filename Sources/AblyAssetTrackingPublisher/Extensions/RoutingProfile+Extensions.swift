import MapboxDirections

extension RoutingProfile {
    func toMapboxProfileIdentifier() -> DirectionsProfileIdentifier {
        switch self {
        case .driving: return DirectionsProfileIdentifier.automobile
        case .cycling: return DirectionsProfileIdentifier.cycling
        case .walking: return DirectionsProfileIdentifier.walking
        case .drivingTraffic: return DirectionsProfileIdentifier.automobileAvoidingTraffic
        }
    }
}
