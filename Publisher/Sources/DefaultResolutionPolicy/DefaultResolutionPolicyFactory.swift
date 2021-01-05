public class DefaultResolutionPolicyFactory: NSObject, ResolutionPolicyFactory {
    private let defaultResolution: Resolution
    public init(defaultResolution: Resolution) {
        self.defaultResolution = defaultResolution
        super.init()
    }

    public func createResolutionPolicy(hooks: ResolutionPolicyHooks, methods: ResolutionPolicyMethods) -> ResolutionPolicy {
        return DefaultResolutionPolicy(hooks: hooks,
                                       methods: methods,
                                       defaultResolution: defaultResolution,
                                       batteryLevelProvider: DefaultBatteryLevelProvider())
    }
}
