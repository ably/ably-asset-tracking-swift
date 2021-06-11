protocol DefaultProximityHandlerDelegate: AnyObject {
    func proximityHandler(sender: DefaultProximityHandler, onProximityReachedWithThreshold threshold: Proximity)
    func proximityHandler(onProximityCancelled sender: DefaultProximityHandler)
}

class DefaultProximityHandler: ProximityHandler {
    weak var delegate: DefaultProximityHandlerDelegate?

    func onProximityReached(threshold: Proximity) {
        delegate?.proximityHandler(sender: self, onProximityReachedWithThreshold: threshold)
    }

    func onProximityCancelled() {
        delegate?.proximityHandler(onProximityCancelled: self)
    }
}
