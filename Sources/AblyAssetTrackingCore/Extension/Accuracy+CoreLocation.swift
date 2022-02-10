import CoreLocation

public extension Accuracy {
    func toCoreLocationAccuracy() -> CLLocationAccuracy {
        switch self {
        case .minimum:
            if #available(iOS 14, *) {
                return kCLLocationAccuracyReduced
            } else {
                return kCLLocationAccuracyThreeKilometers
            }
        case .low:
            return kCLLocationAccuracyKilometer
        case .balanced:
            return kCLLocationAccuracyNearestTenMeters
        case .high:
            return kCLLocationAccuracyBest
        case .maximum:
            return kCLLocationAccuracyBestForNavigation
        }
    }
}
