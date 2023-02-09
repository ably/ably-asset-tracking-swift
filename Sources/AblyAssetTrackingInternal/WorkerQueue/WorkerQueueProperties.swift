import Foundation

/// A protocol that contains prperties that affect a ``WorkerQueue``'s behaviour.
public protocol WorkerQueueProperties {
    /// Determines whether the Queue is stopped and should no longer accept new workers.
    /// If a new worker gets added to a stopped Worker Queue, the `Worker.doWhenStopped` is executed instead.
    var isStopped: Bool { get set }
}
