@objc(SubscriberFactory)
public class SubscriberFactoryObjectiveC: NSObject {
    /**
     Returns the default state of the`SubscriberBuilderObjectiveC`, which is incapable of starting of  `SubscriberObjectiveC`
     instances until it has been configured fully.
     */
    @objc
    public static func subscribers() -> SubscriberBuilderObjectiveC {
        return DefaultSubscriberBuilder()
    }
}

/**
 Factory class used only to get `SubscriberBuilder`
 */
public class SubscriberFactory {
    /**
     Returns the default state of the`SubscriberBuilder`, which is incapable of starting of  `Subscriber`
     instances until it has been configured fully.
     */
    public static func subscribers() -> SubscriberBuilder {
        return DefaultSubscriberBuilder()
    }
}
