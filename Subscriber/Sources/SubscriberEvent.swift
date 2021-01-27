import CoreLocation

protocol SubscriberEvent {}

struct SuccessEvent<T: Any>: SubscriberEvent {
    let resultHandler: ResultHandler<T>
}

//struct ErrorEvent: SubscriberEvent {
//    let error: Error
//    let onError: ErrorHandler
//}

struct StartEvent: SubscriberEvent {}

struct StopEvent: SubscriberEvent {}

struct ChangeResolutionEvent: SubscriberEvent {
    let resolution: Resolution?
    let resultHandler: ResultHandler<Void>
}

// MARK: Delegate handling events
struct DelegateErrorEvent: SubscriberEvent {
    let error: Error
}

struct DelegateEnhancedLocationReceivedEvent: SubscriberEvent {
    let location: CLLocation
}

struct DelegateConnectionStatusChangedEvent: SubscriberEvent {
    let status: AssetConnectionStatus
}
