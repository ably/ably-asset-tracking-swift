import CoreLocation
import Foundation
import AblyAssetTrackingCore

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
        - location: Received location.
     */
    func subscriber(sender: Subscriber, didUpdateEnhancedLocation location: CLLocation)
    
    /**
     Called when the `Subscriber` receive any Resolution update for observed trackable
     
     - Parameters:
        - sender: `Subscriber` instance.
        - resolution: Received `Resolution` object.
     */
    func subscriber(sender: Subscriber, didUpdateEnhancedLocation resolution: Resolution)

    /**
     Called when `Subscriber` change connection status
     
     -  Parameters:
        - sender: `Subscriber` instance.
        - status: Updated connection status.
     */
    func subscriber(sender: Subscriber, didChangeAssetConnectionStatus status: ConnectionState)
}
