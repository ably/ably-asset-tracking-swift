import CoreLocation
import Foundation
import AblyAssetTrackingCore

@objc(SubscriberDelegate)
public protocol SubscriberDelegateObjectiveC: AnyObject {
    /**
     Called when `SubscriberObjectiveC` spot any (location, network or permissions) error
     
     - Parameters:
        - sender: `SubscriberObjectiveC` instance.
        - error: Detected error.
     */
    @objc
    func subscriber(sender: SubscriberObjectiveC, didFailWithError error: ErrorInformation)
    
    /**
     Called when the `SubscriberObjectiveC` receive any Enhanced Location (matched to road) update for observed trackable
     
     - Parameters:
        - sender: `SubscriberObjectiveC` instance.
        - location: Received location.
     */
    @objc
    func subscriber(sender: SubscriberObjectiveC, didUpdateEnhancedLocation location: CLLocation)
    
    /**
     Called when `SubscriberObjectiveC` change connection status
     
     -  Parameters:
        - sender: `SubscriberObjectiveC` instance.
        - status: Updated connection status.
     */
    @objc
    func subscriber(sender: SubscriberObjectiveC, didChangeAssetConnectionStatus status: ConnectionState)
}

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
     Called when `Subscriber` change connection status
     
     -  Parameters:
        - sender: `Subscriber` instance.
        - status: Updated connection status.
     */
    func subscriber(sender: Subscriber, didChangeAssetConnectionStatus status: ConnectionState)
}
