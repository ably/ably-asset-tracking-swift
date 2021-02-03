import CoreLocation

protocol SubscriberEvent {}

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

struct DelegateEnhancedLocationReceivedEvent: SubscriberDelegateEvent {
    let location: CLLocation
}

struct DelegateConnectionStatusChangedEvent: SubscriberDelegateEvent {
    let status: AssetConnectionStatus
}
