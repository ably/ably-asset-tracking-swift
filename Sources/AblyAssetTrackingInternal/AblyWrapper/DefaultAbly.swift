import CoreLocation
import Ably
import AblyAssetTrackingCore
import Logging

public class DefaultAbly: AblyCommon {
    
    public weak var publisherDelegate: AblyPublisherServiceDelegate?
    public weak var subscriberDelegate: AblySubscriberServiceDelegate?
    
    private let internalARTLogHandler: InternalARTLogHandler = InternalARTLogHandler()
    
    private let logHandler: AblyLogHandler?
    private let client: AblySDKRealtime
    private let connectionConfiguration: ConnectionConfiguration
    let mode: AblyMode
    
    private var channels: [String: AblySDKRealtimeChannel] = [:]

    public required init(factory: AblySDKRealtimeFactory, configuration: ConnectionConfiguration, mode: AblyMode, logHandler: AblyLogHandler?) {
        self.logHandler = logHandler
        internalARTLogHandler.logCallback = {  (message, level, error) in
            logHandler?.logMessage(level: level, message: message, error: error)
        }
        self.client = factory.create(withConfiguration: configuration, logHandler: internalARTLogHandler)
        
        self.mode = mode
        self.connectionConfiguration = configuration
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
        
        let presenceDataJSON = self.presenceDataJSON(data: presenceData)
                
        channel.presence.enter(presenceDataJSON) { [weak self] error in
            guard let self = self else { return }
            
            let presenceEnterSuccess = { [weak self] in
                guard let self = self else { return }
                self.channels[trackableId] = channel
                completion(.success)
            }
            
            let presenceEnterTerminalFailure = {(error: ARTErrorInfo) in
                completion(.failure(error.toErrorInformation()))
            }
            
            guard let error = error else {
                presenceEnterSuccess()
                return
            }
            
            if error.code == ARTErrorCode.operationNotPermittedWithProvidedCapability.rawValue && self.connectionConfiguration.usesTokenAuth {
                self.client.auth.authorize { _, error in
                    if let error = error {
                        completion(.failure(ErrorInformation(error: error)))
                    } else {
                        // The channel is currently in the FAILED state, so an immediate attempt to enter presence would fail. We need to first of all explicitly attach to the channel to get it out of the FAILED state (if we _were_ able to attempt to enter presence, doing so would attach to the channel anyway, so we’re not doing anything surprising here).
                        channel.attach { error in
                            if let error = error {
                                completion(.failure(ErrorInformation(error: error)))
                            } else {
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
    
    public func disconnect(trackableId: String, presenceData: PresenceData, completion: @escaping ResultHandler<Bool>) {
        guard let channelToRemove = channels[trackableId] else {
            completion(.success(false))
            
            return
        }
        
        channelToRemove.presence.leave(presenceDataJSON(data: presenceData)) { [weak self] error in
            guard let error = error else {
                channelToRemove.presence.unsubscribe()
                channelToRemove.unsubscribe()
                
                channelToRemove.detach { [weak self] detachError in
                    guard let error = detachError else {
                        self?.channels.removeValue(forKey: trackableId)
                        completion(.success(true))
                        
                        return
                    }
                    completion(.failure(error.toErrorInformation()))
                }
                
                return
            }
            completion(.failure(error.toErrorInformation()))
        }
    }
    
    public func close(presenceData: PresenceData, completion: @escaping ResultHandler<Void>) {
        let closingDispatchGroup = DispatchGroup()
        
        for (trackableId, _) in self.channels {
            closingDispatchGroup.enter()
            self.disconnect(trackableId: trackableId, presenceData: presenceData) { _ in
                closingDispatchGroup.leave()
            }
        }
        
        closingDispatchGroup.notify(queue: .main) { [weak self] in
            self?.closeConnection(completion: completion)
        }
    }
    
    public func subscribeForAblyStateChange() {
        client.connection.on { [weak self] stateChange in
            guard let self = self else {
                return
            }
            
            let receivedConnectionState = stateChange.current.toConnectionState()
            
            self.publisherDelegate?.publisherService(
                sender: self,
                didChangeConnectionState: receivedConnectionState
            )
            self.subscriberDelegate?.subscriberService(
                sender: self,
                didChangeClientConnectionState: receivedConnectionState
            )
        }
    }
    
    public func subscribeForPresenceMessages(trackable: Trackable) {
        guard let channel = channels[trackable.id] else {
            return
        }
        
        channel.presence.get { [weak self] messages, error in
            guard let self = self, let messages = messages else {
                return
            }
            for message in messages {
                self.handleARTPresenceMessage(message, for: trackable)
            }
        }
        channel.presence.subscribe { [weak self] message in
            guard let self = self else { return }
            
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
        self.subscriberDelegate?.subscriberService(sender: self, didReceivePresenceUpdate: presence)
        self.subscriberDelegate?.subscriberService(sender: self, didChangeChannelConnectionState: presence.action.toConnectionState())
        
        // Deleagate `Publisher` resolution if present in PresenceData
        if let resolution = data.resolution, data.type == .publisher {
            self.subscriberDelegate?.subscriberService(sender: self, didReceiveResolution: resolution)
        }
        
        // AblyPublisher delegate
        self.publisherDelegate?.publisherService(
            sender: self,
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
            
            self.publisherDelegate?.publisherService(sender: self, didChangeChannelConnectionState: receivedConnectionState, forTrackable: trackable)
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
    
    private func closeConnection(completion: @escaping ResultHandler<Void>) {
        client.connection.on { stateChange in
            switch stateChange.current {
            case .closed:
                completion(.success)
            case .failed:
                let errorInfo = stateChange.reason?.toErrorInformation() ?? ErrorInformation(type: .publisherError(errorMessage: "Cannot close connection"))
                completion(.failure(errorInfo))
            default:
                return
            }
        }
        
        client.close()
    }
}

extension DefaultAbly: AblySubscriber {
    public func subscribeForRawEvents(trackableId: String) {
        guard let channel = channels[trackableId] else {
            return
        }
        
        channel.subscribe(EventName.raw.rawValue) { [weak self] message in
            self?.handleLocationUpdateResponse(forEvent: .raw, messageData: message.data)
        }
    }
    
    public func subscribeForEnhancedEvents(trackableId: String) {
        guard let channel = channels[trackableId] else {
            return
        }
        
        channel.subscribe(EventName.enhanced.rawValue) { [weak self] message in
            self?.handleLocationUpdateResponse(forEvent: .enhanced, messageData: message.data)
        }
    }
    
    private func handleLocationUpdateResponse(forEvent event: EventName, messageData: Any?) {
        guard let json = messageData as? String else {
            let errorInformation = ErrorInformation(
                type: .subscriberError(
                    errorMessage: "Cannot parse message data for \(event.rawValue) event: \(String(describing: messageData))"
                )
            )
            subscriberDelegate?.subscriberService(sender: self, didFailWithError: errorInformation)
            
            return
        }
        
        do {
            switch event {
            case .raw:
                let message: RawLocationUpdateMessage = try RawLocationUpdateMessage.fromJSONString(json)
                let locationUpdate = RawLocationUpdate(location: message.location.toLocation())
                locationUpdate.skippedLocations = message.skippedLocations.map { $0.toLocation() }
                subscriberDelegate?.subscriberService(sender: self, didReceiveRawLocation: locationUpdate)
            case .enhanced:
                let message: EnhancedLocationUpdateMessage = try EnhancedLocationUpdateMessage.fromJSONString(json)
                let locationUpdate = EnhancedLocationUpdate(location: message.location.toLocation())
                locationUpdate.skippedLocations = message.skippedLocations.map { $0.toLocation() }
                subscriberDelegate?.subscriberService(sender: self, didReceiveEnhancedLocation: locationUpdate)
            }
        } catch let error {
            guard let errorInformation = error as? ErrorInformation else {
                subscriberDelegate?.subscriberService(sender: self, didFailWithError: ErrorInformation(error: error))
                
                return
            }
            
            subscriberDelegate?.subscriberService(sender: self, didFailWithError: errorInformation)
            
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
            publisherDelegate?.publisherService(sender: self, didFailWithError: errorInformation)
            
            return
        }
        
        channel.publish([message]) { [weak self] error in
            guard let self = self else {
                return
            }
            
            if let error = error {
                self.publisherDelegate?.publisherService(sender: self, didFailWithError: error.toErrorInformation())
                
                return
            }
            
            self.publisherDelegate?.publisherService(sender: self, didChangeChannelConnectionState: .online, forTrackable: trackable)
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
            
            channel.publish([message]) { error in
                if let error = error {
                    self.publisherDelegate?.publisherService(sender: self, didFailWithError: error.toErrorInformation())
                } else {
                    completion?(.success)
                }
            }
        } catch {
            let errorInformation = ErrorInformation(
                type: .publisherError(errorMessage: "Cannot create location update message. Underlying error: \(error)")
            )
            publisherDelegate?.publisherService(sender: self, didFailWithError: errorInformation)
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
