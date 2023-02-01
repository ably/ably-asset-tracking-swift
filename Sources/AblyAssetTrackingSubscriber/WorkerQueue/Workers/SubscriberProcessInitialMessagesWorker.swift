import AblyAssetTrackingInternal

class SubscriberProcessInitialMessagesWorker: Worker {
    var completion: ResultHandler<Void>
    
    
    typealias PropertiesType = SubscriberProperties
    typealias WorkerSpecificationType = SubscriberWorkerSpecification
    
    init(completion: @escaping ResultHandler<Void>) {
        self.completion = completion
    }
    
    func doWork(properties: SubscriberProperties, doAsyncWork: (() -> Void) -> Void, postWork: @escaping (WorkerSpecificationType) -> Void) -> SubscriberProperties {
        
        return properties
    }
    

}
