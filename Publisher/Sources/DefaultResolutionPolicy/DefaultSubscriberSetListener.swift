import UIKit

protocol DefaultSubscriberSetListenerDelegate: AnyObject {
    func subscriberSetListener(sender: DefaultSubscriberSetListener, onSubscriberAdded subscriber: Subscriber)
    func subscriberSetListener(sender: DefaultSubscriberSetListener, onSubscriberRemoved subscriber: Subscriber)
}

class DefaultSubscriberSetListener: SubscriberSetListener {
    weak var delegate: DefaultSubscriberSetListenerDelegate?

    func onSubscriberAdded(subscriber: Subscriber) {
        delegate?.subscriberSetListener(sender: self, onSubscriberAdded: subscriber)
    }

    func onSubscriberRemoved(subscriber: Subscriber) {
        delegate?.subscriberSetListener(sender: self, onSubscriberRemoved: subscriber)
    }
}
