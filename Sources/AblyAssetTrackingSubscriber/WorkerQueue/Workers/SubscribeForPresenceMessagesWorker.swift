import AblyAssetTrackingInternal

extension Worker {
    typealias PropertiesType = SubscriberProperties
    typealias WorkerSpecificationType = SubscriberWorkerSpecification
    
    func doWhenStopped(error: ErrorInformation) {
        completion(.failure(error))
    }
    
    func onUnexpectedError(error: ErrorInformation, postWork: @escaping (SubscriberWorkerSpecification) -> Void) {
        completion(.failure(error))
    }
    
    func onUnexpectedAsyncError(error: ErrorInformation, postWork: @escaping (SubscriberWorkerSpecification) -> Void) {
        completion(.failure(error))
    }
}

class SubscribeForPresenceMessagesWorker: Worker {
    typealias PropertiesType = SubscriberProperties
    typealias WorkerSpecificationType = SubscriberWorkerSpecification
    
    var completion: ResultHandler<Void>
    private let ablySubscriber: AblySubscriber
    private let trackable: Trackable
    private let channel: AblySDKRealtimeChannel
    private let logHandler: InternalLogHandler?

    
    init(ablySubscriber: AblySubscriber, trackable: Trackable, channel: AblySDKRealtimeChannel, logHandler: InternalLogHandler?, completion: @escaping ResultHandler<Void>) {
        self.ablySubscriber = ablySubscriber
        self.trackable = trackable
        self.completion = completion
        self.channel = channel
        self.logHandler = logHandler?.addingSubsystem(Self.self)
    }
    
    func doWork(properties: SubscriberProperties, doAsyncWork: (() -> Void) -> Void, postWork: @escaping (WorkerSpecificationType) -> Void) -> SubscriberProperties {

        channel.presence.get { [weak self] messages, error in
            self?.logHandler?.debug(message: "Get presence update from channel", error: nil)
            guard let self = self, let messages = messages else {
                return
            }
            
            postWork(ProcessInitialMessagesSpecification(presenceMessages: messages, callback: self.completion))
//            for message in messages {
//                ablySubscriber.handleARTPresenceMessage(message, for: trackable)
//            }
        }
//        channel.presence.subscribe { [weak self] message in
//            guard let self = self else { return }
//
//            self.logHandler?.debug(message: "Received presence update from channel", error: nil)
//            self.handleARTPresenceMessage(message, for: trackable)
//        }
        
        return properties
    }
}


