import CoreLocation

/**
 Class used to send location updates from Publisher to Subscriber modules.
 It's mapped to GeoJSON format (https://geojson.org) with the following structure:
 
 ````
 {
   "type": "Feature",
   "geometry": {
     "type": "Point",
     "coordinates": [1.0, 2.0]   // [Lon, Lat]
   },
   "properties": {
     "accuracyHorizontal": 1.0,
     "altitude": 1.0,
     "bearing": 2.0,
     "speed": 3.0,
     "time": 2.0
     ...
   }
 }
 ````
 */
class GeoJSONMessage: Codable {
    let type: GeoJSONType
    let geometry: GeoJSONGeometry
    let properties: GeoJSONProperties

    init(location: CLLocation) {
        type = .feature
        geometry = GeoJSONGeometry(location: location)
        properties = GeoJSONProperties(location: location)
        // TODO: Handle data correctness in https://github.com/ably/ably-asset-tracking-cocoa/issues/10
    }

    func toCoreLocation() -> CLLocation {
        return CLLocation(
            coordinate: CLLocationCoordinate2D(latitude: geometry.latitude, longitude: geometry.longitude),
            altitude: properties.altitude,
            horizontalAccuracy: properties.accuracyHorizontal,
            verticalAccuracy: properties.accuracyVertical ?? -1,
            course: properties.bearing ?? -1,
            speed: properties.speed ?? -1,
            timestamp: Date(timeIntervalSince1970: properties.time))
    }
}
