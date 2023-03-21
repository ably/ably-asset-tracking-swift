import AblyAssetTrackingCore
import Foundation

/**
 Factory used only to get `PublisherBuilder`
 */
public enum PublisherFactory {
    /**
     Returns the default state of the publisher `PublisherBuilder`, which is incapable of starting of  `Publisher`
     instances until it has been configured fully.
     */
    public static func publishers() -> PublisherBuilder {
        DefaultPublisherBuilder()
    }
}
