import Foundation

/// A protocol that contains prperties that affect a ``WorkerQueue``'s behaviour.
public protocol Properties {
    var isStopped: Bool { get set }
}
