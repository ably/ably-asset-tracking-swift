import AblyAssetTrackingCore
import CoreLocation
import Foundation

// sourcery: AutoMockable
public protocol AblySubscriberDelegate: AnyObject {
    /**
     Tells the delegate that `Ably` client connection state changed.
     
     - Parameter sender:    The `AblySubscriber` object which is delegating the change.
     - Parameter state:     The `ConnectionState` object
     */
    func ablySubscriber(_ sender: AblySubscriber, didChangeClientConnectionState state: ConnectionState)

    /**
     Tells the delegate that channel connection state changed.
     
     - Parameter sender:        The `AblySubscriber` object which is delegating the change.
     - Parameter state:         The `ConnectionState` object
     */
    func ablySubscriber(_ sender: AblySubscriber, didChangeChannelConnectionState state: ConnectionState)

    /**
     Tells the delegate that channel presence was changed.
     
     - Parameter sender:        The `AblySubscriber` object which is delegating the change.
     - Parameter presence:      The `Presence` object affected by the change.
     */
    func ablySubscriber(_ sender: AblySubscriber, didReceivePresenceUpdate presence: PresenceMessage)

    /**
     Tells the delegate that an error occurred.
     
     This is a generic delegate method and can be called from any method in the `Ably` wrapper
     
     - Parameter sender:        The `AblySubscriber` object which is delegating the change.
     - Parameter error:         The `ErrorInformation` object that contains info about error.
     */
    func ablySubscriber(_ sender: AblySubscriber, didFailWithError error: ErrorInformation)

    /**
     Tells the delegate that published location was changed.
     
     This is a generic delegate method and can be called from any method in the `Ably` wrapper
     
     - Parameter sender:              The `AblySubscriber` object which is delegating the change.
     - Parameter locationUpdate:      The `LocationUpdate` object that contains info about publisher `Enhanced` location.
     */
    func ablySubscriber(_ sender: AblySubscriber, didReceiveEnhancedLocation locationUpdate: LocationUpdate)

    /**
     Tells the delegate that published location was changed.
     
     This is a generic delegate method and can be called from any method in the `Ably` wrapper
     
     - Parameter sender:              The `AblySubscriber` object which is delegating the change.
     - Parameter locationUpdate:      The `LocationUpdate` object that contains info about publisher `Raw` location.
     */
    func ablySubscriber(_ sender: AblySubscriber, didReceiveRawLocation locationUpdate: LocationUpdate)

    /**
     Tells the delegate that resolution was changed.
     
     This is a generic delegate method and can be called from any method in the `Ably` wrapper
     The resolutions publishing needs to be enabled in the Publisher API in order to receive them here.
     
     - Parameter sender:          The `AblySubscriber` object which is delegating the change.
     - Parameter resolution:      The `Resolution` object.
     */
    func ablySubscriber(_ sender: AblySubscriber, didReceiveResolution resolution: Resolution)
}

public protocol AblySubscriber: AblyCommon {
    /**
     The delegate of the `Ably` wrapper object.
     
     The methods declared by the `AblySubscriberDelegate` protocol allow the adopting delegate to respond to messages from the `Ably` wrapper class..
     */
    var subscriberDelegate: AblySubscriberDelegate? { get set }

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
