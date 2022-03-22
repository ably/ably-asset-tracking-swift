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
    
    /**
     Tells the delegate that resolution was changed.
     
     This is a generic delegate method and can be called from any method in the `Ably` wrapper
     The resolutions publishing needs to be enabled in the Publisher API in order to receive them here.
     
     - Parameter sender:          The `AblySubscriber` object which is delegating the change.
     - Parameter resolution:      The `Resolution` object.
     */
    func subscriberService(sender: AblySubscriber, didReceiveResolution resolution: Resolution)
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
}
