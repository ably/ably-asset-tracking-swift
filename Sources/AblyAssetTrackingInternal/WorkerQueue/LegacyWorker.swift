import Foundation

/// A worker that runs tasks that the Publisher and Subscriber used to run asynchronously on their
/// own dispatch queues. This worker allows us to tie up legacy work and new asynchronous
/// work, for simplicity and consistency during the transition.
open class LegacyWorker<PropertiesType, WorkerSpecificationType> : Worker
{
    let work: () -> Void

    public init (work: @escaping () -> Void) {
        self.work = work
    }

    public func doWork(properties: PropertiesType, doAsyncWork: (@escaping ((Error?) -> Void) -> Void) -> Void, postWork: @escaping (WorkerSpecificationType) -> Void) throws -> PropertiesType {
        doAsyncWork({ [work] _ in
            work()
        })

        return properties
    }

    public func doWhenStopped(error: Error) {
        //TODO
    }

    public func onUnexpectedError(error: Error, postWork: @escaping (WorkerSpecificationType) -> Void) {
        //TODO
    }

    public func onUnexpectedAsyncError(error: Error, postWork: @escaping (WorkerSpecificationType) -> Void) {
        //TODO
    }
}
