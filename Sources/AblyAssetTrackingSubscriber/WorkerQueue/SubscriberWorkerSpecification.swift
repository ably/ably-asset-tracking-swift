import Foundation
import AblyAssetTrackingInternal

internal enum SubscriberWorkSpecification {
    case legacy(callback: () -> Void)
}
