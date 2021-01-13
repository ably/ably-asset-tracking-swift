import Ably
import CoreLocation

class DefaultAblyPublisherService: AblyPublisherService {
    private let client: ARTRealtime
    private let configuration: ConnectionConfiguration
    private let presenceData: PresenceData
    private var channels: [Trackable: ARTRealtimeChannel]

    weak var delegate: AblyPublisherServiceDelegate?
    var trackables: [Trackable] { return Array(channels.keys) }

    init(configuration: ConnectionConfiguration) {
        self.configuration = configuration
        self.client = ARTRealtime(key: configuration.apiKey)
        self.presenceData = PresenceData(type: .publisher)
        self.channels = [:]

        setup()
    }

    private func setup() {
        client.connection.on { [weak self] stateChange in
            guard let current = stateChange?.current,
                  let self = self
            else { return }
            logger.debug("Connection to Ably changed. New state: \(current)", source: "DefaultAblyPublisherService")
            self.delegate?.publisherService(
                sender: self,
                didChangeConnectionState: current.toConnectionState()
            )
        }
    }

    // MARK: Main interface
    func track(trackable: Trackable, completion: ((Error?) -> Void)?) {
        // Force cast intentional here. It's a fatal error if we are unable to create presenceData JSON
        let data = try! presenceData.toJSONString()

        let channel = client.channels.get(trackable.id)
        channel.presence.enterClient(configuration.clientId, data: data) { error in
            error == nil ?
                logger.debug("Entered to presence successfully", source: "AblyPublisherService") :
                logger.error("Error during joining to channel presence: \(String(describing: error))", source: "DefaultAblyPublisherService")
            completion?(error)
        }
        channels[trackable] = channel
    }

    func sendRawAssetLocation(location: CLLocation, completion: ((Error?) -> Void)?) {
        sendAssetLocation(location: location, withName: .raw, completion: completion)
    }

    func sendEnhancedAssetLocation(location: CLLocation, completion: ((Error?) -> Void)?) {
        sendAssetLocation(location: location, withName: .enhanced, completion: completion)
    }

    private func sendAssetLocation(location: CLLocation, withName name: EventName, completion: ((Error?) -> Void)?) {
        guard !channels.isEmpty else {
            completion?(AssetTrackingError.publisherError("Attempt to send location while not connected to any channel"))
            return
        }

        // Force cast intentional here. It's a fatal error if we are unable to create JSON String from GeoJSONMessage
        let geoJSON = GeoJSONMessage(location: location)
        let data = try! [geoJSON].toJSONString()

        let message = ARTMessage(name: name.rawValue, data: data)
        channels.forEach { (_, channel) in
            channel.publish([message]) { [weak self] error in
                if let self = self,
                   let error = error {
                    self.delegate?.publisherService(sender: self, didFailWithError: error)
                }
            }
        }
    }

    func stop() {
        client.close()
    }

    func stopTracking(trackable: Trackable, onSuccess: @escaping (_ wasPresent: Bool) -> Void, onError: @escaping ErrorHandler) {
        guard let channel = channels.removeValue(forKey: trackable) else {
            onSuccess(false)
            return
        }
        // Force cast intentional here. It's a fatal error if we are unable to create presenceData JSON
        let data = try! presenceData.toJSONString()

        channel.presence.unsubscribe()
        channel.presence.leaveClient(configuration.clientId, data: data) { error in
            error == nil ? onSuccess(true) : onError(error!)
        }
    }
}
