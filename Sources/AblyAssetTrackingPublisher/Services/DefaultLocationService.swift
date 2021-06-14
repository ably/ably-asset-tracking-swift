import CoreLocation
import MapboxCoreNavigation
import MapboxDirections
import AblyAssetTrackingCore

class DefaultLocationService: LocationService {
    private let locationDataSource: PassiveLocationDataSource
    private let replayLocationManager: ReplayLocationManager?

    weak var delegate: LocationServiceDelegate?

    init(mapboxConfiguration: MapboxConfiguration, historyLocation: [CLLocation]?) {
        if let historyLocation = historyLocation {
            replayLocationManager = ReplayLocationManager(locations: historyLocation)
        } else {
            replayLocationManager = nil
        }

        let directions = Directions(credentials: mapboxConfiguration.getCredentians())
        self.locationDataSource = PassiveLocationDataSource(directions: directions, systemLocationManager: replayLocationManager)

        self.locationDataSource.delegate = self
    }

    func startUpdatingLocation() {
        locationDataSource.startUpdatingLocation()
        replayLocationManager?.startUpdatingLocation()
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
