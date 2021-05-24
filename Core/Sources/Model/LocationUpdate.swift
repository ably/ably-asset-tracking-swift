import CoreLocation

/**
 Enumeration used to determine enhanced location type.
 */
enum LocationUpdateType: String, Codable {
    case predicted = "PREDICTED"
    case actual = "ACTUAL"
}

/**
 Model used to handle location updates.
 */
class EnhancedLocationUpdate {
    let location: CLLocation

    var type: LocationUpdateType {
        return .actual
    }

    init(location: CLLocation) {
        self.location = location
    }
}

class EnhancedLocationUpdateMessage: Codable {
    let location: GeoJSONMessage
    let intermediateLocations: [GeoJSONMessage]
    let type: LocationUpdateType

    init(locationUpdate: EnhancedLocationUpdate) throws {
        self.location = try GeoJSONMessage(location: locationUpdate.location)
        self.intermediateLocations = []
        self.type = locationUpdate.type
    }
}
