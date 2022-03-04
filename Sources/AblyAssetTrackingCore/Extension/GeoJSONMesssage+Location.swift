import Foundation

public extension GeoJSONMessage {
    func toLocation() -> Location {
        return Location(
            coordinate: LocationCoordinate(latitude: geometry.latitude, longitude: geometry.longitude),
            altitude: geometry.altitude,
            ellipsoidalAltitude: .zero,
            horizontalAccuracy: properties.accuracyHorizontal,
            verticalAccuracy: properties.accuracyVertical ?? -1,
            course: properties.bearing ?? -1,
            courseAccuracy: properties.accuracyBearing ?? -1,
            speed: properties.speed ?? -1,
            speedAccuracy: properties.accuracySpeed ?? -1,
            floorLevel: properties.floor,
            timestamp: properties.time)
    }
}
