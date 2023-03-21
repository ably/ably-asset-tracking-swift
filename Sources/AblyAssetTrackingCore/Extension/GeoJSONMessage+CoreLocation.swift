import CoreLocation

public extension GeoJSONMessage {
    func toCoreLocation() -> CLLocation {
        CLLocation(
            coordinate: CLLocationCoordinate2D(latitude: geometry.latitude, longitude: geometry.longitude),
            altitude: geometry.altitude,
            horizontalAccuracy: properties.accuracyHorizontal ?? -1,
            verticalAccuracy: properties.accuracyVertical ?? -1,
            course: properties.bearing ?? -1,
            speed: properties.speed ?? -1,
            timestamp: Date(timeIntervalSince1970: properties.time)
        )
    }
}
