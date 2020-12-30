@testable import Publisher

class MockResolutionPolicyFactory: ResolutionPolicyFactory {
    var resolutionPolicy: MockResolutionPolicy?
    func createResolutionPolicy(hooks: ResolutionPolicyHooks, methods: ResolutionPolicyMethods) -> ResolutionPolicy {
        resolutionPolicy =  MockResolutionPolicy(hooks: hooks, methods: methods)
        return resolutionPolicy!
    }
}
