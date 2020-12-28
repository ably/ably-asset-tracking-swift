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

struct DelegateErrorEvent: PublisherEvent {
    let error: Error
}

struct TrackTrackableEvent: PublisherEvent {
    let trackable: Trackable
    let onSuccess: SuccessHandler
    let onError: ErrorHandler
}

struct TrackableReadyToTrackEvent: PublisherEvent {
    let trackable: Trackable
    let onSuccess: () -> Void
}

struct RawLocationChangedEvent: PublisherEvent {
    let location: CLLocation
}

struct EnhancedLocationChangedEvent: PublisherEvent {
    let location: CLLocation
}


// MARK: Delegate handling events
struct DelegateRawLocationChangedEvent: PublisherEvent {
    let location: CLLocation
}

struct DelegateEnhancedLocationChangedEvent: PublisherEvent {
    let location: CLLocation
}

struct DelegateConnectionStateChangedEvent: PublisherEvent {
    let connectionState: ConnectionState
}

