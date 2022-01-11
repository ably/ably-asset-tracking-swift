
import CoreLocation

public extension CLLocation {
    func toLocation() -> Location {
        var courseAccuracy: Double = 0.0
        if #available(iOS 13.4, *) {
            courseAccuracy = self.courseAccuracy
        }
        
        var ellipsoidalAltitude: Double = 0.0
        if #available(iOS 15.0, *) {
            ellipsoidalAltitude = self.ellipsoidalAltitude
        }
        
        return Location(
            latitude: self.coordinate.latitude,
            longitude: self.coordinate.longitude,
            altitude: self.altitude,
            ellipsoidalAltitude: ellipsoidalAltitude,
            horizontalAccuracy: self.horizontalAccuracy,
            verticalAccuracy: self.verticalAccuracy,
            course: self.course,
            courseAccuracy: courseAccuracy,
            speed: self.speed,
            speedAccuracy: self.speedAccuracy,
            timestamp: self.timestamp.timeIntervalSince1970
        )
    }
}
