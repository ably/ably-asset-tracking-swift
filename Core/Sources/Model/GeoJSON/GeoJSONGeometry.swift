import CoreLocation

/**
 Helper class used in `GeoJSONMessage` to map GeoJSON geometry field (as defined at https://geojson.org ).
 When encoded or decoded from JSON, it produces the following structure:
 ````
 {
    "type": "Point",
    "coordinates": [1.0, 2.0] // [Lon, Lat]
 }
 ````
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
              let longitude = coordinates.first,
              let latitude = coordinates.last
        else {
            throw AblyError.inconsistentData("Invalid count of coordinates in GeoJSONGeometry. Received: \(coordinates)")
        }
        
        guard (latitude >= -90.0 && latitude <= 90.0)
        else {
            throw AblyError.inconsistentData("Latitude out of range [-90, 90]. Received: (\(latitude))")
        }
        
        guard  (longitude >= -180.0 && longitude <= 180.0)
        else {
            throw AblyError.inconsistentData("Longitude out of range [-180, 180]. Received (\(longitude))")
        }
        
        self.latitude = latitude
        self.longitude = longitude
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encode([longitude, latitude], forKey: .coordinates)        
    }
    
    init(location: CLLocation) {
        type = .point
        latitude = location.coordinate.latitude
        longitude = location.coordinate.longitude
    }
}
