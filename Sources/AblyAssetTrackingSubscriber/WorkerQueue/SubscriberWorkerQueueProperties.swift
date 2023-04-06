import AblyAssetTrackingInternal
import Foundation

/*
We use this intermediate struct, instead of directly making SubscriberWorkerQueueProperties a protocol, for two reasons:

1. If it were a protocol, we would not be able create a WorkerQueue whose PropertiesType is SubscriberWorkerQueueProperties (we’d get an error "Type 'any SubscriberWorkerQueueProperties' cannot conform to 'WorkerQueueProperties' — Only concrete types such as structs, enums and classes can conform to protocols")
2. Sourcery is unable to generate mocks for protocols that inherit from other protocols. This means that if SubscriberWorkerQueueProperties were to inherit directly from WorkerQueueProperties, we would not be able to use Sourcery to generate mocks for it.
*/
struct SubscriberWorkerQueueProperties: WorkerQueueProperties {
    var isStopped: Bool
    var specific: SubscriberSpecificWorkerQueuePropertiesProtocol
}

// sourcery: AutoMockable
protocol SubscriberSpecificWorkerQueuePropertiesProtocol {
    var presenceData: PresenceData { get set }

    var presentPublisherMemberKeys: Set<String> { get }
    var lastEmittedValueOfIsPublisherVisible: Bool? { get }
    var lastEmittedTrackableState: TrackableState { get }
    var lastConnectionStateChange: ConnectionStateChange { get }
    var lastChannelConnectionStateChange: ConnectionStateChange { get }
    var pendingPublisherResolutions: PendingResolutions { get }

    var enhancedLocation: LocationUpdate? { get }
    var rawLocation: LocationUpdate? { get }
    var trackableState: TrackableState { get }
    var publisherPresence: Bool { get }
    var resolution: Resolution? { get }
    var nextLocationUpdateInterval: Double? { get }

    mutating func updateForConnectionStateChangeAndThenDelegateStateEventsIfRequired(stateChange: ConnectionStateChange, logHandler: InternalLogHandler?)
    mutating func updateForChannelConnectionStateChangeAndThenDelegateStateEventsIfRequired(stateChange: ConnectionStateChange, logHandler: InternalLogHandler?)
    mutating func updateForPresenceMessagesAndThenDelegateStateEventsIfRequired(presenceMessages: [PresenceMessage], logHandler: InternalLogHandler?)
    mutating func delegateStateEventsIfRequired(logHandler: InternalLogHandler?)
    mutating func notifyEnhancedLocationUpdated(locationUpdate: LocationUpdate, logHandler: InternalLogHandler?)
    mutating func notifyRawLocationUpdated(locationUpdate: LocationUpdate, logHandler: InternalLogHandler?)
    mutating func notifyPublisherPresenceUpdated(isPublisherPresent: Bool, logHandler: InternalLogHandler?)
    mutating func notifyTrackableStateUpdated(trackableState: TrackableState, logHandler: InternalLogHandler?)
    mutating func notifyDidFailWithError(error: ErrorInformation, logHandler: InternalLogHandler?)
    mutating func notifyResolutionsChanged(resolutions: [Resolution], logHandler: InternalLogHandler?)
}

struct SubscriberSpecificWorkerQueuePropertiesImpl: SubscriberSpecificWorkerQueuePropertiesProtocol {
    var presenceData: PresenceData
    private let subscriber: Subscriber

    private(set) var presentPublisherMemberKeys: Set<String> = []
    private(set) var lastEmittedValueOfIsPublisherVisible: Bool?
    private(set) var lastEmittedTrackableState: TrackableState = .offline
    private(set) var lastConnectionStateChange = ConnectionStateChange(state: .offline, errorInformation: nil)
    private(set) var lastChannelConnectionStateChange = ConnectionStateChange(state: .offline, errorInformation: nil)
    private(set) var pendingPublisherResolutions = PendingResolutions()

    private(set) var enhancedLocation: LocationUpdate?
    private(set) var rawLocation: LocationUpdate?
    private(set) var trackableState: TrackableState = .offline
    private(set) var publisherPresence = false
    private(set) var resolution: Resolution?
    private(set) var nextLocationUpdateInterval: Double?

    public init(initialResolution: Resolution?, subscriber: Subscriber) {
        self.presenceData = PresenceData(type: .subscriber, resolution: initialResolution)
        self.subscriber = subscriber
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

        var trackableState: TrackableState?
        switch lastConnectionStateChange.state {
        case .online:
            switch lastChannelConnectionStateChange.state {
            case .online:
                trackableState = isAPublisherPresent ? .online : .offline
            case .offline:
                trackableState = .offline
            case .failed:
                trackableState = .failed
            // TODO investigate, https://github.com/ably/ably-asset-tracking-swift/issues/642
            case .closed:
                trackableState = .offline
            }
        case .offline:
            trackableState = .offline
        case .failed:
            trackableState = .failed
        // TODO investigate, https://github.com/ably/ably-asset-tracking-swift/issues/642
        case .closed:
            trackableState = .offline
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
        delegateEvent(event: .delegateEnhancedLocationReceived(DelegateEvent.DelegateEnhancedLocationReceivedEvent(locationUpdate: locationUpdate)), logHandler: logHandler)
    }

    mutating func notifyRawLocationUpdated(locationUpdate: LocationUpdate, logHandler: InternalLogHandler?) {
        rawLocation = locationUpdate
        delegateEvent(event: .delegateRawLocationReceived(DelegateEvent.DelegateRawLocationReceivedEvent(locationUpdate: locationUpdate)), logHandler: logHandler)
    }

    mutating func notifyPublisherPresenceUpdated(isPublisherPresent: Bool, logHandler: InternalLogHandler?) {
        publisherPresence = isPublisherPresent
        delegateEvent(event: .delegateUpdatedPublisherPresence(DelegateEvent.DelegateUpdatedPublisherPresenceEvent(isPresent: isPublisherPresent)), logHandler: logHandler)
    }

    mutating func notifyTrackableStateUpdated(trackableState: TrackableState, logHandler: InternalLogHandler?) {
        self.trackableState = trackableState
        delegateEvent(event: .delegateTrackableStateChanged(DelegateEvent.DelegateTrackableStateChangedEvent(state: trackableState)), logHandler: logHandler)
    }

    mutating func notifyDidFailWithError(error: ErrorInformation, logHandler: InternalLogHandler?) {
        logHandler?.logPublicAPICall(label: "Calling delegate didFailWithError: \(error)")
        delegateEvent(event: .delegateError(DelegateEvent.DelegateErrorEvent(error: error)), logHandler: logHandler)
    }

    mutating func notifyResolutionsChanged(resolutions: [Resolution], logHandler: InternalLogHandler?) {
        for resolution in resolutions {
            self.resolution = resolution
            self.nextLocationUpdateInterval = resolution.desiredInterval

            delegateEvent(event: .delegateResolutionReceived(DelegateEvent.DelegateResolutionReceivedEvent(resolution: resolution)), logHandler: logHandler)
            delegateEvent(event: .delegateDesiredIntervalReceived(DelegateEvent.DelegateDesiredIntervalReceivedEvent(desiredInterval: resolution.desiredInterval)), logHandler: logHandler)
        }
    }

    // MARK: Delegating events
    // This logic is for now duplicated from DefaultSubscriber and DefaultSubscriberEvents extension. DefaultSubscriber's logic can be removed once we finish replacing the current Events mechanism with WorkerQueue.
    private enum DelegateEvent {
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

    private func delegateEvent(event: DelegateEvent, logHandler: InternalLogHandler?) {
        logHandler?.verbose(message: "Received event to send to delegate, dispatching call to main thread: \(event)", error: nil)
        DispatchQueue.main.async {
            guard let delegate = subscriber.delegate
            else { return }

            let log = { (description: String) in
                logHandler?.logPublicAPIOutput(label: "Calling delegate \(description)")
            }

            switch event {
            case .delegateError(let event):
                log("didFailWithError: \(event.error)")
                delegate.subscriber(sender: subscriber, didFailWithError: event.error)
            case .delegateTrackableStateChanged(let event):
                log("didChangeTrackableState: \(event.state)")
                delegate.subscriber(sender: subscriber, didChangeTrackableState: event.state)
            case .delegateEnhancedLocationReceived(let event):
                log("didUpdateEnhancedLocation: \(event.locationUpdate)")
                delegate.subscriber(sender: subscriber, didUpdateEnhancedLocation: event.locationUpdate)
            case .delegateRawLocationReceived(let event):
                log("didUpdateRawLocation: \(event.locationUpdate)")
                delegate.subscriber(sender: subscriber, didUpdateRawLocation: event.locationUpdate)
            case .delegateResolutionReceived(let event):
                log("didUpdateResolution: \(event.resolution)")
                delegate.subscriber(sender: subscriber, didUpdateResolution: event.resolution)
            case .delegateDesiredIntervalReceived(let event):
                log("didUpdateDesiredInterval: \(event.desiredInterval)")
                delegate.subscriber(sender: subscriber, didUpdateDesiredInterval: event.desiredInterval)
            case .delegateUpdatedPublisherPresence(let event):
                log("didUpdatePublisherPresence: \(event.isPresent)")
                delegate.subscriber(sender: subscriber, didUpdatePublisherPresence: event.isPresent)
            }
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
