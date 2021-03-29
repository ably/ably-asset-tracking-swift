import Foundation
import CoreLocation
import Logging

// Default logger used in Subscriber SDK
let logger: Logger = Logger(label: "com.ably.tracking.Subscriber")

private enum SubscriberState {
    case working
    case stopping
    case stopped
    
    var isStoppingOrStopped: Bool {
        self == .stopping || self == .stopped
    }
}

class DefaultSubscriber: Subscriber, SubscriberObjectiveC {
    private let workingQueue: DispatchQueue
    private let logConfiguration: LogConfiguration
    private let ablyService: AblySubscriberService
    private var subscriberState: SubscriberState = .working
    
    private var ablyClientConnectionState: ConnectionState = .offline
    private var ablyChannelConnectionState: ConnectionState = .offline
    private var lastConnectionState: ConnectionState = .offline
    private var isOnline: Bool = false
    
    weak var delegate: SubscriberDelegate?
    weak var delegateObjectiveC: SubscriberDelegateObjectiveC?

    init(logConfiguration: LogConfiguration,
         ablyService: AblySubscriberService) {
        self.logConfiguration = logConfiguration
        self.workingQueue = DispatchQueue(label: "com.ably.Subscriber.DefaultSubscriber", qos: .default)
        self.ablyService = ablyService
        self.ablyService.delegate = self
    }
    
    @objc
    func sendChangeRequest(resolution: Resolution?, onSuccess: @escaping (() -> Void), onError: @escaping ((ErrorInformation) -> Void)) {
        sendChangeRequest(resolution: resolution) { result in
            switch result {
            case .success:
                onSuccess()
            case .failure(let error):
                onError(error)
            }
        }
    }

    func sendChangeRequest(resolution: Resolution?, completion: @escaping ResultHandler<Void>) {
        guard !subscriberState.isStoppingOrStopped else {
            callback(error: ErrorInformation(type: .subscriberStoppedException), handler: completion)
            return
        }
        
        enqueue(event: ChangeResolutionEvent(resolution: resolution, resultHandler: completion))
    }

    func start() {
        enqueue(event: StartEvent())
    }
    
    func stop(completion: @escaping ResultHandler<Void>) {
        guard !subscriberState.isStoppingOrStopped else {
            callback(value: Void(), handler: completion)
            return
        }
        
        enqueue(event: StopEvent(resultHandler: completion))
    }

    @objc
    func stop(onSuccess: @escaping (() -> Void), onError: @escaping ((ErrorInformation) -> Void)) {
        stop { result in
            switch result {
            case .success:
                onSuccess()
            case .failure(let error):
                onError(error)
            }
        }
    }
}

extension DefaultSubscriber {
    private func enqueue(event: SubscriberEvent) {
        logger.trace("Received event: \(event)")
        performOnWorkingThread { [weak self] in
            switch event {
            case _ as StartEvent: self?.performStart()
            case let event as StopEvent: self?.performStop(event)
            case let event as ChangeResolutionEvent: self?.performChangeResolution(event)
            case let event as AblyConnectionClosedEvent: self?.performStopped(event)
            case let event as AblyClientConnectionStateChangedEvent: self?.performClientConnectionChanged(event)
            case let event as AblyChannelConnectionStateChangedEvent: self?.performChannelConnectionChanged(event)
            case let event as PresenceUpdateEvent: self?.performPresenceUpdated(event)
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

    private func performStop(_ event: StopEvent) {
        subscriberState = .stopping
        
        ablyService.stop { [weak self] result in
            switch result {
            case .success:
                self?.enqueue(event: AblyConnectionClosedEvent(resultHandler: event.resultHandler))
            case .failure(let error):
                self?.callback(error: ErrorInformation(error: error), handler: event.resultHandler)
            }
        }
    }
    
    private func performPresenceUpdated(_ event: PresenceUpdateEvent) {
        switch event.presence {
        case .enter, .present:
            isOnline = true
        default:
            isOnline = false
        }
    }
    
    private func performStopped(_ event: AblyConnectionClosedEvent) {
        subscriberState = .stopped
        callback(value: Void(), handler: event.resultHandler)
    }
    
    private func performClientConnectionChanged(_ event: AblyClientConnectionStateChangedEvent) {
        guard ablyClientConnectionState != event.connectionState else {
            return
        }
        
        ablyClientConnectionState = event.connectionState
        handleConnectionStateChange()
    }
    
    private func performChannelConnectionChanged(_ event: AblyChannelConnectionStateChangedEvent) {
        guard ablyChannelConnectionState != event.connectionState else {
            return
        }
        
        ablyChannelConnectionState = event.connectionState
        handleConnectionStateChange()
    }
    
    private func handleConnectionStateChange() {
        var newConnectionState: ConnectionState = .offline
        
        switch ablyClientConnectionState {
        case .online:
            switch ablyChannelConnectionState {
            case .online:
                newConnectionState = isOnline ? .online : .offline
            case .offline:
                newConnectionState = .offline
            case .failed:
                newConnectionState = .failed
            }
        case .offline:
            newConnectionState = .offline
        case .failed:
            newConnectionState = .failed
        }
        
        ablyChannelConnectionState = newConnectionState
        callback(event: DelegateConnectionStatusChangedEvent(status: newConnectionState))
    }

    // swiftlint:disable vertical_whitespace_between_cases
    private func performChangeResolution(_ event: ChangeResolutionEvent) {
        ablyService.changeRequest(resolution: event.resolution) { [weak self] result in
            switch result {
            case .success:
                self?.callback(value: Void(), handler: event.resultHandler)
            case .failure(let error):
                self?.callback(error: ErrorInformation(error: error), handler: event.resultHandler)
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
    func subscriberService(sender: AblySubscriberService, didReceivePresenceUpdate presence: AblyPublisherPresence) {
        logger.debug("subscriberService.didReceivePresenceUpdate. Presence: \(presence)", source: "DefaultSubscriber")
        enqueue(event: PresenceUpdateEvent(presence: presence))
    }
    
    func subscriberService(sender: AblySubscriberService, didChangeClientConnectionStatus status: ConnectionState) {
        logger.debug("subscriberService.didChangeClientConnectionStatus. Status: \(status)", source: "DefaultSubscriber")
        enqueue(event: AblyClientConnectionStateChangedEvent(connectionState: status))
    }
    
    func subscriberService(sender: AblySubscriberService, didChangeChannelConnectionStatus status: ConnectionState) {
        logger.debug("subscriberService.didChangeChannelConnectionStatus. Status: \(status)", source: "DefaultSubscriber")
        enqueue(event: AblyChannelConnectionStateChangedEvent(connectionState: status))
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
