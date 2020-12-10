import CoreLocation
import MapboxCoreNavigation

protocol LocationServiceDelegate: class {
    func locationService(sender: LocationService, didFailWithError error: Error)
    func locationService(sender: LocationService, didUpdateRawLocation location: CLLocation)
    func locationService(sender: LocationService, didUpdateEnhancedLocation location: CLLocation)
}

private let log = AblyLogger(subsystem: .publisher, category: "LocationService")

class LocationService {
    private let locationDataSource: PassiveLocationDataSource
    weak var delegate: LocationServiceDelegate?
    
    init() {
        self.locationDataSource = PassiveLocationDataSource()
        self.locationDataSource.delegate = self
    }
    
    func startUpdatingLocation() {
        locationDataSource.startUpdatingLocation { [weak self] (error) in
            if let error = error,
               let strongSelf = self {
                log.error("Error while updating location: %{public}@", String(describing: error))
                strongSelf.delegate?.locationService(sender: strongSelf, didFailWithError: error)
            }
        }
    }
    
    func stopUpdatingLocation() {
        locationDataSource.systemLocationManager.stopUpdatingLocation()
    }
    
    func requestAlwaysAuthorization() {
        locationDataSource.systemLocationManager.requestAlwaysAuthorization()
    }
    
    func requestWhenInUseAuthorization() {
        locationDataSource.systemLocationManager.requestWhenInUseAuthorization()
    }
}

extension LocationService: PassiveLocationDataSourceDelegate {
    func passiveLocationDataSource(_ dataSource: PassiveLocationDataSource, didUpdateLocation location: CLLocation, rawLocation: CLLocation) {
        log.info(".passiveLocationDataSource.didUpdateLocation. location: %{private}@, rawLocation: %{private}@", location)
        delegate?.locationService(sender: self, didUpdateRawLocation: rawLocation)
        delegate?.locationService(sender: self, didUpdateEnhancedLocation: location)
    }
    
    func passiveLocationDataSource(_ dataSource: PassiveLocationDataSource, didFailWithError error: Error) {
        log.error("passiveLocationDataSource.didFailWithError. error:%{public}@", String(describing: error))
        delegate?.locationService(sender: self, didFailWithError: error)
    }
    
    func passiveLocationDataSource(_ dataSource: PassiveLocationDataSource, didUpdateHeading newHeading: CLHeading) {
        log.debug("passiveLocationDataSource.didUpdateHeading. heading:%{private}@", newHeading)
    }
    
    func passiveLocationDataSourceDidChangeAuthorization(_ dataSource: PassiveLocationDataSource) {
        log.debug("passiveLocationDataSource.didChangeAuthorization")
    }
}
