import CoreLocation
import Foundation
@testable import Publisher

class MockAblyPublisherService: AblyPublisherService {
    var trackCalled: Bool = false
    var trackParamTrackable: Trackable?
    var trackParamResultHandler: ResultHandler<Void>?
    var trackCompletionHandler: ((ResultHandler<Void>?) -> Void)?
    func track(trackable: Trackable, completion: ResultHandler<Void>?) {
        trackCalled = true
        trackParamTrackable = trackable
        trackParamResultHandler = completion

        trackCompletionHandler?(completion)
    }
    
    var stopTrackingCalled: Bool = false
    var stopTrackingParamTrackable: Trackable?
    var stopTrackingParamResultHandler: ResultHandler<Bool>?
    var stopTrackingResultCompletionHandler: ((ResultHandler<Bool>?) -> Void)?
    func stopTracking(trackable: Trackable, completion: ResultHandler<Bool>?) {
        stopTrackingCalled = true
        stopTrackingParamTrackable = trackable
        stopTrackingParamResultHandler = completion

        stopTrackingResultCompletionHandler?(completion)
    }
    
    var trackablesGetValue: [Trackable] = []
    var trackables: [Trackable] { return trackablesGetValue }

    var wasDelegateSet: Bool = false
    var delegate: AblyPublisherServiceDelegate? {
        didSet { wasDelegateSet = true }
    }

    var sendEnhancedAssetLocationUpdateCalled: Bool = false
    var sendEnhancedAssetLocationUpdateParamLocationUpdate: EnhancedLocationUpdate?
    var sendEnhancedAssetLocationUpdateParamTrackable: Trackable?
    var sendEnhancedAssetLocationUpdateParamCompletion: ResultHandler<Void>?
    func sendEnhancedAssetLocationUpdate(locationUpdate: EnhancedLocationUpdate, forTrackable trackable: Trackable, completion: ResultHandler<Void>?) {
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
