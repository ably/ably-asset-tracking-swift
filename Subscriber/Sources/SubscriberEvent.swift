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

struct ChangeResolutionEvent: SubscriberEvent {
    let resolution: Resolution?
    let onSuccess: SuccessHandler
    let onError: ErrorHandler
}

// MARK: Delegate handling events

protocol SubscriberDelegateEvent {}

struct DelegateErrorEvent: SubscriberDelegateEvent {
    let error: Error
}

struct DelegateEnhancedLocationReceivedEvent: SubscriberDelegateEvent, SubscriberEvent {
    let location: CLLocation
}

struct DelegateConnectionStatusChangedEvent: SubscriberDelegateEvent {
    let status: AssetConnectionStatus
}
