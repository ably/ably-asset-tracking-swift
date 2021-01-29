import CoreLocation
import Core

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

    func track(trackable: Trackable, completion: @escaping ResultHandler<Void>)
    func stopTracking(trackable: Trackable, completion: @escaping ResultHandler<Bool>)
    func sendEnhancedAssetLocation(locationUpdate: EnhancedLocationUpdate, forTrackable trackable: Trackable, completion: @escaping ResultHandler<Void>)
    func stop()
}
