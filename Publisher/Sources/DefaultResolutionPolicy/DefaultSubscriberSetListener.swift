import UIKit

class DefaultSubscriberSetListener: SubscriberSetListener {
    private var subscribers: Set<Subscriber> = []

    func hasSubscribers(trackable: Trackable) -> Bool {
        return subscribers.contains { $0.trackable == trackable }
    }

    // MARK: SubscriberSetListener
    func onSubscriberAdded(subscriber: Subscriber) {
        subscribers.insert(subscriber)
    }

    func onSubscriberRemoved(subscriber: Subscriber) {
        subscribers.remove(subscriber)
    }
}
