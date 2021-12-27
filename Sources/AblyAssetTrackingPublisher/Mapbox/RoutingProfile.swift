import Foundation

// swiftlint:disable trailing_whitespace

/**
 Represents the mean of transport that's being used.
 */
public enum RoutingProfile: Int {
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
