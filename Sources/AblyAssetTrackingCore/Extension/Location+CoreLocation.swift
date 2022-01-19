
import CoreLocation

public extension Location {
    func toCoreLocation() -> CLLocation {
        let date = Date(timeIntervalSince1970: self.timestamp)
        
        if #available(iOS 15.0, *) {
            return CLLocation(
                coordinate: self.coordinate.toCoreLocationCoordinate2d(),
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
                coordinate: self.coordinate.toCoreLocationCoordinate2d(),
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
                coordinate: self.coordinate.toCoreLocationCoordinate2d(),
                altitude: self.altitude,
                horizontalAccuracy: self.horizontalAccuracy,
                verticalAccuracy: self.verticalAccuracy,
                course: self.course,
                speed: self.speed,
                timestamp: date
            )
        }
    }
    
    func distance(from: Location) -> Double {
        self.toCoreLocation().distance(from: from.toCoreLocation())
    }
}
