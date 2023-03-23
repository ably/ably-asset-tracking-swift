import AblyAssetTrackingInternal
import AblyAssetTrackingInternalTesting
@testable import AblyAssetTrackingSubscriber

/// Provides a reusable template for writing a test case for a `Worker`. See the ``test(properties:)`` method.
struct SubscriberWorkerTestScenario<Worker: AblyAssetTrackingInternal.Worker> where Worker.PropertiesType == SubscriberWorkerQueueProperties {
    private let worker: Worker

    /// Initializes a test scenario for testing `worker`.
    init(worker: Worker) {
        self.worker = worker
    }

    /// The results of calling `doWork` on a worker. See ``test(properties:)``.
    public struct DoWorkResult {
        /// TODO this isn't really a result
        public var propertiesMock: SubscriberWorkerQueuePropertiesProtocolMock
        /// The async work posted by the worker.
        public var postedAsyncWork: [((Error?) -> Void) -> Void]
        /// The worker specifications posted by the worker.
        public var postedWork: [Worker.WorkerSpecificationType]
        /// The properties returned by `doWork`.
        public var returnedProperties: Worker.PropertiesType
    }

    /// Provides a reusable template for writing a test case for the `doWork` method of a `Worker` whose `PropertiesType` is `SubscriberWorkerQueueProperties`.
    ///
    /// Specifically, it implements the following parameterized test case, where `${result}` refers to the value returned by this method:
    ///
    /// ```text
    /// Given... a worker ${worker},
    ///
    /// When... doWork is called on the worker, passing a properties whose `subscriberProperties` is ${result.propertiesMock} and whose `recordInvocations` is `true`, // TODO Update
    ///
    /// Then...
    /// ...it posts the worker specifications described by ${result.postedWork}...
    /// ...and posts the async work described by ${result.postedAsyncWork}...
    /// ...and returns the properties described by ${result.returnedProperties}.
    /// ```
    ///
    /// - Note: This method will rethrow any error thrown by `doWork`.
    func test_doWork(properties: SubscriberWorkerQueuePropertiesProtocol) throws -> DoWorkResult {
        // TODO we need to return mock
        let propertiesMock = SubscriberWorkerQueuePropertiesProtocolMock()
        let properties = SubscriberWorkerQueueProperties(isStopped: false, subscriberProperties: propertiesMock)

        let scenario = WorkerTestScenario(worker: worker)
        let scenarioResult = try scenario.test_doWork(properties: properties)

        return .init(propertiesMock: propertiesMock, postedAsyncWork: scenarioResult.postedAsyncWork, postedWork: scenarioResult.postedWork, returnedProperties: scenarioResult.returnedProperties)
    }
}
