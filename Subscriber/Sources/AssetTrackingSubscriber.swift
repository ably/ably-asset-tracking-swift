import UIKit
import CoreLocation

public enum AssetTrackingConnectionStatus {
    case online
    case offline
}

public protocol AssetTrackingSubscriberDelegate {
    /**
     Called when `AssetTrackingSubscriber` spot any (location, network or permissions) error
     
     - Parameters:
        - sender: `AssetTrackingSubscriber` instance.
        - error: Detected error.
     */
    func assetTrackingSubscriber(sender: AssetTrackingSubscriber, didFailWithError error: Error)
    
    /**
    Called when `AssetTrackingSubscriber` receive any Raw Location (received directly from location manager) update for observed trackable
     
     - Parameters:
        - sender: `AssetTrackingSubscriber` instance.
        - location: Received location.
     */
    func assetTrackingSubscriber(sender: AssetTrackingSubscriber, didUpdateRawLocation location: CLLocation)
    
    /**
    Called when AssetTrackingSubscriber receive any Enhanced Location (matched to road) update for observed trackable
     
     - Parameters:
        - sender: `AssetTrackingSubscriber` instance.
        - location: Received location.
     */
    func assetTrackingSubscriber(sender: AssetTrackingSubscriber, didUpdateEnhancedLocation location: CLLocation)
    
    /**
     Called when `AssetTrackingSubscriber` change connection status
     
     -  Parameters:
        - sender: `AssetTrackingSubscriber` instance.
        - status: Updated connection status.
     */
    func assetTrackingSubscriber(sender: AssetTrackingSubscriber, didChangeAssetConnectionStatus status: AssetTrackingConnectionStatus)
}

public protocol AssetTrackingSubscriber {
    /**
     Delegate object to receive events from `AssetTrackingSubscriber`.
     It maintains a weak reference to your delegate, so ensure to maintain your own strong reference as well.
     */
    var delegate: AssetTrackingSubscriberDelegate? { get set }
    
    /**
     Stops asset subscriber from listening for asset location
     */
    func stop()
}
