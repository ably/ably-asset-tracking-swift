import CoreLocation

public enum LocationUpdateType: String, Codable {
    case pradicted = "PREDICTED"
    case actual = "ACTUAL"
}

public class RawLocationUpdate {
    let location: CLLocation
    
    init(location: CLLocation) {
        self.location = location
    }
}

public class EnhancedLocationUpdate {
    let location: CLLocation
    
    var type: LocationUpdateType {
        return .actual
    }
    
    init(location: CLLocation) {
        self.location = location
    }
}

public class EnhacedLocationUpdateMessage: Codable {
    let location: GeoJSONMessage
    
    init(location: CLLocation) {
        self.location = GeoJSONMessage(location: location)
    }
}
