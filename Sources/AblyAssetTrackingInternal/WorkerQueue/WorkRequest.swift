import Foundation

/// A wrapper for the workerSpecification that allows identification of a specific bit of work using a unique ID.
/// Introduced mainly as a mean to improve logging.
struct WorkRequest<WorkerSpecificationType> {
    /// A unique identifier for this request.
    let id = UUID()

    /// The specification of the work to be performed.
    let workerSpecification: WorkerSpecificationType

    init(workerSpecification: WorkerSpecificationType) {
        self.workerSpecification = workerSpecification
    }
}
