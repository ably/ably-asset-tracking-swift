import UIKit
import Ably
import CoreLocation

protocol AblySubscriberServiceDelegate: AnyObject {
    func subscriberService(sender: AblySubscriberService, didChangeClientConnectionStatus status: ConnectionState)
    func subscriberService(sender: AblySubscriberService, didChangeChannelConnectionStatus status: ConnectionState)
    func subscriberService(sender: AblySubscriberService, didReceivePresenceUpdate presence: AblyPresence)
    func subscriberService(sender: AblySubscriberService, didFailWithError error: ErrorInformation)
    func subscriberService(sender: AblySubscriberService, didReceiveEnhancedLocation location: CLLocation)
}

class DefaultAblySubscriberService: AblySubscriberService {
    private let client: ARTRealtime
    private var presenceData: PresenceData
    private let channel: ARTRealtimeChannel

    weak var delegate: AblySubscriberServiceDelegate?

    init(configuration: ConnectionConfiguration, trackingId: String, resolution: Resolution?) {
        self.client = ARTRealtime(options: configuration.getClientOptions())
        self.presenceData = PresenceData(type: .subscriber, resolution: resolution)
        let options = ARTRealtimeChannelOptions()
        options.params = ["rewind": "1"]
        channel = client.channels.getChannelFor(trackingId: trackingId, options: options)
        
        setup()
    }

    func start(completion: @escaping ResultHandler<Void>) {
        // Trigger offline event at start
        delegate?.subscriberService(sender: self, didChangeChannelConnectionStatus: .offline)
        channel.presence.subscribe({ [weak self] message in
            logger.debug("Received presence update from channel", source: "AblySubscriberService")
            self?.handleIncomingPresenceMessage(message)
        })

        // Force cast intentional here. It's a fatal error if we are unable to create presenceData JSON
        let data = try! presenceData.toJSONString()

        channel.presence.enter(data) { error in
            guard let error = error else {
                logger.debug("Entered to channel presence successfully", source: "AblySubscriberService")
                completion(.success)
                return
            }
            
            logger.error("Error during joining to channel presence: \(String(describing: error))", source: "AblySubscriberService")
            completion(.failure(error.toErrorInformation()))
        }

        channel.subscribe(EventName.raw.rawValue) { [weak self] message in
            logger.debug("Received raw location message from channel", source: "AblySubscriberService")
            self?.handleLocationUpdateResponse(forEvent: .raw, messageData: message.data)
        }

        channel.subscribe(EventName.enhanced.rawValue) { [weak self] message in
            logger.debug("Received enhanced location message from channel", source: "AblySubscriberService")
            self?.handleLocationUpdateResponse(forEvent: .enhanced, messageData: message.data)
        }
    }

    func stop(completion: @escaping ResultHandler<Void>) {
        channel.unsubscribe()
        leaveChannelPresence(completion: completion)
        client.close()
    }

    func sendResolutionPreference(resolution: Resolution?, completion: @escaping ResultHandler<Void>) {
        logger.debug("Changing resolution to: \(String(describing: resolution))", source: "AblySubscriberService")
        presenceData = PresenceData(type: presenceData.type, resolution: resolution)

        // Force cast intentional here. It's a fatal error if we are unable to create presenceData JSON
        let data = try! presenceData.toJSONString()
        channel.presence.update(data) { error in
            if let error = error {
                completion(.failure(error.toErrorInformation()))
            } else {
                completion(.success)
            }
        }
    }

    // MARK: Utils
    private func setup() {
        client.connection.on { [weak self] connectionState in
            guard let self = self,
                  let receivedConnectionState = connectionState?.current.toConnectionState() else {
                return
            }
            
            logger.debug("Connection to Ably changed. New state: \(receivedConnectionState)", source: "DefaultAblyPublisherService")
            self.delegate?.subscriberService(sender: self, didChangeClientConnectionStatus: receivedConnectionState)
        }
        
        channel.on { [weak self] channelStatus in
            guard let self = self,
                  let receivedConnectionState = channelStatus?.current.toConnectionState() else {
                return
            }
            
            logger.debug("Channel connection state changed. New state: \(receivedConnectionState)", source: "DefaultAblyPublisherService")
            self.delegate?.subscriberService(sender: self, didChangeChannelConnectionStatus: receivedConnectionState)
        }
    }
    
    private func handleLocationUpdateResponse(forEvent event: EventName, messageData: Any?) {
        guard let json = messageData as? String else {
            let errorInformation = ErrorInformation(type: .subscriberError(errorMessage: "Cannot parse message data for \(event.rawValue) event: \(String(describing: messageData))"))
            delegate?.subscriberService(sender: self, didFailWithError: errorInformation)
            return
        }
        
        do {
            let message: EnhancedLocationUpdateMessage = try EnhancedLocationUpdateMessage.fromJSONString(json)
            delegate?.subscriberService(sender: self, didReceiveEnhancedLocation: message.location.toCoreLocation())
        } catch let error {
            guard let errorInformation = error as? ErrorInformation else {
                delegate?.subscriberService(sender: self, didFailWithError: ErrorInformation(error: error))
                return
            }

            delegate?.subscriberService(sender: self, didFailWithError: errorInformation)
            return
        }
    }

    private func handleIncomingPresenceMessage(_ message: ARTPresenceMessage) {
        let supportedActions: [ARTPresenceAction] = [.present, .enter, .leave]
        guard supportedActions.contains(message.action),
              let dataJSON = message.data as? String,
              let data = dataJSON.data(using: .utf8),
              let presenceData = try? JSONDecoder().decode(PresenceData.self, from: data),
              presenceData.type == .publisher
        else { return }
        
        let presence = message.action.toAblyPresence()

        delegate?.subscriberService(sender: self, didReceivePresenceUpdate: presence)
        delegate?.subscriberService(sender: self, didChangeChannelConnectionStatus: presence.toConnectionState())
    }

    private func leaveChannelPresence(completion: @escaping ResultHandler<Void>) {
        channel.presence.unsubscribe()
        delegate?.subscriberService(sender: self, didChangeChannelConnectionStatus: .offline)
        
        // Force cast intentional here. It's a fatal error if we are unable to create presenceData JSON
        let data = try! presenceData.toJSONString()

        channel.presence.leave(data) { [weak self] error in
            guard let self = self else {
                let error = ErrorInformation(type: .subscriberError(errorMessage: "Error during leaving to channel presence."))
                completion(.failure(error))
                return
            }
            
            if let error = error {
                logger.error("Error during leaving to channel presence: \(String(describing: error))", source: "AblySubscriberService")
                self.delegate?.subscriberService(sender: self, didChangeChannelConnectionStatus: .failed)
                completion(.failure(error.toErrorInformation()))
                return
            }
            
            logger.debug("Left channel presence successfully", source: "AblySubscriberService")
            completion(.success)
        }
    }
}
