import CoreLocation
import Ably
import AblyAssetTrackingCore

public class DefaultAbly: AblyCommon {
    public weak var publisherDelegate: AblyPublisherDelegate?
    public weak var subscriberDelegate: AblySubscriberDelegate?
    
     //log handler used to capture internal events from the Ably-Cocoa, and pass them to LogHandler via `logCallback`
    private let internalARTLogHandler: InternalARTLogHandler = InternalARTLogHandler()
    
    private let logHandler: InternalLogHandler?
    private let client: AblySDKRealtime
    private let connectionConfiguration: ConnectionConfiguration
    let mode: AblyMode
    
    private var channels: [String: AblySDKRealtimeChannel] = [:]

    public required init(factory: AblySDKRealtimeFactory, configuration: ConnectionConfiguration, mode: AblyMode, logHandler: InternalLogHandler?) {
        self.logHandler = logHandler?.addingSubsystem(Self.self)
        let ablySDKSubsystemLogHandler = self.logHandler?.addingSubsystem(.named("ablySDK"))
        internalARTLogHandler.logCallback = { (message, level, error) in
            // We don't add line numbers to messages emitted by ably-cocoa,
            // since it doesn’t expose that information to us through the
            // ARTLog interface. Also, some (but not all) log messages from
            // ably-cocoa already include line number information.
            switch level {
            case .verbose:
                ablySDKSubsystemLogHandler?.verbose(message: message, error: error, file: nil, line: nil)
            case .info:
                ablySDKSubsystemLogHandler?.info(message: message, error: error, file: nil, line: nil)
            case .debug:
                ablySDKSubsystemLogHandler?.debug(message: message, error: error, file: nil, line: nil)
            case .warn:
                ablySDKSubsystemLogHandler?.warn(message: message, error: error, file: nil, line: nil)
            case .error:
                ablySDKSubsystemLogHandler?.error(message: message, error: error, file: nil, line: nil)
            }
        }
        self.client = factory.create(withConfiguration: configuration, logHandler: internalARTLogHandler)
        
        self.mode = mode
        self.connectionConfiguration = configuration
    }

    public func startConnection(completion: @escaping AblyAssetTrackingCore.ResultHandler<Void>) {
        var listener: AblySDKEventListener?

        guard client.connection.state() != ARTRealtimeConnectionState.connected else {
            completion(.success)
            return
        }

        guard client.connection.state() != ARTRealtimeConnectionState.failed else {
            let errorInfo = client.connection.errorInfo() ?? ErrorInformation(code: 0, statusCode: 0, message: "No error reason provided", cause: nil, href: nil)

            completion(.failure(errorInfo))
            return
        }

        /**
         According to the ably spec, connection.on should accept some sort of object with an actual identity, allowing you to do something
         like [connection.off(self)]. This is helpful for us here as we want to detach the listener once the connection comes online.

         However, ably-cocoa does not allow this and accepts a callback function, so we have to do this workaround by maintaining an optional
         reference to the instance returned by the SDK. To ensure that we don't hit any race conditions between the listener being returned
         and the state coming through, a semaphore is used.
         */
        let stateGuard = DispatchSemaphore(value: 1)
        stateGuard.wait()
        listener = client.connection.on { [weak self] stateChange in
            stateGuard.wait()

            defer {
                stateGuard.signal()
            }

            guard let self = self else {
                return
            }

            switch (stateChange.current.toConnectionState()) {
            case .online:
                self.client.connection.off(listener!)
                completion(.success)
            case .failed:
                self.client.connection.off(listener!)
                completion(
                    .failure(
                        ErrorInformation(code: 0, statusCode: 0, message: "Connection failed waiting for start", cause: nil, href: nil)
                    )
                )
            case .closed:
                self.client.connection.off(listener!)
                completion(
                    .failure(
                        ErrorInformation(code: 0, statusCode: 0, message: "Connection closed waiting for start", cause: nil, href: nil)
                    )
                )
            case .offline:
                break
            }
        }

        stateGuard.signal()
        client.connect()
    }
    
    public func connect(
        trackableId: String,
        presenceData: PresenceData,
        useRewind: Bool,
        completion: @escaping ResultHandler<Void>
    ) {
        guard channels[trackableId] == nil else {
            completion(.success)
            
            return
        }
        
        let options = ARTRealtimeChannelOptions()
        options.modes = [.presenceSubscribe, .presence]
        
        if useRewind {
            options.params = ["rewind": "1"]
        }
        
        if mode.contains(.subscribe) {
            options.modes.insert(.subscribe)
        }
        
        if mode.contains(.publish) {
            options.modes.insert(.publish)
        }
        
        let channel = client.channels.getChannelFor(trackingId: trackableId, options: options)
        
        if [.detached, .failed].contains(channel.state) {
            logHandler?.debug(message: "Channel for trackable \(trackableId) is in state \(channel.state); attaching", error: nil)
            channel.attach { [weak self] error in
                guard let self = self else { return }
                if let error = error {
                    self.logHandler?.error(message: "Failed to attach to channel for trackable \(trackableId)", error: error)
                    completion(.failure(error.toErrorInformation()))
                    return
                }
                self.enterPresence(trackableId: trackableId, presenceData: presenceData, channel: channel, completion: completion)
            }
        } else {
            enterPresence(trackableId: trackableId, presenceData: presenceData, channel: channel, completion: completion)
        }
    }
    
    private func enterPresence(
        trackableId: String,
        presenceData: PresenceData,
        channel: AblySDKRealtimeChannel,
        completion: @escaping ResultHandler<Void>
    ) {
        let presenceDataJSON = self.presenceDataJSON(data: presenceData)
                
        channel.presence.enter(presenceDataJSON) { [weak self] error in
            guard let self = self else { return }
            self.logHandler?.debug(message: "Entered a channel [id: \(trackableId)] presence successfully", error: nil)
            
            let presenceEnterSuccess = { [weak self] in
                self?.channels[trackableId] = channel
                completion(.success)
            }
            
            let presenceEnterTerminalFailure = { [weak self] (error: ARTErrorInfo) in
                self?.logHandler?.error(message: "Error while joining a channel [id: \(trackableId)] presence", error: error)
                completion(.failure(error.toErrorInformation()))
            }
            
            guard let error = error else {
                presenceEnterSuccess()
                return
            }
            
            if error.code == ARTErrorCode.operationNotPermittedWithProvidedCapability.rawValue && self.connectionConfiguration.usesTokenAuth {
                self.logHandler?.debug(message: "Failed to enter presence on channel [id: \(trackableId)], requesting Ably SDK to re-authorize", error: error)
                self.client.auth.authorize { [weak self] _, error in
                    guard let self = self
                    else { return }
                    if let error = error {
                        self.logHandler?.error(message: "Error calling authorize: \(String(describing: error))", error: error)
                        completion(.failure(ErrorInformation(error: error)))
                    } else {
                        // The channel is currently in the FAILED state, so an immediate attempt to enter presence would fail. We need to first of all explicitly attach to the channel to get it out of the FAILED state (if we _were_ able to attempt to enter presence, doing so would attach to the channel anyway, so we’re not doing anything surprising here).
                        self.logHandler?.debug(message: "Authorize succeeded, attaching to channel so that we can retry presence enter", error: nil)

                        channel.attach { error in
                            if let error = error {
                                self.logHandler?.error(message: "Error attaching to channel [id: \(trackableId)]: \(String(describing: error))", error: error)
                                completion(.failure(ErrorInformation(error: error)))
                            } else {
                                self.logHandler?.debug(message: "Channel attach succeeded, retrying presence enter", error: nil)
                                channel.presence.enter(presenceDataJSON) { error in
                                    guard let error = error else {
                                        presenceEnterSuccess()
                                        return
                                    }
                                    presenceEnterTerminalFailure(error)
                                }
                            }
                        }
                    }
                }
            } else {
                presenceEnterTerminalFailure(error)
            }
        }
    }
    
    public func disconnect(trackableId: String, presenceData: PresenceData?, completion: @escaping ResultHandler<Bool>) {
        guard let channelToRemove = channels[trackableId] else {
            completion(.success(false))
            return
        }
        
        let presenceDataJSON: Any?
        if let presenceData = presenceData {
            presenceDataJSON = self.presenceDataJSON(data: presenceData)
        } else {
            presenceDataJSON = nil
        }
        
        channelToRemove.presence.leave(presenceDataJSON) { [weak self] error in
            guard let error = error else {
                self?.logHandler?.debug(message: "Left channel [id: \(trackableId)] presence successfully", error: nil)
                channelToRemove.presence.unsubscribe()
                channelToRemove.unsubscribe()
                
                channelToRemove.detach { [weak self] detachError in
                    guard let error = detachError else {
                        self?.channels.removeValue(forKey: trackableId)
                        completion(.success(true))
                        
                        return
                    }
                    self?.logHandler?.error(message: "Error during detach channel [id: \(trackableId)] presence", error: error)
                    completion(.failure(error.toErrorInformation()))
                }
                
                return
            }
            self?.logHandler?.error(message: "Error while leaving the channel [id: \(trackableId)] presence", error: error)
            completion(.failure(error.toErrorInformation()))
        }
    }
    
    public func close(presenceData: PresenceData, completion: @escaping ResultHandler<Void>) {
        let closingDispatchGroup = DispatchGroup()
        
        for (trackableId, _) in self.channels {
            closingDispatchGroup.enter()
            self.disconnect(trackableId: trackableId, presenceData: presenceData) {[weak self] result in
                switch result {
                case .success(let wasPresent):
                    self?.logHandler?.info(message: "Trackable \(trackableId) removed successfully. Was present \(wasPresent)", error: nil)
                case .failure(let error):
                    self?.logHandler?.error(message: "Removing trackable \(trackableId) failed", error: error)
                }
                closingDispatchGroup.leave()
            }
        }
        
        closingDispatchGroup.notify(queue: .main) { [weak self] in
            self?.logHandler?.info(message: "All trackables removed.", error: nil)
            self?.stopConnection(completion: completion)
        }
    }

    
    public func subscribeForAblyStateChange() {
        client.connection.on { [weak self] stateChange in
            guard let self = self else {
                return
            }
            
            let receivedConnectionState = stateChange.current.toConnectionState()
            self.logHandler?.debug(message: "Connection to Ably changed. New state: \(receivedConnectionState.description)", error: nil)
            
            self.publisherDelegate?.ablyPublisher(
                self,
                didChangeConnectionState: receivedConnectionState
            )
            self.subscriberDelegate?.ablySubscriber(
                self,
                didChangeClientConnectionState: receivedConnectionState
            )
        }
    }
    
    public func subscribeForPresenceMessages(trackable: Trackable) {
        guard let channel = channels[trackable.id] else {
            return
        }
        
        channel.presence.get { [weak self] messages, error in
            self?.logHandler?.debug(message: "Get presence update from channel", error: nil)
            guard let self = self, let messages = messages else {
                return
            }
            for message in messages {
                self.handleARTPresenceMessage(message, for: trackable)
            }
        }
        channel.presence.subscribe { [weak self] message in
            guard let self = self else { return }
            
            self.logHandler?.debug(message: "Received presence update from channel", error: nil)
            self.handleARTPresenceMessage(message, for: trackable)
        }
    }
    
    private func handleARTPresenceMessage(_ message: ARTPresenceMessage, for trackable: Trackable) {
        guard
            let jsonData = message.data,
            let data: PresenceData = try? PresenceData.fromAny(jsonData),
            let clientId = message.clientId
        else { return }
        
        let presence = Presence(
            action: message.action.toPresenceAction(),
            type: data.type.toPresenceType()
        )
        
        // AblySubscriber delegate
        self.subscriberDelegate?.ablySubscriber(self, didReceivePresenceUpdate: presence)
        self.subscriberDelegate?.ablySubscriber(self, didChangeChannelConnectionState: presence.action.toConnectionState())
        
        // Deleagate `Publisher` resolution if present in PresenceData
        if let resolution = data.resolution, data.type == .publisher {
            self.subscriberDelegate?.ablySubscriber(self, didReceiveResolution: resolution)
        }
        
        // AblyPublisher delegate
        self.publisherDelegate?.ablyPublisher(
            self,
            didReceivePresenceUpdate: presence,
            forTrackable: trackable,
            presenceData: data,
            clientId: clientId
        )
    }
    
    public func subscribeForChannelStateChange(trackable: Trackable) {
        guard let channel = channels[trackable.id] else {
            return
        }
        
        channel.on { [weak self] stateChange in
            guard let self = self else {
                return
            }
            
            let receivedConnectionState = stateChange.current.toConnectionState()
            self.logHandler?.debug(message: "Channel state for trackable \(trackable.id) changed. New state: \(receivedConnectionState.description)", error: nil)
            self.publisherDelegate?.ablyPublisher(self, didChangeChannelConnectionState: receivedConnectionState, forTrackable: trackable)
        }
    }
    
    public func updatePresenceData(trackableId: String, presenceData: PresenceData, completion: ResultHandler<Void>?) {
        guard let channel = channels[trackableId] else {
            return
        }
        
        channel.presence.update(presenceDataJSON(data: presenceData)) { error in
            if let error = error {
                completion?(.failure(error.toErrorInformation()))
            } else {
                completion?(.success)
            }
        }
    }
    
    public func stopConnection(completion: @escaping ResultHandler<Void>) {
        var listener: AblySDKEventListener?

        /**
         According to the ably spec, connection.on should accept some sort of object with an actual identity, allowing you to do something
         like [connection.off(self)]. This is helpful for us here as we want to detach the listener once the connection comes online.

         However, ably-cocoa does not allow this and accepts a callback function, so we have to do this workaround by maintaining an optional
         reference to the instance returned by the SDK. To ensure that we don't hit any race conditions between the listener being returned
         and the state coming through, a semaphore is used.
         */
        let stateChangeGuard = DispatchSemaphore(value: 1)
        stateChangeGuard.wait()
        listener = client.connection.on {[weak self] stateChange in
            stateChangeGuard.wait()

            defer {
                stateChangeGuard.signal()
            }

            guard let self = self else {
                return
            }

            switch stateChange.current {
            case .closed:
                self.logHandler?.info(message: "Ably connection closed successfully.", error: nil)
                self.client.connection.off(listener!)
                completion(.success)
            case .failed:
                let errorInfo = stateChange.reason?.toErrorInformation() ?? ErrorInformation(type: .publisherError(errorMessage: "Cannot close connection"))
                self.logHandler?.error(message: "Error while closing connection", error: errorInfo)
                self.client.connection.off(listener!)
                completion(.failure(errorInfo))
            default:
                break
            }
        }

        stateChangeGuard.signal()
        client.close()
    }
}

extension DefaultAbly: AblySubscriber {
    public func subscribeForRawEvents(trackableId: String) {
        guard let channel = channels[trackableId] else {
            return
        }
        
        channel.subscribe(EventName.raw.rawValue) { [weak self] message in
            self?.logHandler?.debug(message: "Received raw location message from channel", error: nil)
            self?.handleLocationUpdateResponse(forEvent: .raw, messageData: message.data)
        }
    }
    
    public func subscribeForEnhancedEvents(trackableId: String) {
        guard let channel = channels[trackableId] else {
            return
        }
        
        channel.subscribe(EventName.enhanced.rawValue) { [weak self] message in
            self?.logHandler?.debug(message: "Received enhanced location message from channel", error: nil)
            self?.handleLocationUpdateResponse(forEvent: .enhanced, messageData: message.data)
        }
    }
    
    private func handleLocationUpdateResponse(forEvent event: EventName, messageData: Any?) {
        guard let json = messageData as? String else {
            let errorInformation = ErrorInformation(code: ErrorCode.invalidMessage.rawValue, statusCode: 400, message: "Received a non-string message for \(event.rawValue) event: \(String(describing: messageData))", cause: nil, href: nil)
            logHandler?.error(message: "Received a non-string message for \(event.rawValue) event: \(String(describing: messageData))", error: errorInformation)
            subscriberDelegate?.ablySubscriber(self, didFailWithError: errorInformation)
            
            return
        }
        
        do {
            switch event {
            case .raw:
                let message: RawLocationUpdateMessage = try RawLocationUpdateMessage.fromJSONString(json)
                let locationUpdate = RawLocationUpdate(location: message.location.toLocation())
                locationUpdate.skippedLocations = message.skippedLocations.map { $0.toLocation() }
                subscriberDelegate?.ablySubscriber(self, didReceiveRawLocation: locationUpdate)
            case .enhanced:
                let message: EnhancedLocationUpdateMessage = try EnhancedLocationUpdateMessage.fromJSONString(json)
                let locationUpdate = EnhancedLocationUpdate(location: message.location.toLocation())
                locationUpdate.skippedLocations = message.skippedLocations.map { $0.toLocation() }
                subscriberDelegate?.ablySubscriber(self, didReceiveEnhancedLocation: locationUpdate)
            }
        } catch let error {
            guard let errorInformation = error as? ErrorInformation else {
                let errorInformation = ErrorInformation(code: ErrorCode.invalidMessage.rawValue, statusCode: 400, message: "Received a malformed message for \(event.rawValue) event", cause: error, href: nil)
                logHandler?.error(message: "Received a malformed message for \(event.rawValue) event", error: errorInformation)
                subscriberDelegate?.ablySubscriber(self, didFailWithError: errorInformation)
                return
            }
            logHandler?.error(message: "Cannot parse message data for \(event.rawValue) event:", error: errorInformation)
            subscriberDelegate?.ablySubscriber(self, didFailWithError: errorInformation)
            
            return
        }
    }
    
    private func presenceDataJSON(data: PresenceData) -> String {
        do {
            return try data.toJSONString()
        } catch {
            fatalError("Can't encode presenceData. Reason: \(error)")
        }
    }
}

extension DefaultAbly: AblyPublisher {
    public func sendEnhancedLocation(
        locationUpdate: EnhancedLocationUpdate,
        trackable: Trackable,
        completion: ResultHandler<Void>?
    ) {
        
        guard let channel = channels[trackable.id] else {
            let errorInformation = ErrorInformation(type: .publisherError(errorMessage: "Attempt to send location while not tracked channel"))
            logHandler?.error(message: "Attempting to send a location while channel is not tracked", error: errorInformation)
            completion?(.failure(errorInformation))
            
            return
        }
        
        let message: ARTMessage
        do {
            message = try createARTMessage(for: locationUpdate)
        } catch {
            let errorInformation = ErrorInformation(
                type: .publisherError(errorMessage: "Cannot create location update message. Underlying error: \(error)")
            )
            logHandler?.error(message: "Cannot create location update message. Underlying error", error: error)
            publisherDelegate?.ablyPublisher(self, didFailWithError: errorInformation)
            
            return
        }
        
        channel.publish([message]) { [weak self] error in
            guard let self = self else {
                return
            }
            
            if let error = error {
                self.logHandler?.error(message: "Cannot publish a message to channel [trackable id: \(trackable.id)]", error: error)
                self.publisherDelegate?.ablyPublisher(self, didFailWithError: error.toErrorInformation())
                
                return
            }
            
            self.publisherDelegate?.ablyPublisher(self, didChangeChannelConnectionState: .online, forTrackable: trackable)
            completion?(.success)
        }
    }
    
    public func sendRawLocation(
        location: RawLocationUpdate,
        trackable: Trackable,
        completion: ResultHandler<Void>?
    ) {
        guard let channel = channels[trackable.id] else {
            completion?(.success)
            
            return
        }
        
        do {
            let geoJson = try RawLocationUpdateMessage(locationUpdate: location)
            let data = try geoJson.toJSONString()
            let message = ARTMessage(name: EventName.raw.rawValue, data: data)
            
            channel.publish([message]) {[weak self] error in
                guard let self = self
                else { return }
                
                if let error = error {
                    self.logHandler?.error(message: "Cannot publish a message to channel [trackable id: \(trackable.id)]", error: error)
                    self.publisherDelegate?.ablyPublisher(self, didFailWithError: error.toErrorInformation())
                } else {
                    completion?(.success)
                }
            }
        } catch {
            let errorInformation = ErrorInformation(
                type: .publisherError(errorMessage: "Cannot create location update message. Underlying error: \(error)")
            )
            self.logHandler?.error(message: "Cannot create location update message.", error: errorInformation)
            publisherDelegate?.ablyPublisher(self, didFailWithError: errorInformation)
        }
    }
    
    private func createARTMessage(for locationUpdate: EnhancedLocationUpdate) throws -> ARTMessage {
        let geoJson = try EnhancedLocationUpdateMessage(locationUpdate: locationUpdate)
        let data = try geoJson.toJSONString()
        
        return ARTMessage(name: EventName.enhanced.rawValue, data: data)
    }
}

fileprivate extension ConnectionConfiguration {
    var usesTokenAuth: Bool {
        return authCallback != nil
    }
}
