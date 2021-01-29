import Core

protocol DefaultTrackableSetListenerDelegate: AnyObject {
    func trackableSetListener(sender: DefaultTrackableSetListener, onTrackableAdded trackable: Trackable)
    func trackableSetListener(sender: DefaultTrackableSetListener, onTrackableRemoved trackable: Trackable)
    func trackableSetListener(sender: DefaultTrackableSetListener, onActiveTrackableChanged trackable: Trackable?)
}

class DefaultTrackableSetListener: TrackableSetListener {
    weak var delegate: DefaultTrackableSetListenerDelegate?

    func onTrackableAdded(trackable: Trackable) {
        delegate?.trackableSetListener(sender: self, onTrackableAdded: trackable)
    }

    func onTrackableRemoved(trackable: Trackable) {
        delegate?.trackableSetListener(sender: self, onTrackableRemoved: trackable)
    }

    func onActiveTrackableChanged(trackable: Trackable?) {
        delegate?.trackableSetListener(sender: self, onActiveTrackableChanged: trackable)
    }
}
