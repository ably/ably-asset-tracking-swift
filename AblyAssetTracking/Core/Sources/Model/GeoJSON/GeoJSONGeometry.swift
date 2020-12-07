import CoreLocation

/**
 Part of DTO used in `GeoJSONMessage`, used to map GeoJSON geometry field (as defined in https://geojson.org ).
 */
class GeoJSONGeometry: Codable {
    let type: GeoJSONType
    let coordinates: Array<Double> // Array of two elements: [Lon, Lat]
    
    init(location: CLLocation) {
        type = .point
        coordinates = [location.coordinate.longitude, location.coordinate.latitude]
    }
}
