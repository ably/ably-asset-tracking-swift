import UIKit


public protocol AblyAssetTrackingPublisherDelegate: class {
    func ablyAssetTrackingPublisher(sendeR: AblyAssetTrackingPublisher, didFailWithError error: Error)
}

public class AblyAssetTrackingPublisher {
    private let configuration: AblyConfiguration
    private let locationSerice: LocationService
    
    public weak var delegate: AblyAssetTrackingPublisherDelegate?
    
    public init(configuration: AblyConfiguration) {
        self.configuration = configuration
        self.locationSerice = LocationService()
    }
    

}
