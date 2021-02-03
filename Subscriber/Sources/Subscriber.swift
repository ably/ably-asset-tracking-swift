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
     Sends the desired resolution for updates, to be requested from the remote publisher.
     An initial resolution may be defined from the outset of a `Subscriber`'s lifespan by using the `resolution` `Builder.resolution` method on the `Builder` instance used to `start` `Builder.start` it.
     Requests sent using this method will take time to propagate back to the publisher.
     The `onSuccess` callback will be called once the request has been successfully registered with the server,
     however this does not necessarily mean that the request has been received and actioned by the publisher.

     - Parameters:
        - resolution: The resolution to request, or `null` to indicate that this subscriber should explicitly indicate that it has no preference in respect of resolution.
        - onSuccess: Function to be called if the request was successfully registered with the server.
        - onError: Function to be called if the request could not be sent or it was not possible to confirm that the server had processed the request.
     */
    func sendChangeRequest(resolution: Resolution?, onSuccess: @escaping SuccessHandler, onError: @escaping ErrorHandler)

    /**
     Stops asset subscriber from listening for asset location
     */
    func stop()
}
