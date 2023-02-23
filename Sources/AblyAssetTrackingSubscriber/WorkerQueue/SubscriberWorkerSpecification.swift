import Foundation
import AblyAssetTrackingInternal

public enum SubscriberWorkSpecification {
    case legacy(callback: () -> Void, logger: InternalLogHandler?)
}
