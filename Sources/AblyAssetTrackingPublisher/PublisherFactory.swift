import Foundation
import AblyAssetTrackingCore

/**
 Factory class used only to get `PublisherBuilder`
 */
@objc
public class PublisherFactory: NSObject {
    /**
     Returns the default state of the publisher `PublisherBuilder`, which is incapable of starting of  `Publisher`
     instances until it has been configured fully.
     */
    @objc
    static public func publishers() -> PublisherBuilder {
        return DefaultPublisherBuilder()
    }
}
