import CoreLocation
import MapboxCoreNavigation

protocol LocationServiceDelegate: class {
    func locationService(sender: LocationService, didFailWithError error: Error)
    func locationService(sender: LocationService, didUpdateLocation location: CLLocation)
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
            guard let error = error,
                  let strongSelf = self
            else { return }
            self?.delegate?.locationService(sender: strongSelf, didFailWithError: error)
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
        delegate?.locationService(sender: self, didUpdateLocation: location)
    }
    
    func passiveLocationDataSource(_ dataSource: PassiveLocationDataSource, didFailWithError error: Error) {
        delegate?.locationService(sender: self, didFailWithError: error)
    }
    
    func passiveLocationDataSource(_ dataSource: PassiveLocationDataSource, didUpdateHeading newHeading: CLHeading) {
        // TODO: Log suitable message when Logger become available:
        // https://github.com/ably/ably-asset-tracking-cocoa/issues/8
    }
    
    func passiveLocationDataSourceDidChangeAuthorization(_ dataSource: PassiveLocationDataSource) {
        // TODO: Log suitable message when Logger become available:
        // https://github.com/ably/ably-asset-tracking-cocoa/issues/8
    }
}
