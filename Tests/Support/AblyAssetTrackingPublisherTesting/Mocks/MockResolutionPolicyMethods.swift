import AblyAssetTrackingCore
@testable import AblyAssetTrackingPublisher

public class MockResolutionPolicyMethods: ResolutionPolicyMethods {
    public init() {}

    public var refreshCalled = false
    public func refresh() {
        refreshCalled = true
    }

    public var setProximityThresholdCalled = false
    public var setProximityThresholdParamThreshold: Proximity?
    public var setProximityThresholdParamHandler: ProximityHandler?
    public func setProximityThreshold(threshold: Proximity, handler: ProximityHandler) {
        setProximityThresholdCalled = true
        setProximityThresholdParamThreshold = threshold
        setProximityThresholdParamHandler = handler
    }

    public var cancelProximityThresholdCalled = false
    public func cancelProximityThreshold() {
        cancelProximityThresholdCalled = true
    }
}
