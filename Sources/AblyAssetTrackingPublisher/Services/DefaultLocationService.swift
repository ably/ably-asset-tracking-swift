import CoreLocation
import MapboxCoreNavigation
import MapboxDirections
import AblyAssetTrackingCore

class DefaultLocationService: LocationService {
    private let locationManager: PassiveLocationManager
    private let replayLocationManager: ReplayLocationManager?
    private let logHandler: LogHandler?

    weak var delegate: LocationServiceDelegate?

    init(mapboxConfiguration: MapboxConfiguration,
         historyLocation: [CLLocation]?,
         logHandler: LogHandler?) {
        
        let directions = Directions(credentials: mapboxConfiguration.getCredentials())
        NavigationSettings.shared.initialize(directions: directions, tileStoreConfiguration: .default)
        
        if let historyLocation = historyLocation {
            replayLocationManager = ReplayLocationManager(locations: historyLocation)
        } else {
            replayLocationManager = nil
        }
        self.logHandler = logHandler

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
        /**
         It's not possible to change time interval for location updates in `CLLocationManager` from Apple `CoreLocation` framework.
         Documentation: https://developer.apple.com/documentation/corelocation/cllocationmanager
         */
        locationManager.systemLocationManager.desiredAccuracy = resolution.accuracy.toCoreLocationAccuracy()
        locationManager.systemLocationManager.distanceFilter = resolution.minimumDisplacement
    }
}

extension DefaultLocationService: PassiveLocationManagerDelegate {
    func passiveLocationManagerDidChangeAuthorization(_ manager: PassiveLocationManager) {
        logHandler?.debug(message: "\(String(describing: Self.self)), passiveLocationManager.passiveLocationManagerDidChangeAuthorization", error: nil)
    }
    
    func passiveLocationManager(_ manager: PassiveLocationManager, didUpdateLocation location: CLLocation, rawLocation: CLLocation) {
        logHandler?.verbose(message: "\(String(describing: Self.self)), passiveLocationManager(\(manager), didUpdateLocation: \(String(reflecting: location)), rawLocation: \(String(reflecting: rawLocation))", error: nil)
        delegate?.locationService(sender: self, didUpdateRawLocationUpdate: RawLocationUpdate(location: rawLocation.toLocation()))
        delegate?.locationService(sender: self, didUpdateEnhancedLocationUpdate: EnhancedLocationUpdate(location: location.toLocation()))
    }
    
    func passiveLocationManager(_ manager: PassiveLocationManager, didUpdateHeading newHeading: CLHeading) {
        logHandler?.debug(message: "\(String(describing: Self.self)), passiveLocationManager.didUpdateHeading", error: nil)
    }
    
    func passiveLocationManager(_ manager: PassiveLocationManager, didFailWithError error: Error) {
        logHandler?.error(message: "\(String(describing: Self.self)), passiveLocationManager.didFailWithError", error: error)
        let errorInformation = ErrorInformation(type: .publisherError(errorMessage: error.localizedDescription))
        delegate?.locationService(sender: self, didFailWithError: errorInformation)
    }
}
