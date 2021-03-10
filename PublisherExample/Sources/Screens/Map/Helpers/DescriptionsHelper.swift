import AblyAssetTracking

extension RoutingProfile {
    var description: String {
        switch self {
        case .driving: return "Driving"
        case .cycling: return "Cycling"
        case .walking: return "Walking"
        case .drivingTraffic: return "Driving traffic"
        }
    }
}

class DescriptionsHelper {
    // MARK: - RoutingProfile
    class RoutingProfileDescHelper {
        static func getDescription(for routingProfile: RoutingProfile) -> String {
            return "Routing profile: \(routingProfile.description)"
        }
    }
    
    // MARK: - ResolutionState
    enum ResolutionState {
        case none
        case notEmpty(_: Resolution)
    }
    
    class ResolutionStateHelper {
        static func getDescription(for state: ResolutionState) -> String {
            switch state {
            case .none:
                return "Resolution: None"
            case .notEmpty(let resolution):
                return """
                    Resolution:
                    Accuracy: \(resolution.accuracy)
                    Minimum displacement: \(resolution.minimumDisplacement)
                    Desired interval: \(resolution.desiredInterval)
                    """
            }
        }
    }
    
    // MARK: ConnectionState
    class ConnectionStateHelper {
        static func getDescriptionAndColor(for state: ConnectionState) -> (desc: String, color: UIColor) {
            switch state {
            case .online:
                return ("online", .systemGreen)
            case .offline, .failed:
                return ("offline", .systemRed)
            }
        }
    }
}
