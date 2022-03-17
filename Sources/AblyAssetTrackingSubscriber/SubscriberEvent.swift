import CoreLocation
import AblyAssetTrackingCore
import AblyAssetTrackingInternal

protocol SubscriberEvent {}

struct StartEvent: SubscriberEvent {
    let resultHandler: ResultHandler<Void>
}

struct StopEvent: SubscriberEvent {
    let resultHandler: ResultHandler<Void>
}

struct ChangeResolutionEvent: SubscriberEvent {
    let resolution: Resolution?
    let resultHandler: ResultHandler<Void>
}

struct PresenceUpdateEvent: SubscriberEvent {
    let presence: Presence
}

struct AblyConnectionClosedEvent: SubscriberEvent {
    let resultHandler: ResultHandler<Void>
}

struct AblyClientConnectionStateChangedEvent: SubscriberEvent {
    let connectionState: ConnectionState
}

struct AblyChannelConnectionStateChangedEvent: SubscriberEvent {
    let connectionState: ConnectionState
}

// MARK: Delegate handling events

protocol SubscriberDelegateEvent {}

struct DelegateErrorEvent: SubscriberDelegateEvent {
    let error: ErrorInformation
}

struct DelegateEnhancedLocationReceivedEvent: SubscriberDelegateEvent {
    let location: Location
}

struct DelegateRawLocationReceivedEvent: SubscriberDelegateEvent {
    let location: Location
}

struct DelegateResolutionReceivedEvent: SubscriberDelegateEvent {
    let resolution: Resolution
}

struct DelegateConnectionStatusChangedEvent: SubscriberDelegateEvent {
    let status: ConnectionState
}
