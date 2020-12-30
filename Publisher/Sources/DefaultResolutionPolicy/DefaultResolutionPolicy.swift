class DefaultResolutionPolicy: ResolutionPolicy {
    private let hooks: ResolutionPolicyHooks
    private let methods: ResolutionPolicyMethods
    private let defaultResolution: Resolution
    private let subscriberSetListener: DefaultSubscriberSetListener
    private let trackableSetListener: DefaultTrackableSetListener

    init(hooks: ResolutionPolicyHooks, methods: ResolutionPolicyMethods, defaultResolution: Resolution) {
        self.hooks = hooks
        self.methods = methods
        self.defaultResolution = defaultResolution
        self.subscriberSetListener = DefaultSubscriberSetListener()
        self.trackableSetListener = DefaultTrackableSetListener()

        self.subscriberSetListener.delegate = self
        self.trackableSetListener.delegate = self

        hooks.subscribers(listener: subscriberSetListener)
        hooks.trackables(listener: trackableSetListener)
    }

    func resolve(request: TrackableResolutionRequest) -> Resolution {
        return .default
    }

    func resolve(resolutions: Set<Resolution>) -> Resolution {
        return .default
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
extension DefaultResolutionPolicy: DefaultSubscriberSetListenerDelegate {
    func subscriberSetListener(sender: DefaultSubscriberSetListener, onSubscriberAdded subscriber: Subscriber) {
        // TODO: Handle
    }

    func subscriberSetListener(sender: DefaultSubscriberSetListener, onSubscriberRemoved subscriber: Subscriber) {
        // TODO: Handle
    }
}
