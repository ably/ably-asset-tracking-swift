import AblyAssetTrackingCore
import CoreLocation

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
        - state: Most recent state of the trackable
        - trackable: Trackable which trackable state relates to.
     */
    func publisher(sender: Publisher, didChangeState state: TrackableState, forTrackable trackable: Trackable)

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

    /**
     Called when the publisher has finished recording location history data, to expose the data that it recorded. The publisher will call this method after it receives the ``Publisher/stop(completion:)`` method call and before that method’s completion handler is called. It will only do so if at least one trackable was added to the publisher during its lifetime.
     */
    func publisher(sender: Publisher, didFinishRecordingLocationHistoryData locationHistoryData: LocationHistoryData)

    /**
     Called when the publisher has finished recording location history data, to expose the raw history data emitted by the Mapbox SDK. The publisher will call this method if and only if it calls the ``publisher(sender:didFinishRecordingLocationHistoryData:)`` method; see the documentation for that method for more information on the circumstances in which it is called.
     
     - Important: This delegate method should be considered an experimental API, which may be removed or changed at any time. It is currently only intended to be used internally by Ably for debugging.
     */
    func publisher(sender: Publisher, didFinishRecordingRawMapboxDataToTemporaryFile temporaryFile: TemporaryFile)
}

public extension PublisherDelegate {
    /**
     Default implementation to make this method `optional`
     */
    func publisher(sender: Publisher, didFinishRecordingLocationHistoryData locationHistoryData: LocationHistoryData) {}
    /**
     Default implementation to make this method `optional`
     */
    func publisher(sender: Publisher, didFinishRecordingRawMapboxDataToTemporaryFile temporaryFile: TemporaryFile) {}
}
