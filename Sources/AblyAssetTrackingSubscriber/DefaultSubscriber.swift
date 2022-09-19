import Foundation
import CoreLocation
import Foundation
import AblyAssetTrackingCore
import AblyAssetTrackingInternal

// Default logger used in Subscriber SDK

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
    private let trackableId: String
    private let presenceData: PresenceData
    private let logHandler: LogHandler?
    
    private var ablySubscriber: AblySubscriber
    private var subscriberState: SubscriberState = .working
    private var receivedAblyClientConnectionState: ConnectionState = .offline
    private var receivedAblyChannelConnectionState: ConnectionState = .offline
    private var currentTrackableConnectionState: ConnectionState = .offline
    private var isPublisherOnline: Bool = false
    
    weak var delegate: SubscriberDelegate?

    init(
        ablySubscriber: AblySubscriber,
        trackableId: String,
        resolution: Resolution?,
        logHandler: LogHandler?) {
            
        self.workingQueue = DispatchQueue(label: "com.ably.Subscriber.DefaultSubscriber", qos: .default)
        self.ablySubscriber = ablySubscriber
        self.trackableId = trackableId
        self.presenceData = PresenceData(type: .subscriber, resolution: resolution)
        self.logHandler = logHandler
        
        self.ablySubscriber.subscriberDelegate = self
        
        self.ablySubscriber.subscribeForAblyStateChange()
    }

    func resolutionPreference(resolution: Resolution?, completion: @escaping ResultHandler<Void>) {
        guard !subscriberState.isStoppingOrStopped else {
            callback(error: ErrorInformation(type: .subscriberStoppedException), handler: completion)
            return
        }
        
        enqueue(event: .changeResolution(.init(resolution: resolution, resultHandler: completion)))
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
        enqueue(event: .start(.init(resultHandler: completion)))
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
        
        enqueue(event: .stop(.init(resultHandler: completion)))
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
    private func enqueue(event: Event) {
        logHandler?.v(message: "\(String(describing: Self.self)): enqueuing event: \(event)", error: nil)
        performOnWorkingThread { [weak self] in
            switch event {
            case .start(let event): self?.performStart(event)
            case .stop(let event): self?.performStop(event)
            case .changeResolution(let event): self?.performChangeResolution(event)
            case .ablyConnectionClosed(let event): self?.performStopped(event)
            case .ablyClientConnectionStateChanged(let event): self?.performClientConnectionChanged(event)
            case .ablyChannelConnectionStateChanged(let event): self?.performChannelConnectionChanged(event)
            case .presenceUpdate(let event): self?.performPresenceUpdated(event)
            case .ablyError(let event): self?.performAblyError(event)
            }
        }
    }

    private func callback<T: Any>(value: T, handler: @escaping ResultHandler<T>) {
        performOnMainThread { handler(.success(value)) }
    }

    private func callback<T: Any>(error: ErrorInformation, handler: @escaping ResultHandler<T>) {
        performOnMainThread { handler(.failure(error)) }
    }

    private func callback(event: DelegateEvent) {
        logHandler?.v(message: "\(String(describing: Self.self)): received delegate event: \(event)", error: nil)
        performOnMainThread { [weak self] in
            guard let self = self,
                  let delegate = self.delegate
            else { return }

            switch event {
            case .delegateError(let event): delegate.subscriber(sender: self, didFailWithError: event.error)
            case .delegateConnectionStatusChanged(let event): delegate.subscriber(sender: self, didChangeAssetConnectionStatus: event.status)
            case .delegateEnhancedLocationReceived(let event): delegate.subscriber(sender: self, didUpdateEnhancedLocation: event.locationUpdate)
            case .delegateRawLocationReceived(let event): delegate.subscriber(sender: self, didUpdateRawLocation: event.locationUpdate)
            case .delegateResolutionReceived(let event): delegate.subscriber(sender: self, didUpdateResolution: event.resolution)
            case .delegateDesiredIntervalReceived(let event): delegate.subscriber(sender: self, didUpdateDesiredInterval: event.desiredInterval)
            }
        }
    }

    // MARK: Start/Stop
    private func performStart(_ event: Event.StartEvent) {
        
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
                
                self.callback(value: Void(), handler: event.resultHandler)
            case .failure(let error):
                self.callback(error: error, handler: event.resultHandler)
            }
        }
        
    }
    
    private func performStop(_ event: Event.StopEvent) {
        subscriberState = .stopping
        
        ablySubscriber.close(presenceData: presenceData) { [weak self] result in
            switch result {
            case .success:
                self?.enqueue(event: .ablyConnectionClosed(.init(resultHandler: event.resultHandler)))
            case .failure(let error):
                self?.callback(error: ErrorInformation(error: error), handler: event.resultHandler)
            }
        }
    }
    
    private func performPresenceUpdated(_ event: Event.PresenceUpdateEvent) {
        guard event.presence.type == .publisher else {
            return
        }
        
        if event.presence.action.isPresentOrEnter {
            isPublisherOnline = true
        } else if event.presence.action.isLeaveOrAbsent {
            isPublisherOnline = false
        }
    }
    
    private func performStopped(_ event: Event.AblyConnectionClosedEvent) {
        subscriberState = .stopped
        callback(value: Void(), handler: event.resultHandler)
    }
    
    private func performClientConnectionChanged(_ event: Event.AblyClientConnectionStateChangedEvent) {
        receivedAblyClientConnectionState = event.connectionState
        handleConnectionStateChange()
    }
    
    private func performChannelConnectionChanged(_ event: Event.AblyChannelConnectionStateChangedEvent) {
        receivedAblyChannelConnectionState = event.connectionState
        handleConnectionStateChange()
    }
    
    private func handleConnectionStateChange() {
        if currentTrackableConnectionState == .failed {
            logHandler?.d(message: "\(String(describing: Self.self)): Ignoring state change since state is already .failed", error: nil)
            return
        }
        
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
            callback(event: .delegateConnectionStatusChanged(.init(status: newConnectionState)))
        }
    }

    private func performChangeResolution(_ event: Event.ChangeResolutionEvent) {
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
    
    private func performAblyError(_ event: Event.AblyErrorEvent) {
        callback(event: .delegateError(.init(error: event.error)))
        
        if event.error.code == ErrorCode.invalidMessage.rawValue {
            logHandler?.e(message: "\(String(describing: Self.self)): invalidMessage error received, emitting failed connection status", error: event.error)
            currentTrackableConnectionState = .failed
            callback(event: .delegateConnectionStatusChanged(.init(status: .failed)))

            ablySubscriber.disconnect(trackableId: trackableId, presenceData: nil) { [weak self, trackableId] error in
                if case .failure(let error) = error {
                    self?.logHandler?.e(message: "\(String(describing: Self.self)): Failed to disconnect trackable (\(trackableId)) after receiving invalid message.", error: error)
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
}

extension DefaultSubscriber: AblySubscriberDelegate {
    func ablySubscriber(_ sender: AblySubscriber, didReceivePresenceUpdate presence: Presence) {
        logHandler?.d(message: "\(String(describing: Self.self)): ablySubscriber.didReceivePresenceUpdate. Presence: \(presence)", error: nil)
        enqueue(event: .presenceUpdate(.init(presence: presence)))
    }
    
    func ablySubscriber(_ sender: AblySubscriber, didChangeClientConnectionState state: ConnectionState) {
        logHandler?.d(message: "\(String(describing: Self.self)): ablySubscriber.didChangeClientConnectionState. Status: \(state)", error: nil)
        enqueue(event: .ablyClientConnectionStateChanged(.init(connectionState: state)))
    }
    
    func ablySubscriber(_ sender: AblySubscriber, didChangeChannelConnectionState state: ConnectionState) {
        logHandler?.d(message: "\(String(describing: Self.self)): ablySubscriber.didChangeChannelConnectionState. Status: \(state)", error: nil)
            enqueue(event: .ablyChannelConnectionStateChanged(.init(connectionState: state)))
    }

    func ablySubscriber(_ sender: AblySubscriber, didFailWithError error: ErrorInformation) {
        logHandler?.e(message: "\(String(describing: Self.self)): ablySubscriber.didFailWithError", error: error)
        enqueue(event: .ablyError(.init(error: error)))
    }

    func ablySubscriber(_ sender: AblySubscriber, didReceiveRawLocation location: LocationUpdate) {
        logHandler?.d(message: "\(String(describing: Self.self)): ablySubscriber.didReceiveRawLocation", error: nil)
        callback(event: .delegateRawLocationReceived(.init(locationUpdate: location)))
    }
    
    func ablySubscriber(_ sender: AblySubscriber, didReceiveEnhancedLocation location: LocationUpdate) {
        logHandler?.d(message: "\(String(describing: Self.self)): ablySubscriber.didReceiveEnhancedLocation", error: nil)
        callback(event: .delegateEnhancedLocationReceived(.init(locationUpdate: location)))
    }
    
    func ablySubscriber(_ sender: AblySubscriber, didReceiveResolution resolution: Resolution) {
        logHandler?.d(message: "\(String(describing: Self.self)): ablySubscriber.didReceiveResolution", error: nil)
        callback(event: .delegateResolutionReceived(.init(resolution: resolution)))
        callback(event: .delegateDesiredIntervalReceived(.init(desiredInterval: resolution.desiredInterval)))
    }
}
