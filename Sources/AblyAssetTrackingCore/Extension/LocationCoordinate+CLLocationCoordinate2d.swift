import CoreLocation

public extension LocationCoordinate {
    // swiftlint:disable:next missing_docs
    func toCoreLocationCoordinate2d() -> CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
    }
}
