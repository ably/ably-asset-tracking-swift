import Core
import CoreLocation

protocol SubscriberEvent {}

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
