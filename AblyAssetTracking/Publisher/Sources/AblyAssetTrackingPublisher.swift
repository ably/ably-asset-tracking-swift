import UIKit
import CoreLocation

public class AblyAssetTrackingPublisher: AssetTrackingPublisher {
    private let configuration: AssetTrackingPublisherConfiguration
    private let locationSerice: LocationService
    
    public weak var delegate: AssetTrackingPublisherDelegate?
    public var activeTrackable: Trackable?
    public var transportationMode: TransportationMode
    
    /**
     Default constructor. Initializes Publisher with given `AssetTrackingPublisherConfiguration`.
     Publisher starts listening (and notifying delegate) after initialization.
     - Parameters:
     -  configuration: Configuration struct to use in this instance.
     */
    public init(configuration: AssetTrackingPublisherConfiguration) {
        self.configuration = configuration
        self.locationSerice = LocationService()
        
        // TODO: Set proper values from configuration
        self.activeTrackable = nil
        self.transportationMode = TransportationMode()
    }
    
    public func track(trackable: Trackable) {    
        // TODO: Implement method
    }
    
    public func add(trackable: Trackable) {
        // TODO: Implement method
    }
    
    public func remove(trackable: Trackable) -> Bool {
        // TODO: Implement method
        return false;
    }
    
    public func stop() {
        // TODO: Implement method
    }
}

extension AblyAssetTrackingPublisher: LocationServiceDelegate {
    func locationService(sender: LocationService, didFailWithError error: Error) {
        delegate?.assetTrackingPublisher(sender: self, didFailWithError: error)
    }
    
    func locationService(sender: LocationService, didUpdateLocation location: CLLocation) {
        delegate?.assetTrackingPublisher(sender: self, didUpdateLocation: location)
        // TOOD - convert CLLocation to GeoJSON and pass to AblyService.
    }
}
