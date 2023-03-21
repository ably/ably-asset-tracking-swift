import Foundation

public extension GeoJSONMessage {
    func toLocation() -> Location {
        Location(
            coordinate: LocationCoordinate(latitude: geometry.latitude, longitude: geometry.longitude),
            altitude: geometry.altitude,
            ellipsoidalAltitude: .zero,
            horizontalAccuracy: properties.accuracyHorizontal ?? -1,
            verticalAccuracy: properties.accuracyVertical ?? -1,
            course: properties.bearing ?? -1,
            courseAccuracy: properties.accuracyBearing ?? -1,
            speed: properties.speed ?? -1,
            speedAccuracy: properties.accuracySpeed ?? .zero,
            floorLevel: properties.floor,
            timestamp: properties.time
        )
    }
}
