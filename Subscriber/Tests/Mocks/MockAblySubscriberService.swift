import Foundation
@testable import Subscriber

class MockAblySubscriberService: AblySubscriberService {
    var wasDelegateSet: Bool = false
    var delegate: AblySubscriberServiceDelegate? {
        didSet { wasDelegateSet = true }
    }
    
    var startWasCalled: Bool = false
    func start(completion: ((Error?) -> Void)?) {
        startWasCalled = true
    }
    
    var stopResultHandler: ResultHandler<Void>?
    var stopCompletionHandler: ((ResultHandler<Void>?) -> Void)?
    var stopWasCalled: Bool = false
    func stop(completion: @escaping ResultHandler<Void>) {
        stopWasCalled = true
        stopResultHandler = completion
        
        stopCompletionHandler?(completion)
    }
    
    var changeRequestWasCalled: Bool = false
    func changeRequest(resolution: Resolution?, completion: @escaping ResultHandler<Void>) {
        changeRequestWasCalled = true
    }
}
