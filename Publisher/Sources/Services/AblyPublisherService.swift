import Ably
import CoreLocation

protocol AblyPublisherServiceDelegate: AnyObject {
    func publisherService(sender: AblyPublisherService, didChangeConnectionState state: ConnectionState)
}

class AblyPublisherService {
    private let client: ARTRealtime
    private let configuration: ConnectionConfiguration

    private let presenceData: PresenceData
    private var channel: ARTRealtimeChannel?

    weak var delegate: AblyPublisherServiceDelegate?
    var connectionState: ConnectionState {
        return client.connection.state.toConnectionState()
    }

    init(configuration: ConnectionConfiguration) {
        self.configuration = configuration
        self.client = ARTRealtime(key: configuration.apiKey)
        self.presenceData = PresenceData(type: .publisher)

        setup()
    }

    private func setup() {
        client.connection.on { [weak self] stateChange in
            guard let current = stateChange?.current,
                  let self = self
            else { return }
            logger.debug("Connection to Ably changed. New state: \(current)", source: "AblyPublisherService")
            self.delegate?.publisherService(
                sender: self,
                didChangeConnectionState: current.toConnectionState()
            )
        }
    }

    // MARK: Main interface
    func track(trackable: Trackable, completion: ((Error?) -> Void)?) {
        precondition(channel == nil, "In current SDK version, service can track only one asset per instance")

        // Force cast intentional here. It's a fatal error if we are unable to create presenceData JSON
        let data = try! presenceData.toJSONString()

        channel = client.channels.get(trackable.id)
        channel?.presence.enterClient(configuration.clientId, data: data) { error in
            error == nil ?
                logger.debug("Entered to presence successfully", source: "AblyPublisherService") :
                logger.error("Error during joining to channel presence: \(String(describing: error))", source: "AblyPublisherService")
            completion?(error)
        }
    }

    func sendRawAssetLocation(location: CLLocation, completion: ((Error?) -> Void)?) {
        sendAssetLocation(location: location, withName: .raw, completion: completion)
    }

    func sendEnhancedAssetLocation(location: CLLocation, completion: ((Error?) -> Void)?) {
        sendAssetLocation(location: location, withName: .enhanced, completion: completion)
    }

    private func sendAssetLocation(location: CLLocation, withName name: EventName, completion: ((Error?) -> Void)?) {
        guard let channel = channel else {
            completion?(AssetTrackingError.publisherError("Attempt to send location while not connected to any channel"))
            return
        }

        // Force cast intentional here. It's a fatal error if we are unable to create JSON String from GeoJSONMessage
        let geoJSON = GeoJSONMessage(location: location)
        let data = try! [geoJSON].toJSONString()

        let message = ARTMessage(name: name.rawValue, data: data)
        channel.publish([message]) { errorInfo in
            completion?(errorInfo)
        }
    }

    func stop() {
        // TODO: Should we clear channel here? Can AblyService be restarted?
        client.close()
    }
}
