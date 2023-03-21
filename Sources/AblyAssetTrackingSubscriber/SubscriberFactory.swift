import Foundation
import AblyAssetTrackingCore

/**
 Factory used only to get `SubscriberBuilder`
 */
public enum SubscriberFactory {
    /**
     Returns the default state of the `SubscriberBuilder`, which is incapable of starting of  `Subscriber`
     instances until it has been configured fully.
     */
    public static func subscribers() -> SubscriberBuilder {
        return DefaultSubscriberBuilder()
    }
}
