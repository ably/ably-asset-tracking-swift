import Foundation
import CoreLocation
import Logging
import Foundation
import AblyAssetTrackingCore
import AblyAssetTrackingInternal

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

class DefaultSubscriber: Subscriber {
    private let workingQueue: DispatchQueue
    private let logConfiguration: LogConfiguration
    private let trackableId: String
    private let presenceData: PresenceData
    
    private var ablySubscriber: AblySubscriber
    private var subscriberState: SubscriberState = .working
    private var receivedAblyClientConnectionState: ConnectionState = .offline
    private var receivedAblyChannelConnectionState: ConnectionState = .offline
    private var currentTrackableConnectionState: ConnectionState = .offline
    private var isPublisherOnline: Bool = false
    
    weak var delegate: SubscriberDelegate?

    init(
        logConfiguration: LogConfiguration,
        ablySubscriber: AblySubscriber,
        trackableId: String,
        resolution: Resolution?
    ) {
        self.logConfiguration = logConfiguration
        self.workingQueue = DispatchQueue(label: "com.ably.Subscriber.DefaultSubscriber", qos: .default)
        self.ablySubscriber = ablySubscriber
        self.trackableId = trackableId
        self.presenceData = PresenceData(type: .subscriber, resolution: resolution)
        self.ablySubscriber.subscriberDelegate = self
        
        self.ablySubscriber.subscribeForAblyStateChange()
    }

    func resolutionPreference(resolution: Resolution?, completion: @escaping ResultHandler<Void>) {
        guard !subscriberState.isStoppingOrStopped else {
            callback(error: ErrorInformation(type: .subscriberStoppedException), handler: completion)
            return
        }
        
        enqueue(event: ChangeResolutionEvent(resolution: resolution, resultHandler: completion))
    }
    
    func resolutionPreference(resolution: Resolution?, onSuccess: @escaping (() -> Void), onError: @escaping ((ErrorInformation) -> Void)) {
        resolutionPreference(resolution: resolution) { result in
            switch result {
            case .success:
                onSuccess()
            case .failure(let error):
                onError(error)
            }
        }
    }

    func start(completion: @escaping ResultHandler<Void>) {
        enqueue(event: StartEvent(resultHandler: completion))
    }
    
    func start(onSuccess: @escaping (() -> Void), onError: @escaping ((ErrorInformation) -> Void)) {
        start { result in
            switch result {
            case .success:
                onSuccess()
            case .failure(let error):
                onError(error)
            }
        }
    }
    
    func stop(completion: @escaping ResultHandler<Void>) {
        guard !subscriberState.isStoppingOrStopped else {
            callback(value: Void(), handler: completion)
            return
        }
        
        enqueue(event: StopEvent(resultHandler: completion))
    }

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
            case let event as StartEvent: self?.performStart(event)
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
            case let event as DelegateResolutionReceivedEvent: delegate.subscriber(sender: self, didUpdateResolution: event.resolution)
            default: preconditionFailure("Unhandled delegate event in DefaultSubscriber: \(event) ")
            }
        }
    }

    // MARK: Start/Stop
    private func performStart(_ event: StartEvent) {
        
        ablySubscriber.connect(
            trackableId: trackableId,
            presenceData: presenceData,
            useRewind: true
        ) { [weak self] result in
            guard let self = self else {
                return
            }
            
            switch result {
            case .success:
                self.ablySubscriber.subscribeForPresenceMessages(trackable: .init(id: self.trackableId))
                self.ablySubscriber.subscribeForRawEvents(trackableId: self.trackableId)
                self.ablySubscriber.subscribeForEnhancedEvents(trackableId: self.trackableId)
                self.ablySubscriber.subscribeForResolutionEvents(trackableId: self.trackableId)
                
                self.callback(value: Void(), handler: event.resultHandler)
            case .failure(let error):
                self.callback(error: error, handler: event.resultHandler)
            }
        }
        
    }
    
    private func performStop(_ event: StopEvent) {
        subscriberState = .stopping
        
        ablySubscriber.close(presenceData: presenceData) { [weak self] result in
            switch result {
            case .success:
                self?.enqueue(event: AblyConnectionClosedEvent(resultHandler: event.resultHandler))
            case .failure(let error):
                self?.callback(error: ErrorInformation(error: error), handler: event.resultHandler)
            }
        }
    }
    
    private func performPresenceUpdated(_ event: PresenceUpdateEvent) {
        if event.presence.isPresentOrEnter {
            isPublisherOnline = true
        } else if event.presence.isLeaveOrAbsent {
            isPublisherOnline = false
        }
    }
    
    private func performStopped(_ event: AblyConnectionClosedEvent) {
        subscriberState = .stopped
        callback(value: Void(), handler: event.resultHandler)
    }
    
    private func performClientConnectionChanged(_ event: AblyClientConnectionStateChangedEvent) {
        receivedAblyClientConnectionState = event.connectionState
        handleConnectionStateChange()
    }
    
    private func performChannelConnectionChanged(_ event: AblyChannelConnectionStateChangedEvent) {
        receivedAblyChannelConnectionState = event.connectionState
        handleConnectionStateChange()
    }
    
    private func handleConnectionStateChange() {
        var newConnectionState: ConnectionState = .offline
        
        switch receivedAblyClientConnectionState {
        case .online:
            switch receivedAblyChannelConnectionState {
            case .online:
                newConnectionState = isPublisherOnline ? .online : .offline
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
        
        if newConnectionState != currentTrackableConnectionState {
            currentTrackableConnectionState = newConnectionState
            callback(event: DelegateConnectionStatusChangedEvent(status: newConnectionState))
        }
    }

    // swiftlint:disable vertical_whitespace_between_cases
    private func performChangeResolution(_ event: ChangeResolutionEvent) {
        guard let resolution = event.resolution else {
            callback(value: Void(), handler: event.resultHandler)
            
            return
        }
        
        let presenceDataUpdate = PresenceData(type: presenceData.type, resolution: resolution)
        ablySubscriber.updatePresenceData(
            trackableId: trackableId,
            presenceData: presenceDataUpdate
        ) { [weak self] result in
            
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
    func subscriberService(sender: AblySubscriber, didReceivePresenceUpdate presence: Presence) {
        logger.debug("subscriberService.didReceivePresenceUpdate. Presence: \(presence)", source: String(describing: Self.self))
        enqueue(event: PresenceUpdateEvent(presence: presence))
    }
    
    func subscriberService(sender: AblySubscriber, didChangeClientConnectionState state: ConnectionState) {
        logger.debug("subscriberService.didChangeClientConnectionStatus. Status: \(state)", source: String(describing: Self.self))
        enqueue(event: AblyClientConnectionStateChangedEvent(connectionState: state))
    }
    
    func subscriberService(sender: AblySubscriber, didChangeChannelConnectionState state: ConnectionState) {
        logger.debug("subscriberService.didChangeChannelConnectionStatus. Status: \(state)", source: String(describing: Self.self))
        enqueue(event: AblyChannelConnectionStateChangedEvent(connectionState: state))
    }

    func subscriberService(sender: AblySubscriber, didFailWithError error: ErrorInformation) {
        logger.error("subscriberService.didFailWithError. Error: \(error)", source: "DefaultSubscriber")
        callback(event: DelegateErrorEvent(error: error))
    }

    func subscriberService(sender: AblySubscriber, didReceiveRawLocation location: Location) {
        logger.debug("subscriberService.didReceiveRawLocation.", source: String(describing: Self.self))
        callback(event: DelegateRawLocationReceivedEvent(location: location))
    }
    
    func subscriberService(sender: AblySubscriber, didReceiveEnhancedLocation location: CLLocation) {
        logger.debug("subscriberService.didReceiveEnhancedLocation.", source: String(describing: Self.self))
        callback(event: DelegateEnhancedLocationReceivedEvent(location: location))
    }
    
    func subscriberService(sender: AblySubscriber, didReceiveResolution resolution: Resolution) {
        logger.debug("subscriberService.didReceiveResolution.", source: String(describing: Self.self))
        callback(event: DelegateResolutionReceivedEvent(resolution: resolution))
    }
}
