/**
 A handler of events relating to the addition, removal and activation of `Trackable` objects for a
 `Publisher` instance.
 */
protocol ResolutionPolicyTrackableHooks {
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
     The `actively``Publisher.active` tracked object has changed.

     - Parameters:
        - trackable: The object, from the tracked set, which has been activated - or no value if there is no longer an actively tracked object.
     */
    func onActiveTrackableChanged(trackable: Trackable?)
}

protocol ResolutionPolicySubscriberHooks {
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
