import AblyAssetTrackingInternal
import Foundation

// TODO document, explain why not generated, explain limitations
struct SubscriberWorkerQueuePropertiesProxy: WorkerQueueProperties {
    private var underlying: SubscriberWorkerQueueProperties
    private var recordInvocations: Bool

    // MARK: Initializer

    public init(underlying: SubscriberWorkerQueueProperties, recordInvocations: Bool) {
        self.underlying = underlying
        self.recordInvocations = recordInvocations
    }

    // MARK: Recording invocations

    private(set) var invocations: [Invocation] = []

    enum Invocation {
        case addUpdatingResolution(trackableId: String, resolution: Resolution?)
        case removeUpdatingResolution(trackableId: String, resolution: Resolution?)
        case updateForConnectionStateChangeAndThenDelegateStateEventsIfRequired(stateChange: ConnectionStateChange, logHandler: InternalLogHandler?)
        case updateForChannelConnectionStateChangeAndThenDelegateStateEventsIfRequired(stateChange: ConnectionStateChange, logHandler: InternalLogHandler?)
        case updateForPresenceMessagesAndThenDelegateStateEventsIfRequired(presenceMessages: [PresenceMessage], logHandler: InternalLogHandler?)
        case delegateStateEventsIfRequired(logHandler: InternalLogHandler?)
        case notifyEnhancedLocationUpdated(locationUpdate: LocationUpdate)
        case notifyRawLocationUpdated(locationUpdate: LocationUpdate, logHandler: InternalLogHandler?)
        case notifyPublisherPresenceUpdated(isPublisherPresent: Bool, logHandler: InternalLogHandler?)
        case notifyTrackableStateUpdated(trackableState: ConnectionState, logHandler: InternalLogHandler?)
        case notifyDidFailWithError(error: ErrorInformation, logHandler: InternalLogHandler?)
        case notifyResolutionsChanged(resolutions: [Resolution], logHandler: InternalLogHandler?)
    }

    private mutating func recordInvocation(_ invocation: Invocation) {
        guard recordInvocations else {
            return
        }

        invocations.append(invocation)
    }

    // MARK: Proxying to underlying properties

    public var isStopped: Bool {
        get {
            underlying.isStopped
        }

        set {
            underlying.isStopped = newValue
        }
    }

    var presenceData: PresenceData {
        get {
            underlying.presenceData
        }

        set {
            underlying.presenceData = newValue
        }
    }

    weak var subscriber: Subscriber? {
        get {
            underlying.subscriber
        }

        set {
            underlying.subscriber = newValue
        }
    }
    
    var enhancedLocation: LocationUpdate? {
        get {
            underlying.enhancedLocation
        }

        set {
            underlying.enhancedLocation = newValue
        }
    }
    var rawLocation: LocationUpdate? {
        get {
            underlying.rawLocation
        }

        set {
            underlying.rawLocation = newValue
        }
    }
    var trackableState: ConnectionState {
        get {
            underlying.trackableState
        }

        set {
            underlying.trackableState = newValue
        }
    }
    var publisherPresence: Bool {
        get {
            underlying.publisherPresence
        }

        set {
            underlying.publisherPresence = newValue
        }
    }
    var resolution: Resolution? {
        get {
            underlying.resolution
        }

        set {
            underlying.resolution = newValue
        }
    }
    var nextLocationUpdateInterval: Double? {
        get {
            underlying.nextLocationUpdateInterval
        }

        set {
            underlying.nextLocationUpdateInterval = newValue
        }
    }
    
    weak var delegate: SubscriberDelegate? {
        get {
            underlying.delegate
        }

        set {
            underlying.delegate = newValue
        }
    }
    
    mutating func addUpdatingResolution(trackableId: String, resolution: Resolution?) {
        recordInvocation(.addUpdatingResolution(trackableId: trackableId, resolution: resolution))
        underlying.addUpdatingResolution(trackableId: trackableId, resolution: resolution)
    }
    
    func containsUpdatingResolution(trackableId: String, resolution: Resolution?) -> Bool {
        return underlying.containsUpdatingResolution(trackableId: trackableId, resolution: resolution)
    }
    
    func isLastUpdatingResolution(trackableId: String, resolution: Resolution?) -> Bool {
        return underlying.isLastUpdatingResolution(trackableId: trackableId, resolution: resolution)
    }
    
    mutating func removeUpdatingResolution(trackableId: String, resolution: Resolution?) {
        recordInvocation(.removeUpdatingResolution(trackableId: trackableId, resolution: resolution))
        underlying.removeUpdatingResolution(trackableId: trackableId, resolution: resolution)
    }
    
    mutating func updateForConnectionStateChangeAndThenDelegateStateEventsIfRequired(stateChange: ConnectionStateChange, logHandler: InternalLogHandler?) {
        recordInvocation(.updateForConnectionStateChangeAndThenDelegateStateEventsIfRequired(stateChange: stateChange, logHandler: logHandler))
        underlying.updateForConnectionStateChangeAndThenDelegateStateEventsIfRequired(stateChange: stateChange, logHandler: logHandler)
    }
    
    mutating func updateForChannelConnectionStateChangeAndThenDelegateStateEventsIfRequired(stateChange: ConnectionStateChange, logHandler: InternalLogHandler?) {
        recordInvocation(.updateForChannelConnectionStateChangeAndThenDelegateStateEventsIfRequired(stateChange: stateChange, logHandler: logHandler))
        underlying.updateForChannelConnectionStateChangeAndThenDelegateStateEventsIfRequired(stateChange: stateChange, logHandler: logHandler)
    }
    
    mutating func updateForPresenceMessagesAndThenDelegateStateEventsIfRequired(presenceMessages: [PresenceMessage], logHandler: InternalLogHandler?) {
        recordInvocation(.updateForPresenceMessagesAndThenDelegateStateEventsIfRequired(presenceMessages: presenceMessages, logHandler: logHandler))
        underlying.updateForPresenceMessagesAndThenDelegateStateEventsIfRequired(presenceMessages: presenceMessages, logHandler: logHandler)
    }
    
    mutating func delegateStateEventsIfRequired(logHandler: InternalLogHandler?) {
        recordInvocation(.delegateStateEventsIfRequired(logHandler: logHandler))
        underlying.delegateStateEventsIfRequired(logHandler: logHandler)
    }
    
    mutating func notifyEnhancedLocationUpdated(locationUpdate: LocationUpdate) {
        recordInvocation(.notifyEnhancedLocationUpdated(locationUpdate: locationUpdate))
        underlying.notifyEnhancedLocationUpdated(locationUpdate: locationUpdate)
    }
    
    mutating func notifyRawLocationUpdated(locationUpdate: LocationUpdate, logHandler: InternalLogHandler?) {
        recordInvocation(.notifyRawLocationUpdated(locationUpdate: locationUpdate, logHandler: logHandler))
        underlying.notifyRawLocationUpdated(locationUpdate: locationUpdate, logHandler: logHandler)
    }
    
    mutating func notifyPublisherPresenceUpdated(isPublisherPresent: Bool, logHandler: InternalLogHandler?) {
        recordInvocation(.notifyPublisherPresenceUpdated(isPublisherPresent: isPublisherPresent, logHandler: logHandler))
        underlying.notifyPublisherPresenceUpdated(isPublisherPresent: isPublisherPresent, logHandler: logHandler)
    }
    
    mutating func notifyTrackableStateUpdated(trackableState: ConnectionState, logHandler: InternalLogHandler?) {
        recordInvocation(.notifyTrackableStateUpdated(trackableState: trackableState, logHandler: logHandler))
        underlying.notifyTrackableStateUpdated(trackableState: trackableState, logHandler: logHandler)
    }
    
    mutating func notifyDidFailWithError(error: ErrorInformation, logHandler: InternalLogHandler?) {
        recordInvocation(.notifyDidFailWithError(error: error, logHandler: logHandler))
        underlying.notifyDidFailWithError(error: error, logHandler: logHandler)
    }
    
    mutating func notifyResolutionsChanged(resolutions: [Resolution], logHandler: InternalLogHandler?) {
        recordInvocation(.notifyResolutionsChanged(resolutions: resolutions, logHandler: logHandler))
        underlying.notifyResolutionsChanged(resolutions: resolutions, logHandler: logHandler)
    }
}

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
