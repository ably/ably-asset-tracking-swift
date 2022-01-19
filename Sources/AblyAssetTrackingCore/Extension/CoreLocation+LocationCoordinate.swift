
import CoreLocation

public extension CLLocationCoordinate2D {
    func toLocationCoordinate() -> LocationCoordinate {
        LocationCoordinate(latitude: self.latitude, longitude: self.longitude)
    }
}
