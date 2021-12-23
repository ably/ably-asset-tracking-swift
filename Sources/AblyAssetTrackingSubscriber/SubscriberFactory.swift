import Foundation
import AblyAssetTrackingCore

/**
 Factory class used only to get `SubscriberBuilder`
 */
public class SubscriberFactory {
    /**
     Returns the default state of the `SubscriberBuilder`, which is incapable of starting of  `Subscriber`
     instances until it has been configured fully.
     */
    public static func subscribers() -> SubscriberBuilder {
        return DefaultSubscriberBuilder()
    }
}
