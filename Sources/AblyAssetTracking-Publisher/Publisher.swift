import Foundation

/**
 Main `PublisherObjectiveC` interface implemented in SDK by `DefaultPublisher`
 */
@objc(Publisher)
public protocol PublisherObjectiveC: AnyObject {
    /**
     Delegate object to receive events from `PublisherObjectiveC`.
     It holds a weak reference so make sure to keep your delegate object in memory.
     */
    @objc var delegateObjectiveC: PublisherDelegateObjectiveC? { get set }
    
    /**
     The actively tracked object, being the `Trackable` object whose destination will be used for location
     enhancement, if available.
     This state can be changed by calling the [track] method.
     */
    @objc var activeTrackable: Trackable? { get }
    
    /**
     Represents active mean of transport used by the publisher.
     */
    @objc var routingProfile: RoutingProfile { get }

    /**
     Adds a `Trackable` object and makes it the actively tracked object, meaning that the state of the `activeTrackable` property
     will be updated to this object, if that wasn't already the case.
     If this object was already in this publisher's tracked set then this method only serves to change the actively
     tracked object.
     
     - Parameters:
        - trackable The object to be added to this publisher's tracked set, if it's not already there, and to be made the actively tracked object.
        - onSuccess called when the trackable is successfully added and make the actively tracked object.
        - onError called when an error occurs.
     */
    @objc
    func track(trackable: Trackable, onSuccess: @escaping (() -> Void), onError: @escaping ((ErrorInformation) -> Void))
    
    /**
     Adds a `Trackable` object, but does not make it the actively tracked object, meaning that the state of the
     `activeTrackable` property will not change.
     If this object was already in this publisher's tracked set then this method does nothing.
     
     - Parameters:
        - trackable: The object to be added to this publisher's tracked set, if it's not already there.
        - onSuccess called when the trackable is successfully added.
        - onError called when an error occurs.
     */
    @objc
    func add(trackable: Trackable, onSuccess: @escaping (() -> Void), onError: @escaping ((ErrorInformation) -> Void))
    
    /**
     Removes a `Trackable` property if it is known to this publisher, otherwise does nothing and returns false.
     If the removed object is the current actively `active` object then that state will be cleared, meaning that for
     another object to become the actively tracked delivery then the `track` method must be subsequently called.
     
     - Parameters:
        - trackable: The object to be removed from this publisher's tracked set, if it's there.
        - onSuccess called when the removing was successful, wasPresent is true when the object was known to this publisher, being that it was in the tracked set.
        - onError called when an error occurs.
     */
    @objc
    func remove(trackable: Trackable, onSuccess: @escaping ((Bool) -> Void), onError: @escaping ((ErrorInformation) -> Void))
    
    /**
     Changes the current routing profile.
     
     - Parameters:
        - profile: The routing profile to be used from now on.
        - onSuccess: called when RoutingProfile is successfuly changed.
        - onError: called when an error occurs.
    */
    @objc
    func changeRoutingProfile(profile: RoutingProfile, onSuccess: @escaping (() -> Void), onError: @escaping ((ErrorInformation) -> Void))
    
    /**
     Stops this publisher from publishing locations. Once a publisher has been stopped, it cannot be restarted.
     
     - Parameters:
        - onSuccess: called when the Publisher stopped successfuly.
        - onError: called when an error occurs.
     */
    @objc
    func stop(onSuccess: @escaping (() -> Void), onError: @escaping ((ErrorInformation) -> Void))
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
     Represents active mean of transport used by the publisher.
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
     
     - Parameters:
        - completion: Called on completion of the `stop` method. Ends with:
            - `success` called when the Publisher stopped successfuly.
            - `failure` when an error occurs.
    */
    func stop(completion: @escaping ResultHandler<Void>) 
}
