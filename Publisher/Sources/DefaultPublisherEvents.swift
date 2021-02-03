import CoreLocation
import MapboxDirections

protocol PublisherEvent {}

struct TrackTrackableEvent: PublisherEvent {
    let trackable: Trackable
    let onSuccess: SuccessHandler
    let onError: ErrorHandler
}

struct AddTrackableEvent: PublisherEvent {
    let trackable: Trackable
    let onSuccess: SuccessHandler
    let onError: ErrorHandler
}

struct RemoveTrackableEvent: PublisherEvent {
    let trackable: Trackable
    let onSuccess: (_ wasPresent: Bool) -> Void
    let onError: ErrorHandler
}

struct ClearActiveTrackableEvent: PublisherEvent {
    let trackable: Trackable
    let onSuccess: (_ wasPresent: Bool) -> Void
}

struct ClearRemovedTrackableMetadataEvent: PublisherEvent {
    let trackable: Trackable
    let onSuccess: (_ wasPresent: Bool) -> Void
}

struct PresenceJoinedSuccessfullyEvent: PublisherEvent {
    let trackable: Trackable
    let onComplete: SuccessHandler
}

struct TrackableReadyToTrackEvent: PublisherEvent {
    let trackable: Trackable
    let onSuccess: SuccessHandler
}

struct SetDestinationSuccessEvent: PublisherEvent {
    let route: Route
}

struct EnhancedLocationChangedEvent: PublisherEvent {
    let locationUpdate: EnhancedLocationUpdate
}

struct RefreshResolutionPolicyEvent: PublisherEvent {}

struct ChangeLocationEngineResolutionEvent: PublisherEvent {}

struct ChangeRoutingProfileEvent: PublisherEvent {
    let profile: RoutingProfile
    let onSuccess: SuccessHandler
    let onError: ErrorHandler
}

struct PresenceUpdateEvent: PublisherEvent {
    let trackable: Trackable
    let presence: AblyPublisherPresence
    let presenceData: PresenceData
    let clientId: String
}

// MARK: Delegate handling events
protocol PublisherDelegateEvent {}

struct DelegateErrorEvent: PublisherEvent, PublisherDelegateEvent {
    let error: Error
}

struct DelegateEnhancedLocationChangedEvent: PublisherEvent, PublisherDelegateEvent {
    let locationUpdate: EnhancedLocationUpdate
}

struct DelegateConnectionStateChangedEvent: PublisherEvent, PublisherDelegateEvent {
    let connectionState: ConnectionState
}

struct DelegateResolutionUpdateEvent: PublisherEvent {
    let resolution: Resolution
}

struct DelegatePresenceUpdateEvent: PublisherEvent {
    let trackable: Trackable
    let presence: AblyPublisherPresence
    let presenceData: PresenceData
    let clientId: String
}
