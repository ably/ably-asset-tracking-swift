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

    init(locationUpdate: EnhancedLocationUpdate) {
        self.location = GeoJSONMessage(location: locationUpdate.location)
    }
}
