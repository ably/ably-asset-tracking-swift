class DefaultResolutionPolicyFactory: NSObject, ResolutionPolicyFactory {
    func createResolutionPolicy(hooks: ResolutionPolicyHooks, methods: ResolutionPolicyMethods) -> ResolutionPolicy {
        return DefaultResolutionPolicy(hooks: hooks, methods: methods, defaultResolution: .default)
    }
}
