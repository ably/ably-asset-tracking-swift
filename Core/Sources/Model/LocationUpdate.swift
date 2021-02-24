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

public class EnhancedLocationUpdateMessage: Codable {
    let location: GeoJSONMessage
    let batteryStatus: Float

    init(locationUpdate: EnhancedLocationUpdate, batteryLevel: Float?) throws {
        self.location = try GeoJSONMessage(location: locationUpdate.location)
        self.batteryStatus = batteryLevel ?? 0
    }
}
