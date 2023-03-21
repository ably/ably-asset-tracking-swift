import AblyAssetTrackingPublisher

class DummyPublisher: Publisher {
    var delegate: AblyAssetTrackingPublisher.PublisherDelegate?
    
    func track(trackable: AblyAssetTrackingCore.Trackable, completion: @escaping AblyAssetTrackingCore.ResultHandler<Void>) {
    }
    
    func add(trackable: AblyAssetTrackingCore.Trackable, completion: @escaping AblyAssetTrackingCore.ResultHandler<Void>) {
    }
    
    func remove(trackable: AblyAssetTrackingCore.Trackable, completion: @escaping AblyAssetTrackingCore.ResultHandler<Bool>) {
    }
    
    var activeTrackable: AblyAssetTrackingCore.Trackable?
    
    var routingProfile: AblyAssetTrackingPublisher.RoutingProfile = .cycling
    
    func changeRoutingProfile(profile: AblyAssetTrackingPublisher.RoutingProfile, completion: @escaping AblyAssetTrackingCore.ResultHandler<Void>) {
    }
    
    func stop(completion: @escaping AblyAssetTrackingCore.ResultHandler<Void>) {
    }
}
