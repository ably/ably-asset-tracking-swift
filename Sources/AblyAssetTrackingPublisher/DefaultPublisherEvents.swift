import CoreLocation
import MapboxDirections
import AblyAssetTrackingCore
import AblyAssetTrackingInternal

// These types are only used internally by DefaultPublisher.
extension DefaultPublisher {
    enum PublisherEvent {
        case trackTrackable(TrackTrackableEvent)
        case addTrackable(AddTrackableEvent)
        case removeTrackable(RemoveTrackableEvent)
        case clearActiveTrackable(ClearActiveTrackableEvent)
        case clearRemovedTrackableMetadata(ClearRemovedTrackableMetadataEvent)
        case presenceJoinedSuccessfully(PresenceJoinedSuccessfullyEvent)
        case trackableReadyToTrack(TrackableReadyToTrackEvent)
        case setDestinationSuccess(SetDestinationSuccessEvent)
        case enhancedLocationChanged(EnhancedLocationChangedEvent)
        case sendEnhancedLocationSuccess(SendEnhancedLocationSuccessEvent)
        case sendEnhancedLocationFailure(SendEnhancedLocationFailureEvent)
        case rawLocationChanged(RawLocationChangedEvent)
        case sendRawLocationSuccess(SendRawLocationSuccessEvent)
        case sendRawLocationFailure(SendRawLocationFailureEvent)
        case refreshResolutionPolicy(RefreshResolutionPolicyEvent)
        case changeLocationEngineResolution(ChangeLocationEngineResolutionEvent)
        case changeRoutingProfile(ChangeRoutingProfileEvent)
        case presenceUpdate(PresenceUpdateEvent)
        case stop(StopEvent)
        case ablyConnectionClosed(AblyConnectionClosedEvent)
        case ablyClientConnectionStateChanged(AblyClientConnectionStateChangedEvent)
        case ablyChannelConnectionStateChanged(AblyChannelConnectionStateChangedEvent)
        case delegateError(DelegateErrorEvent)
        case delegateEnhancedLocationChanged(DelegateEnhancedLocationChangedEvent)
        case delegateTrackableConnectionStateChanged(DelegateTrackableConnectionStateChangedEvent)
        case delegateResolutionUpdate(DelegateResolutionUpdateEvent)
        
        struct TrackTrackableEvent {
            let trackable: Trackable
            let resultHandler: ResultHandler<Void>
        }
        
        struct AddTrackableEvent {
            let trackable: Trackable
            let resultHandler: ResultHandler<Void>
        }
        
        struct RemoveTrackableEvent {
            let trackable: Trackable
            let resultHandler: ResultHandler<Bool>
        }
        
        struct ClearActiveTrackableEvent {
            let trackable: Trackable
            let resultHandler: ResultHandler<Bool>
        }
        
        struct ClearRemovedTrackableMetadataEvent {
            let trackable: Trackable
            let resultHandler: ResultHandler<Bool>
        }
        
        struct PresenceJoinedSuccessfullyEvent {
            let trackable: Trackable
            let resultHandler: ResultHandler<Void>
        }
        
        struct TrackableReadyToTrackEvent {
            let trackable: Trackable
            let resultHandler: ResultHandler<Void>
        }
        
        struct SetDestinationSuccessEvent {
            let route: Route
        }
        
        struct EnhancedLocationChangedEvent {
            let locationUpdate: EnhancedLocationUpdate
        }
        
        struct SendEnhancedLocationSuccessEvent {
            let trackable: Trackable
            let location: Location
        }
        
        struct SendEnhancedLocationFailureEvent {
            let error: ErrorInformation
            let locationUpdate: EnhancedLocationUpdate
            let trackable: Trackable
        }
        
        struct RawLocationChangedEvent {
            var locationUpdate: RawLocationUpdate
        }
        
        struct SendRawLocationSuccessEvent {
            let trackable: Trackable
            let location: Location
        }
        
        struct SendRawLocationFailureEvent {
            let error: ErrorInformation
            let locationUpdate: RawLocationUpdate
            let trackable: Trackable
        }
        
        struct RefreshResolutionPolicyEvent {}
        
        struct ChangeLocationEngineResolutionEvent {}
        
        struct ChangeRoutingProfileEvent {
            let profile: RoutingProfile
            let resultHandler: ResultHandler<Void>
        }
        
        struct PresenceUpdateEvent {
            let trackable: Trackable
            let presence: Presence
            let presenceData: PresenceData
            let clientId: String
        }
        
        struct StopEvent {
            let resultHandler: ResultHandler<Void>
        }
        
        struct AblyConnectionClosedEvent {
            let resultHandler: ResultHandler<Void>
        }
        
        struct AblyClientConnectionStateChangedEvent {
            let connectionState: ConnectionState
        }
        
        struct AblyChannelConnectionStateChangedEvent {
            let trackable: Trackable
            let connectionState: ConnectionState
        }
        
        struct DelegateErrorEvent {
            let error: ErrorInformation
        }
        
        struct DelegateEnhancedLocationChangedEvent {
            let locationUpdate: EnhancedLocationUpdate
        }
        
        struct DelegateTrackableConnectionStateChangedEvent {
            let trackable: Trackable
            let connectionState: ConnectionState
        }
        
        struct DelegateResolutionUpdateEvent {
            let resolution: Resolution
        }
    }
    
    // MARK: Delegate handling events
    enum PublisherDelegateEvent {
        case delegateError(DelegateErrorEvent)
        case delegateEnhancedLocationChanged(DelegateEnhancedLocationChangedEvent)
        case delegateTrackableConnectionStateChanged(DelegateTrackableConnectionStateChangedEvent)
        
        struct DelegateErrorEvent {
            let error: ErrorInformation
        }
        
        struct DelegateEnhancedLocationChangedEvent {
            let locationUpdate: EnhancedLocationUpdate
        }
        
        struct DelegateTrackableConnectionStateChangedEvent {
            let trackable: Trackable
            let connectionState: ConnectionState
        }
    }
}
