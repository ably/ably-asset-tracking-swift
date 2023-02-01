import AblyAssetTrackingCore
import Ably
import AblyAssetTrackingInternal

class SubscriberWorkerFactory: WorkerFactory {
    typealias PropertiesType = SubscriberProperties
    typealias WorkerSpecificationType = SubscriberWorkerSpecification
    
    private let ablySubscriber: AblySubscriber
    private let trackable: Trackable
    private let channel: AblySDKRealtimeChannel
    private let logHandler: InternalLogHandler?
    
    init(ablySubscriber: AblySubscriber, trackable: Trackable, channel: AblySDKRealtimeChannel, logHandler: InternalLogHandler?) {
        self.ablySubscriber = ablySubscriber
        self.trackable = trackable
        self.channel = channel
        self.logHandler = logHandler
    }
    
    func createWorker(workerSpecification: SubscriberWorkerSpecification) -> any Worker<SubscriberProperties, SubscriberWorkerSpecification> {
        
        if let specification = workerSpecification as? StartConnectionSpecification {
            return SubscriberStartConnectionWorker(ablySubscriber: ablySubscriber, trackableId: trackable.id, callback: specification.completion)
        }
        
        if let specification = workerSpecification as? SubscribeForPresenceMessagesSpecification {
            return SubscribeForPresenceMessagesWorker(ablySubscriber: ablySubscriber, trackable: trackable, channel: channel, logHandler: logHandler, completion: specification.completion)
        }
        
        if let specification = workerSpecification as? ProcessInitialMessagesSpecification {
            return SubscriberProcessInitialMessagesWorker(completion: specification.completion)
        }
        
        else {
            fatalError()
        }
    }
}

protocol SubscriberWorkerSpecification {}

struct StartConnectionSpecification: SubscriberWorkerSpecification {
    let completion: ResultHandler<Void>
}

struct SubscribeForPresenceMessagesSpecification: SubscriberWorkerSpecification {
    let completion: ResultHandler<Void>
}

struct ProcessInitialMessagesSpecification: SubscriberWorkerSpecification {
    let presenceMessages: [ARTPresenceMessage]
    let completion: ResultHandler<Void>
}

extension Worker where PropertiesType == SubscriberProperties, WorkerSpecificationType == SubscriberWorkerSpecification {
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
