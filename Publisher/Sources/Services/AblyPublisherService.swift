import CoreLocation

protocol AblyPublisherServiceDelegate: AnyObject {
    func publisherService(sender: AblyPublisherService, didChangeConnectionState state: ConnectionState)
    func publisherService(sender: AblyPublisherService, didFailWithError error: Error)
    func publisherService(sender: AblyPublisherService,
                          didReceivePresenceUpdate presence: AblyPublisherPresence,
                          forTrackable trackable: Trackable,
                          presenceData: PresenceData,
                          clientId: String)
}

protocol AblyPublisherService: AnyObject {
    var delegate: AblyPublisherServiceDelegate? { get set }
    var trackables: [Trackable] { get }

    func track(trackable: Trackable, completion: ((Error?) -> Void)?)
    func stopTracking(trackable: Trackable, onSuccess: @escaping (_ wasPresent: Bool) -> Void, onError: @escaping ErrorHandler)
    func sendEnhancedAssetLocation(locationUpdate: EnhancedLocationUpdate, forTrackable trackable: Trackable, completion: ((Error?) -> Void)?)
    func stop()
}
