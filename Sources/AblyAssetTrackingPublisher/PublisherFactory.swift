import Foundation
import AblyAssetTrackingCore

/**
 Factory class used only to get `PublisherBuilder`
 */
@objc(PublisherFactory)
public class PublisherFactoryObjectiveC: NSObject {
    /**
     Returns the default state of the publisher `PublisherBuilderObjectiveC`, which is incapable of starting of  `Publisher`
     instances until it has been configured fully.
     */
    @objc
    static public func publishers() -> PublisherBuilderObjectiveC {
        return DefaultPublisherBuilder()
    }
}

/**
 Factory class used only to get `PublisherBuilder`
 */
public class PublisherFactory {
    /**
     Returns the default state of the publisher `PublisherBuilder`, which is incapable of starting of  `Publisher`
     instances until it has been configured fully.
     */
    static public func publishers() -> PublisherBuilder {
        return DefaultPublisherBuilder()
    }
}
