import AblyAssetTrackingInternal

class SubscriberStartConnectionWorker: Worker {
    typealias PropertiesType = SubscriberProperties
    typealias WorkerSpecificationType = SubscriberWorkerSpecification
    
    let ablySubscriber: AblySubscriber
    let trackableId: String
    let callback: ResultHandler<Void>
    init(ablySubscriber: AblySubscriber, trackableId: String, callback: @escaping ResultHandler<Void>)  {
        self.ablySubscriber = ablySubscriber
        self.trackableId = trackableId
        self.callback = callback
    }
    
    func doWork(properties: SubscriberProperties, doAsyncWork: (() -> Void) -> Void, postWork: @escaping (WorkerSpecificationType) -> Void) -> PropertiesType {
        doAsyncWork {
            ablySubscriber.connect(
                trackableId: trackableId,
                presenceData: properties.presenceData,
                useRewind: true
            ) { [weak self] result in
                guard let self = self else {
                    return
                }
                
                switch result {
                case .success:
                    postWork(SubscribeForPresenceMessagesSpecification(callback: self.callback))
                    break
                case .failure:
                    self.callback(result)
                    break
                }
                
                
//                switch result {
//                case .success:
//                    self.ablySubscriber.subscribeForPresenceMessages(trackable: .init(id: self.trackableId))
//                    self.ablySubscriber.subscribeForRawEvents(trackableId: self.trackableId)
//                    self.ablySubscriber.subscribeForEnhancedEvents(trackableId: self.trackableId)
//
//                    self.callback(value: Void(), handler: event.resultHandler)
//                case .failure(let error):
//                    self.callback(error: error, handler: event.resultHandler)
//                }
            }
        }
        
        
        return properties
    }
}
