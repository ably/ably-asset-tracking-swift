import UIKit
import MapboxDirections

/**
 Represents the means of transport that's being used.
 */
public enum RoutingProfile: String, Codable {
    /**
     For car and motorcycle routing. This profile prefers high-speed roads like highways.
    */
    case driving
    
    /**
     For bicycle routing. This profile prefers routes that are safe for cyclist, avoiding highways and preferring streets with bike lanes.
    */
    case cycling
    
    /**
     For pedestrian and hiking routing. This profile prefers sidewalks and trails.
    */
    case walking
    
    /**
     For car and motorcycle routing. This profile factors in current and historic traffic conditions to avoid slowdowns.
    */
    case drivingTraffic
}

extension RoutingProfile {
    func toMapboxProfileIdentifier() -> DirectionsProfileIdentifier {
        switch self {
        case .driving:
            return DirectionsProfileIdentifier.automobile
        case .cycling:
            return DirectionsProfileIdentifier.cycling
        case .walking:
            return DirectionsProfileIdentifier.walking
        case .drivingTraffic:
            return DirectionsProfileIdentifier.automobileAvoidingTraffic
        }
    }
}
