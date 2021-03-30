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
    let batteryLevel: Float
    let intermediateLocations: [GeoJSONMessage]
    let type: LocationUpdateType

    init(locationUpdate: EnhancedLocationUpdate, batteryLevel: Float?) throws {
        self.location = try GeoJSONMessage(location: locationUpdate.location)
        self.batteryLevel = batteryLevel ?? 0
        self.intermediateLocations = []
        self.type = locationUpdate.type
    }
}
