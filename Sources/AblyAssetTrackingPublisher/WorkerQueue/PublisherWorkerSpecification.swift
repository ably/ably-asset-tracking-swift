import Foundation
import AblyAssetTrackingInternal

public enum PublisherWorkSpecification {
    case legacy(callback: () -> Void, logger: InternalLogHandler?)
}

