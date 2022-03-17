import Foundation
import AblyAssetTrackingCore
import CoreLocation

public protocol AblySubscriberServiceDelegate: AnyObject {
    /**
     Tells the delegate that `Ably` client connection state changed.
     
     - Parameter sender:    The `AblySubscriber` object which is delegating the change.
     - Parameter state:     The `ConnectionState` object
     */
    func subscriberService(sender: AblySubscriber, didChangeClientConnectionState state: ConnectionState)
    
    /**
     Tells the delegate that channel connection state changed.
     
     - Parameter sender:        The `AblySubscriber` object which is delegating the change.
     - Parameter state:         The `ConnectionState` object
     */
    func subscriberService(sender: AblySubscriber, didChangeChannelConnectionState state: ConnectionState)
    
    /**
     Tells the delegate that channel presence was changed.
     
     - Parameter sender:        The `AblySubscriber` object which is delegating the change.
     - Parameter presence:      The `Presence` object affected by the change.
     */
    func subscriberService(sender: AblySubscriber, didReceivePresenceUpdate presence: Presence)
    
    /**
     Tells the delegate that an error occurred.
     
     This is a generic delegate method and can be called from any method in the `Ably` wrapper
     
     - Parameter sender:        The `AblySubscriber` object which is delegating the change.
     - Parameter error:         The `ErrorInformation` object that contains info about error.
     */
    func subscriberService(sender: AblySubscriber, didFailWithError error: ErrorInformation)
    
    /**
     Tells the delegate that published location was changed.
     
     This is a generic delegate method and can be called from any method in the `Ably` wrapper
     
     - Parameter sender:        The `AblySubscriber` object which is delegating the change.
     - Parameter location:      The `Location` object that contains info about publisher `Enhanced` location.
     */
    func subscriberService(sender: AblySubscriber, didReceiveEnhancedLocation location: Location)
    
    /**
     Tells the delegate that published location was changed.
     
     This is a generic delegate method and can be called from any method in the `Ably` wrapper
     
     - Parameter sender:        The `AblySubscriber` object which is delegating the change.
     - Parameter location:      The `Location` object that contains info about publisher `Raw` location.
     */
    func subscriberService(sender: AblySubscriber, didReceiveRawLocation location: Location)
}

public protocol AblySubscriber: AblyCommon {
    /**
     The delegate of the `Ably` wrapper object.
     
     The methods declared by the `AblySubscriberServiceDelegate` protocol allow the adopting delegate to respond to messages from the `Ably` wrapper class..
     */
    var subscriberDelegate: AblySubscriberServiceDelegate? { get set }
    
    /**
     Observe  for the enhanced location change.
     
     Subscription should be able  only when there's an existing channel for the `trackableId`
     
     - Parameter trackableId: The identifier of the channel.
     */
    func subscribeForEnhancedEvents(trackableId: String)
    
    /**
     Observe  for the raw location change.
     
     Subscription should be able  only when there's an existing channel for the `trackableId`
     
     - Parameter trackableId: The identifier of the channel.
     */
    func subscribeForRawEvents(trackableId: String)
    
    /**
     Updates presence data in the `trackableId` channel's presence.
     
     Should be called only when there's an existing channel for the `trackableId`.
     If a channel for the `trackableId` doesn't exist then nothing happens.
     
     - Parameter trackableId:    The ID of the trackable channel.
     - Parameter presenceData:   The data that will be send via the presence channel.
     - Parameter callback:       The closure that will be called when updating presence data completes. If something goes wrong it will be called with an `error`object.
     */
    func updatePresenceData(trackableId: String, presenceData: PresenceData, completion: @escaping ResultHandler<Void>)
}
