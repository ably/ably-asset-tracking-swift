import Core

/**
 Defines the methods which can be called by a resolution policy when it is created.
 Methods on this interface may only be called from within implementations of
 `createResolutionPolicy` `Factory.createResolutionPolicy`.
 */
public protocol ResolutionPolicyHooks {
    /**
     Register a handler for the addition, removal and activation of `Trackable` objects for the `Publisher`
     instance whose `creation` `Publisher.Builder.start` caused
     `createResolutionPolicy` `Factory.createResolutionPolicy` to be called.

     This method should only be called once within the scope of creation of a single publisher's resolution
     policy. Subsequent calls to this method will replace the previous handler.
     - Parameters:
        - listener: The handler, which may be called multiple times during the lifespan of the publisher.
     */
    func trackables(listener: TrackableSetListener)

    /**
     Register a handler for the addition and removal of remote `Subscriber`s to the `Publisher` instance whose
     `creation` `Publisher.Builder.start` caused `createResolutionPolicy` `Factory.createResolutionPolicy` to be
     called.
     This method should only be called once within the scope of creation of a single publisher's resolution
     policy. Subsequent calls to this method will replace the previous handler.

     - Parameters:
        - listener: The handler, which may be called multiple times during the lifespan of the publisher.
     */
    func subscribers(listener: SubscriberSetListener)
 }

 /**
  A handler of events relating to the addition, removal and activation of `Trackable` objects for a
  `Publisher` instance.
  */
 public protocol TrackableSetListener {
    /**
     A `Trackable` object has been added to the `Publisher`'s set of tracked objects.
     If the operation adding `trackable` is also making it the `actively` `Publisher.active` tracked object
     then `onActiveTrackableChanged` will subsequently be called.

     - Parameters:
        - trackable: The object which has been added to the tracked set.
     */
    func onTrackableAdded(trackable: Trackable)

    /**
     A `Trackable` object has been removed from the `Publisher`'s set of tracked objects.
     If `trackable` was the `actively``Publisher.active` tracked object then `onActiveTrackableChanged` will
     subsequently be called.

     - Parameters:
        - trackable: The object which has been removed from the tracked set.
     */
    func onTrackableRemoved(trackable: Trackable)

    /**
     The `actively` `Publisher.active` tracked object has changed.

     - Parameters:
        - trackable: The object, from the tracked set, which has been activated - or no value if there is no longer an actively tracked object.
     */
    func onActiveTrackableChanged(trackable: Trackable?)
 }

/**
A handler of events relating to the addition or removal of remote `Subscriber`s to a `Publisher` instance.
*/
 public protocol SubscriberSetListener {
    /**
     A `Subscriber` has subscribed to receive updates for one or more `Trackable` objects from the
     `Publisher`'s set of tracked objects.

     - Parameters:
        - subscriber: The remote entity that subscribed.
     */
    func onSubscriberAdded(subscriber: Subscriber)

    /**
     A `Subscriber` has unsubscribed from updates for one or more `Trackable` objects from the `Publisher`'s
     set of tracked objects.

     - Parameters:
        - subscriber: The remote entity that unsubscribed.
     */
    func onSubscriberRemoved(subscriber: Subscriber)
 }

public class Subscriber: NSObject {
    let id: String
    let trackable: Trackable

    init(id: String, trackable: Trackable) {
        self.id = id
        self.trackable = trackable
    }
}
