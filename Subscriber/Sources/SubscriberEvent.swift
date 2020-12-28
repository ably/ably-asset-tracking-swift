import CoreLocation

protocol SubscriberEvent {}

struct SuccessEvent: SubscriberEvent {
    let onSuccess: SuccessHandler
}

struct ErrorEvent: SubscriberEvent {
    let error: Error
    let onError: ErrorHandler
}

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
