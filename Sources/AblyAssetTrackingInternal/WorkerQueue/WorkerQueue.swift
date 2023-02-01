import Foundation
import AblyAssetTrackingCore

class WorkerQueue<PropertiesType, WorkerSpecificationType> where PropertiesType: Properties {
    private var properties: PropertiesType
    private let workingQueue: DispatchQueue
    private let logHandler: InternalLogHandler?
    private let workerFactory: any WorkerFactory<PropertiesType, WorkerSpecificationType>

    init(properties: PropertiesType, queue: DispatchQueue, logHandler: InternalLogHandler?, workerFactory: any WorkerFactory<PropertiesType, WorkerSpecificationType>) {
        self.properties = properties
        self.workingQueue = queue
        self.logHandler = logHandler
        self.workerFactory = workerFactory
    }
    
    func enqueue(workerSpecification: WorkerSpecificationType) {
        let worker = workerFactory.createWorker(workerSpecification: workerSpecification)
    }
}
