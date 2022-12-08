import AblyAssetTrackingCore
@testable import AblyAssetTrackingPublisher

public class MockResolutionPolicyMethods: ResolutionPolicyMethods {
    public init() {}

    public var refreshCalled: Bool = false
    public func refresh() {
        refreshCalled = true
    }

    public var setProximityThresholdCalled: Bool = false
    public var setProximityThresholdParamThreshold: Proximity?
    public var setProximityThresholdParamHandler: ProximityHandler?
    public func setProximityThreshold(threshold: Proximity, handler: ProximityHandler) {
        setProximityThresholdCalled = true
        setProximityThresholdParamThreshold = threshold
        setProximityThresholdParamHandler = handler
    }

    public var cancelProximityThresholdCalled: Bool = false
    public func cancelProximityThreshold() {
        cancelProximityThresholdCalled = true
    }
}
