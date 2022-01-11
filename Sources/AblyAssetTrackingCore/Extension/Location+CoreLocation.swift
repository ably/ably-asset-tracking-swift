
import CoreLocation

public extension Location {
    func toCoreLocation() -> CLLocation {
        let coordinates = CLLocationCoordinate2D(
            latitude: self.latitude,
            longitude: self.longitude
        )
        
        let date = Date(timeIntervalSince1970: self.timestamp)
        
        if #available(iOS 15.0, *) {
            return CLLocation(
                coordinate: coordinates,
                altitude: self.altitude,
                horizontalAccuracy: self.horizontalAccuracy,
                verticalAccuracy: self.verticalAccuracy,
                course: self.course,
                courseAccuracy: self.courseAccuracy,
                speed: self.speed,
                speedAccuracy: self.speedAccuracy,
                timestamp: date
            )
            
        } else if #available(iOS 13.4, *) {
            return CLLocation(
                coordinate: coordinates,
                altitude: self.altitude,
                horizontalAccuracy: self.horizontalAccuracy,
                verticalAccuracy: self.verticalAccuracy,
                course: self.course,
                courseAccuracy: self.courseAccuracy,
                speed: self.speed,
                speedAccuracy: self.speedAccuracy,
                timestamp: date
            )
            
        } else {
            return CLLocation(
                coordinate: coordinates,
                altitude: self.altitude,
                horizontalAccuracy: self.horizontalAccuracy,
                verticalAccuracy: self.verticalAccuracy,
                course: self.course,
                speed: self.speed,
                timestamp: date
            )
        }
    }
}
