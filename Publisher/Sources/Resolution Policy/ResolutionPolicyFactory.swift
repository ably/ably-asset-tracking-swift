protocol ResolutionPolicyFactory {
    /**
     This method will be called once for each `Publisher` instance started by any `Builder``Publisher.Builder`
     instance against which this `Factory` was `registered``Publisher.Builder.resolutionPolicy`.
     Calling methods on `hooks` after this method has returned will throw an exception.
     Calling methods on `methods` after this method has returned is allowed and expected.
     - Parameters:
        - hooks: Methods which may be called while inside this method implementation, but not after.
        - methods: Methods which may be called after this method has returned.
     - Returns: A resolution policy to be used for the lifespan of the associated `Publisher`.
     */
    func createResolutionPolicy(hooks: ResolutionPolicyHooks,
                                methods: ResolutionPolicyMethods) -> ResolutionPolicy
}
