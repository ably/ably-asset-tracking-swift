import UIKit
import CoreLocation

/**
 Indicates Asset connection status (i.e. if courier is publishing his location)
 */
public enum AssetConnectionStatus {
    /**
     Asset is connected to tracking system and we're receiving his position
     */
    case online

    /**
     Asset is not connected
     */
    case offline
}

public protocol SubscriberDelegate: AnyObject {
    /**
     Called when `Subscriber` spot any (location, network or permissions) error
     
     - Parameters:
        - sender: `Subscriber` instance.
        - error: Detected error.
     */
    func subscriber(sender: Subscriber, didFailWithError error: Error)

    /**
     Called when `Subscriber` receive any Raw Location (received directly from location manager) update for observed trackable
     
     - Parameters:
        - sender: `Subscriber` instance.
        - location: Received location.
     */
    func subscriber(sender: Subscriber, didUpdateRawLocation location: CLLocation)

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
    func subscriber(sender: Subscriber, didChangeAssetConnectionStatus status: AssetConnectionStatus)
}

/**
 Factory class used only to get `SubscriberBuilder`
 */
public class SubscriberFactory {
    /**
     Returns the default state of the`SubscriberBuilder`, which is incapable of starting of  `Subscriber`
     instances until it has been configured fully.
     */
    public static func subscribers() -> SubscriberBuilder {
        return DefaultSubscriberBuilder()
    }
}

/**
 Main `Subscriber` interface implemented in SDK by `DefaultSubscriber`
 */
public protocol Subscriber {
    /**
     Delegate object to receive events from `Subscriber`.
     It maintains a weak reference to your delegate, so ensure to maintain your own strong reference as well.
     */
    var delegate: SubscriberDelegate? { get set }

    /**
     Stops asset subscriber from listening for asset location
     */
    func stop()
}
