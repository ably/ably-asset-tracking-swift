@testable import Publisher

class MockResolutionPolicy: ResolutionPolicy {
    let trackablesSetListener: MockTrackableSetListener
    let subscribersSetListener: MockSubscriberSetListener

    init(hooks: ResolutionPolicyHooks, methods: ResolutionPolicyMethods) {
        trackablesSetListener = MockTrackableSetListener()
        subscribersSetListener = MockSubscriberSetListener()
        
        hooks.trackables(listener: trackablesSetListener)
        hooks.subscribers(listener: subscribersSetListener)
    }

    var resolveRequestCalled: Bool = false
    var resolveRequestParamRequest: TrackableResolutionRequest?
    var resolveRequestReturnValue: Resolution = .default
    func resolve(request: TrackableResolutionRequest) -> Resolution {
        resolveRequestCalled = true
        resolveRequestParamRequest = request
        return resolveRequestReturnValue
    }

    var resolveResolutionsCalled: Bool = false
    var resolveResolutionsParamResolutions: Set<Resolution>?
    var resolveResolutionsReturnValue: Resolution = .default
    func resolve(resolutions: Set<Resolution>) -> Resolution {
        resolveRequestCalled = true
        resolveResolutionsParamResolutions = resolutions
        return resolveResolutionsReturnValue
    }
}
