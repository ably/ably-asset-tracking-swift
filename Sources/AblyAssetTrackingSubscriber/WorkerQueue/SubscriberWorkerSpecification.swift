import Foundation
import AblyAssetTrackingInternal

enum SubscriberWorkSpecification {
    case legacy(callback: () -> Void)
}
