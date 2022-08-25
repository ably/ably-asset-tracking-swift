import CoreLocation
import MapboxDirections
import AblyAssetTrackingCore
import AblyAssetTrackingInternal

protocol PublisherEvent {}

struct TrackTrackableEvent: PublisherEvent {
    let trackable: Trackable
    let resultHandler: ResultHandler<Void>
}

struct AddTrackableEvent: PublisherEvent {
    let trackable: Trackable
    let resultHandler: ResultHandler<Void>
}

struct RemoveTrackableEvent: PublisherEvent {
    let trackable: Trackable
    let resultHandler: ResultHandler<Bool>
}

struct ClearActiveTrackableEvent: PublisherEvent {
    let trackable: Trackable
    let resultHandler: ResultHandler<Bool>
}

struct ClearRemovedTrackableMetadataEvent: PublisherEvent {
    let trackable: Trackable
    let resultHandler: ResultHandler<Bool>
}

struct PresenceJoinedSuccessfullyEvent: PublisherEvent {
    let trackable: Trackable
    let resultHandler: ResultHandler<Void>
}

struct TrackableReadyToTrackEvent: PublisherEvent {
    let trackable: Trackable
    let resultHandler: ResultHandler<Void>
}

struct SetDestinationSuccessEvent: PublisherEvent {
    let route: Route
}

struct EnhancedLocationChangedEvent: PublisherEvent {
    let locationUpdate: EnhancedLocationUpdate
}

struct SendEnhancedLocationSuccessEvent: PublisherEvent {
    let trackable: Trackable
    let location: Location
}

struct SendEnhancedLocationFailureEvent: PublisherEvent {
    let error: ErrorInformation
    let locationUpdate: EnhancedLocationUpdate
    let trackable: Trackable
}

struct RawLocationChangedEvent: PublisherEvent {
    var locationUpdate: RawLocationUpdate
}

struct SendRawLocationSuccessEvent: PublisherEvent {
    let trackable: Trackable
    let location: Location
}

struct SendRawLocationFailureEvent: PublisherEvent {
    let error: ErrorInformation
    let locationUpdate: RawLocationUpdate
    let trackable: Trackable
}

struct RefreshResolutionPolicyEvent: PublisherEvent {}

struct ChangeLocationEngineResolutionEvent: PublisherEvent {}

struct ChangeRoutingProfileEvent: PublisherEvent {
    let profile: RoutingProfile
    let resultHandler: ResultHandler<Void>
}

struct PresenceUpdateEvent: PublisherEvent {
    let trackable: Trackable
    let presence: Presence
    let presenceData: PresenceData
    let clientId: String
}

struct StopEvent: PublisherEvent {
    let resultHandler: ResultHandler<Void>
}

struct AblyConnectionClosedEvent: PublisherEvent {
    let resultHandler: ResultHandler<Void>
}

struct AblyClientConnectionStateChangedEvent: PublisherEvent {
    let connectionState: ConnectionState
}

struct AblyChannelConnectionStateChangedEvent: PublisherEvent {
    let trackable: Trackable
    let connectionState: ConnectionState
}

// MARK: Delegate handling events
protocol PublisherDelegateEvent {}

struct DelegateErrorEvent: PublisherEvent, PublisherDelegateEvent {
    let error: ErrorInformation
}

struct DelegateEnhancedLocationChangedEvent: PublisherEvent, PublisherDelegateEvent {
    let locationUpdate: EnhancedLocationUpdate
}

struct DelegateTrackableConnectionStateChangedEvent: PublisherEvent, PublisherDelegateEvent {
    let trackable: Trackable
    let connectionState: ConnectionState
}

struct DelegateResolutionUpdateEvent: PublisherEvent {
    let resolution: Resolution
}
