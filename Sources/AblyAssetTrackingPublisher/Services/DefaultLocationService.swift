import CoreLocation
import MapboxCoreNavigation
import MapboxDirections
import AblyAssetTrackingCore

class DefaultLocationService: LocationService {
    private let locationManager: PassiveLocationManager
    private let replayLocationManager: ReplayLocationManager?

    weak var delegate: LocationServiceDelegate?

    init(mapboxConfiguration: MapboxConfiguration, historyLocation: [CLLocation]?) {
        let directions = Directions(credentials: mapboxConfiguration.getCredentials())
        NavigationSettings.shared.initialize(directions: directions, tileStoreConfiguration: .default)
        
        if let historyLocation = historyLocation {
            replayLocationManager = ReplayLocationManager(locations: historyLocation)
        } else {
            replayLocationManager = nil
        }
        
        self.locationManager = PassiveLocationManager(systemLocationManager: replayLocationManager)
        self.locationManager.delegate = self
    }

    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
        replayLocationManager?.startUpdatingLocation()
    }

    func stopUpdatingLocation() {
        locationManager.systemLocationManager.stopUpdatingLocation()
    }

    func changeLocationEngineResolution(resolution: Resolution) {
        // TODO: Implement method
    }
}

extension DefaultLocationService: PassiveLocationManagerDelegate {
    func passiveLocationManagerDidChangeAuthorization(_ manager: PassiveLocationManager) {
        logger.debug("passiveLocationManager.passiveLocationManagerDidChangeAuthorization", source: String(describing: Self.self))
    }
    
    func passiveLocationManager(_ manager: PassiveLocationManager, didUpdateLocation location: CLLocation, rawLocation: CLLocation) {
        delegate?.locationService(sender: self, didUpdateEnhancedLocationUpdate: EnhancedLocationUpdate(location: location))
    }
    
    func passiveLocationManager(_ manager: PassiveLocationManager, didUpdateHeading newHeading: CLHeading) {
        logger.debug("passiveLocationManager.didUpdateHeading", source: String(describing: Self.self))
    }
    
    func passiveLocationManager(_ manager: PassiveLocationManager, didFailWithError error: Error) {
        logger.error("passiveLocationManager.didFailWithError", source: "DefaultLocationService")
        let errorInformation = ErrorInformation(type: .publisherError(errorMessage: error.localizedDescription))
        delegate?.locationService(sender: self, didFailWithError: errorInformation)
    }
}
