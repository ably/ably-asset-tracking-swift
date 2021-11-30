import Foundation
import AblyAssetTrackingCore
@testable import AblyAssetTrackingSubscriber

class MockAblySubscriberService: AblySubscriberService {
    var wasDelegateSet: Bool = false
    var delegate: AblySubscriberServiceDelegate? {
        didSet { wasDelegateSet = true }
    }
    
    var startCompletionHandler: ((ResultHandler?/*Void*/) -> Void)?
    var startResultHandler: ResultHandler?/*Void*/
    var startWasCalled: Bool = false
    func start(completion: @escaping ResultHandler/*Void*/) {
        startWasCalled = true
        startResultHandler = completion
        
        startCompletionHandler?(completion)
    }
    
    var stopResultHandler: ResultHandler?/*Void*/
    var stopCompletionHandler: ((ResultHandler?/*Void*/) -> Void)?
    var stopWasCalled: Bool = false
    func stop(completion: @escaping ResultHandler/*Void*/) {
        stopWasCalled = true
        stopResultHandler = completion
        
        stopCompletionHandler?(completion)
    }
    
    var sendResolutionPreferenceWasCalled: Bool = false
    var sendResolutionPreferenceResolutionParam: Resolution?
    var sendResolutionPreferenceResultHander: ResultHandler?/*Void*/
    var sendResolutionPreferenceCompletionHandler: ((ResultHandler?/*Void*/) -> Void)?
    func sendResolutionPreference(resolution: Resolution?, completion: @escaping ResultHandler/*Void*/) {
        sendResolutionPreferenceWasCalled = true
        sendResolutionPreferenceResolutionParam = resolution
        sendResolutionPreferenceResultHander = completion
        
        sendResolutionPreferenceCompletionHandler?(completion)
    }
}
