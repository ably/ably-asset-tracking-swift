class DefaultResolutionPolicyFactory: NSObject, ResolutionPolicyFactory {
    func createResolutionPolicy(hooks: ResolutionPolicyHooks, methods: ResolutionPolicyMethods) -> ResolutionPolicy {
        return DefaultResolutionPolicy(hooks: hooks, methods: methods, defaultResolution: .default)
    }
}

class DefaultResolutionPolicy: NSObject, ResolutionPolicy {
    private let hooks: ResolutionPolicyHooks
    private let methods: ResolutionPolicyMethods
    private let defaultResolution: Resolution

    init(hooks: ResolutionPolicyHooks, methods: ResolutionPolicyMethods, defaultResolution: Resolution) {
        self.hooks = hooks
        self.methods = methods
        self.defaultResolution = defaultResolution
        super.init()
    }

    func resolve(request: TrackableResolutionRequest) -> Resolution {
        return .default
    }

    func resolve(resolutions: Set<Resolution>) -> Resolution {
        return .default
    }
}
