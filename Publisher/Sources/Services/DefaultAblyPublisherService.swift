import Ably
import CoreLocation

class DefaultAblyPublisherService: AblyPublisherService {
    private let client: ARTRealtime
    private let presenceData: PresenceData
    private var channels: [Trackable: ARTRealtimeChannel]

    weak var delegate: AblyPublisherServiceDelegate?

    init(configuration: ConnectionConfiguration) {
        self.client = ARTRealtime(options: configuration.getClientOptions())
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

        channel.presence.enter(data) { error in
            guard let error = error else {
                logger.debug("Entered to presence successfully", source: "AblyPublisherService")
                self.channels[trackable] = channel
                completion?(.success)
                return
            }

            logger.error("Error during joining to channel presence: \(String(describing: error))", source: "AblyPublisherService")
            completion?(.failure(error.toErrorInformation()))
        }
    }

    func sendEnhancedAssetLocationUpdate(locationUpdate: EnhancedLocationUpdate, batteryLevel: Float?, forTrackable trackable: Trackable, completion: ResultHandler<Void>?) {
        guard let channel = channels[trackable] else {
            let errorInformation = ErrorInformation(type: .publisherError(errorMessage: "Attempt to send location while not tracked channel"))
            completion?(.failure(errorInformation))
            return
        }

        guard let message = createARTMessage(for: locationUpdate, and: batteryLevel) else {
            let errorInformation = ErrorInformation(type: .publisherError(errorMessage: "Cannot create location update message."))
            self.delegate?.publisherService(sender: self, didFailWithError: errorInformation)
            return
        }

        channel.publish([message]) { [weak self] error in
            guard let self = self,
                  let error = error else {
                logger.debug("ablyService.didSendEnhancedLocation.", source: "DefaultAblyService")
                return
            }

            self.delegate?.publisherService(sender: self, didFailWithError: error.toErrorInformation())
        }
    }

    private func createARTMessage(for locationUpdate: EnhancedLocationUpdate, and batteryLevel: Float?) -> ARTMessage? {
        do {
            let geoJson = try EnhancedLocationUpdateMessage(locationUpdate: locationUpdate, batteryLevel: batteryLevel)
            let data = try [geoJson].toJSONString()
            return ARTMessage(name: EventName.enhanced.rawValue, data: data)
        } catch let error {
            self.delegate?.publisherService(sender: self, didFailWithError: ErrorInformation(error: error))
            return nil
        }
    }
    
    func close(completion: @escaping ResultHandler<Void>) {
        closeAllChannels { result in
            switch result {
            case .success:
                self.closeClientConnection(completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func closeClientConnection(completion: @escaping ResultHandler<Void>) {
        client.connection.on { connectionChange in
            guard let connectionState = connectionChange?.current else {
                return
            }
            
            switch connectionState {
            case .closed:
                logger.info("Ably connection closed successfully.")
                completion(.success)
            case .failed:
                let errorInfo = connectionChange?.reason?.toErrorInformation() ?? ErrorInformation(type: .publisherError(errorMessage: "Cannot close connection"))
                completion(.failure(errorInfo))
            default:
                return
            }
        }
        
        client.close()
    }
    
    private func closeAllChannels(completion: @escaping ResultHandler<Void>) {
        guard !channels.isEmpty else {
            completion(.success)
            return
        }
        
        let closingDispatchGroup = DispatchGroup()
        channels.forEach { channel in
            closingDispatchGroup.enter()
            self.stopTracking(trackable: channel.key) { result in
                switch result {
                case .success(let wasPresent):
                    logger.info("Trackable \(channel.key.id) removed successfully. Was present \(wasPresent)")
                    closingDispatchGroup.leave()
                case .failure(let error):
                    logger.error("Removing trackable \(channel.key) failed. Error \(error.message)")
                    completion(.failure(error))
                }
            }
        }
        
        closingDispatchGroup.notify(queue: .main) {
            logger.info("All trackables removed.")
            completion(.success)
        }
    }

    func stopTracking(trackable: Trackable, completion: ResultHandler<Bool>?) {
        guard let channel = channels.removeValue(forKey: trackable) else {
            completion?(.success(false))
            return
        }
        // Force cast intentional here. It's a fatal error if we are unable to create presenceData JSON
        let data = try! presenceData.toJSONString()

        channel.presence.unsubscribe()
        channel.presence.leave(data) { error in
            guard let error = error else {
                completion?(.success(true))
                return
            }
            let errorInformation = error.toErrorInformation()
            completion?(.failure(errorInformation))
        }
    }
}
