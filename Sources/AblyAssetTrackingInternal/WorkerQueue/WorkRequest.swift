import Foundation

/// A wrapper for the workerSpecification that allows identification of a specific bit of work using a unique ID.
/// Introduced mainly as a mean to improve logging.
public struct WorkRequest<WorkerSpecificationType> {
    /// A unique identifier for this request.
    let id = UUID()

    /// The specification of the work to be performed.
    public let workerSpecification: WorkerSpecificationType

    public init(workerSpecification: WorkerSpecificationType) {
        self.workerSpecification = workerSpecification
    }
}
