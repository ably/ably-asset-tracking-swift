import Foundation
import CoreLocation
import Logging

// Default logger used in Subscriber SDK
let logger: Logger = Logger(label: "com.ably.tracking.Subscriber")

class DefaultSubscriber: Subscriber {
    private let workingQueue: DispatchQueue
    private let logConfiguration: LogConfiguration
    private let trackingId: String
    private let resolution: Double?
    private let ablyService: AblySubscriberService
    weak var delegate: SubscriberDelegate?

    init(connectionConfiguration: ConnectionConfiguration,
         logConfiguration: LogConfiguration,
         trackingId: String,
         resolution: Double?) {
        self.trackingId = trackingId
        self.resolution = resolution
        self.logConfiguration = logConfiguration
        self.workingQueue = DispatchQueue(label: "com.ably.Subscriber.DefaultSubscriber", qos: .default)
        self.ablyService = AblySubscriberService(configuration: connectionConfiguration,
                                                 trackingId: trackingId)
        self.ablyService.delegate = self
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
            default: preconditionFailure("Unhandled event in DefaultSubscriber: \(event) ")
            }
        }
    }

    private func callback(_ handler: @escaping SuccessHandler) {
        performOnMainThread(handler)
    }

    private func callback(error: Error, handler: @escaping ErrorHandler) {
        performOnMainThread { handler(error) }
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
            case let event as DelegateRawLocationReceivedEvent: delegate.subscriber(sender: self, didUpdateRawLocation: event.location)
            case let event as DelegateEnhancedLocationReceivedEvent: delegate.subscriber(sender: self, didUpdateEnhancedLocation: event.location)
            default: preconditionFailure("Unhandled delegate event in DefaultSubscriber: \(event) ")
            }
        }
    }

    // MARK: Start/Stop
    private func performStart() {
        ablyService.start { [weak self] error in
            guard let error = error else { return }
            self?.callback(event: DelegateErrorEvent(error: error))
        }
    }

    private func performStop() {
        ablyService.stop()
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

    func subscriberService(sender: AblySubscriberService, didFailWithError error: Error) {
        logger.error("subscriberService.didFailWithError. Error: \(error)", source: "DefaultSubscriber")
        callback(event: DelegateErrorEvent(error: error))
    }

    func subscriberService(sender: AblySubscriberService, didReceiveRawLocation location: CLLocation) {
        logger.debug("subscriberService.didReceiveRawLocation.", source: "DefaultSubscriber")
        callback(event: DelegateRawLocationReceivedEvent(location: location))
    }

    func subscriberService(sender: AblySubscriberService, didReceiveEnhancedLocation location: CLLocation) {
        logger.debug("subscriberService.didReceiveEnhancedLocation.", source: "DefaultSubscriber")
        callback(event: DelegateEnhancedLocationReceivedEvent(location: location))
    }
}
