import Foundation
import CoreLocation

@objc
public protocol PublisherDelegateObjectiveC: AnyObject {
    /**
     Called when the `PublisherObjectiveC` spot any (location, network or permissions) error
     
     - Parameters:
        - sender: `PublisherObjectiveC` instance.
        - error: Detected error.
     */
    func publisher(sender: PublisherObjectiveC, didFailWithError error: ErrorInformation)
    
    /**
     Called when the `PublisherObjectiveC` detect new enhanced (map matched) location. Same location will be sent to the Subscriber module
     
     - Parameters:
        - sender:`PublisherObjectiveC` instance.
        - location: Location object received from LocationManager
     */
    func publisher(sender: PublisherObjectiveC, didUpdateEnhancedLocation location: CLLocation)
    
    /**
     Called when there is a connection update directly in AblySDK.
     
     - Parameters:
        - sender:`PublisherObjectiveC` instance.
        - state: Most recent connection state
     */
    func publisher(sender: PublisherObjectiveC, didChangeConnectionState state: ConnectionState)
    
    /**
     Called when there is a resolution update directly in AblySDK.
     
     - Parameters:
        - sender: `PublisherObjectiveC` instance.
        - resolution: Most recent resolution.
    */
    func publisher(sender: PublisherObjectiveC, didUpdateResolution resolution: Resolution)
}

public protocol PublisherDelegate: AnyObject {
    /**
     Called when the `Publisher` spot any (location, network or permissions) error
     
     - Parameters:
        - sender: `Publisher` instance.
        - error: Detected error.
     */
    func publisher(sender: Publisher, didFailWithError error: ErrorInformation)

    /**
     Called when the `Publisher` detect new enhanced (map matched) location. Same location will be sent to the Subscriber module
     
     - Parameters:
        - sender:`Publisher` instance.
        - location: Location object received from LocationManager
     */
    func publisher(sender: Publisher, didUpdateEnhancedLocation location: CLLocation)

    /**
     Called when there is a connection update directly in AblySDK.
     
     - Parameters:
        - sender:`Publisher` instance.
        - state: Most recent connection state
     */
    func publisher(sender: Publisher, didChangeConnectionState state: ConnectionState)
    
    /**
     Called when there is a resolution update directly in AblySDK.
     
     - Parameters:
        - sender: `Publisher` instance.
        - resolution: Most recent resolution.
    */
    func publisher(sender: Publisher, didUpdateResolution resolution: Resolution)
}

/**
 Factory class used only to get `PublisherBuilder`
 */
public class PublisherFactory: NSObject {
    /**
     Returns the default state of the publisher `PublisherBuilder`, which is incapable of starting of  `Publisher`
     instances until it has been configured fully.
     */
    static public func publishers() -> PublisherBuilder {
        return DefaultPublisherBuilder()
    }
}

/**
 Main `Publisher` interface implemented in SDK by `DefaultPublisher`
 */
@objc
public protocol PublisherObjectiveC {
    /**
     Delegate object to receive events from `Publisher`.
     It holds a weak reference so make sure to keep your delegate object in memory.
     */
    var delegateObjectiveC: PublisherDelegateObjectiveC? { get set }

    @objc func track(trackable: Trackable, onSuccess: @escaping (() -> Void), onError: @escaping ((ErrorInformation) -> Void))
    
    @objc func add(trackable: Trackable, onSuccess: @escaping (() -> Void), onError: @escaping ((ErrorInformation) -> Void))
    
    @objc func remove(trackable: Trackable, onSuccess: @escaping ((Bool) -> Void), onError: @escaping ((ErrorInformation) -> Void))
    
    @objc var activeTrackable: Trackable? { get }
    
    @objc var routingProfile: RoutingProfile { get }
    
    @objc func changeRoutingProfile(profile: RoutingProfile, onSuccess: @escaping (() -> Void), onError: @escaping ((ErrorInformation) -> Void))
    
    @objc func stop()
}

/**
 Main `Publisher` interface implemented in SDK by `DefaultPublisher`
 */
public protocol Publisher {
    /**
     Delegate object to receive events from `Publisher`.
     It holds a weak reference so make sure to keep your delegate object in memory.
     */
    var delegate: PublisherDelegate? { get set }

    /**
     Adds a `Trackable` object and makes it the actively tracked object, meaning that the state of the `activeTrackable` property
     will be updated to this object, if that wasn't already the case.
     If this object was already in this publisher's tracked set then this method only serves to change the actively
     tracked object.
     
     - Parameters:
        - trackable The object to be added to this publisher's tracked set, if it's not already there, and to be made the actively tracked object.
        - completion: Called on completion of the `track` method. Ends with:
            - `success` when the trackable is successfully added and make the actively tracked object.
            - `failure` when an error occurs.
     */
    func track(trackable: Trackable, completion: @escaping ResultHandler<Void>)

    /**
     Adds a `Trackable` object, but does not make it the actively tracked object, meaning that the state of the
     `activeTrackable` property will not change.
     If this object was already in this publisher's tracked set then this method does nothing.
     
     - Parameters:
        - trackable: The object to be added to this publisher's tracked set, if it's not already there.
        - completion: Called on completion of the `add` method. Ends with:
            - `success` when the trackable is successfully added.
            - `failure` when an error occurs.
     */
    func add(trackable: Trackable, completion: @escaping ResultHandler<Void>)

    /**
     Removes a `Trackable` property if it is known to this publisher, otherwise does nothing and returns false.
     If the removed object is the current actively `active` object then that state will be cleared, meaning that for
     another object to become the actively tracked delivery then the `track` method must be subsequently called.
     
     - Parameters:
        - trackable: The object to be removed from this publisher's tracked set, if it's there.
        - completion: Called on completion of the `remove` method. Ends with:
            - `success` when the removing was successful, wasPresent is true when the object was known to this publisher, being that it was in the tracked set.
            - `failure` when an error occurs.
     */
    func remove(trackable: Trackable, completion: @escaping ResultHandler<Bool>)

    /**
     The actively tracked object, being the `Trackable` object whose destination will be used for location
     enhancement, if available.
     This state can be changed by calling the [track] method.
     */
    var activeTrackable: Trackable? { get }

    /**
     The active means of transport for this publisher.
     */
    var routingProfile: RoutingProfile { get }

    /**
     Changes the current routing profile.
     
     - Parameters:
        - profile: The routing profile to be used from now on.
        - completion: Called on completion of the `add` method. Ends with:
            - `success` when RoutingProfile is successfuly changed.
            - `failure` when an error occurs.
    */
    func changeRoutingProfile(profile: RoutingProfile, completion: @escaping ResultHandler<Void>)

    /**
     Stops this publisher from publishing locations. Once a publisher has been stopped, it cannot be restarted.
     */
    func stop()
}
