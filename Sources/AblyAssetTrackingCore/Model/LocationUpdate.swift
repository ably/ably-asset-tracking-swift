import CoreLocation

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
public class EnhancedLocationUpdate {
    public let location: CLLocation

    public var type: LocationUpdateType {
        return .actual
    }

    public init(location: CLLocation) {
        self.location = location
    }
}

public class EnhancedLocationUpdateMessage: Codable {
    public let location: GeoJSONMessage
    public let intermediateLocations: [GeoJSONMessage]
    public let type: LocationUpdateType

    public init(locationUpdate: EnhancedLocationUpdate) throws {
        self.location = try GeoJSONMessage(location: locationUpdate.location)
        self.intermediateLocations = []
        self.type = locationUpdate.type
    }
}
