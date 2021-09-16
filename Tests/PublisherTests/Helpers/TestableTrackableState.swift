import Foundation
@testable import AblyAssetTrackingPublisher

class TestableTrackableState: TrackableState {
    
    private var unmarkMessageAsPendingDidCallClosure: (() -> Void)?

    /**
     `unmarkMessageAsPending(_:)` is always called on `SendEnhancedLocationSuccessEvent`
     Since there is no callback on `sendEnhancedAssetLocaionUpdate` we're using it as `success` for the testing purpose
     */
    func unmarkMessageAsPendingDidCall(_ closure: @escaping (() -> Void)) {
        unmarkMessageAsPendingDidCallClosure = closure
    }
    
    override func unmarkMessageAsPending(for trackableId: String) {
        super.unmarkMessageAsPending(for: trackableId)
        unmarkMessageAsPendingDidCallClosure?()
    }
}
