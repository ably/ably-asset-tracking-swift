import Foundation

// swiftlint:disable:next missing_docs
public protocol Proximity { }

public class DefaultProximity: Proximity {
    /**
     Estimated time remaining to arrive at the destination, in milliseconds.
     */
    public let temporal: Double?

    /**
     Distance from the destination, in metres.
     */
    public let spatial: Double?

    public init(spatial: Double) {
        self.spatial = spatial
        self.temporal = nil
    }

    public init(temporal: Double) {
        self.spatial = nil
        self.temporal = temporal
    }
}

/**
 Defines the methods to be implemented by proximity handlers.
*/
public protocol ProximityHandler {
    /**
     The desired proximity has been reached.
     - Parameters:
     - threshold: The threshold which was supplied when this handler was registered.
     */
    func onProximityReached(threshold: Proximity)

    /**
     This handler has been cancelled, either explicitly using [cancelProximityThreshold], or implicitly
     because a new handler has taken its place for the associated [Publisher].
     */
    func onProximityCancelled()
}
