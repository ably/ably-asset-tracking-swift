import CoreLocation

protocol AblyPublisherServiceDelegate: AnyObject {
    func publisherService(sender: AblyPublisherService, didChangeConnectionState state: ConnectionState)
    func publisherService(sender: AblyPublisherService, didChangeChannelConnectionState state: ConnectionState, forTrackable trackable: Trackable)
    func publisherService(sender: AblyPublisherService, didFailWithError error: ErrorInformation)
    func publisherService(sender: AblyPublisherService,
                          didReceivePresenceUpdate presence: AblyPresence,
                          forTrackable trackable: Trackable,
                          presenceData: PresenceData,
                          clientId: String)
}

protocol AblyPublisherService: AnyObject {
    var delegate: AblyPublisherServiceDelegate? { get set }

    func track(trackable: Trackable, completion: ResultHandler<Void>?)
    func stopTracking(trackable: Trackable, completion: ResultHandler<Bool>?)
    func sendEnhancedAssetLocationUpdate(locationUpdate: EnhancedLocationUpdate, forTrackable trackable: Trackable, completion: ResultHandler<Void>?)
    func close(completion: @escaping ResultHandler<Void>)
}
