import Foundation
import CoreLocation

public protocol AssetTrackingPublisherDelegate: class {
    /**
     Called when `AssetTrackingPublisher` spot any (location, network or permissions) error
     - Parameters:
     - sender: `AssetTrackingPublisher` instance.
     - error: Detected error.
     */
    func assetTrackingPublisher(sender: AssetTrackingPublisher, didFailWithError error: Error)
    
    /**
     Called when `AssetTrackingPublisher` detect new Raw location. Same location will be sent to the Subscriber module
     - Parameters:
     - sender:`AssetTrackingPublisher` instance.
     - location: Location object received from LocationManager
     */
    func assetTrackingPublisher(sender: AssetTrackingPublisher, didUpdateLocation location: CLLocation)
}

public protocol AssetTrackingPublisher {
    
    /**
     Delegate object to receive events from `AssetTrackingPublisher`.
     It holds a weak reference so make sure to keep your delegate object in memory.
     */
    var delegate: AssetTrackingPublisherDelegate? { get set }
    
    /**
     Adds a `Trackable` object and makes it the actively tracked object, meaning that the state of the `activeTrackable` property
     will be updated to this object, if that wasn't already the case.
     
     If this object was already in this publisher's tracked set then this method only serves to change the actively
     tracked object.
     
     - Parameters:
     - trackable The object to be added to this publisher's tracked set, if it's not already there, and to be made the actively tracked object.
     */
    func track(trackable: Trackable)
    
    /**
     Adds a `Trackable` object, but does not make it the actively tracked object, meaning that the state of the
     `activeTrackable` property will not change.
     
     If this object was already in this publisher's tracked set then this method does nothing.
     
     - Parameters:
     - trackable The object to be added to this publisher's tracked set, if it's not already there.
     */
    func add(trackable: Trackable)
    
    /**
     Removes a `Trackable` property if it is known to this publisher, otherwise does nothing and returns false.
     
     If the removed object is the current actively `active` object then that state will be cleared, meaning that for
     another object to become the actively tracked delivery then the `track` method must be subsequently called.
     
     - Parameters:
     - trackable The object to be removed from this publisher's tracked set, if it's there.
     - Returns: `true` if the object was known to this publisher, being that it was in the tracked set.
     */
    func remove(trackable: Trackable) -> Bool
    
    /**
     The actively tracked object, being the `Trackable` object whose destination will be used for location
     enhancement, if available.
     
     This state can be changed by calling the [track] method.
     */
    var activeTrackable: Trackable? { get }
    
    /**
     The active means of transport for this publisher.
     */
    var transportationMode: TransportationMode { get set }
    
    /**
     Stops this publisher from publishing locations. Once a publisher has been stopped, it cannot be restarted.
     */
    func stop()
}
