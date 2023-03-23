import AblyAssetTrackingInternal
import Foundation

// TODO why intermediate struct? two reasons: 1 to be able to use an any protocol type, 2 so that SubscriberWorkerQueuePropertiesProtocol doesn't need to inherit form WorkerQueueProperties and hence we can generate mocsk using Sourcery
struct SubscriberWorkerQueueProperties: WorkerQueueProperties {
    var isStopped: Bool = false
    var subscriberProperties: SubscriberWorkerQueuePropertiesProtocol
}

// sourcery: AutoMockable
protocol SubscriberWorkerQueuePropertiesProtocol {
    var presenceData: PresenceData { get set }
    /* weak */ var subscriber: Subscriber? { get set }
    
    var enhancedLocation: LocationUpdate? { get set }
    var rawLocation: LocationUpdate? { get set }
    var trackableState: ConnectionState { get set }
    var publisherPresence: Bool { get set }
    var resolution: Resolution? { get set }
    var nextLocationUpdateInterval: Double? { get set }
    
    /* weak */ var delegate: SubscriberDelegate? { get set }
    
    mutating func addUpdatingResolution(trackableId: String, resolution: Resolution?) 
    func containsUpdatingResolution(trackableId: String, resolution: Resolution?) -> Bool 
    func isLastUpdatingResolution(trackableId: String, resolution: Resolution?) -> Bool 
    mutating func removeUpdatingResolution(trackableId: String, resolution: Resolution?) 
    mutating func updateForConnectionStateChangeAndThenDelegateStateEventsIfRequired(stateChange: ConnectionStateChange, logHandler: InternalLogHandler?) 
    mutating func updateForChannelConnectionStateChangeAndThenDelegateStateEventsIfRequired(stateChange: ConnectionStateChange, logHandler: InternalLogHandler?) 
    mutating func updateForPresenceMessagesAndThenDelegateStateEventsIfRequired(presenceMessages: [PresenceMessage], logHandler: InternalLogHandler?) 
    mutating func delegateStateEventsIfRequired(logHandler: InternalLogHandler?) 
    mutating func notifyEnhancedLocationUpdated(locationUpdate: LocationUpdate) 
    mutating func notifyRawLocationUpdated(locationUpdate: LocationUpdate, logHandler: InternalLogHandler?) 
    mutating func notifyPublisherPresenceUpdated(isPublisherPresent: Bool, logHandler: InternalLogHandler?) 
    mutating func notifyTrackableStateUpdated(trackableState: ConnectionState, logHandler: InternalLogHandler?) 
    mutating func notifyDidFailWithError(error: ErrorInformation, logHandler: InternalLogHandler?) 
    mutating func notifyResolutionsChanged(resolutions: [Resolution], logHandler: InternalLogHandler?) 
}

struct SubscriberWorkerQueuePropertiesImpl: SubscriberWorkerQueuePropertiesProtocol {
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
    
    mutating func updateForConnectionStateChangeAndThenDelegateStateEventsIfRequired(stateChange: ConnectionStateChange, logHandler: InternalLogHandler?) {
        lastConnectionStateChange = stateChange
        delegateStateEventsIfRequired(logHandler: logHandler)
    }
    
    mutating func updateForChannelConnectionStateChangeAndThenDelegateStateEventsIfRequired(stateChange: ConnectionStateChange, logHandler: InternalLogHandler?) {
        lastChannelConnectionStateChange = stateChange
        delegateStateEventsIfRequired(logHandler: logHandler)
    }
    
    mutating func updateForPresenceMessagesAndThenDelegateStateEventsIfRequired(presenceMessages: [PresenceMessage], logHandler: InternalLogHandler?) {
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
        delegateStateEventsIfRequired(logHandler: logHandler)
    }
    
    mutating func delegateStateEventsIfRequired(logHandler: InternalLogHandler?) {
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
            }
            break
        case .offline:
            trackableState = .offline
        case .failed:
            trackableState = .failed
        }
        
        if let trackableState = trackableState, trackableState != lastEmittedTrackableState {
            lastEmittedTrackableState = trackableState
            notifyTrackableStateUpdated(trackableState: trackableState, logHandler: logHandler)
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
            notifyPublisherPresenceUpdated(isPublisherPresent: isPublisherVisible, logHandler: logHandler)
        }
        
        notifyResolutionsChanged(resolutions: pendingPublisherResolutions.drain(), logHandler: logHandler)
    }
    
    mutating func notifyEnhancedLocationUpdated(locationUpdate: LocationUpdate) {
        enhancedLocation = locationUpdate
        guard let subscriber = subscriber
        else { return }
        delegate?.subscriber(sender: subscriber, didUpdateEnhancedLocation: locationUpdate)
    }
    
    mutating func notifyRawLocationUpdated(locationUpdate: LocationUpdate, logHandler: InternalLogHandler?) {
        rawLocation = locationUpdate
        guard let subscriber = subscriber
        else { return }
        delegate?.subscriber(sender: subscriber, didUpdateRawLocation: locationUpdate)
    }
    
    mutating func notifyPublisherPresenceUpdated(isPublisherPresent: Bool, logHandler: InternalLogHandler?) {
        publisherPresence = isPublisherPresent
        guard let subscriber = subscriber
        else { return }
        delegate?.subscriber(sender: subscriber, didUpdatePublisherPresence: publisherPresence)
    }
    
    mutating func notifyTrackableStateUpdated(trackableState: ConnectionState, logHandler: InternalLogHandler?) {
        self.trackableState = trackableState
        guard let subscriber = subscriber
        else { return }
        delegate?.subscriber(sender: subscriber, didChangeAssetConnectionStatus: trackableState)
    }
    
    mutating func notifyDidFailWithError(error: ErrorInformation, logHandler: InternalLogHandler?) {
        guard let subscriber = subscriber
        else { return }
        delegate?.subscriber(sender: subscriber, didFailWithError: error)
    }
    
    mutating func notifyResolutionsChanged(resolutions: [Resolution], logHandler: InternalLogHandler?) {
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
