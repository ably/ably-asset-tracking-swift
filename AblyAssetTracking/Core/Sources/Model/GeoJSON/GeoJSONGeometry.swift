import CoreLocation

/**
 Part of DTO used in `GeoJSONMessage`, used to map GeoJSON geometry field (as defined in https://geojson.org ).
 */
class GeoJSONGeometry: Codable {
    let type: GeoJSONType
    let latitude: Double
    let longitude: Double
    
    enum CodingKeys: String, CodingKey {
        case coordinates
        case latitude
        case longitude
        case type
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(GeoJSONType.self, forKey: .type)
        
        let coordinates = try container.decode(Array<Double>.self, forKey: .coordinates)
        guard coordinates.count == 2,
              let latitude = coordinates.first,
              let longitude = coordinates.last
        else {
            throw AblyError.inconsistentData("Invalid count of coordinates in GeoJSONGeometry. Received \(coordinates)")
        }
        
        self.latitude = latitude
        self.longitude = longitude
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encode([latitude, longitude], forKey: .coordinates)        
    }
    
    init(location: CLLocation) {
        type = .point
        latitude = location.coordinate.latitude
        longitude = location.coordinate.longitude
    }
}
