import Foundation
import AblyAssetTrackingCore

public protocol AblyPublisherServiceDelegate: AnyObject {
    /**
     Tells the delegate that `Ably` client connection state changed.
     
     - Parameter sender:    The `AblyPublisher` object which is delegating the change.
     - Parameter state:     The `ConnectionState` object
     */
    func publisherService(sender: AblyPublisher, didChangeConnectionState state: ConnectionState)
    
    /**
     Tells the delegate that channel connection state changed.
     
     - Parameter sender:        The `AblyPublisher` object which is delegating the change.
     - Parameter state:         The `ConnectionState` object
     - Parameter trackable:     The `Trackable` object affected by the change
     */
    func publisherService(sender: AblyPublisher, didChangeChannelConnectionState state: ConnectionState, forTrackable trackable: Trackable)
    
    /**
     Tells the delegate that an error occurred.
     
     This is a generic delegate method and can be called from any method in the `Ably` wrapper
     
     - Parameter sender:        The `AblyPublisher` object which is delegating the change.
     - Parameter error:         The `ErrorInformation` object that contains info about error.
     */
    func publisherService(sender: AblyPublisher, didFailWithError error: ErrorInformation)
    
    /**
     Tells the delegate that channel presence data was changed.
     
     - Parameter sender:        The `AblyPublisher` object which is delegating the change.
     - Parameter presence:      The `Presence` object affected by the change.
     - Parameter trackable:     The `Trackable` object affected by the change.
     - Parameter presenceData:  The `PresenceData` object that contains info related to presence change.
     - Parameter clientId:      The `Ably` client identifier.
     */
    func publisherService(
        sender: AblyPublisher,
        didReceivePresenceUpdate presence: Presence,
        forTrackable trackable: Trackable,
        presenceData: PresenceData,
        clientId: String
    )
}

public protocol AblyPublisher: AblyCommon {
    /**
     The delegate of the `Ably` wrapper object.
     
     The methods declared by the `AblyPublisherServiceDelegate` protocol allow the adopting delegate to respond to messages from the `Ably` wrapper class..
     */
    var publisherDelegate: AblyPublisherServiceDelegate? { get set }
    
    /**
     Sends an enhanced location update to the channel.
     
     Should be called only when there's an existing channel for the `trackable.id`.
     If a channel for the `trackable.id` doesn't exist then it just calls `completion` with success.
     
     - Parameter locationUpdate:     The location update that is sent to the channel.
     - Parameter trackable:          The `Trackable` instance.
     - Parameter completion:         The closure that will be called when sending completes. If something goes wrong it will be called with an `error` object.
     */
    func sendEnhancedLocation(
        locationUpdate: EnhancedLocationUpdate,
        trackable: Trackable,
        completion: ResultHandler<Void>?
    )
    
    /**
     Sends a raw location update to the channel.
     
     Should be called only when there's an existing channel for the `trackable.id`.
     If a channel for the `trackable.id` doesn't exist then it just calls `completion` with success.
     
     - Parameter location              The `Location` object. This is the object containing raw location data.
     - Parameter trackable            The `Trackable` object.
     - Parameter completion          The closure that will be called when sending completes. If something goes wrong it will be called with an `error` object.
     */
    func sendRawLocation(
        location: RawLocationUpdate,
        trackable: Trackable,
        completion: ResultHandler<Void>?
    )
    
    /**
     Sends a resolution to the channel.
     Should be called only when there's an existing channel for the `trackable.id`.
     If a channel for the `trackable.id` doesn't exist then it just calls `completion` closure with success.
     
     - Parameter trackable          The `Trackable` object
     - Parameter resolution        The resolution that is sent to the channel.
     - Parameter completion        The closure that will be called when sending completes. If something goes wrong it will be called with an `error` object.
     */
    
    func sendResolution(
        trackable: Trackable,
        resolution: Resolution,
        completion: ResultHandler<Void>?
    )
}
