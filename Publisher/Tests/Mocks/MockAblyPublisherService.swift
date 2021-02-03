import CoreLocation
import Foundation
@testable import Publisher

class MockAblyPublisherService: AblyPublisherService {
    var trackablesGetValue: [Trackable] = []
    var trackables: [Trackable] { return trackablesGetValue }

    var wasDelegateSet: Bool = false
    var delegate: AblyPublisherServiceDelegate? {
        didSet { wasDelegateSet = true }
    }

    var trackCalled: Bool = false
    var trackParamTrackable: Trackable?
    var trackParamCompletion: ((Error?) -> Void)?
    var trackCompletionHandler: ((((Error?) -> Void)?) -> Void)?
    func track(trackable: Trackable, completion: ((Error?) -> Void)?) {
        trackCalled = true
        trackParamTrackable = trackable
        trackParamCompletion = completion

        trackCompletionHandler?(completion)
    }

    var stopTrackingCalled: Bool = false
    var stopTrackingParamTrackable: Trackable?
    var stopTrackingParamOnSuccess: ((Bool) -> Void)?
    var stopTrackingParamOnError: ErrorHandler?
    var stopTrackingOnErrorCompletionHandler: ((ErrorHandler) -> Void)?
    var stopTrackingOnSuccessCompletionHandler: (((Bool) -> Void) -> Void)?
    func stopTracking(trackable: Trackable, onSuccess: @escaping (Bool) -> Void, onError: @escaping ErrorHandler) {
        stopTrackingCalled = true
        stopTrackingParamTrackable = trackable
        stopTrackingParamOnSuccess = onSuccess
        stopTrackingParamOnError = onError

        stopTrackingOnSuccessCompletionHandler?(onSuccess)
        stopTrackingOnErrorCompletionHandler?(onError)
    }

    var sendEnhancedAssetLocationUpdateCalled: Bool = false
    var sendEnhancedAssetLocationUpdateParamLocationUpdate: EnhancedLocationUpdate?
    var sendEnhancedAssetLocationUpdateParamTrackable: Trackable?
    var sendEnhancedAssetLocationUpdateParamCompletion: ((Error?) -> Void)?
    func sendEnhancedAssetLocationUpdate(locationUpdate: EnhancedLocationUpdate, forTrackable trackable: Trackable, completion: ((Error?) -> Void)?) {
        sendEnhancedAssetLocationUpdateCalled = true
        sendEnhancedAssetLocationUpdateParamLocationUpdate = locationUpdate
        sendEnhancedAssetLocationUpdateParamTrackable = trackable
        sendEnhancedAssetLocationUpdateParamCompletion = completion
    }

    var stopCalled: Bool = false
    func stop() {
        stopCalled = true
    }
}
