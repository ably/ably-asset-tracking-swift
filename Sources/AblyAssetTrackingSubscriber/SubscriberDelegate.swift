import AblyAssetTrackingCore
import CoreLocation
import Foundation

// sourcery: AutoMockable
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
     Called when `Subscriber` change trackable status
     
     -  Parameters:
        - sender: `Subscriber` instance.
        - status: Updated trackable status.
     */
    func subscriber(sender: Subscriber, didChangeTrackableState state: TrackableState)

    /**
     Called when the `Subscriber` receives updated information about whether the publisher is present.
     
     > Note: This API is experimental and may change or be removed in the future.
     
     - Parameters:
        - sender: `Subscriber` instance.
        - isPresent: Whether the publisher is present.
     */
    func subscriber(sender: Subscriber, didUpdatePublisherPresence isPresent: Bool)
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

    /**
     Default implementation to make this method `optional`
    */
    func subscriber(sender: Subscriber, didUpdatePublisherPresence isPresent: Bool) {}
}
