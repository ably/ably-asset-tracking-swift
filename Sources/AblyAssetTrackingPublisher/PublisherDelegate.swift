import CoreLocation
import AblyAssetTrackingCore

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
    func publisher(sender: Publisher, didUpdateEnhancedLocation location: EnhancedLocationUpdate)

    /**
     Called when there is a connection update directly in AblySDK.
     
     - Parameters:
        - sender:`Publisher` instance.
        - state: Most recent trackable's connection state
        - trackable: Trackable which connection state relates to.
     */
    func publisher(sender: Publisher, didChangeConnectionState state: ConnectionState, forTrackable trackable: Trackable)
    
    /**
     Called when there is a resolution update directly in AblySDK.
     
     - Parameters:
        - sender: `Publisher` instance.
        - resolution: Most recent resolution.
    */
    func publisher(sender: Publisher, didUpdateResolution resolution: Resolution)
    
    /**
     Called whenever the trackables list of a `Publisher` instance changes
     
     - Parameters:
        - sender: `Publisher` instance.
        - trackables: a set of trackables that are currently present on the `sender`'s instance
    */
    func publisher(sender: Publisher, didChangeTrackables trackables: Set<Trackable>)
}
