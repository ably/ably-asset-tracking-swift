import CoreLocation
import AblyAssetTrackingCore
import AblyAssetTrackingInternal

// These types are only used internally by DefaultSubscriber.
extension DefaultSubscriber {
    enum Event {
        case start(StartEvent)
        case stop(StopEvent)
        case changeResolution(ChangeResolutionEvent)
        case presenceUpdate(PresenceUpdateEvent)
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
        
        struct PresenceUpdateEvent {
            let presence: Presence
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
        case delegateConnectionStatusChanged(DelegateConnectionStatusChangedEvent)
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
        
        struct DelegateConnectionStatusChangedEvent {
            let status: ConnectionState
        }
        
        struct DelegateUpdatedPublisherPresenceEvent {
            let isPresent: Bool
        }
    }
}
