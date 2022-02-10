import CoreLocation
import AblyAssetTrackingCore
import AblyAssetTrackingInternal

protocol AblyPublisherService: AnyObject {
    var delegate: AblyPublisherServiceDelegate? { get set }

    func track(trackable: Trackable, completion: ResultHandler<Void>?)
    func stopTracking(trackable: Trackable, completion: ResultHandler<Bool>?)
    func sendEnhancedAssetLocationUpdate(locationUpdate: EnhancedLocationUpdate, forTrackable trackable: Trackable, completion: ResultHandler<Void>?)
    func close(completion: @escaping ResultHandler<Void>)
}
