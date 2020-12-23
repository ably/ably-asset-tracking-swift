import UIKit
import Ably
import CoreLocation

protocol AblySubscriberServiceDelegate: AnyObject {
    func subscriberService(sender: AblySubscriberService, didChangeAssetConnectionStatus status: AssetConnectionStatus)
    func subscriberService(sender: AblySubscriberService, didFailWithError error: Error)
    func subscriberService(sender: AblySubscriberService, didReceiveRawLocation location: CLLocation)
    func subscriberService(sender: AblySubscriberService, didReceiveEnhancedLocation location: CLLocation)
}

class AblySubscriberService {
    private let client: ARTRealtime
    private let configuration: ConnectionConfiguration
    private let presenceData: PresenceData
    private let channel: ARTRealtimeChannel

    weak var delegate: AblySubscriberServiceDelegate?

    init(configuration: ConnectionConfiguration, trackingId: String) {
        self.client = ARTRealtime(key: configuration.apiKey)
        self.presenceData = PresenceData(type: .subscriber)
        self.configuration = configuration

        let options = ARTRealtimeChannelOptions()
        options.params = ["rewind": "1"]
        channel = client.channels.get(trackingId, options: options)
    }

    func start(completion: ((Error?) -> Void)?) {
        // Trigger offline event at start
        delegate?.subscriberService(sender: self, didChangeAssetConnectionStatus: .offline)
        channel.presence.subscribe({ [weak self] message in
            logger.debug("Received presence update from channel")
            self?.handleIncomingPresenceMessage(message)
        })

        // Force cast intentional here. It's a fatal error if we are unable to create presenceData JSON
        let data = try! presenceData.toJSONString()

        channel.presence.enterClient(configuration.clientId, data: data) { error in
            error == nil ?
                logger.debug("Entered to channel presence successfully", source: "AblySubscriberService") :
                logger.error("Error during joining to channel presence: \(String(describing: error))", source: "AblySubscriberService")
            completion?(error)
        }

        channel.subscribe(EventName.raw.rawValue) { [weak self] message in
            logger.debug("Received raw location message from channel")
            self?.handleLocationUpdateResponse(forEvent: .raw, messageData: message.data)
        }

        channel.subscribe(EventName.enhanced.rawValue) { [weak self] message in
            logger.debug("Received enhanced location message from channel")
            self?.handleLocationUpdateResponse(forEvent: .enhanced, messageData: message.data)
        }
    }

    func stop() {
        channel.unsubscribe()
        leaveChannelPresence()
        client.close()
    }

    // MARK: Utils
    private func handleLocationUpdateResponse(forEvent event: EventName, messageData: Any?) {
        guard let json = messageData as? String else {
            let error = AssetTrackingError.inconsistentData("Cannot parse message data for \(event.rawValue) event: \(String(describing: messageData))")
            delegate?.subscriberService(sender: self, didFailWithError: error)
            return
        }

        var messages: [GeoJSONMessage] = []
        do {
            messages = try [GeoJSONMessage].fromJSONString(json)
        } catch let error {
            delegate?.subscriberService(sender: self, didFailWithError: error)
            return
        }

        let locations = messages.map { $0.toCoreLocation() }
        event == .raw ?
            locations.forEach({ delegate?.subscriberService(sender: self, didReceiveRawLocation: $0) }) :
            locations.forEach({ delegate?.subscriberService(sender: self, didReceiveEnhancedLocation: $0) })
    }

    private func handleIncomingPresenceMessage(_ message: ARTPresenceMessage) {
        let supportedActions: [ARTPresenceAction] = [.present, .enter, .leave]
        guard supportedActions.contains(message.action),
              let dataJSON = message.data as? String,
              let data = dataJSON.data(using: .utf8),
              let presenceData = try? JSONDecoder().decode(PresenceData.self, from: data),
              presenceData.type == .publisher
        else { return }

        switch message.action {
        case .present, .enter:
            delegate?.subscriberService(sender: self, didChangeAssetConnectionStatus: .online)

        case .leave:
            delegate?.subscriberService(sender: self, didChangeAssetConnectionStatus: .offline)
        default: break
        }
    }

    private func leaveChannelPresence() {
        channel.presence.unsubscribe()
        delegate?.subscriberService(sender: self, didChangeAssetConnectionStatus: .offline)

        // Force cast intentional here. It's a fatal error if we are unable to create presenceData JSON
        let data = try! presenceData.toJSONString()

        channel.presence.leaveClient(configuration.clientId, data: data) { [weak self] error in
            error == nil ?
                logger.debug("Left channel presence successfully", source: "AblySubscriberService") :
                logger.error("Error during leaving to channel presence: \(String(describing: error))", source: "AblySubscriberService")
            if let error = error,
               let self = self {
                self.delegate?.subscriberService(sender: self, didFailWithError: error)
            }
        }
    }
}
