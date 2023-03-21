import Combine
import AblyAssetTrackingPublisher
import Foundation
import Logging

class ObservablePublisher: ObservableObject {
    private let publisher: AblyAssetTrackingPublisher.Publisher
    private let logger: Logger?
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
    init(publisher: AblyAssetTrackingPublisher.Publisher, configInfo: PublisherConfigInfo, locationHistoryDataHandler: LocationHistoryDataHandlerProtocol? = nil, logger: Logger? = nil) {
        self.publisher = publisher
        self.configInfo = configInfo
        self.routingProfile = publisher.routingProfile
        self.locationHistoryDataHandler = locationHistoryDataHandler
        self.logger = logger
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
            guard let self else { return }
            self.routingProfile = self.publisher.routingProfile
            completion(result)
        }
    }

    private func updateTrackables(latestReceived: Set<Trackable>) {
        trackables = latestReceived.reduce(into: [:]) { accum, trackable in
            accum[trackable] = trackables[trackable] ?? .init()
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
        if SettingsModel.shared.logLocationHistoryJSON {
            do {
                let jsonData = try JSONEncoder().encode(locationHistoryData)
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    logger?.log(level: .debug, "Received location history data: \(jsonString)")
                } else {
                    logger?.log(level: .error, "Failed to convert location history data to string")
                }
            } catch {
                logger?.log(level: .error, "Failed to serialize location history data to JSON: \(error.localizedDescription)")
            }
        }

        locationHistoryDataHandler?.handleLocationHistoryData(locationHistoryData)
    }

    // As mentioned in the documentation for this delegate method, this is an experimental Ably-only API that we are using to debug the Asset Tracking (in this case, we upload the raw location history data to S3 for analysis by the Mapbox team).
    func publisher(sender: AblyAssetTrackingPublisher.Publisher, didFinishRecordingRawMapboxDataToTemporaryFile temporaryFile: TemporaryFile) {
        locationHistoryDataHandler?.handleRawMapboxData(inTemporaryFile: temporaryFile)
    }
}
