import CoreLocation

@objc(PublisherDelegate)
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
}
