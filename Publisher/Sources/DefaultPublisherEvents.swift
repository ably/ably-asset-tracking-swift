import Foundation
import CoreLocation

protocol PublisherEvent {}

struct SuccessEvent: PublisherEvent {
    let onSuccess: SuccessHandler
}

struct ErrorEvent: PublisherEvent {
    let error: Error
    let onError: ErrorHandler
}

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

// MARK: Delegate handling events
struct DelegateErrorEvent: PublisherEvent {
    let error: Error
}

struct DelegateRawLocationChangedEvent: PublisherEvent {
    let location: CLLocation
}

struct DelegateEnhancedLocationChangedEvent: PublisherEvent {
    let location: CLLocation
}

struct DelegateConnectionStateChangedEvent: PublisherEvent {
    let connectionState: ConnectionState
}

struct DelegatePresenceUpdateEvent: PublisherEvent {
    let trackable: Trackable
    let presence: AblyPublisherPresence
    let presenceData: PresenceData
    let clientId: String
}
