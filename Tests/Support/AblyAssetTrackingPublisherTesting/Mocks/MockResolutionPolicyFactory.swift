import AblyAssetTrackingCore
@testable import AblyAssetTrackingPublisher

public class MockResolutionPolicyFactory: ResolutionPolicyFactory {
    public init() {}

    public var resolutionPolicy: MockResolutionPolicy?
    public func createResolutionPolicy(hooks: ResolutionPolicyHooks, methods: ResolutionPolicyMethods) -> ResolutionPolicy {
        resolutionPolicy =  MockResolutionPolicy(hooks: hooks, methods: methods)
        
        return resolutionPolicy!
    }
}
