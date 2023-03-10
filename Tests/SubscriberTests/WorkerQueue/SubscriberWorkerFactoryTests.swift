import XCTest
import AblyAssetTrackingInternal
import AblyAssetTrackingInternalTesting
@testable import AblyAssetTrackingSubscriber
import AblyAssetTrackingSubscriberTesting

class SubscriberWorkerFactoryTests: XCTestCase
{
    private let logHandler = InternalLogHandlerMock.configured
    private let configuration = ConnectionConfiguration(apiKey: "API_KEY", clientId: "CLIENT_ID")
    private var ablySubscriber: MockAblySubscriber!
    private let logger = InternalLogHandlerMock.configured

    private var subscriber: DefaultSubscriber?
    private var properties: SubscriberWorkerQueueProperties?
    
    private let factory = SubscriberWorkerFactory()

    override func setUp() {
        ablySubscriber = MockAblySubscriber(configuration: configuration, mode: .subscribe)
        subscriber = DefaultSubscriber(
            ablySubscriber: ablySubscriber,
            trackableId: "testId",
            resolution: nil,
            logHandler: logger
        )
        
        properties = SubscriberWorkerQueueProperties(initialResolution: Resolution(accuracy: .balanced, desiredInterval: 1.0, minimumDisplacement: 1.0), ablySubscriber: subscriber!)
        
        let workerQueue = WorkerQueue(
            properties: SubscriberWorkerQueueProperties(initialResolution: nil, ablySubscriber: subscriber!),
            workingQueue: DispatchQueue(label: "com.ably.Subscriber.DefaultSubscriber", qos: .default),
            logHandler: logger,
            workerFactory: SubscriberWorkerFactory(),
            asyncWorkWorkingQueue: DispatchQueue(label: "com.ably.Subscriber.DefaultSubscriber.async", qos: .default),
            getStoppedError: { return ErrorInformation(type: .subscriberStoppedException)}
        )
        subscriber?.configureWorkerQueue(workerQueue: workerQueue)

    }
    
    func test_ItBuildsLegacyWork()
    {
        var legacyWorkerCalled = false
        let callback = {
            legacyWorkerCalled = true
            return
        }

        let worker = factory.createWorker(
            workerSpecification: SubscriberWorkSpecification.legacy(callback: callback),
            logHandler: logHandler
        )

        XCTAssertTrue(worker is LegacyWorker<SubscriberWorkerQueueProperties, SubscriberWorkSpecification>)
        let _ = try! worker.doWork(
            properties: properties!,
            doAsyncWork: {_ in },
            postWork: {_ in }
        )
        XCTAssertTrue(legacyWorkerCalled, "Legacy worker work not called")
    }
}
