import Foundation
import AblyAssetTrackingInternal

struct SubscriberWorkerQueueProperties: WorkerQueueProperties {
    public var isStopped = false
    var presenceData: PresenceData
    weak var subscriber: Subscriber?
    
    private var updatingResolutions: [String: [Resolution?]] = [:]
    private var presentPublisherMemberKeys: Set<String> = []
    private var lastEmittedValueOfIsPublisherVisible: Bool?
    private var lastEmittedTrackableState: ConnectionState = .offline
    private var lastConnectionStateChange: ConnectionStateChange = ConnectionStateChange(state: .offline, errorInformation: nil)
    private var lastChannelConnectionStateChange: ConnectionStateChange = ConnectionStateChange(state: .offline, errorInformation: nil)
    private var pendingPublisherResolutions: PendingResolutions = PendingResolutions()
    
    var enhancedLocation: LocationUpdate?
    var rawLocation: LocationUpdate?
    var trackableState: ConnectionState = .offline
    var publisherPresence: Bool = false
    var resolution: Resolution?
    var nextLocationUpdateInterval: Double?
    
    weak var delegate: SubscriberDelegate?
    
    public init(initialResolution: Resolution?) {
        self.presenceData = PresenceData(type: .subscriber, resolution: initialResolution)
    }
    
    mutating func addUpdatingResolution(trackableId: String, resolution: Resolution?) {
        var updatingList = updatingResolutions[trackableId] ?? []
        updatingList.append(resolution)
        updatingResolutions[trackableId] = updatingList
    }
    
    func containsUpdatingResolution(trackableId: String, resolution: Resolution?) -> Bool {
        return updatingResolutions[trackableId]?.contains(resolution) ?? false
    }
    
    func isLastUpdatingResolution(trackableId: String, resolution: Resolution?) -> Bool {
        return updatingResolutions[trackableId]?.last == resolution
    }
    
    mutating func removeUpdatingResolution(trackableId: String, resolution: Resolution?) {
        updatingResolutions[trackableId]?.removeAll(where: { resolutionToRemove in
            resolutionToRemove == resolution
        })
        
        if (updatingResolutions[trackableId]?.isEmpty == true) {
            updatingResolutions.removeValue(forKey: trackableId)
        }
    }
    
    mutating func updateForConnectionStateChangeAndThenDelegateStateEventsIfRequired(stateChange: ConnectionStateChange) {
        lastConnectionStateChange = stateChange
        delegateStateEventsIfRequired()
    }
    
    mutating func updateForChannelConnectionStateChangeAndThenDelegateStateEventsIfRequired(stateChange: ConnectionStateChange) {
        lastChannelConnectionStateChange = stateChange
        delegateStateEventsIfRequired()
    }
    
    mutating func updateForPresenceMessagesAndThenDelegateStateEventsIfRequired(presenceMessages: [Presence]) {
        for presenceMessage in presenceMessages {
            if (presenceMessage.data.type == .publisher) {
                
                if (presenceMessage.action == .leave || presenceMessage.action == .absent) {
                    presentPublisherMemberKeys.remove(presenceMessage.memberKey)
                } else if (presenceMessage.action == .present || presenceMessage.action == .enter || presenceMessage.action == .update){
                    presentPublisherMemberKeys.insert(presenceMessage.memberKey)
                    
                    if let publisherResolution = presenceMessage.data.resolution {
                        pendingPublisherResolutions.add(resolution: publisherResolution)
                    }
                    
                }
            }
        }
        delegateStateEventsIfRequired()
    }
    
    mutating func delegateStateEventsIfRequired() {
        let isAPublisherPresent = !presentPublisherMemberKeys.isEmpty
        
        var trackableState: ConnectionState?
        switch lastConnectionStateChange.state {
        case .online:
            switch lastChannelConnectionStateChange.state {
            case .online:
                trackableState = isAPublisherPresent ? .online : .offline
            case .offline:
                trackableState = .offline
            case .failed:
                trackableState = .failed
            case .publishing:
                break
            }
            break
        case .publishing:
            break
        case .offline:
            trackableState = .offline
        case .failed:
            trackableState = .failed
        }
        
        if let trackableState = trackableState, trackableState != lastEmittedTrackableState {
            lastEmittedTrackableState = trackableState
            notifyTrackableStateUpdated(trackableState: trackableState)
        }
        // It is possible for presentPublisherMemberKeys to not be empty, even when there's no connectivity from our side,
        // because it's possible to have presence entry events without subsequent leave events.
        // Therefore, from the perspective of a user consuming events from publisherPresenceStateFlow, what matters
        // is what's computed for isPublisherVisible (not the simple isAPublisherPresent).
        var isPublisherVisible = false
        if case .online = lastConnectionStateChange.state {
            if isAPublisherPresent {
                isPublisherVisible = true
            }
        }
        
        if lastEmittedValueOfIsPublisherVisible != isPublisherVisible {
            lastEmittedValueOfIsPublisherVisible = isPublisherVisible
            notifyPublisherPresenceUpdated(isPublisherPresent: isPublisherVisible)
        }
        
        notifyResolutionsChanged(resolutions: pendingPublisherResolutions.drain())
    }
    
    mutating func notifyEnhancedLocationUpdated(locationUpdate: LocationUpdate) {
        enhancedLocation = locationUpdate
        guard let subscriber = subscriber
        else { return }
        delegate?.subscriber(sender: subscriber, didUpdateEnhancedLocation: locationUpdate)
    }
    
    mutating func notifyRawLocationUpdated(locationUpdate: LocationUpdate) {
        rawLocation = locationUpdate
        guard let subscriber = subscriber
        else { return }
        delegate?.subscriber(sender: subscriber, didUpdateRawLocation: locationUpdate)
    }
    
    mutating func notifyPublisherPresenceUpdated(isPublisherPresent: Bool) {
        publisherPresence = isPublisherPresent
        guard let subscriber = subscriber
        else { return }
        delegate?.subscriber(sender: subscriber, didUpdatePublisherPresence: publisherPresence)
    }
    
    mutating func notifyTrackableStateUpdated(trackableState: ConnectionState) {
        self.trackableState = trackableState
        guard let subscriber = subscriber
        else { return }
        delegate?.subscriber(sender: subscriber, didChangeAssetConnectionStatus: trackableState)
    }
    
    mutating func notifyDidFailWithError(error: ErrorInformation) {
        guard let subscriber = subscriber
        else { return }
        delegate?.subscriber(sender: subscriber, didFailWithError: error)
    }
    
    mutating func notifyResolutionsChanged(resolutions: [Resolution]) {
        if !resolutions.isEmpty {
            for resolution in resolutions {
                self.resolution = resolution
                self.nextLocationUpdateInterval = resolution.desiredInterval
                guard let subscriber = subscriber
                else { return }
                delegate?.subscriber(sender: subscriber, didUpdateResolution: resolution)
                delegate?.subscriber(sender: subscriber, didUpdateDesiredInterval: resolution.desiredInterval)
            }
        }
    }
}

fileprivate class PendingResolutions {
    private var resolutions: [Resolution] = []

    func add(resolution: Resolution) {
        resolutions.append(resolution)
    }

    func drain() -> Array<Resolution> {
        let array = resolutions
        resolutions.removeAll()
        return array
    }
}
