import AblyAssetTrackingCore
import AblyAssetTrackingInternal
import CoreLocation

// These types are only used internally by DefaultSubscriber.
extension DefaultSubscriber {
    enum Event {
        case start(StartEvent)
        case stop(StopEvent)
        case changeResolution(ChangeResolutionEvent)
        case presenceMessageReceived(PresenceMessageReceivedEvent)
        case ablyConnectionClosed(AblyConnectionClosedEvent)
        case ablyClientConnectionStateChanged(AblyClientConnectionStateChangedEvent)
        case ablyChannelConnectionStateChanged(AblyChannelConnectionStateChangedEvent)
        case ablyError(AblyErrorEvent)

        struct StartEvent {
            let completion: Callback<Void>
        }

        struct StopEvent {
            let completion: Callback<Void>
        }

        struct ChangeResolutionEvent {
            let resolution: Resolution?
            let completion: Callback<Void>
        }

        struct PresenceMessageReceivedEvent {
            let presence: PresenceMessage
        }

        struct AblyConnectionClosedEvent {
            let completion: Callback<Void>
        }

        struct AblyClientConnectionStateChangedEvent {
            let connectionState: ConnectionState
        }

        struct AblyChannelConnectionStateChangedEvent {
            let connectionState: ConnectionState
        }

        struct AblyErrorEvent {
            let error: ErrorInformation
        }
    }

    // MARK: Delegate handling events

    enum DelegateEvent {
        case delegateError(DelegateErrorEvent)
        case delegateEnhancedLocationReceived(DelegateEnhancedLocationReceivedEvent)
        case delegateRawLocationReceived(DelegateRawLocationReceivedEvent)
        case delegateResolutionReceived(DelegateResolutionReceivedEvent)
        case delegateDesiredIntervalReceived(DelegateDesiredIntervalReceivedEvent)
        case delegateTrackableStateChanged(DelegateTrackableStateChangedEvent)
        case delegateUpdatedPublisherPresence(DelegateUpdatedPublisherPresenceEvent)

        struct DelegateErrorEvent {
            let error: ErrorInformation
        }

        struct DelegateEnhancedLocationReceivedEvent {
            let locationUpdate: LocationUpdate
        }

        struct DelegateRawLocationReceivedEvent {
            let locationUpdate: LocationUpdate
        }

        struct DelegateResolutionReceivedEvent {
            let resolution: Resolution
        }

        struct DelegateDesiredIntervalReceivedEvent {
            let desiredInterval: Double
        }

        struct DelegateTrackableStateChangedEvent {
            let state: TrackableState
        }

        struct DelegateUpdatedPublisherPresenceEvent {
            let isPresent: Bool
        }
    }
}
