import Foundation
import CoreLocation
import Logging

// Default logger used in Subscriber SDK
let logger: Logger = Logger(label: "com.ably.asset-tracking.Subscriber")

class DefaultSubscriber: Subscriber {
    private let logConfiguration: LogConfiguration
    private let trackingId: String
    private let resolution: Double?
    private let ablyService: AblySubscriberService
    weak var delegate: SubscriberDelegate?

    init(connectionConfiguration: ConnectionConfiguration,
         logConfiguration: LogConfiguration,
         trackingId: String,
         resolution: Double?) {
        self.trackingId = trackingId
        self.resolution = resolution
        self.logConfiguration = logConfiguration
        self.ablyService = AblySubscriberService(configuration: connectionConfiguration,
                                                 trackingId: trackingId)
        self.ablyService.delegate = self
    }

    func start() {
        ablyService.start { [weak self] error in
            if let error = error,
               let self = self {
                self.delegate?.subscriber(sender: self, didFailWithError: error)
            }
        }
    }

    func stop() {
        ablyService.stop()
    }
}

extension DefaultSubscriber: AblySubscriberServiceDelegate {
    func subscriberService(sender: AblySubscriberService, didChangeAssetConnectionStatus status: AssetConnectionStatus) {
        logger.debug("subscriberService.didChangeAssetConnectionStatus. Status: \(status)", source: "DefaultSubscriber")
        delegate?.subscriber(sender: self, didChangeAssetConnectionStatus: status)
    }

    func subscriberService(sender: AblySubscriberService, didFailWithError error: Error) {
        logger.error("subscriberService.didFailWithError. Error: \(error)", source: "DefaultSubscriber")
        delegate?.subscriber(sender: self, didFailWithError: error)
    }

    func subscriberService(sender: AblySubscriberService, didReceiveRawLocation location: CLLocation) {
        logger.debug("subscriberService.didReceiveRawLocation.", source: "DefaultSubscriber")
        delegate?.subscriber(sender: self, didUpdateRawLocation: location)
    }

    func subscriberService(sender: AblySubscriberService, didReceiveEnhancedLocation location: CLLocation) {
        logger.debug("subscriberService.didReceiveEnhancedLocation.", source: "DefaultSubscriber")
        delegate?.subscriber(sender: self, didUpdateEnhancedLocation: location)
    }
}
