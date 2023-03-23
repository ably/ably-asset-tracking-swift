import AblyAssetTrackingInternal

/// Provides a reusable template for writing a test case for a `Worker`. See the ``test(properties:)`` method.
public struct WorkerTestScenario<Worker: AblyAssetTrackingInternal.Worker> {
    private let worker: Worker

    /// Initializes a test scenario for testing `worker`.
    public init(worker: Worker) {
        self.worker = worker
    }

    /// The results of calling `doWork` on a worker. See ``test(properties:)``.
    public struct DoWorkResult {
        /// The async work posted by the worker.
        public var postedAsyncWork: [((Error?) -> Void) -> Void]
        /// The worker specifications posted by the worker.
        public var postedWork: [Worker.WorkerSpecificationType]
        /// The properties returned by `doWork`.
        public var returnedProperties: Worker.PropertiesType
    }

    /// Provides a reusable template for writing a test case for a `Worker`’s `doWork` method.
    ///
    /// Specifically, it implements the following parameterized test case, where `${result}` refers to the value returned by this method:
    ///
    /// ```text
    /// Given... a worker ${worker},
    ///
    /// When... doWork is called on the worker, passing properties ${properties},
    ///
    /// Then...
    /// ...it posts the worker specifications described by ${result.postedWork}...
    /// ...and posts the async work described by ${result.postedAsyncWork}...
    /// ...and returns the properties described by ${result.returnedProperties}.
    /// ```
    ///
    /// - Note: This method will rethrow any error thrown by `doWork`.
    public func test_doWork(properties: Worker.PropertiesType) throws -> DoWorkResult {
        var postedAsyncWork: [((Error?) -> Void) -> Void] = []
        var postedWork: [Worker.WorkerSpecificationType] = []

        let doAsyncWork: (@escaping ((Error?) -> Void) -> Void) -> Void = { asyncWork in
            postedAsyncWork.append(asyncWork)
        }

        let postWork: (Worker.WorkerSpecificationType) -> Void = { specification in
            postedWork.append(specification)
        }

        let returnedProperties = try worker.doWork(properties: properties, doAsyncWork: doAsyncWork, postWork: postWork)

        return .init(
            postedAsyncWork: postedAsyncWork,
            postedWork: postedWork,
            returnedProperties: returnedProperties
        )
    }
}
