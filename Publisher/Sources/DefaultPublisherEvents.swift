import Foundation
import CoreLocation

protocol PublisherEvent {}

struct TrackTrackableEvent: PublisherEvent {
    let trackable: Trackable
    let onSuccess: SuccessHandler
    let onError: ErrorHandler
}

struct StopPublisherEvent: PublisherEvent {}
struct StartPublisherEvent: PublisherEvent {}

struct RemoveTrackableEvent: PublisherEvent {
    let trackable: Trackable
    let onSuccess: (_ wasPresent: Bool) -> Void
    let onError: (Error) -> Void
}

struct SuccessEvent: PublisherEvent {
    let onSuccess: () -> Void
}

struct ErrorEvent: PublisherEvent {
    let exception: Error
    let onError: (Error) -> Void
}

struct AddTrackableEvent: PublisherEvent {
    let trackable: Trackable
    let onSuccess: () -> Void
    let onError: (Error) -> Void
}

struct JoinPresenceSuccessEvent: PublisherEvent {
    let trackable: Trackable
//    let channel: Channel
    let onSuccess: () -> Void
}

struct TrackableReadyToTrackEvent: PublisherEvent {
    let trackable: Trackable
    let onSuccess: () -> Void
}

struct ClearActiveTrackableEvent: PublisherEvent {
    let trackable: Trackable
    let onSuccess: () -> Void
}

struct RawLocationChangedEvent: PublisherEvent {
    let location: CLLocation
    let geoJsonMessage: GeoJSONMessage
}

struct EnhancedLocationChangedEvent: PublisherEvent {
    let location: CLLocation
    let geoJsonMessages: [GeoJSONMessage]
}

struct SetDestinationEvent: PublisherEvent {
    let destination: CLLocation
}

struct RefreshResolutionPolicyEvent: PublisherEvent {}

struct SetDestinationSuccessEvent: PublisherEvent {
    let routeDurationInMilliseconds: Double
}

struct PresenceMessageEvent: PublisherEvent {
    let trackable: Trackable
//    let presenceMessage: PresenceMessage
}
