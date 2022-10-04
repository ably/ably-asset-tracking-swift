
/**
 Enumeration used to determine enhanced location type.
 */
public enum LocationUpdateType: String, Codable {
    case predicted = "PREDICTED"
    case actual = "ACTUAL"
}

/**
 Model used to handle location updates.
 */
public class EnhancedLocationUpdate: LocationUpdate {
    public let location: Location
    public var skippedLocations: [Location] = []

    public var type: LocationUpdateType {
        return .actual
    }

    public init(location: Location) {
        self.location = location
    }
    
}

extension EnhancedLocationUpdate: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "{ location: \(String(reflecting: location)), skippedLocations: \(String(reflecting: skippedLocations)), type: \(String(reflecting: type)) }"
    }
}

extension EnhancedLocationUpdate: Equatable {
    public static func == (lhs: EnhancedLocationUpdate, rhs: EnhancedLocationUpdate) -> Bool {
        lhs.location == rhs.location && lhs.skippedLocations == rhs.skippedLocations && lhs.type == rhs.type
    }
}
