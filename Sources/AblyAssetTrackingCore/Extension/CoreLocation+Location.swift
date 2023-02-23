
import CoreLocation

public extension CLLocation {
    func toLocation() -> Result<Location, LocationValidationError> {
        var courseAccuracy: Double = -1
        if #available(iOS 13.4, *) {
            courseAccuracy = self.courseAccuracy
        }
        
        var ellipsoidalAltitude: Double = .zero
        if #available(iOS 15.0, *) {
            ellipsoidalAltitude = self.ellipsoidalAltitude
        }
        
        return Location(
            coordinate: self.coordinate.toLocationCoordinate(),
            altitude: self.altitude,
            ellipsoidalAltitude: ellipsoidalAltitude,
            horizontalAccuracy: self.horizontalAccuracy,
            verticalAccuracy: self.verticalAccuracy,
            course: self.course,
            courseAccuracy: courseAccuracy,
            speed: self.speed,
            speedAccuracy: self.speedAccuracy,
            floorLevel: self.floor?.level,
            timestamp: self.timestamp.timeIntervalSince1970
        )
        .sanitize()
        .validate()
    }
}
