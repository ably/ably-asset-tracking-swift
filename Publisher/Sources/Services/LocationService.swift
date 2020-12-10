import CoreLocation
import MapboxCoreNavigation
import os.log

protocol LocationServiceDelegate: class {
    func locationService(sender: LocationService, didFailWithError error: Error)
    func locationService(sender: LocationService, didUpdateRawLocation location: CLLocation)
    func locationService(sender: LocationService, didUpdateEnhancedLocation location: CLLocation)
}

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
                os_log("Error while updating location: %{public}@", log: .location, type: .error, error as CVarArg)
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
        os_log(".passiveLocationDataSource.didUpdateLocation. location: %{private}@, rawLocation: %{private}@",
               log: .location, type: .info, location)
        
        delegate?.locationService(sender: self, didUpdateRawLocation: rawLocation)
        delegate?.locationService(sender: self, didUpdateEnhancedLocation: location)
    }
    
    func passiveLocationDataSource(_ dataSource: PassiveLocationDataSource, didFailWithError error: Error) {
        os_log("passiveLocationDataSource.didFailWithError. error:%{public}@", log: .location, type: .error, error as CVarArg)
        delegate?.locationService(sender: self, didFailWithError: error)
    }
    
    func passiveLocationDataSource(_ dataSource: PassiveLocationDataSource, didUpdateHeading newHeading: CLHeading) {
        os_log("passiveLocationDataSource.didUpdateHeading. heading:%{private}@", log: .location, type: .debug, newHeading)        
    }
    
    func passiveLocationDataSourceDidChangeAuthorization(_ dataSource: PassiveLocationDataSource) {
        os_log("passiveLocationDataSource.didChangeAuthorization", log: .location, type: .debug)
    }
}
