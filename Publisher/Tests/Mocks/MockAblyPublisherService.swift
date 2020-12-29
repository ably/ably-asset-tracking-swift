import CoreLocation
import Foundation
@testable import Publisher

class MockAblyPublisherService: AblyPublisherService {
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
    func stopTracking(trackable: Trackable, onSuccess: @escaping (Bool) -> Void, onError: @escaping ErrorHandler) {
        stopTrackingCalled = true
        stopTrackingParamTrackable = trackable
        stopTrackingParamOnSuccess = onSuccess
        stopTrackingParamOnError = onError
    }

    var sendRawAssetLocationCalled: Bool = false
    var sendRawAssetLocationParamLocation: CLLocation?
    var sendRawAssetLocationParamCompletion: ((Error?) -> Void)?
    func sendRawAssetLocation(location: CLLocation, completion: ((Error?) -> Void)?) {
        sendRawAssetLocationCalled = true
        sendRawAssetLocationParamLocation = location
        sendRawAssetLocationParamCompletion = completion
    }

    var sendEnhancedAssetLocationCalled: Bool = false
    var sendEnhancedAssetLocationParamLocation: CLLocation?
    var sendEnhancedAssetLocationParamCompletion: ((Error?) -> Void)?
    func sendEnhancedAssetLocation(location: CLLocation, completion: ((Error?) -> Void)?) {
        sendEnhancedAssetLocationCalled = true
        sendEnhancedAssetLocationParamLocation = location
        sendEnhancedAssetLocationParamCompletion = completion
    }

    var stopCalled: Bool = false
    func stop() {
        stopCalled = true
    }
}
