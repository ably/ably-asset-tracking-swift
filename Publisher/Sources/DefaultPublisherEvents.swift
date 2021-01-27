import Foundation
import CoreLocation
import MapboxDirections

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

struct SetDestinationEvent: PublisherEvent {
    let destination: CLLocationCoordinate2D?
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
    let resultHandler: ResultHandler<Void>
}

// MARK: Delegate handling events
struct DelegateErrorEvent: PublisherEvent {
    let error: Error
}

struct DelegateEnhancedLocationChangedEvent: PublisherEvent {
    let locationUpdate: EnhancedLocationUpdate
}

struct DelegateConnectionStateChangedEvent: PublisherEvent {
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
