public protocol WorkerFactory<PropertiesType, WorkerSpecificationType> {
    associatedtype PropertiesType
    associatedtype WorkerSpecificationType
    
    func createWorker(workerSpecification: WorkerSpecificationType) -> any Worker<PropertiesType, WorkerSpecificationType>
}
