import AblyAssetTrackingCore
@testable import AblyAssetTrackingPublisher

class MockResolutionPolicyMethods: ResolutionPolicyMethods {
    var refreshCalled: Bool = false
    func refresh() {
        refreshCalled = true
    }

    var setProximityThresholdCalled: Bool = false
    var setProximityThresholdParamThreshold: Proximity?
    var setProximityThresholdParamHandler: ProximityHandler?
    func setProximityThreshold(threshold: Proximity, handler: ProximityHandler) {
        setProximityThresholdCalled = true
        setProximityThresholdParamThreshold = threshold
        setProximityThresholdParamHandler = handler
    }

    var cancelProximityThresholdCalled: Bool = false
    func cancelProximityThreshold() {
        cancelProximityThresholdCalled = true
    }
}
