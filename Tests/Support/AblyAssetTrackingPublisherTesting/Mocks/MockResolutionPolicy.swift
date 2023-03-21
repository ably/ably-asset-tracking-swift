import AblyAssetTrackingCore
@testable import AblyAssetTrackingPublisher

public class MockResolutionPolicy: ResolutionPolicy {
    public let trackablesSetListener: MockTrackableSetListener
    public let subscribersSetListener: MockSubscriberSetListener

    public init(hooks: ResolutionPolicyHooks, methods: ResolutionPolicyMethods) {
        trackablesSetListener = MockTrackableSetListener()
        subscribersSetListener = MockSubscriberSetListener()

        hooks.trackables(listener: trackablesSetListener)
        hooks.subscribers(listener: subscribersSetListener)
    }

    public var resolveRequestCalled = false
    public var resolveRequestParamRequest: TrackableResolutionRequest?
    public var resolveRequestReturnValue: Resolution = .default
    public func resolve(request: TrackableResolutionRequest) -> Resolution {
        resolveRequestCalled = true
        resolveRequestParamRequest = request
        return resolveRequestReturnValue
    }

    public var resolveResolutionsCalled = false
    public var resolveResolutionsParamResolutions: Set<Resolution>?
    public var resolveResolutionsReturnValue: Resolution = .default
    public func resolve(resolutions: Set<Resolution>) -> Resolution {
        resolveResolutionsCalled = true
        resolveResolutionsParamResolutions = resolutions
        return resolveResolutionsReturnValue
    }
}
