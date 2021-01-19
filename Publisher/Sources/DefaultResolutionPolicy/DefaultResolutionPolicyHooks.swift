class DefaultResolutionPolicyHooks: ResolutionPolicyHooks {
    var trackables: TrackableSetListener?
    var subscribers: SubscriberSetListener?

    func trackables(listener: TrackableSetListener) {
        self.trackables = listener
    }

    func subscribers(listener: SubscriberSetListener) {
        self.subscribers = listener
    }
}
