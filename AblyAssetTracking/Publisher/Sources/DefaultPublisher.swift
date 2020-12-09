import UIKit
import CoreLocation

public class DefaultPublisher: AssetTrackingPublisher {
    private let configuration: AssetTrackingPublisherConfiguration
    private let locationService: LocationService
    
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
        self.locationService = LocationService()
        
        // TODO: Set proper values from configuration
        self.activeTrackable = nil
        self.transportationMode = TransportationMode()
    }
    
    public func track(trackable: Trackable) {
        // TODO: Implement method
        failWithNotYetImplemented()
    }
    
    public func add(trackable: Trackable) {
        // TODO: Implement method
        failWithNotYetImplemented()
    }
    
    public func remove(trackable: Trackable) -> Bool {
        // TODO: Implement method
        failWithNotYetImplemented()
        
        return false;
    }
    
    public func stop() {
        // TODO: Implement method
        failWithNotYetImplemented()
    }
}

extension DefaultPublisher: LocationServiceDelegate {
    func locationService(sender: LocationService, didFailWithError error: Error) {
        delegate?.assetTrackingPublisher(sender: self, didFailWithError: error)
    }
    
    func locationService(sender: LocationService, didUpdateRawLocation location: CLLocation) {
        delegate?.assetTrackingPublisher(sender: self, didUpdateRawLocation: location)
        // TOOD - convert CLLocation to GeoJSON and pass to AblyService.
    }
    
    func locationService(sender: LocationService, didUpdateEnhancedLocation location: CLLocation) {
        delegate?.assetTrackingPublisher(sender: self, didUpdateEnhancedLocation: location)
        // TOOD - convert CLLocation to GeoJSON and pass to AblyService.
    }
}
