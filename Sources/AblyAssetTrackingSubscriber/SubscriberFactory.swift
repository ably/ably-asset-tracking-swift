import Foundation
import AblyAssetTrackingCore

/**
 Factory class used only to get `SubscriberBuilder`
 */
@objc
public class SubscriberFactory: NSObject {
    /**
     Returns the default state of the `SubscriberBuilder`, which is incapable of starting of  `Subscriber`
     instances until it has been configured fully.
     */
    @objc
    public static func subscribers() -> SubscriberBuilder {
        return DefaultSubscriberBuilder()
    }
}
