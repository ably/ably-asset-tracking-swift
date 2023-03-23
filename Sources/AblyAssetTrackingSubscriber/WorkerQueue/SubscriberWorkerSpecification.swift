import AblyAssetTrackingInternal
import Foundation

enum SubscriberWorkSpecification {
    case legacy(callback: () -> Void)
    case updatePublisherPresence(presenceMessage: PresenceMessage)
}
