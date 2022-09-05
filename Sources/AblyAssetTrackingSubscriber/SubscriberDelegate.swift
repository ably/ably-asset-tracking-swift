import CoreLocation
import Foundation
import AblyAssetTrackingCore

//sourcery: AutoMockable
public protocol SubscriberDelegate: AnyObject {
    /**
     Called when `Subscriber` spot any (location, network or permissions) error
     
     - Parameters:
        - sender: `Subscriber` instance.
        - error: Detected error.
     */
    func subscriber(sender: Subscriber, didFailWithError error: ErrorInformation)

    /**
     Called when the `Subscriber` receive any Enhanced Location (matched to road) update for observed trackable
     
     - Parameters:
        - sender: `Subscriber` instance.
        - location: Received location update.
     */
    func subscriber(sender: Subscriber, didUpdateEnhancedLocation locationUpdate: LocationUpdate)
    
    /**
     Called when the `Subscriber` receive any Raw Location update for observed trackable
     
     - Parameters:
        - sender: `Subscriber` instance.
        - location: Received location update.
     */
    func subscriber(sender: Subscriber, didUpdateRawLocation locationUpdate: LocationUpdate)
    
    /**
     Called when the `Subscriber` receive any Resolution update for observed trackable
     
     - Parameters:
        - sender: `Subscriber` instance.
        - resolution: Received `Resolution` object.
     */
    func subscriber(sender: Subscriber, didUpdateResolution resolution: Resolution)
    
    /**
     Called when the `Subscriber` receive estimated next location update intervals (in milliseconds) for observed trackable
     */
    func subscriber(sender: Subscriber, didUpdateDesiredInterval interval: Double)

    /**
     Called when `Subscriber` change connection status
     
     -  Parameters:
        - sender: `Subscriber` instance.
        - status: Updated connection status.
     */
    func subscriber(sender: Subscriber, didChangeAssetConnectionStatus status: ConnectionState)
}

public extension SubscriberDelegate {
    /**
     Default implementation to make this method `optional`
     */
    func subscriber(sender: Subscriber, didUpdateResolution resolution: Resolution) {}
    
    /**
     Default implementation to make this method `optional`
     */
    func subscriber(sender: Subscriber, didUpdateRawLocation locationUpdate: LocationUpdate) {}
    
    /**
     Default implementation to make this method `optional`
    */
    func subscriber(sender: Subscriber, didUpdateDesiredInterval interval: Double) {}
}
