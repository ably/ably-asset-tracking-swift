import CoreLocation

protocol SubscriberEvent {}

struct StartEvent: SubscriberEvent {}

struct StopEvent: SubscriberEvent {}

// MARK: Delegate handling events

protocol SubscriberDelegateEvent {}

struct DelegateErrorEvent: SubscriberDelegateEvent {
    let error: Error
}

struct DelegateRawLocationReceivedEvent: SubscriberDelegateEvent {
    let location: CLLocation
}

struct DelegateEnhancedLocationReceivedEvent: SubscriberDelegateEvent {
    let location: CLLocation
}

struct DelegateConnectionStatusChangedEvent: SubscriberDelegateEvent {
    let status: AssetConnectionStatus
}
