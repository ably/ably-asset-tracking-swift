import CoreLocation

public extension LocationCoordinate {
    func toCoreLocationCoordinate2d() -> CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
    }
}
