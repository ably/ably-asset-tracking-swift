import Ably
import CoreLocation

protocol AblyPublisherServiceDelegate: class {
    func publisherService(sender: AblyPublisherService, didChangeConnectionStatus status: AblyConnectionStatus)
}

class AblyPublisherService {
    private let client: ARTRealtime
    private let clientId: String
    private let presenceData: PresenceData
    private var channel: ARTRealtimeChannel?
    
    weak var delegate: AblyPublisherServiceDelegate?
    var connectionState: AblyConnectionStatus {
        return client.connection.state.toAblyConnectionStatus()
    }
    
    init(apiKey: String, clientId: String) {
        self.clientId = clientId
        self.client = ARTRealtime(key: apiKey)
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
        guard channel == nil else {
            completion?(AblyError.alreadyConnectedToChannel)
            return
        }
        
        // Force cast allowed here, as presence data is our internal class which should never fail to encode
        let data = presenceData.toEncodedJSONString()!
        
        channel = client.channels.get(trackable.id)
        channel?.presence.enterClient(clientId, data: data) { error in
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
                    
        let geoJSON = GeoJSONMessage(location: location)
        guard let data = [geoJSON].toEncodedJSONString() else {
            completion?(AblyError.inconsistentData("Cannot encode location data to JSON"))
            return
        }
        
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
