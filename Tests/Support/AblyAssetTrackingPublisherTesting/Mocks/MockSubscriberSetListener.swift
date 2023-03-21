@testable import AblyAssetTrackingPublisher

public class MockSubscriberSetListener: SubscriberSetListener {
    public init() {}

    public var onSubscriberAddedCalled = false
    public var onSubscriberAddedParamSubscriber: Subscriber?
    public func onSubscriberAdded(subscriber: Subscriber) {
        onSubscriberAddedCalled = true
        onSubscriberAddedParamSubscriber = subscriber
    }

    public var onSubscriberRemovedCalled = false
    public var onSubscriberRemovedSubscriber: Subscriber?
    public func onSubscriberRemoved(subscriber: Subscriber) {
        onSubscriberRemovedCalled = true
        onSubscriberRemovedSubscriber = subscriber
    }
}
