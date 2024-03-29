/// WorkerFactory is responcible for instantiating ``Worker``s using a passed specification.
public protocol WorkerFactory<PropertiesType, WorkerSpecificationType> {
    // swiftlint:disable:next missing_docs
    associatedtype PropertiesType
    // swiftlint:disable:next missing_docs
    associatedtype WorkerSpecificationType

    /// Creates an appropriate ``Worker`` using a passed ``WorkerSpecificationType``.
    ///
    /// - parameters:
    ///    - workerSpecification: indicates which implementation of ``Worker`` should be created.
    ///    - Returns: a new ``Worker`` instance.
    func createWorker(workerSpecification: WorkerSpecificationType, logHandler: InternalLogHandler?) -> any Worker<PropertiesType, WorkerSpecificationType>
}
