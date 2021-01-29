import CoreLocation

public enum LocationUpdateType: String, Codable {
    case pradicted = "PREDICTED"
    case actual = "ACTUAL"
}

public class EnhancedLocationUpdate {
    public let location: CLLocation
    
    var type: LocationUpdateType {
        return .actual
    }
    
    public init(location: CLLocation) {
        self.location = location
    }
}

public class EnhacedLocationUpdateMessage: Codable {
    public let location: GeoJSONMessage
    
    public init(locationUpdate: EnhancedLocationUpdate) {
        self.location = GeoJSONMessage(location: locationUpdate.location)
    }
}
