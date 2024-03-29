import AblyAssetTrackingCore
import Foundation

public class DefaultResolutionPolicyFactory: ResolutionPolicyFactory {
    private let defaultResolution: Resolution

    public init(defaultResolution: Resolution) {
        self.defaultResolution = defaultResolution
    }

    public func createResolutionPolicy(hooks: ResolutionPolicyHooks, methods: ResolutionPolicyMethods) -> ResolutionPolicy {
        DefaultResolutionPolicy(
            hooks: hooks,
            methods: methods,
            defaultResolution: defaultResolution,
            batteryLevelProvider: DefaultBatteryLevelProvider()
        )
    }
}
