import AblyAssetTrackingTesting

struct SubscriberNetworkConnectivityTestsParam: ParameterizedTestCaseParam {
    static func fetchParams(_ completion: @escaping (Result<[SubscriberNetworkConnectivityTestsParam], Error>) -> Void) {
        let logHandler = TestLogging.sharedInternalLogHandler.addingSubsystem(.typed(self))
        var proxyClient: SDKTestProxyClient? = SDKTestProxyClient(logHandler: logHandler)

        proxyClient!.getAllFaults { result in
            let paramsResult = result.map { faultNames in
                faultNames.map(SubscriberNetworkConnectivityTestsParam.init(faultName:))
            }
            proxyClient = nil
            completion(paramsResult)
        }
    }

    var faultName: String

    var methodNameComponent: String {
        faultName
    }

    /// If this returns `true`, then all test cases will be skipped for this parameter.
    ///
    /// This allows us to write test cases for faults that might not yet be handled by the SDK, and be sure that they compile.
    ///
    /// As faults become properly handled by the SDK, they should be removed here. And, as new faults are introduced which are not yet properly handled by the SDK, they should be added here.
    var isSkipped: Bool {
        [
            // Failures:
            // test_faultBeforeStartingSubscriber_TcpConnectionRefused
            // test_faultBeforeStoppingSubscriber_TcpConnectionRefused
            // test_faultWhilstTracking_TcpConnectionRefused
            "TcpConnectionRefused",

            // Failures:
            // test_faultBeforeStartingSubscriber_TcpConnectionUnresponsive
            // test_faultBeforeStoppingSubscriber_TcpConnectionUnresponsive
            // test_faultWhilstTracking_TcpConnectionUnresponsive
            "TcpConnectionUnresponsive",

            // Failures:
            // test_faultBeforeStartingSubscriber_AttachUnresponsive
            "AttachUnresponsive",

            // Failures:
            // test_faultBeforeStartingSubscriber_DisconnectWithFailedResume
            "DisconnectWithFailedResume",

            // Failures:
            // test_faultBeforeStartingSubscriber_EnterFailedWithNonfatalNack
            "EnterFailedWithNonfatalNack",

            // Failures:
            // test_faultBeforeStartingSubscriber_UpdateFailedWithNonfatalNack
            // test_faultWhilstTracking_UpdateFailedWithNonfatalNack
            "UpdateFailedWithNonfatalNack",

            // Failures:
            // test_faultBeforeStartingSubscriber_DisconnectAndSuspend
            // test_faultBeforeStoppingSubscriber_DisconnectAndSuspend
            // test_faultWhilstTracking_DisconnectAndSuspend
            "DisconnectAndSuspend",

            // Failures:
            // test_faultBeforeStoppingSubscriber_ReenterOnResumeFailed
            // test_faultWhilstTracking_ReenterOnResumeFailed
            "ReenterOnResumeFailed",

            // Failures:
            // test_faultBeforeStartingSubscriber_EnterUnresponsive
            "EnterUnresponsive"
        ].contains(faultName)
    }
}
