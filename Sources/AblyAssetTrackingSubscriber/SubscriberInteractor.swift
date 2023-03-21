import Foundation
import AblyAssetTrackingInternal

/// This protocol is to be implemented by the subscriber, and is used to give
/// the worker queue access to certain operations on the subscriber.
/// Methods here should be uncommented as they are implemented (as workers begin to need
/// them).
protocol SubscriberInteractor {
    /// Given the subscribers presence data at the point at which it subscribed
    /// to the channel, this method subscribes the publisher to the Ably SDK wrapper
    /// for any raw location events that come through.
    // func subscribeForRawEvents(presenceData: PresenceData)

    /// Given the subscribers presence data at the point at which it subscribed
    /// to the channel, this method subscribes the publisher to the Ably SDK wrapper
    /// for any enhanced location events that come through.
    // func subscribeForEnhancedEvents(presenceData: PresenceData)

    /// This method should subscribe the subscriber to channel state update events from
    /// the ably SDK wrapper for the currently active tracakble.
    // func subscribeForChannelState()

    /// This method should mark the current trackable as offline.
    // func notifyAssetIsOffline()
}
