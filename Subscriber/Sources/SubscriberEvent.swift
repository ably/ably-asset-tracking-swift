import CoreLocation

protocol SubscriberEvent {}

struct StartEvent: SubscriberEvent {}

struct StopEvent: SubscriberEvent {}

// MARK: Delegate handling events
struct DelegateErrorEvent: SubscriberEvent {
    let error: Error
}

struct DelegateRawLocationReceivedEvent: SubscriberEvent {
    let location: CLLocation
}

struct DelegateEnhancedLocationReceivedEvent: SubscriberEvent {
    let location: CLLocation
}

struct DelegateConnectionStatusChangedEvent: SubscriberEvent {
    let status: AssetConnectionStatus
}
