import Foundation
import CoreLocation
import Logging

// Default logger used in Subscriber SDK
let logger: Logger = Logger(label: "com.ably.asset-tracking.Subscriber")

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
        self.workingQueue = DispatchQueue(label: "io.ably.asset-tracking.Publisher.DefaultPublisher",
                                          qos: .default)

        self.ablyService = AblySubscriberService(configuration: connectionConfiguration,
                                                 trackingId: trackingId,
                                                 resolution: resolution)
        self.ablyService.delegate = self
    }

    func sendChangeRequest(resolution: Resolution?, completion: @escaping ResultHandler<Void>) {
        execute(event: ChangeResolutionEvent(resolution: resolution, resultHandler: completion))
    }

    func start() {
        execute(event: StartEvent())
    }

    func stop() {
        execute(event: StopEvent())
        ablyService.stop()
    }
}

extension DefaultSubscriber {
    private func execute(event: SubscriberEvent) {
        logger.trace("Received event: \(event)")
        performOnWorkingThread { [weak self] in
            switch event {
            case _ as StartEvent: self?.performStart()
            case _ as StopEvent: self?.performStop()
            case let event as ChangeResolutionEvent: self?.performChangeResolution(event)
            case let event as DelegateErrorEvent: self?.notifyDelegateDidFailWithError(event.error)
            case let event as DelegateConnectionStatusChangedEvent: self?.notifyDelegateConnectionStatusChanged(event)
            case let event as DelegateEnhancedLocationReceivedEvent: self?.notifyDelegateEnhancedLocationChanged(event)
            default: preconditionFailure("Unhandled event in DefaultSubscriber: \(event) ")
            }
        }
    }
    // MARK: Start/Stop
    private func performStart() {
        ablyService.start { [weak self] result in
            switch result {
            case .success:
                return
            case .failure(let error):
                self?.execute(event: DelegateErrorEvent(error: error))
            }
        }
    }

    private func performStop() {
        ablyService.stop()
    }

    private func performChangeResolution(_ event: ChangeResolutionEvent) {
        ablyService.changeRequest(resolution: event.resolution) { [weak self] result in
            switch result {
            case .success:
                self?.performOnMainThread {
                    event.resultHandler(.success(()))
                }
            case .failure(let error):
                self?.performOnMainThread {
                    event.resultHandler(.failure(error))
                }
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

    // MARK: Delegate
    private func notifyDelegateDidFailWithError(_ error: Error) {
        performOnMainThread { [weak self] in
            guard let self = self else { return }
            self.delegate?.subscriber(sender: self, didFailWithError: error)
        }
    }

    private func notifyDelegateConnectionStatusChanged(_ event: DelegateConnectionStatusChangedEvent) {
        performOnMainThread { [weak self] in
            guard let self = self else { return }
            self.delegate?.subscriber(sender: self, didChangeAssetConnectionStatus: event.status)
        }
    }

    private func notifyDelegateEnhancedLocationChanged(_ event: DelegateEnhancedLocationReceivedEvent) {
        performOnMainThread { [weak self] in
            guard let self = self else { return }
            self.delegate?.subscriber(sender: self, didUpdateEnhancedLocation: event.location)
        }
    }
}

extension DefaultSubscriber: AblySubscriberServiceDelegate {
    func subscriberService(sender: AblySubscriberService, didChangeAssetConnectionStatus status: AssetConnectionStatus) {
        logger.debug("subscriberService.didChangeAssetConnectionStatus. Status: \(status)", source: "DefaultSubscriber")
        execute(event: DelegateConnectionStatusChangedEvent(status: status))
    }

    func subscriberService(sender: AblySubscriberService, didFailWithError error: Error) {
        logger.error("subscriberService.didFailWithError. Error: \(error)", source: "DefaultSubscriber")
        execute(event: DelegateErrorEvent(error: error))
    }

    func subscriberService(sender: AblySubscriberService, didReceiveEnhancedLocation location: CLLocation) {
        logger.debug("subscriberService.didReceiveEnhancedLocation.", source: "DefaultSubscriber")
        execute(event: DelegateEnhancedLocationReceivedEvent(location: location))
    }
}
