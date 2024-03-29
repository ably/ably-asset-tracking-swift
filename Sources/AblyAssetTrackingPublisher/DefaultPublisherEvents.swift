import AblyAssetTrackingCore
import AblyAssetTrackingInternal
import CoreLocation
import MapboxDirections

// These types are only used internally by DefaultPublisher.
extension DefaultPublisher {
    enum Event {
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
        case presenceMessage(PresenceMessageEvent)
        case stop(StopEvent)
        case ablyConnectionClosed(AblyConnectionClosedEvent)
        case ablyClientConnectionStateChanged(AblyClientConnectionStateChangedEvent)
        case ablyChannelConnectionStateChanged(AblyChannelConnectionStateChangedEvent)
        case delegateError(DelegateErrorEvent)
        case delegateEnhancedLocationChanged(DelegateEnhancedLocationChangedEvent)
        case delegateTrackableConnectionStateChanged(DelegateTrackableStateChangedEvent)
        case delegateResolutionUpdate(DelegateResolutionUpdateEvent)

        struct TrackTrackableEvent {
            let trackable: Trackable
            let completion: Callback<Void>
        }

        struct AddTrackableEvent {
            let trackable: Trackable
            let completion: Callback<Void>
        }

        struct RemoveTrackableEvent {
            let trackable: Trackable
            let completion: Callback<Bool>
        }

        struct ClearActiveTrackableEvent {
            let trackable: Trackable
            let completion: Callback<Bool>
        }

        struct ClearRemovedTrackableMetadataEvent {
            let trackable: Trackable
            let completion: Callback<Bool>
        }

        struct PresenceJoinedSuccessfullyEvent {
            let trackable: Trackable
            let completion: Callback<Void>
        }

        struct TrackableReadyToTrackEvent {
            let trackable: Trackable
            let completion: Callback<Void>
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
            let completion: Callback<Void>
        }

        struct PresenceMessageEvent {
            let trackable: Trackable
            let presence: PresenceMessage
            let presenceData: PresenceData
            let clientId: String
        }

        struct StopEvent {
            let completion: Callback<Void>
        }

        struct AblyConnectionClosedEvent {
            let completion: Callback<Void>
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

        struct DelegateTrackableStateChangedEvent {
            let trackable: Trackable
            let state: TrackableState
        }

        struct DelegateResolutionUpdateEvent {
            let resolution: Resolution
        }
    }

    // MARK: Delegate handling events
    enum DelegateEvent {
        case error(ErrorEvent)
        case enhancedLocationChanged(EnhancedLocationChangedEvent)
        case trackableStateChanged(TrackableStateChangedEvent)
        case finishedRecordingLocationHistoryData(FinishedRecordingLocationHistoryDataEvent)
        case finishedRecordingRawMapboxData(FinishedRecordingRawMapboxDataEvent)
        case didUpdateResolution(DidUpdateResolutionEvent)
        case didChangeTrackables(DidChangeTrackablesEvent)

        struct ErrorEvent {
            let error: ErrorInformation
        }

        struct EnhancedLocationChangedEvent {
            let locationUpdate: EnhancedLocationUpdate
        }

        struct TrackableStateChangedEvent {
            let trackable: Trackable
            let state: TrackableState
        }

        struct FinishedRecordingLocationHistoryDataEvent {
            let locationHistoryData: LocationHistoryData
        }

        struct FinishedRecordingRawMapboxDataEvent {
            let temporaryFile: TemporaryFile
        }

        struct DidUpdateResolutionEvent {
            let resolution: Resolution
        }

        struct DidChangeTrackablesEvent {
            let trackables: Set<Trackable>
        }
    }
}
