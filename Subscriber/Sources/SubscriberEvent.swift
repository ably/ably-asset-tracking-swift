import CoreLocation

protocol SubscriberEvent {}

struct StartEvent: SubscriberEvent {}

struct StopEvent: SubscriberEvent {}

struct ChangeResolutionEvent: SubscriberEvent {
    let resolution: Resolution?
    let resultHandler: ResultHandler<Void>
}

// MARK: Delegate handling events

protocol SubscriberDelegateEvent {}

struct DelegateErrorEvent: SubscriberDelegateEvent {
    let error: ErrorInformation
}

struct DelegateEnhancedLocationReceivedEvent: SubscriberDelegateEvent {
    let location: CLLocation
}

struct DelegateConnectionStatusChangedEvent: SubscriberDelegateEvent {
    let status: ConnectionState
}
