import CoreLocation
import MapboxCoreNavigation

class PassiveLocationService: LocationService {
    private let locationDataSource: PassiveLocationDataSource

    weak var delegate: LocationServiceDelegate?

    init() {
        self.locationDataSource = PassiveLocationDataSource()
        self.locationDataSource.delegate = self
    }

    func startUpdatingLocation() {
        locationDataSource.startUpdatingLocation { [weak self] (error) in
            if let error = error,
               let self = self {
                logger.error("Error while starting location updates: \(error)", source: "LocationService")
                self.delegate?.locationService(sender: self, didFailWithError: error)
            }
        }
    }

    func stopUpdatingLocation() {
        locationDataSource.systemLocationManager.stopUpdatingLocation()
    }

    func changeLocationEngineResolution(resolution: Resolution) {
        // TODO: Implement method
    }
}

extension PassiveLocationService: PassiveLocationDataSourceDelegate {
    func passiveLocationDataSource(_ dataSource: PassiveLocationDataSource,
                                   didUpdateLocation location: CLLocation,
                                   rawLocation: CLLocation) {
        delegate?.locationService(sender: self, didUpdateRawLocation: rawLocation)
        delegate?.locationService(sender: self, didUpdateEnhancedLocation: location)
    }

    func passiveLocationDataSource(_ dataSource: PassiveLocationDataSource, didFailWithError error: Error) {
        delegate?.locationService(sender: self, didFailWithError: error)
    }

    func passiveLocationDataSource(_ dataSource: PassiveLocationDataSource, didUpdateHeading newHeading: CLHeading) {
        logger.debug("passiveLocationDataSource.didUpdateHeading", source: "LocationService")
    }

    func passiveLocationDataSourceDidChangeAuthorization(_ dataSource: PassiveLocationDataSource) {
        logger.debug("passiveLocationDataSource.passiveLocationDataSourceDidChangeAuthorization", source: "LocationService")
    }
}
