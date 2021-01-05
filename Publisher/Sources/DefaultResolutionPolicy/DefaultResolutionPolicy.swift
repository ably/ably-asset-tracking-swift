class DefaultResolutionPolicy: ResolutionPolicy {
    private let hooks: ResolutionPolicyHooks
    private let methods: ResolutionPolicyMethods
    private let defaultResolution: Resolution
    private let subscriberSetListener: DefaultSubscriberSetListener
    private let trackableSetListener: DefaultTrackableSetListener
    private let batteryLevelProvider: BatteryLevelProvider
    private var proximityThresholdReached: Bool

    private var proximityHandler: DefaultProximityHandler
    private var trackedSubscribers: Set<Subscriber>
    private var trackedTrackables: Set<Trackable>
    private var activeTrackable: Trackable?

    init(hooks: ResolutionPolicyHooks,
         methods: ResolutionPolicyMethods,
         defaultResolution: Resolution,
         batteryLevelProvider: BatteryLevelProvider) {
        self.hooks = hooks
        self.methods = methods
        self.defaultResolution = defaultResolution
        self.batteryLevelProvider = batteryLevelProvider
        self.subscriberSetListener = DefaultSubscriberSetListener()
        self.trackableSetListener = DefaultTrackableSetListener()
        self.proximityThresholdReached = false
        self.trackedTrackables = []
        self.trackedSubscribers = []
        self.proximityHandler = DefaultProximityHandler()

        self.proximityHandler.delegate = self
        self.subscriberSetListener.delegate = self
        self.trackableSetListener.delegate = self

        hooks.subscribers(listener: subscriberSetListener)
        hooks.trackables(listener: trackableSetListener)
    }

    func resolve(request: TrackableResolutionRequest) -> Resolution {
        guard let constraints = request.trackable.constraints as? DefaultResolutionConstraints
        else { return resolveFromRequests(requests: request.remoteRequests) }

        let resolutionFromTrackable = constraints.resolutions.getResolution(
            isNear: proximityThresholdReached,
            hasSubscriber: hasSubscribers(forTrackable: request.trackable)
        )
        var allResolutions = Set<Resolution>(request.remoteRequests)
        allResolutions.insert(resolutionFromTrackable)

        let finalResolution = allResolutions.isEmpty ? defaultResolution : createFinalResolution(resolutions: allResolutions)
        return adjustToBatteryLevel(resolution: finalResolution, constraints: constraints)
    }

    func resolve(resolutions: Set<Resolution>) -> Resolution {
        return resolveFromRequests(requests: resolutions)
    }

    // MARK: Utils
    private func resolveFromRequests(requests: Set<Resolution>) -> Resolution {
        return requests.isEmpty ? defaultResolution : createFinalResolution(resolutions: requests)
    }

    private func createFinalResolution(resolutions: Set<Resolution>) -> Resolution {
        var accuracy = Accuracy.minimum
        var desiredInterval = Double.greatestFiniteMagnitude
        var minimumDisplacement = Double.greatestFiniteMagnitude
        resolutions.forEach {
            accuracy = higher(accuracy, $0.accuracy)
            desiredInterval = min(desiredInterval, $0.desiredInterval)
            minimumDisplacement = min(minimumDisplacement, $0.minimumDisplacement)
        }

        return Resolution(accuracy: accuracy, desiredInterval: desiredInterval, minimumDisplacement: minimumDisplacement)
    }

    private func higher(_ lhs: Accuracy, _ rhs: Accuracy) -> Accuracy {
        return lhs.rawValue > rhs.rawValue ? lhs : rhs
    }

    private func adjustToBatteryLevel(resolution: Resolution, constraints: DefaultResolutionConstraints) -> Resolution {
        if let currentBatteryLevel = batteryLevelProvider.currentBatteryPercentage,
           currentBatteryLevel < constraints.batteryLevelThreshold {
            let newInterval = resolution.desiredInterval * Double(constraints.lowBatteryMultiplier)
            return Resolution(accuracy: resolution.accuracy,
                              desiredInterval: newInterval,
                              minimumDisplacement: resolution.minimumDisplacement)
        } else {
            return resolution
        }
    }

    private func hasSubscribers(forTrackable trackable: Trackable) -> Bool {
        return trackedSubscribers.contains { $0.trackable == trackable }
    }
}

extension DefaultResolutionPolicy: DefaultTrackableSetListenerDelegate {
    func trackableSetListener(sender: DefaultTrackableSetListener, onTrackableAdded trackable: Trackable) {
        trackedTrackables.insert(trackable)
    }

    func trackableSetListener(sender: DefaultTrackableSetListener, onTrackableRemoved trackable: Trackable) {
        trackedTrackables.remove(trackable)
    }

    func trackableSetListener(sender: DefaultTrackableSetListener, onActiveTrackableChanged trackable: Trackable?) {
        activeTrackable = trackable
        if let trackable = trackable,
           let constraints = trackable.constraints as? DefaultResolutionConstraints {
            methods.setProximityThreshold(threshold: constraints.proximityThreshold, handler: proximityHandler)
        } else {
            methods.cancelProximityThreshold()
        }
    }
}

extension DefaultResolutionPolicy: DefaultSubscriberSetListenerDelegate {
    func subscriberSetListener(sender: DefaultSubscriberSetListener, onSubscriberAdded subscriber: Subscriber) {
        trackedSubscribers.insert(subscriber)
    }

    func subscriberSetListener(sender: DefaultSubscriberSetListener, onSubscriberRemoved subscriber: Subscriber) {
        trackedSubscribers.remove(subscriber)
    }
}

extension DefaultResolutionPolicy: DefaultProximityHandlerDelegate {
    func proximityHandler(sender: DefaultProximityHandler, onProximityReachedWithThreshold threshold: Proximity) {
        proximityThresholdReached = true
        methods.refresh()
    }

    func proximityHandler(onProximityCancelled sender: DefaultProximityHandler) {
        proximityThresholdReached = false
    }
}

extension DefaultResolutionSet {
    func getResolution(isNear: Bool, hasSubscriber: Bool) -> Resolution {
        if isNear && hasSubscriber { return nearWithSubscriber }
        if isNear && !hasSubscriber { return nearWithoutSubscriber }
        if !isNear && hasSubscriber { return farWithSubscriber }
        return farWithoutSubscriber
    }
}
