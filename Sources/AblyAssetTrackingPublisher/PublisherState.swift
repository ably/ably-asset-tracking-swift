import Foundation

enum PublisherState {
    /// This state is when the publisher has not been stopped, but has no trackables added
    /// and ideally, not connected to Ably.
    case idle
    
    /// This state is when the publisher is in the process of adding the first trackable
    /// and connecting to Ably.
    case connecting
    
    /// This state is when the publisher is connected to Ably with a trackable added (regardless of
    /// whether one is being actively tracked).
    case connected
    
    /// This state is whenever the publisher is disconnecting from Ably, usually whenever the last trackable
    /// has been removed (and therefore prior to entering the idle state).
    case disconnecting

    /// This isn't present in AAT Android, but it arguably serves a different purpose to disconnecting.
    /// Is used when the publisher is in the process of a stop operation.
    case stopping
    
    /// The publisher has been stopped and cannot be restarted.
    case stopped
    
    var isStoppingOrStopped: Bool {
        self == .stopping || self == .stopped
    }
}
