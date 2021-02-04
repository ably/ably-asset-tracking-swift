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
    func track(trackable: Trackable, completion: ResultHandler<Void>?) {
        // Force cast intentional here. It's a fatal error if we are unable to create presenceData JSON
        let data = try! presenceData.toJSONString()

        let channel = client.channels.get(trackable.id)
        channel.presence.subscribe { [weak self] message in
            guard let self = self,
                  let json = message.data as? String,
                  let data: PresenceData = try? PresenceData.fromJSONString(json),
                  let clientId = message.clientId
            else { return }

            self.delegate?.publisherService(sender: self,
                                             didReceivePresenceUpdate: message.action.toAblyPublisherPresence(),
                                             forTrackable: trackable,
                                             presenceData: data,
                                             clientId: clientId)
        }

        channel.presence.enterClient(configuration.clientId, data: data) { error in
            guard let error = error else {
                logger.debug("Entered to presence successfully", source: "AblyPublisherService")
                completion?(.success(()))
                return
            }

            logger.error("Error during joining to channel presence: \(String(describing: error))", source: "AblyPublisherService")
            completion?(.failure(error.toErrorInformation()))
        }
        channels[trackable] = channel
    }

    func sendEnhancedAssetLocationUpdate(locationUpdate: EnhancedLocationUpdate, forTrackable trackable: Trackable, completion: ResultHandler<Void>?) {
        guard let channel = channels[trackable] else {
            let errorInformation = ErrorInformation(type: .publisherError(inObject: self, errorMessage: "Attempt to send location while not tracked channel"))
            completion?(.failure(errorInformation))
            return
        }
        
        let geoJson = EnhacedLocationUpdateMessage(locationUpdate: locationUpdate)
        let data = try! [geoJson].toJSONString()
        let message = ARTMessage(name: EventName.enhanced.rawValue, data: data)
        
        channel.publish([message]) { [weak self] error in
            guard let self = self,
                  let error = error else {
                logger.debug("ablyService.didSendEnhancedLocation.", source: "DefaultAblyService")
                return
            }
            
            self.delegate?.publisherService(sender: self, didFailWithError:error.toErrorInformation())
        }
    }

    func stop() {
        client.close()
    }

    func stopTracking(trackable: Trackable, completion: ResultHandler<Bool>?) {
        guard let channel = channels.removeValue(forKey: trackable) else {
            completion?(.success(false))
            return
        }
        // Force cast intentional here. It's a fatal error if we are unable to create presenceData JSON
        let data = try! presenceData.toJSONString()

        channel.presence.unsubscribe()
        channel.presence.leaveClient(configuration.clientId, data: data) { error in
            guard let error = error else {
                completion?(.success(true))
                return
            }
            let errorInformation = error.toErrorInformation()
            completion?(.failure(errorInformation))
        }
    }
}
