import CoreLocation
import Ably
import AblyAssetTrackingCore

public class DefaultAbly: AblyCommon {
    enum AblyError : Error {
        case connectionError(errorInfo: ARTErrorInfo)
    }

    public weak var publisherDelegate: AblyPublisherDelegate?
    public weak var subscriberDelegate: AblySubscriberDelegate?
    
     //log handler used to capture internal events from the Ably-Cocoa, and pass them to AblyLogHandler via `logCallback`
    private let internalARTLogHandler: InternalARTLogHandler = InternalARTLogHandler()
    
    private let logHandler: AblyLogHandler?
    private let client: AblySDKRealtime
    private let connectionConfiguration: ConnectionConfiguration
    let mode: AblyMode
    
    private var channels: [String: AblySDKRealtimeChannel] = [:]

    public required init(factory: AblySDKRealtimeFactory, configuration: ConnectionConfiguration, mode: AblyMode, logHandler: AblyLogHandler?) {
        self.logHandler = logHandler
        internalARTLogHandler.logCallback = { (message, level, error) in
            switch level {
            case .verbose:
                logHandler?.v(message: message, error: error)
            case .info:
                logHandler?.i(message: message, error: error)
            case .debug:
                logHandler?.d(message: message, error: error)
            case .warn:
                logHandler?.w(message: message, error: error)
            case .error:
                logHandler?.e(message: message, error: error)
            }
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
            self.logHandler?.d(message: "\(String(describing: Self.self)): Entered a channel [id: \(trackableId)] presence successfully", error: nil)
            
            let presenceEnterSuccess = { [weak self] in
                self?.channels[trackableId] = channel
                completion(.success)
            }
            
            let presenceEnterTerminalFailure = { [weak self] (error: ARTErrorInfo) in
                self?.logHandler?.e(message: "\(String(describing: Self.self)): Error while joining a channel [id: \(trackableId)] presence", error: error)
                completion(.failure(error.toErrorInformation()))
            }
            
            guard let error = error else {
                presenceEnterSuccess()
                return
            }
            
            if error.code == ARTErrorCode.operationNotPermittedWithProvidedCapability.rawValue && self.connectionConfiguration.usesTokenAuth {
                self.logHandler?.d(message: "\(String(describing: Self.self)): Failed to enter presence on channel [id: \(trackableId)], requesting Ably SDK to re-authorize", error: error)
                self.client.auth.authorize { [weak self] _, error in
                    guard let self = self
                    else { return }
                    if let error = error {
                        self.logHandler?.e(message: "\(String(describing: Self.self)): Error calling authorize: \(String(describing: error))", error: error)
                        completion(.failure(ErrorInformation(error: error)))
                    } else {
                        // The channel is currently in the FAILED state, so an immediate attempt to enter presence would fail. We need to first of all explicitly attach to the channel to get it out of the FAILED state (if we _were_ able to attempt to enter presence, doing so would attach to the channel anyway, so we’re not doing anything surprising here).
                        self.logHandler?.d(message: "\(String(describing: Self.self)): Authorize succeeded, attaching to channel so that we can retry presence enter", error: nil)

                        channel.attach { error in
                            if let error = error {
                                self.logHandler?.e(message: "Error attaching to channel [id: \(trackableId)]: \(String(describing: error))", error: error)
                                completion(.failure(ErrorInformation(error: error)))
                            } else {
                                self.logHandler?.d(message: "\(String(describing: Self.self)): Channel attach succeeded, retrying presence enter", error: nil)
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

        do {
            try performChannelOperationWithRetry(channel: channelToRemove, operation: { channel in
                guard let presenceData = presenceData else {
                    return
                }

                try disconnectChannel(channel: channel, presenceData: presenceData)
            })
            
            channels.removeValue(forKey: trackableId)
            completion(.success(true))
        }catch AblyError.connectionError(let errorInfo){
            completion(.failure(errorInfo.toErrorInformation()))
        }catch{
            completion(.failure(ErrorInformation(error: AblyError.connectionError(errorInfo: ARTErrorInfo.create(withCode: 100_000, message: "Unknown error while disconnecting")))))
        }
    }
    
    private func disconnectChannel(channel:AblySDKRealtimeChannel, presenceData: PresenceData) throws{
        leavePresence(channel: channel, presenceData: presenceData) { leaveError in
            if let leaveError = leaveError {
                throw AblyError.connectionError(errorInfo: leaveError)
            }
            
            channel.unsubscribe()
            channel.presence.unsubscribe()
            self.detachFromChannel(channel: channel) { detachError in
                guard let error = detachError else { return }
                throw AblyError.connectionError(errorInfo: error)
            }
        }
    }
    
    private func leavePresence(channel:AblySDKRealtimeChannel, presenceData: PresenceData?, completion : @escaping (ARTErrorInfo?) throws -> Void){
        let presenceDataJSON: Any?
        if let presenceData = presenceData {
            presenceDataJSON = self.presenceDataJSON(data: presenceData)
        } else {
            presenceDataJSON = nil
        }
        
         channel.presence.leave(presenceDataJSON){ errorInfo in
             //This is to maintain closure signature
             do{
                 try completion(errorInfo)
             }catch{}
        }

    }
    
    private func detachFromChannel(channel:AblySDKRealtimeChannel, completion : @escaping (ARTErrorInfo?) throws -> Void) {
        channel.detach { errorInfo in
            do{
                try completion(errorInfo)
            }catch{}
        }
    }

    /**
     * Performs the [operation] and if a "connection resume" exception is thrown it waits for the [channel] to
     * reconnect and retries the [operation], otherwise it rethrows the exception. If the [operation] fails for
     * the second time the exception is rethrown no matter if it was the "connection resume" exception or not.
     */
    private func performChannelOperationWithRetry(channel:AblySDKRealtimeChannel, operation : (AblySDKRealtimeChannel) throws ->Void) throws {
      do {
          logHandler?.w(message: "Trying to perform an operation on a suspended channel \(channel.name), waiting for the channel to be reconnected", error: nil)
          try waitForChannelReconnection(channel: channel)
          try operation(channel)
      } catch  AblyError.connectionError(let errorInfo) {
           if errorInfo.isConnectionResumeException(){
            
               logHandler?.w(message: "Connection resume failed for channel \(channel), waiting for the channel to be reconnected",
                       error: errorInfo
               )

               do {
                   try waitForChannelReconnection(channel: channel)
                   try operation(channel)
               }catch AblyError.connectionError(let secondError){
                   logHandler?.w(message: "Retrying the operation on channel \(channel.name) has failed for the second time",
                                          error: secondError
                                      )
                   throw AblyError.connectionError(errorInfo: secondError)
               }
           }else {
               throw AblyError.connectionError(errorInfo: errorInfo)
           }
      }
    }

    /**
     * Waits for the [channel] to change to the [ChannelState.attached] state.
     * If this doesn't happen during the next [timeoutInMs] milliseconds, then an exception is thrown.
     */
    private func waitForChannelReconnection(channel:AblySDKRealtimeChannel, timeoutInMs:Int = 10_000) throws{
        guard channel.state.toConnectionState() != .online else{
            return
        }
        let blockingDispatchGroup = DispatchGroup()
        blockingDispatchGroup.enter()
        channel.on { stateChange in
            if (stateChange.current.toConnectionState() == .online){
                blockingDispatchGroup.leave()
            }
            
        }
        let timeout: DispatchTime = .now() + .seconds(timeoutInMs / 1000)
        
        let result = blockingDispatchGroup.wait(timeout: timeout)
        
        if (result == .timedOut){
            throw AblyError.connectionError(errorInfo: ARTErrorInfo.create(withCode: 100000, message: "Timeout was thrown when waiting for channel to attach"))
        }
    }
    
    
    public func close(presenceData: PresenceData, completion: @escaping ResultHandler<Void>) {
        let closingDispatchGroup = DispatchGroup()
        
        for (trackableId, _) in self.channels {
            closingDispatchGroup.enter()
            self.disconnect(trackableId: trackableId, presenceData: presenceData) {[weak self] result in
                switch result {
                case .success(let wasPresent):
                    self?.logHandler?.i(message: "\(String(describing: Self.self)): Trackable \(trackableId) removed successfully. Was present \(wasPresent)", error: nil)
                case .failure(let error):
                    self?.logHandler?.e(message: "\(String(describing: Self.self)): Removing trackable \(trackableId) failed", error: error)
                }
                closingDispatchGroup.leave()
            }
        }
        
        closingDispatchGroup.notify(queue: .main) { [weak self] in
            self?.logHandler?.i(message: "\(String(describing: Self.self)): All trackables removed.", error: nil)
            self?.closeConnection(completion: completion)
        }
    }
    
    public func subscribeForAblyStateChange() {
        client.connection.on { [weak self] stateChange in
            guard let self = self else {
                return
            }
            
            let receivedConnectionState = stateChange.current.toConnectionState()
            self.logHandler?.d(message: "\(String(describing: Self.self)): Connection to Ably changed. New state: \(receivedConnectionState.description)", error: nil)
            
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
            self?.logHandler?.d(message: "\(String(describing: Self.self)): Get presence update from channel", error: nil)
            guard let self = self, let messages = messages else {
                return
            }
            for message in messages {
                self.handleARTPresenceMessage(message, for: trackable)
            }
        }
        channel.presence.subscribe { [weak self] message in
            guard let self = self else { return }
            
            self.logHandler?.d(message: "\(String(describing: Self.self)): Received presence update from channel", error: nil)
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
            self.logHandler?.d(message: "\(String(describing: Self.self)): Channel state for trackable \(trackable.id) changed. New state: \(receivedConnectionState.description)", error: nil)
            self.publisherDelegate?.ablyPublisher(self, didChangeChannelConnectionState: receivedConnectionState, forTrackable: trackable)
        }
    }
    
    private func updatePresenceData(channel: AblySDKRealtimeChannel, presenceData: PresenceData, _ completion: ResultHandler<Void>?) {
        channel.presence.update(presenceDataJSON(data: presenceData)) { error in
            if let error = error {
                completion?(.failure(error.toErrorInformation()))
            } else {
                completion?(.success)
            }
        }
    }
    
    public func updatePresenceData(trackableId: String, presenceData: PresenceData, completion: ResultHandler<Void>?) {
        guard let channel = channels[trackableId] else {
            return
        }
        do{
           try performChannelOperationWithRetry(channel: channel) { channel in
               updatePresenceData(channel: channel, presenceData: presenceData, completion)
            }
        } catch AblyError.connectionError(let errorInfo){
            completion?(.failure(errorInfo.toErrorInformation()))
        }catch{
            let artErrorInfo = ARTErrorInfo.create(from: error)
            completion?(.failure(artErrorInfo.toErrorInformation()))
        }
    }
    
    private func closeConnection(completion: @escaping ResultHandler<Void>) {
        client.connection.on {[weak self] stateChange in
            switch stateChange.current {
            case .closed:
                self?.logHandler?.i(message: "\(String(describing: Self.self)): Ably connection closed successfully.", error: nil)
                completion(.success)
            case .failed:
                let errorInfo = stateChange.reason?.toErrorInformation() ?? ErrorInformation(type: .publisherError(errorMessage: "Cannot close connection"))
                self?.logHandler?.e(message: "\(String(describing: Self.self)): Error while closing connection", error: errorInfo)
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
            self?.logHandler?.d(message: "\(String(describing: Self.self)): Received raw location message from channel", error: nil)
            self?.handleLocationUpdateResponse(forEvent: .raw, messageData: message.data)
        }
    }
    
    public func subscribeForEnhancedEvents(trackableId: String) {
        guard let channel = channels[trackableId] else {
            return
        }
        
        channel.subscribe(EventName.enhanced.rawValue) { [weak self] message in
            self?.logHandler?.d(message: "\(String(describing: Self.self)): Received enhanced location message from channel", error: nil)
            self?.handleLocationUpdateResponse(forEvent: .enhanced, messageData: message.data)
        }
    }
    
    private func handleLocationUpdateResponse(forEvent event: EventName, messageData: Any?) {
        guard let json = messageData as? String else {
            let errorInformation = ErrorInformation(code: ErrorCode.invalidMessage.rawValue, statusCode: 400, message: "Received a non-string message for \(event.rawValue) event: \(String(describing: messageData))", cause: nil, href: nil)
            logHandler?.e(message: "\(String(describing: Self.self)): Received a non-string message for \(event.rawValue) event: \(String(describing: messageData))", error: errorInformation)
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
                logHandler?.e(message: "\(String(describing: Self.self)): Received a malformed message for \(event.rawValue) event", error: errorInformation)
                subscriberDelegate?.ablySubscriber(self, didFailWithError: errorInformation)
                return
            }
            logHandler?.e(message: "\(String(describing: Self.self)): Cannot parse message data for \(event.rawValue) event:", error: errorInformation)
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
            logHandler?.e(message: "\(String(describing: Self.self)): Attempting to send a location while channel is not tracked", error: errorInformation)
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
            logHandler?.e(message: "\(String(describing: Self.self)): Cannot create location update message. Underlying error", error: error)
            publisherDelegate?.ablyPublisher(self, didFailWithError: errorInformation)
            
            return
        }

        sendMessageForTrackable(channel: channel, message: message, trackable: trackable, completion: completion)
    }

    private func sendMessageForTrackable(channel: AblySDKRealtimeChannel, message: ARTMessage, trackable: Trackable, completion: ResultHandler<()>?) {
        do {
            try performChannelOperationWithRetry(channel: channel) { channel in
                channel.publish([message]) { [weak self] error in
                    guard let self = self else {
                        return
                    }

                    if let error = error {
                        self.logHandler?.e(message: "\(String(describing: Self.self)): Cannot publish a message to channel [trackable id: \(trackable.id)]", error: error)
                        self.publisherDelegate?.ablyPublisher(self, didFailWithError: error.toErrorInformation())

                        return
                    }

                    self.publisherDelegate?.ablyPublisher(self, didChangeChannelConnectionState: .online, forTrackable: trackable)
                    completion?(.success)
                }
            }

        } catch AblyError.connectionError(let errorInfo){
            completion?(.failure(errorInfo.toErrorInformation()))
        }catch{
            let artErrorInfo = ARTErrorInfo.create(from: error)
            completion?(.failure(artErrorInfo.toErrorInformation()))
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

            sendMessageForTrackable(channel: channel, message: message, trackable: trackable, completion: completion)
        } catch {
            let errorInformation = ErrorInformation(
                type: .publisherError(errorMessage: "Cannot create location update message. Underlying error: \(error)")
            )
            self.logHandler?.e(message: "\(String(describing: Self.self)): Cannot create location update message.", error: errorInformation)
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

extension ARTErrorInfo {
    func isConnectionResumeException() -> Bool {
        let errorInfo = toErrorInformation()
        return  errorInfo.message == "Connection resume failed" && errorInfo.code == 50000 && errorInfo.statusCode == 500
    }
}
