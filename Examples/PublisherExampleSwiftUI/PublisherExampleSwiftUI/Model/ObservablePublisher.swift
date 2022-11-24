import Combine
import AblyAssetTrackingPublisher
import Foundation

class ObservablePublisher: ObservableObject {
    private let publisher: AblyAssetTrackingPublisher.Publisher
    let configInfo: PublisherConfigInfo
    let locationHistoryDataHandler: LocationHistoryDataHandlerProtocol?
    
    struct PublisherConfigInfo {
        var areRawLocationsEnabled: Bool
        var constantResolution: Resolution?
    }
    
    struct TrackableState {
        var connectionState: ConnectionState?
    }
    @Published private(set) var trackables: [Trackable: TrackableState] = [:]
    @Published private(set) var location: EnhancedLocationUpdate?
    @Published private(set) var resolution: Resolution?
    @Published private(set) var routingProfile: RoutingProfile?
    @Published private(set) var lastError: ErrorInformation?
    
    // After initialising an ObservablePublisher instance, you need to manually set the publisher’s delegate to the created instance.
    init(publisher: AblyAssetTrackingPublisher.Publisher, configInfo: PublisherConfigInfo, locationHistoryDataHandler: LocationHistoryDataHandlerProtocol? = nil) {
        self.publisher = publisher
        self.configInfo = configInfo
        self.routingProfile = publisher.routingProfile
        self.locationHistoryDataHandler = locationHistoryDataHandler
    }
    
    func stop(completion: @escaping ResultHandler<Void>) {
        publisher.stop(completion: completion)
    }
    
    func track(trackable: Trackable, completion: @escaping ResultHandler<Void>) {
        publisher.track(trackable: trackable, completion: completion)
    }
    
    func remove(trackable: Trackable, completion: @escaping ResultHandler<Bool>) {
        publisher.remove(trackable: trackable, completion: completion)
    }
    
    func changeRoutingProfile(profile: RoutingProfile, completion: @escaping ResultHandler<Void>) {
        publisher.changeRoutingProfile(profile: profile) { [weak self] result in
            guard let self = self else { return }
            self.routingProfile = self.publisher.routingProfile
            completion(result)
        }
    }
    
    private func updateTrackables(latestReceived: Set<Trackable>) {
        trackables = latestReceived.reduce([:]) { accum, trackable in
            var newAccum = accum
            newAccum[trackable] = trackables[trackable] ?? .init()
            return newAccum
        }
    }
    
    private func updateConnectionState(_ connectionState: ConnectionState, forTrackable trackable: Trackable) {
        guard let trackableState = trackables[trackable] else {
            return
        }
        var newTrackableState = trackableState
        newTrackableState.connectionState = connectionState
        trackables[trackable] = newTrackableState
    }
}

extension ObservablePublisher: PublisherDelegate {
    func publisher(sender: AblyAssetTrackingPublisher.Publisher, didFailWithError error: AblyAssetTrackingCore.ErrorInformation) {
        lastError = error
    }
    
    func publisher(sender: AblyAssetTrackingPublisher.Publisher, didUpdateEnhancedLocation location: AblyAssetTrackingCore.EnhancedLocationUpdate) {
        self.location = location
    }
    
    func publisher(sender: AblyAssetTrackingPublisher.Publisher, didChangeConnectionState state: AblyAssetTrackingCore.ConnectionState, forTrackable trackable: AblyAssetTrackingCore.Trackable) {
        updateConnectionState(state, forTrackable: trackable)
    }
    
    func publisher(sender: AblyAssetTrackingPublisher.Publisher, didUpdateResolution resolution: AblyAssetTrackingCore.Resolution) {
        self.resolution = resolution
    }
    
    func publisher(sender: AblyAssetTrackingPublisher.Publisher, didChangeTrackables trackables: Set<AblyAssetTrackingCore.Trackable>) {
        updateTrackables(latestReceived: trackables)
    }
    
    func publisher(sender: AblyAssetTrackingPublisher.Publisher, didFinishRecordingLocationHistoryData locationHistoryData: LocationHistoryData) {
        locationHistoryDataHandler?.handleLocationHistoryData(locationHistoryData)
    }
    
    // As mentioned in the documentation for this delegate method, this is an experimental Ably-only API that we are using to debug the Asset Tracking (in this case, we upload the raw location history data to S3 for analysis by the Mapbox team).
    func publisher(sender: AblyAssetTrackingPublisher.Publisher, didFinishRecordingRawMapboxDataToTemporaryFile temporaryFile: TemporaryFile) {
        locationHistoryDataHandler?.handleRawMapboxData(inTemporaryFile: temporaryFile)
    }
}
