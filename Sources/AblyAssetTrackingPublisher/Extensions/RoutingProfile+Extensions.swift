import AblyAssetTrackingCore
import MapboxDirections

extension RoutingProfile {
    func toMapboxProfileIdentifier() -> ProfileIdentifier {
        switch self {
        case .driving: return ProfileIdentifier.automobile
        case .cycling: return ProfileIdentifier.cycling
        case .walking: return ProfileIdentifier.walking
        case .drivingTraffic: return ProfileIdentifier.automobileAvoidingTraffic
        }
    }
}
