import CoreLocation
import AblyAssetTrackingCore
import AblyAssetTrackingInternal

// These types are only used internally by DefaultSubscriber.
extension DefaultSubscriber {
    enum SubscriberEvent {
        case start(StartEvent)
        case stop(StopEvent)
        case changeResolution(ChangeResolutionEvent)
        case presenceUpdate(PresenceUpdateEvent)
        case ablyConnectionClosed(AblyConnectionClosedEvent)
        case ablyClientConnectionStateChanged(AblyClientConnectionStateChangedEvent)
        case ablyChannelConnectionStateChanged(AblyChannelConnectionStateChangedEvent)
        
        struct StartEvent {
            let resultHandler: ResultHandler<Void>
        }
        
        struct StopEvent {
            let resultHandler: ResultHandler<Void>
        }
        
        struct ChangeResolutionEvent {
            let resolution: Resolution?
            let resultHandler: ResultHandler<Void>
        }
        
        struct PresenceUpdateEvent {
            let presence: Presence
        }
        
        struct AblyConnectionClosedEvent {
            let resultHandler: ResultHandler<Void>
        }
        
        struct AblyClientConnectionStateChangedEvent {
            let connectionState: ConnectionState
        }
        
        struct AblyChannelConnectionStateChangedEvent {
            let connectionState: ConnectionState
        }
    }
    
    // MARK: Delegate handling events
    
    enum SubscriberDelegateEvent {
        case delegateError(DelegateErrorEvent)
        case delegateEnhancedLocationReceived(DelegateEnhancedLocationReceivedEvent)
        case delegateRawLocationReceived(DelegateRawLocationReceivedEvent)
        case delegateResolutionReceived(DelegateResolutionReceivedEvent)
        case delegateDesiredIntervalReceived(DelegateDesiredIntervalReceivedEvent)
        case delegateConnectionStatusChanged(DelegateConnectionStatusChangedEvent)
        
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
    }
}
