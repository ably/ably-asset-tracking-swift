import AblyAssetTrackingInternal
import Foundation

struct SubscriberWorkerQueueProperties: WorkerQueueProperties {
    public var isStopped = false
    var presenceData: PresenceData
    weak var subscriber: Subscriber?

    private(set) var presentPublisherMemberKeys: Set<String> = []
    private(set) var lastEmittedValueOfIsPublisherVisible: Bool?
    private(set) var lastEmittedTrackableState: ConnectionState = .offline
    private(set) var lastConnectionStateChange = ConnectionStateChange(state: .offline, errorInformation: nil)
    private(set) var lastChannelConnectionStateChange = ConnectionStateChange(state: .offline, errorInformation: nil)
    private(set) var pendingPublisherResolutions = PendingResolutions()

    private(set) var enhancedLocation: LocationUpdate?
    private(set) var rawLocation: LocationUpdate?
    private(set) var trackableState: ConnectionState = .offline
    private(set) var publisherPresence = false
    private(set) var resolution: Resolution?
    private(set) var nextLocationUpdateInterval: Double?

    public init(initialResolution: Resolution?) {
        self.presenceData = PresenceData(type: .subscriber, resolution: initialResolution)
    }

    mutating func updateForConnectionStateChangeAndThenDelegateStateEventsIfRequired(stateChange: ConnectionStateChange, logHandler: InternalLogHandler?) {
        lastConnectionStateChange = stateChange
        delegateStateEventsIfRequired(logHandler: logHandler)
    }

    mutating func updateForChannelConnectionStateChangeAndThenDelegateStateEventsIfRequired(stateChange: ConnectionStateChange, logHandler: InternalLogHandler?) {
        lastChannelConnectionStateChange = stateChange
        delegateStateEventsIfRequired(logHandler: logHandler)
    }

    mutating func updateForPresenceMessagesAndThenDelegateStateEventsIfRequired(presenceMessages: [Presence], logHandler: InternalLogHandler?) {
        for presenceMessage in presenceMessages where presenceMessage.data.type == .publisher {
            switch presenceMessage.action {
            case .leave, .absent:
                presentPublisherMemberKeys.remove(presenceMessage.memberKey)
            case .present, .enter, .update:
                presentPublisherMemberKeys.insert(presenceMessage.memberKey)
                if let publisherResolution = presenceMessage.data.resolution {
                    pendingPublisherResolutions.add(resolution: publisherResolution)
                }
            case .unknown:
                break
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
        case .offline:
            trackableState = .offline
        case .failed:
            trackableState = .failed
        }

        if let trackableState, trackableState != lastEmittedTrackableState {
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

    mutating func notifyEnhancedLocationUpdated(locationUpdate: LocationUpdate, logHandler: InternalLogHandler?) {
        enhancedLocation = locationUpdate
        guard let subscriber
        else { return }
        logHandler?.logPublicAPICall(label: "Calling delegate didUpdateEnhancedLocation: \(locationUpdate)")
        subscriber.delegate?.subscriber(sender: subscriber, didUpdateEnhancedLocation: locationUpdate)
    }

    mutating func notifyRawLocationUpdated(locationUpdate: LocationUpdate, logHandler: InternalLogHandler?) {
        rawLocation = locationUpdate
        guard let subscriber
        else { return }
        logHandler?.logPublicAPICall(label: "Calling delegate didUpdateRawLocation: \(locationUpdate)")
        subscriber.delegate?.subscriber(sender: subscriber, didUpdateRawLocation: locationUpdate)
    }

    mutating func notifyPublisherPresenceUpdated(isPublisherPresent: Bool, logHandler: InternalLogHandler?) {
        publisherPresence = isPublisherPresent
        guard let subscriber
        else { return }
        logHandler?.logPublicAPICall(label: "Calling delegate didUpdatePublisherPresence: \(publisherPresence)")
        subscriber.delegate?.subscriber(sender: subscriber, didUpdatePublisherPresence: publisherPresence)
    }

    mutating func notifyTrackableStateUpdated(trackableState: ConnectionState, logHandler: InternalLogHandler?) {
        self.trackableState = trackableState
        guard let subscriber
        else { return }
        logHandler?.logPublicAPICall(label: "Calling delegate didChangeAssetConnectionStatus: \(trackableState)")
        subscriber.delegate?.subscriber(sender: subscriber, didChangeAssetConnectionStatus: trackableState)
    }

    mutating func notifyDidFailWithError(error: ErrorInformation, logHandler: InternalLogHandler?) {
        guard let subscriber
        else { return }
        logHandler?.logPublicAPICall(label: "Calling delegate didFailWithError: \(error)")
        subscriber.delegate?.subscriber(sender: subscriber, didFailWithError: error)
    }

    mutating func notifyResolutionsChanged(resolutions: [Resolution], logHandler: InternalLogHandler?) {
        guard !resolutions.isEmpty
        else { return }
        for resolution in resolutions {
            self.resolution = resolution
            self.nextLocationUpdateInterval = resolution.desiredInterval
            guard let subscriber
            else { return }
            logHandler?.logPublicAPICall(label: "Calling delegate didUpdateResolution: \(resolution)")
            subscriber.delegate?.subscriber(sender: subscriber, didUpdateResolution: resolution)
            logHandler?.logPublicAPICall(label: "Calling delegate didUpdateDesiredInterval: \(resolution.desiredInterval)")
            subscriber.delegate?.subscriber(sender: subscriber, didUpdateDesiredInterval: resolution.desiredInterval)
        }
    }
}

struct PendingResolutions {
    private var resolutions: [Resolution] = []

    mutating func add(resolution: Resolution) {
        resolutions.append(resolution)
    }

    mutating func drain() -> [Resolution] {
        let array = resolutions
        resolutions.removeAll()
        return array
    }
}
