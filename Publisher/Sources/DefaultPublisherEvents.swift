import CoreLocation

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

struct RawLocationChangedEvent: PublisherEvent {
    let location: CLLocation
}

struct EnhancedLocationChangedEvent: PublisherEvent {
    let location: CLLocation
}

struct RefreshResolutionPolicyEvent: PublisherEvent {}

struct ChangeLocationEngineResolutionEvent: PublisherEvent {}

struct PresenceUpdateEvent: PublisherEvent {
    let trackable: Trackable
    let presence: AblyPublisherPresence
    let presenceData: PresenceData
    let clientId: String
}


// MARK: Delegate handling events
protocol PublisherDelegateEvent {}

struct DelegateErrorEvent: PublisherDelegateEvent {
    let error: Error
}

struct DelegateRawLocationChangedEvent: PublisherDelegateEvent {
    let location: CLLocation
}

struct DelegateEnhancedLocationChangedEvent: PublisherDelegateEvent {
    let location: CLLocation
}

struct DelegateConnectionStateChangedEvent: PublisherDelegateEvent {
    let connectionState: ConnectionState
}
