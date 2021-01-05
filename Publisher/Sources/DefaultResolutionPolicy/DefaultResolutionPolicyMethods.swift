protocol DefaultResolutionPolicyMethodsDelegate: AnyObject {
    func resolutionPolicyMethods(refreshWithSender sender: DefaultResolutionPolicyMethods)
    func resolutionPolicyMethods(cancelProximityThresholdWithSender sender: DefaultResolutionPolicyMethods)
    func resolutionPolicyMethods(sender: DefaultResolutionPolicyMethods, setProximityThreshold threshold: Proximity, withHandler handler: ProximityHandler)
}

class DefaultResolutionPolicyMethods: ResolutionPolicyMethods {
    weak var delegate: DefaultResolutionPolicyMethodsDelegate?
    
    func refresh() {
        delegate?.resolutionPolicyMethods(refreshWithSender: self)
    }

    func setProximityThreshold(threshold: Proximity, handler: ProximityHandler) {
        delegate?.resolutionPolicyMethods(sender: self, setProximityThreshold: threshold, withHandler: handler)
    }

    func cancelProximityThreshold() {
        delegate?.resolutionPolicyMethods(cancelProximityThresholdWithSender: self)
    }
}
