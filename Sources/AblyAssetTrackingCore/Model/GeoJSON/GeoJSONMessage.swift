/**
 Class used to send location updates from Publisher to Subscriber modules.
 It's mapped to GeoJSON format (https://geojson.org) with the following structure:
 
 ````
 {
   "type": "Feature",
   "geometry": {
     "type": "Point",
     "coordinates": [1.0, 2.0, 3.0]   // [Lon, Lat, Alt]
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
public struct GeoJSONMessage: Codable {
    let type: GeoJSONType
    let geometry: GeoJSONGeometry
    let properties: GeoJSONProperties

    public init(location: Location) throws {
        type = .feature
        geometry = try GeoJSONGeometry(location: location)
        properties = try GeoJSONProperties(location: location)
    }
}
