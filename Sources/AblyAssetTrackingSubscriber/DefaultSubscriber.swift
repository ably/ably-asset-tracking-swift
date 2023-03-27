import AblyAssetTrackingCore
import AblyAssetTrackingInternal
import CoreLocation
import Foundation

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
    private let workerQueue: WorkerQueue<SubscriberWorkerQueueProperties, SubscriberWorkSpecification>
    private let trackableId: String
    private let presenceData: PresenceData
    private let logHandler: InternalLogHandler?

    private var ablySubscriber: AblySubscriber
    private var subscriberState: SubscriberState = .working
    private var receivedAblyClientConnectionState: ConnectionState = .offline
    private var receivedAblyChannelConnectionState: ConnectionState = .offline
    private var currentTrackableConnectionState: ConnectionState = .offline
    private var isPublisherOnline = false
    private var lastEmittedIsPublisherOnline: Bool?

    weak var delegate: SubscriberDelegate?

    init(
        ablySubscriber: AblySubscriber,
        trackableId: String,
        resolution: Resolution?,
        logHandler: InternalLogHandler?
    ) {
        self.logHandler = logHandler?.addingSubsystem(Self.self)
        // swiftlint:disable:next trailing_closure
        self.workerQueue = WorkerQueue(
            properties: SubscriberWorkerQueueProperties(),
            workingQueue: DispatchQueue(label: "com.ably.Subscriber.DefaultSubscriber", qos: .default),
            logHandler: self.logHandler,
            workerFactory: SubscriberWorkerFactory(),
            asyncWorkWorkingQueue: DispatchQueue(label: "com.ably.Subscriber.DefaultSubscriber.async", qos: .default),
            getStoppedError: { ErrorInformation(type: .subscriberStoppedException) }
        )
        self.ablySubscriber = ablySubscriber
        self.trackableId = trackableId
        self.presenceData = PresenceData(type: .subscriber, resolution: resolution)

        self.ablySubscriber.subscriberDelegate = self

        self.ablySubscriber.subscribeForAblyStateChange()
    }

    func resolutionPreference(resolution: Resolution?, completion publicCompletion: @escaping ResultHandler<Void>) {
        logHandler?.logPublicAPICall(label: "resolutionPreference(\(String(describing: resolution)))")

        let completion = Callback(source: .publicAPI(label: #function), logHandler: logHandler, resultHandler: publicCompletion)

        guard !subscriberState.isStoppingOrStopped else {
            completion.handleSubscriberStopped()
            return
        }

        enqueue(event: .changeResolution(.init(resolution: resolution, completion: completion)))
    }

    func start(completion publicCompletion: @escaping ResultHandler<Void>) {
        logHandler?.logPublicAPICall(label: "start()")

        let completion = Callback(source: .publicAPI(label: #function), logHandler: logHandler, resultHandler: publicCompletion)
        enqueue(event: .start(.init(completion: completion)))
    }

    func stop(completion publicCompletion: @escaping ResultHandler<Void>) {
        logHandler?.logPublicAPICall(label: "stop()")

        let completion = Callback(source: .publicAPI(label: #function), logHandler: logHandler, resultHandler: publicCompletion)

        guard !subscriberState.isStoppingOrStopped else {
            completion.handleSuccess()
            return
        }

        enqueue(event: .stop(.init(completion: completion)))
    }
}

extension DefaultSubscriber {
    private func enqueue(event: Event) {
        logHandler?.verbose(message: "Enqueuing event: \(event)", error: nil)
        performOnWorkingThread { [weak self] in
            switch event {
            case .start(let event):
                self?.performStart(event)
            case .stop(let event):
                self?.performStop(event)
            case .changeResolution(let event):
                self?.performChangeResolution(event)
            case .ablyConnectionClosed(let event):
                self?.performStopped(event)
            case .ablyClientConnectionStateChanged(let event):
                self?.performClientConnectionChanged(event)
            case .ablyChannelConnectionStateChanged(let event):
                self?.performChannelConnectionChanged(event)
            case .presenceUpdate(let event):
                self?.performPresenceUpdated(event)
            case .ablyError(let event):
                self?.performAblyError(event)
            }
        }
    }

    private func callback(event: DelegateEvent) {
        logHandler?.verbose(message: "Received event to send to delegate, dispatching call to main thread: \(event)", error: nil)
        performOnMainThread { [weak self] in
            guard let self,
                  let delegate = self.delegate
            else { return }

            let log = { (description: String) in
                self.logHandler?.logPublicAPIOutput(label: "Calling delegate \(description)")
            }

            switch event {
            case .delegateError(let event):
                log("didFailWithError: \(event.error)")
                delegate.subscriber(sender: self, didFailWithError: event.error)
            case .delegateConnectionStatusChanged(let event):
                log("didChangeAssetConnectionStatus: \(event.status)")
                delegate.subscriber(sender: self, didChangeAssetConnectionStatus: event.status)
            case .delegateEnhancedLocationReceived(let event):
                log("didUpdateEnhancedLocation: \(event.locationUpdate)")
                delegate.subscriber(sender: self, didUpdateEnhancedLocation: event.locationUpdate)
            case .delegateRawLocationReceived(let event):
                log("didUpdateRawLocation: \(event.locationUpdate)")
                delegate.subscriber(sender: self, didUpdateRawLocation: event.locationUpdate)
            case .delegateResolutionReceived(let event):
                log("didUpdateResolution: \(event.resolution)")
                delegate.subscriber(sender: self, didUpdateResolution: event.resolution)
            case .delegateDesiredIntervalReceived(let event):
                log("didUpdateDesiredInterval: \(event.desiredInterval)")
                delegate.subscriber(sender: self, didUpdateDesiredInterval: event.desiredInterval)
            case .delegateUpdatedPublisherPresence(let event):
                log("didUpdatePublisherPresence: \(event.isPresent)")
                delegate.subscriber(sender: self, didUpdatePublisherPresence: event.isPresent)
            }
        }
    }

    // MARK: Start/Stop
    private func performStart(_ event: Event.StartEvent) {
        ablySubscriber.startConnection { [weak self] result in
            guard let self else {
                return
            }

            switch result {
            case .success:
                self.ablySubscriber.connect(
                    trackableId: self.trackableId,
                    presenceData: self.presenceData,
                    useRewind: true
                ) { [weak self] result in
                    guard let self else {
                        return
                    }

                    switch result {
                    case .success:
                        self.ablySubscriber.subscribeForPresenceMessages(trackable: .init(id: self.trackableId))
                        self.ablySubscriber.subscribeForRawEvents(trackableId: self.trackableId)
                        self.ablySubscriber.subscribeForEnhancedEvents(trackableId: self.trackableId)

                        event.completion.handleSuccess()
                    case .failure(let error):
                        event.completion.handleError(error)
                    }
                }
            case .failure(let error):
                self.ablySubscriber.stopConnection(completion: { [error] _ in
                    event.completion.handleError(error)
                })
            }
        }
    }

    private func performStop(_ event: Event.StopEvent) {
        subscriberState = .stopping

        ablySubscriber.close(presenceData: presenceData) { [weak self] result in
            switch result {
            case .success:
                self?.enqueue(event: .ablyConnectionClosed(.init(completion: event.completion)))
            case .failure(let error):
                event.completion.handleError(ErrorInformation(error: error))
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

        if isPublisherOnline != lastEmittedIsPublisherOnline {
            lastEmittedIsPublisherOnline = isPublisherOnline
            callback(event: .delegateUpdatedPublisherPresence(.init(isPresent: isPublisherOnline)))
        }
    }

    private func performStopped(_ event: Event.AblyConnectionClosedEvent) {
        subscriberState = .stopped
        event.completion.handleSuccess()
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
            logHandler?.debug(message: "Ignoring state change since state is already .failed", error: nil)
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
            case .closed:
                newConnectionState = .offline
            case .failed:
                newConnectionState = .failed
            }
        case .offline:
            newConnectionState = .offline
        case .failed:
            newConnectionState = .failed
        case .closed:
            newConnectionState = .offline
        }

        if newConnectionState != currentTrackableConnectionState {
            currentTrackableConnectionState = newConnectionState
            callback(event: .delegateConnectionStatusChanged(.init(status: newConnectionState)))
        }
    }

    private func performChangeResolution(_ event: Event.ChangeResolutionEvent) {
        guard let resolution = event.resolution else {
            event.completion.handleSuccess()

            return
        }

        let presenceDataUpdate = PresenceData(type: presenceData.type, resolution: resolution)
        ablySubscriber.updatePresenceData(
            trackableId: trackableId,
            presenceData: presenceDataUpdate
        ) { result in
            switch result {
            case .success:
                event.completion.handleSuccess()
            case .failure(let error):
                event.completion.handleError(ErrorInformation(error: error))
            }
        }
    }

    private func performAblyError(_ event: Event.AblyErrorEvent) {
        callback(event: .delegateError(.init(error: event.error)))

        if event.error.code == ErrorCode.invalidMessage.rawValue {
            logHandler?.error(message: "invalidMessage error received, emitting failed connection status", error: event.error)
            currentTrackableConnectionState = .failed
            callback(event: .delegateConnectionStatusChanged(.init(status: .failed)))

            ablySubscriber.disconnect(trackableId: trackableId, presenceData: nil) { [weak self, trackableId] error in
                if case .failure(let error) = error {
                    self?.logHandler?.error(message: "Failed to disconnect trackable (\(trackableId)) after receiving invalid message.", error: error)
                }
            }
        }
    }

    // MARK: Utils
    private func performOnWorkingThread(_ operation: @escaping () -> Void) {
        workerQueue.enqueue(
            workRequest: WorkRequest<SubscriberWorkSpecification>(
                workerSpecification: SubscriberWorkSpecification.legacy(callback: operation)
            )
        )
    }

    private func performOnMainThread(_ operation: @escaping () -> Void) {
        DispatchQueue.main.async(execute: operation)
    }
}

extension DefaultSubscriber: AblySubscriberDelegate {
    func ablySubscriber(_ sender: AblySubscriber, didReceivePresenceUpdate presence: Presence) {
        logHandler?.debug(message: "ablySubscriber.didReceivePresenceUpdate. Presence: \(presence)", error: nil)
        enqueue(event: .presenceUpdate(.init(presence: presence)))
    }

    func ablySubscriber(_ sender: AblySubscriber, didChangeClientConnectionState state: ConnectionState) {
        logHandler?.debug(message: "ablySubscriber.didChangeClientConnectionState. Status: \(state)", error: nil)
        enqueue(event: .ablyClientConnectionStateChanged(.init(connectionState: state)))
    }

    func ablySubscriber(_ sender: AblySubscriber, didChangeChannelConnectionState state: ConnectionState) {
        logHandler?.debug(message: "ablySubscriber.didChangeChannelConnectionState. Status: \(state)", error: nil)
            enqueue(event: .ablyChannelConnectionStateChanged(.init(connectionState: state)))
    }

    func ablySubscriber(_ sender: AblySubscriber, didFailWithError error: ErrorInformation) {
        logHandler?.error(message: "ablySubscriber.didFailWithError", error: error)
        enqueue(event: .ablyError(.init(error: error)))
    }

    func ablySubscriber(_ sender: AblySubscriber, didReceiveRawLocation location: LocationUpdate) {
        logHandler?.debug(message: "ablySubscriber.didReceiveRawLocation", error: nil)
        callback(event: .delegateRawLocationReceived(.init(locationUpdate: location)))
    }

    func ablySubscriber(_ sender: AblySubscriber, didReceiveEnhancedLocation location: LocationUpdate) {
        logHandler?.debug(message: "ablySubscriber.didReceiveEnhancedLocation", error: nil)
        callback(event: .delegateEnhancedLocationReceived(.init(locationUpdate: location)))
    }

    func ablySubscriber(_ sender: AblySubscriber, didReceiveResolution resolution: Resolution) {
        logHandler?.debug(message: "ablySubscriber.didReceiveResolution", error: nil)
        callback(event: .delegateResolutionReceived(.init(resolution: resolution)))
        callback(event: .delegateDesiredIntervalReceived(.init(desiredInterval: resolution.desiredInterval)))
    }
}
