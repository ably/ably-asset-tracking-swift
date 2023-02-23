import Foundation

/// A protocol that contains prperties that affect a ``WorkerQueue``'s behaviour.
public protocol WorkerQueueProperties {
    /// Determines whether the Queue is stopped and should no longer accept new workers.
    /// All the workers handled by the Worker Queue while ``isStopped`` is true will have their ``Worker.doWhenStopped`` method executed instead of
    /// ``Worker.doWork``.
    var isStopped: Bool { get set }
}
