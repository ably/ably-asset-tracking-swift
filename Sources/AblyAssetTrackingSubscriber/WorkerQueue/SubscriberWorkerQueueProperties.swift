import AblyAssetTrackingInternal
import Foundation

struct SubscriberWorkerQueueProperties: WorkerQueueProperties {
    public var isStopped = false
    var presenceData: PresenceData
    weak var subscriber: Subscriber?

    private var presentPublisherMemberKeys: Set<String> = []
    private var lastEmittedValueOfIsPublisherVisible: Bool?
    private var lastEmittedTrackableState: ConnectionState = .offline
    private var lastConnectionStateChange = ConnectionStateChange(state: .offline, errorInformation: nil)
    private var lastChannelConnectionStateChange = ConnectionStateChange(state: .offline, errorInformation: nil)
    private var pendingPublisherResolutions = PendingResolutions()

    var enhancedLocation: LocationUpdate?
    var rawLocation: LocationUpdate?
    var trackableState: ConnectionState = .offline
    var publisherPresence = false
    var resolution: Resolution?
    var nextLocationUpdateInterval: Double?

    public init(initialResolution: Resolution?) {
        self.presenceData = PresenceData(type: .subscriber, resolution: initialResolution)
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
            }
        case .offline:
            trackableState = .offline
        case .failed:
            trackableState = .failed
        }

        if let trackableState, trackableState != lastEmittedTrackableState {
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
        guard let subscriber
        else { return }
        subscriber.delegate?.subscriber(sender: subscriber, didUpdateEnhancedLocation: locationUpdate)
    }

    mutating func notifyRawLocationUpdated(locationUpdate: LocationUpdate) {
        rawLocation = locationUpdate
        guard let subscriber
        else { return }
        subscriber.delegate?.subscriber(sender: subscriber, didUpdateRawLocation: locationUpdate)
    }

    mutating func notifyPublisherPresenceUpdated(isPublisherPresent: Bool) {
        publisherPresence = isPublisherPresent
        guard let subscriber
        else { return }
        subscriber.delegate?.subscriber(sender: subscriber, didUpdatePublisherPresence: publisherPresence)
    }

    mutating func notifyTrackableStateUpdated(trackableState: ConnectionState) {
        self.trackableState = trackableState
        guard let subscriber
        else { return }
        subscriber.delegate?.subscriber(sender: subscriber, didChangeAssetConnectionStatus: trackableState)
    }

    mutating func notifyDidFailWithError(error: ErrorInformation) {
        guard let subscriber
        else { return }
        subscriber.delegate?.subscriber(sender: subscriber, didFailWithError: error)
    }

    mutating func notifyResolutionsChanged(resolutions: [Resolution]) {
        guard !resolutions.isEmpty
        else { return }
        for resolution in resolutions {
            self.resolution = resolution
            self.nextLocationUpdateInterval = resolution.desiredInterval
            guard let subscriber
            else { return }
            subscriber.delegate?.subscriber(sender: subscriber, didUpdateResolution: resolution)
            subscriber.delegate?.subscriber(sender: subscriber, didUpdateDesiredInterval: resolution.desiredInterval)
        }
    }
}

private class PendingResolutions {
    private var resolutions: [Resolution] = []

    func add(resolution: Resolution) {
        resolutions.append(resolution)
    }

    func drain() -> [Resolution] {
        let array = resolutions
        resolutions.removeAll()
        return array
    }
}
