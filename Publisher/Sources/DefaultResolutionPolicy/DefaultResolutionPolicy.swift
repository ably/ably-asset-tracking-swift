class DefaultResolutionPolicy: ResolutionPolicy {
    private let hooks: ResolutionPolicyHooks
    private let methods: ResolutionPolicyMethods
    private let defaultResolution: Resolution
    private let subscriberSetListener: DefaultSubscriberSetListener
    private let trackableSetListener: DefaultTrackableSetListener
    private let batteryLevelProvider: BatteryLevelProvider
    private var proximityThresholdReached: Bool
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
        self.trackableSetListener.delegate = self

        hooks.subscribers(listener: subscriberSetListener)
        hooks.trackables(listener: trackableSetListener)
    }

    func resolve(request: TrackableResolutionRequest) -> Resolution {
        guard let constraints = request.trackable.constraints as? DefaultResolutionConstraints
        else { return resolveFromRequests(requests: request.remoteRequests) }

        let resolutionFromTrackable = constraints.resolutions.getResolution(
            isNear: proximityThresholdReached,
            hasSubscriber: subscriberSetListener.hasSubscribers(trackable: request.trackable)
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
}

extension DefaultResolutionPolicy: DefaultTrackableSetListenerDelegate {
    func trackableSetListener(sender: DefaultTrackableSetListener, onTrackableAdded trackable: Trackable) {
        // TODO: Handle
    }

    func trackableSetListener(sender: DefaultTrackableSetListener, onTrackableRemoved trackable: Trackable) {
        // TODO: Handle
    }

    func trackableSetListener(sender: DefaultTrackableSetListener, onActiveTrackableChanged trackable: Trackable?) {
        // TODO: Handle
    }
}

extension DefaultResolutionSet {
    func getResolution(isNear: Bool, hasSubscriber: Bool) -> Resolution {
        if isNear && hasSubscriber { return nearWithoutSubscriber }
        if isNear && !hasSubscriber { return nearWithoutSubscriber }
        if !isNear && hasSubscriber { return farWithSubscriber }
        return farWithoutSubscriber
    }
}
