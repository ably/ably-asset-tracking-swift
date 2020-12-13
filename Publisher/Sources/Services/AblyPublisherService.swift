import Ably
import CoreLocation

protocol AblyPublisherServiceDelegate: AnyObject {
    func publisherService(sender: AblyPublisherService, didChangeConnectionStatus status: AblyConnectionStatus)
}

class AblyPublisherService {
    private let client: ARTRealtime
    private let configuration: ConnectionConfiguration

    private let presenceData: PresenceData
    private var channel: ARTRealtimeChannel?

    weak var delegate: AblyPublisherServiceDelegate?
    var connectionState: AblyConnectionStatus {
        return client.connection.state.toAblyConnectionStatus()
    }

    init(configuration: ConnectionConfiguration) {
        self.configuration = configuration
        self.client = ARTRealtime(key: configuration.apiKey)
        self.presenceData = PresenceData(type: .publisher)

        setup()
    }

    private func setup() {
        // TODO: Log suitable message when Logger become available:
        // https://github.com/ably/ably-asset-tracking-cocoa/issues/8
        client.connection.on { [weak self] stateChange in
            guard let current = stateChange?.current,
                  let self = self
            else { return }
            self.delegate?.publisherService(
                sender: self,
                didChangeConnectionStatus: current.toAblyConnectionStatus()
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
            // TODO: Log suitable message when Logger become available:
            // https://github.com/ably/ably-asset-tracking-cocoa/issues/8
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
            completion?(AblyError.publisherError("Attempt to send location while not connected to any channel"))
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
