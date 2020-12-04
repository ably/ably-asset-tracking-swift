import UIKit
import CoreLocation

public protocol AblyAssetTrackingPublisherDelegate: class {
    func ablyAssetTrackingPublisher(sender: AblyAssetTrackingPublisher, didFailWithError error: Error)
    func ablyAssetTrackingPublisher(sender: AblyAssetTrackingPublisher, didUpdateLocation location: CLLocation)
}

public class AblyAssetTrackingPublisher {
    private let configuration: AblyConfiguration
    private let locationService: LocationService
    
    public weak var delegate: AblyAssetTrackingPublisherDelegate?
    
    public init(configuration: AblyConfiguration) {
        self.configuration = configuration
        self.locationService = LocationService()
    }
    
    public func start() {
        locationService.startUpdatingLocation()
    }
    
    public func stop() {
        locationService.stopUpdatingLocation()
    }
    
    // TODO - Clarify if we need those methods.
    public func requestAlwaysAuthorization() {
        locationService.requestAlwaysAuthorization()
    }
    
    public func requestWhenInUseAuthorization() {
        locationService.requestWhenInUseAuthorization()
    }
}

extension AblyAssetTrackingPublisher: LocationServiceDelegate {
    func locationService(sender: LocationService, didFailWithError error: Error) {
        delegate?.ablyAssetTrackingPublisher(sender: self, didFailWithError: error)
    }
    
    func locationService(sender: LocationService, didUpdateLocation location: CLLocation) {
        delegate?.ablyAssetTrackingPublisher(sender: self, didUpdateLocation: location)
        // TODO - convert CLLocation to GeoJSON and pass to AblyService.
    }
}
