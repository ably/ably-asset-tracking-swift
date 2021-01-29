import CoreLocation
import Foundation
@testable import Core
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
    var trackResultHandler: ResultHandler<Void>?
    var trackCompletionHandler: ((ResultHandler<Void>?) -> Void)?
    func track(trackable: Trackable, completion: @escaping ResultHandler<Void>) {
        trackCalled = true
        trackParamTrackable = trackable
        trackResultHandler = completion
        trackCompletionHandler?(completion)
    }

    var stopTrackingCalled: Bool = false
    var stopTrackingParamTrackable: Trackable?
    var stopTrackingResultHandler: ResultHandler<Bool>?
    var stopTrackingCompletionHandler: ((ResultHandler<Bool>?) -> Void)?
    func stopTracking(trackable: Trackable, completion: @escaping ResultHandler<Bool>) {
        stopTrackingCalled = true
        stopTrackingParamTrackable = trackable
        stopTrackingResultHandler = completion
        stopTrackingCompletionHandler?(completion)
    }

    var sendRawAssetLocationCalled: Bool = false
    var sendRawAssetLocationParamLocation: CLLocation?
    var sendRawAssetLocationParamTrackable: Trackable?
    var sendRawAssetLocationResultHandler: ResultHandler<Void>?
    
    var sendRawAssetLocationParamCompletion: ((Error?) -> Void)?
    func sendRawAssetLocation(location: CLLocation, forTrackable trackable: Trackable, completion: @escaping ResultHandler<Void>) {
        sendRawAssetLocationCalled = true
        sendRawAssetLocationParamLocation = location
        sendRawAssetLocationParamTrackable = trackable
        sendRawAssetLocationResultHandler = completion
    }

    var sendEnhancedAssetLocationCalled: Bool = false
    var sendEnhancedAssetLocationParamLocationUpdate: EnhancedLocationUpdate?
    var sendEnhancedAssetLocationParamTrackable: Trackable?
    var sendEnhancedAssetLocationResultHandler: ResultHandler<Void>?
    
    var sendEnhancedAssetLocationParamCompletion: ((Error?) -> Void)?
    func sendEnhancedAssetLocation(locationUpdate: EnhancedLocationUpdate, forTrackable trackable: Trackable, completion: @escaping ResultHandler<Void>) {
        sendEnhancedAssetLocationCalled = true
        sendEnhancedAssetLocationParamLocationUpdate = locationUpdate
        sendEnhancedAssetLocationParamTrackable = trackable
        sendEnhancedAssetLocationResultHandler = completion
    }

    var stopCalled: Bool = false
    func stop() {
        stopCalled = true
    }
}
