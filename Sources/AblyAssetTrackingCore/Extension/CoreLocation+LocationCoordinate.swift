import CoreLocation

public extension CLLocationCoordinate2D {
    // swiftlint:disable:next missing_docs
    func toLocationCoordinate() -> LocationCoordinate {
        LocationCoordinate(latitude: self.latitude, longitude: self.longitude)
    }
}
