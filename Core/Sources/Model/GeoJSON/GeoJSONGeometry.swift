import CoreLocation

/**
 Helper class used in `GeoJSONMessage` to map GeoJSON geometry field (as defined at https://geojson.org ).
 When encoded or decoded from JSON, it produces the following structure:
 ````
 {
    "type": "Point",
    "coordinates": [1.0, 2.0, 3.0] // [Lon, Lat, Alt]
 }
 ````
 */
class GeoJSONGeometry: Codable {
    let type: GeoJSONType
    let latitude: Double
    let longitude: Double
    let altitude: Double
    
    private let longitudeIndex = 0
    private let latitudeIndex = 1
    private let altitudeIndex = 2

    enum CodingKeys: String, CodingKey {
        case coordinates
        case latitude
        case longitude
        case altitude
        case type
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(GeoJSONType.self, forKey: .type)

        let coordinates = try container.decode(Array<Double>.self, forKey: .coordinates)
        guard coordinates.count == 3,
              let longitude = coordinates.element(at: longitudeIndex),
              let latitude = coordinates.element(at: latitudeIndex),
              let altitude = coordinates.element(at: altitudeIndex)
        else {
            throw ErrorInformation(type: .commonError(errorMessage: "Invalid count of coordinates in GeoJSONGeometry. Received: \(coordinates)"))
        }

        guard latitude >= -90.0 && latitude <= 90.0
        else {
            throw ErrorInformation(type: .commonError(errorMessage: "Latitude out of range [-90, 90]. Received: (\(latitude))"))
        }

        guard  longitude >= -180.0 && longitude <= 180.0
        else {
            throw ErrorInformation(type: .commonError(errorMessage: "Longitude out of range [-180, 180]. Received (\(longitude))"))
        }

        self.latitude = latitude
        self.longitude = longitude
        self.altitude = altitude
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encode([longitude, latitude, altitude], forKey: .coordinates)
    }

    init(location: CLLocation) {
        type = .point
        latitude = location.coordinate.latitude
        longitude = location.coordinate.longitude
        altitude = location.altitude
    }
}

private extension Collection {
    func element(at index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
