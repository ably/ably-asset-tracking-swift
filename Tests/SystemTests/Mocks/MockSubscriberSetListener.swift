@testable import AblyAssetTrackingPublisher

class MockSubscriberSetListener: SubscriberSetListener {
    var onSubscriberAddedCalled: Bool = false
    var onSubscriberAddedParamSubscriber: Subscriber?
    func onSubscriberAdded(subscriber: Subscriber) {
        onSubscriberAddedCalled = true
        onSubscriberAddedParamSubscriber = subscriber
    }

    var onSubscriberRemovedCalled: Bool = false
    var onSubscriberRemovedSubscriber: Subscriber?
    func onSubscriberRemoved(subscriber: Subscriber) {
        onSubscriberRemovedCalled = true
        onSubscriberRemovedSubscriber = subscriber
    }
}
