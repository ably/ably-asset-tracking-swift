import CoreLocation

protocol SubscriberEvent {}

struct SuccessEvent: SubscriberEvent {
    let onSuccess: SuccessHandler
}

struct ErrorEvent: SubscriberEvent {
    let error: Error
    let onError: ErrorHandler
}

struct RawLocationReceivedEvent: SubscriberEvent {
    let location: CLLocation
}

struct EnhancedLocationReceivedEvent: SubscriberEvent {
    let location: CLLocation
}
