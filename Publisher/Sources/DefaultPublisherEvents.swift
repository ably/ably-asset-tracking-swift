import CoreLocation

protocol PublisherEvent {}

struct TrackTrackableEvent: PublisherEvent {
    let trackable: Trackable
    let onSuccess: SuccessHandler
    let onError: ErrorHandler
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

// MARK: Delegate handling events
protocol DelegatePublisherEvent {}

struct DelegateErrorEvent: DelegatePublisherEvent {
    let error: Error
}

struct DelegateRawLocationChangedEvent: DelegatePublisherEvent {
    let location: CLLocation
}

struct DelegateEnhancedLocationChangedEvent: DelegatePublisherEvent {
    let location: CLLocation
}

struct DelegateConnectionStateChangedEvent: DelegatePublisherEvent {
    let connectionState: ConnectionState
}
