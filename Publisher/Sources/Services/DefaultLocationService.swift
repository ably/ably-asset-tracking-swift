import CoreLocation
import MapboxCoreNavigation
import MapboxDirections

class DefaultLocationService: LocationService {
    private let locationDataSource: PassiveLocationDataSource

    weak var delegate: LocationServiceDelegate?

    init(mapboxConfiguration: MapboxConfiguration) {
        let directions = Directions(credentials: mapboxConfiguration.getCredentians())
        self.locationDataSource = PassiveLocationDataSource(directions: directions, systemLocationManager: nil)

        self.locationDataSource.delegate = self
    }

    func startUpdatingLocation() {
        locationDataSource.startUpdatingLocation { [weak self] (error) in
            if let error = error,
               let self = self {
                logger.error("Error while starting location updates: \(error)", source: "DefaultLocationService")
                let errorInformation = ErrorInformation(type: .publisherError(errorMessage: "Error while starting location updates: \(error)"))
                self.delegate?.locationService(sender: self, didFailWithError: errorInformation)
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

extension DefaultLocationService: PassiveLocationDataSourceDelegate {
    func passiveLocationDataSource(_ dataSource: PassiveLocationDataSource,
                                   didUpdateLocation location: CLLocation,
                                   rawLocation: CLLocation) {
        delegate?.locationService(sender: self, didUpdateEnhancedLocationUpdate: EnhancedLocationUpdate(location: location))
    }

    func passiveLocationDataSource(_ dataSource: PassiveLocationDataSource, didFailWithError error: Error) {
        logger.error("passiveLocationDataSource.didFailWithError", source: "DefaultLocationService")
        let errorInformation = ErrorInformation(type: .publisherError(errorMessage: error.localizedDescription))
        delegate?.locationService(sender: self, didFailWithError: errorInformation)
    }

    func passiveLocationDataSource(_ dataSource: PassiveLocationDataSource, didUpdateHeading newHeading: CLHeading) {
        logger.debug("passiveLocationDataSource.didUpdateHeading", source: "DefaultLocationService")
    }

    func passiveLocationDataSourceDidChangeAuthorization(_ dataSource: PassiveLocationDataSource) {
        logger.debug("passiveLocationDataSource.passiveLocationDataSourceDidChangeAuthorization", source: "DefaultLocationService")
    }
}
