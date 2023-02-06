import Foundation

/// A protocol that contains prperties that affect a ``WorkerQueue``'s behaviour.
public protocol WorkerQueueProperties {
    var isStopped: Bool { get set }
}
