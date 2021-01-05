import XCTest
import CoreLocation
@testable import Publisher

class DefaultResolutionPolicyTests: XCTestCase {
    var hooks: DefaultResolutionPolicyHooks!
    var methods: MockResolutionPolicyMethods!
    var defaultResolution: Resolution!
    var batteryLevelProvider: MockBatteryLevelProvider!
    var resolutionPolicy: DefaultResolutionPolicy!

    override func setUpWithError() throws {
        hooks = DefaultResolutionPolicyHooks()
        methods = MockResolutionPolicyMethods()
        defaultResolution = Resolution(accuracy: .balanced, desiredInterval: 100, minimumDisplacement: 100)
        batteryLevelProvider = MockBatteryLevelProvider()
        resolutionPolicy = DefaultResolutionPolicy(hooks: hooks,
                                                   methods: methods,
                                                   defaultResolution: defaultResolution,
                                                   batteryLevelProvider: batteryLevelProvider)
    }
}
