import Foundation
import CoreLocation
import Logging

// Default logger used in Subscriber SDK
let logger: Logger = Logger(label: "com.ably.tracking.Subscriber")

class DefaultSubscriber: Subscriber {
    private let workingQueue: DispatchQueue
    private let logConfiguration: LogConfiguration
    private let trackingId: String
    private let ablyService: AblySubscriberService
    weak var delegate: SubscriberDelegate?

    init(connectionConfiguration: ConnectionConfiguration,
         logConfiguration: LogConfiguration,
         trackingId: String,
         resolution: Resolution?) {
        self.trackingId = trackingId
        self.logConfiguration = logConfiguration
        self.workingQueue = DispatchQueue(label: "com.ably.Subscriber.DefaultSubscriber", qos: .default)
        self.ablyService = AblySubscriberService(configuration: connectionConfiguration,
                                                 trackingId: trackingId,
                                                 resolution: resolution)
        self.ablyService.delegate = self
    }

    func sendChangeRequest(resolution: Resolution?, completion: @escaping ResultHandler<Void>) {
        enqueue(event: ChangeResolutionEvent(resolution: resolution, resultHandler: completion))
    }

    func start() {
        enqueue(event: StartEvent())
    }

    func stop() {
        enqueue(event: StopEvent())
        ablyService.stop()
    }
}

extension DefaultSubscriber {
    private func enqueue(event: SubscriberEvent) {
        logger.trace("Received event: \(event)")
        performOnWorkingThread { [weak self] in
            switch event {
            case _ as StartEvent: self?.performStart()
            case _ as StopEvent: self?.performStop()
            case let event as ChangeResolutionEvent: self?.performChangeResolution(event)
            default: preconditionFailure("Unhandled event in DefaultSubscriber: \(event) ")
            }
        }
    }

    private func callback<T: Any>(value: T, handler: @escaping ResultHandler<T>) {
        performOnMainThread { handler(.success(value)) }
    }

    private func callback<T: Any>(error: ErrorInformation, handler: @escaping ResultHandler<T>) {
        performOnMainThread { handler(.failure(error)) }
    }

    private func callback(event: SubscriberDelegateEvent) {
        logger.trace("Received delegate event: \(event)")
        performOnMainThread { [weak self] in
            guard let self = self,
                  let delegate = self.delegate
            else { return }

            switch event {
            case let event as DelegateErrorEvent: delegate.subscriber(sender: self, didFailWithError: event.error)
            case let event as DelegateConnectionStatusChangedEvent: delegate.subscriber(sender: self, didChangeAssetConnectionStatus: event.status)
            case let event as DelegateEnhancedLocationReceivedEvent: delegate.subscriber(sender: self, didUpdateEnhancedLocation: event.location)
            default: preconditionFailure("Unhandled delegate event in DefaultSubscriber: \(event) ")
            }
        }
    }

    // MARK: Start/Stop
    private func performStart() {
        ablyService.start { [weak self] error in
            guard let error = error else { return }
            self?.callback(event: DelegateErrorEvent(error: ErrorInformation(error: error)))
        }
    }

    private func performStop() {
        ablyService.stop()
    }

    private func performChangeResolution(_ event: ChangeResolutionEvent) {
        ablyService.changeRequest(resolution: event.resolution) { [weak self] result in
            switch result {
            case .success:
                self?.callback(value: (), handler: event.resultHandler)
            case .failure(let error):
                self?.callback(error: error, handler: event.resultHandler)
            }
        }
    }

    // MARK: Utils
    private func performOnWorkingThread(_ operation: @escaping () -> Void) {
        workingQueue.async(execute: operation)
    }

    private func performOnMainThread(_ operation: @escaping () -> Void) {
        DispatchQueue.main.async(execute: operation)
    }
}

extension DefaultSubscriber: AblySubscriberServiceDelegate {
    func subscriberService(sender: AblySubscriberService, didChangeAssetConnectionStatus status: AssetConnectionStatus) {
        logger.debug("subscriberService.didChangeAssetConnectionStatus. Status: \(status)", source: "DefaultSubscriber")
        callback(event: DelegateConnectionStatusChangedEvent(status: status))
    }

    func subscriberService(sender: AblySubscriberService, didFailWithError error: ErrorInformation) {
        logger.error("subscriberService.didFailWithError. Error: \(error)", source: "DefaultSubscriber")
        callback(event: DelegateErrorEvent(error: error))
    }

    func subscriberService(sender: AblySubscriberService, didReceiveEnhancedLocation location: CLLocation) {
        logger.debug("subscriberService.didReceiveEnhancedLocation.", source: "DefaultSubscriber")
        callback(event: DelegateEnhancedLocationReceivedEvent(location: location))
    }
}
