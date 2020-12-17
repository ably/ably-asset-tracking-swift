import Foundation
import CoreLocation
import Core

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
        delegate?.subscriber(sender: self, didChangeAssetConnectionStatus: status)
    }

    func subscriberService(sender: AblySubscriberService, didFailWithError error: Error) {
        delegate?.subscriber(sender: self, didFailWithError: error)
    }

    func subscriberService(sender: AblySubscriberService, didReceiveRawLocation location: CLLocation) {
        delegate?.subscriber(sender: self, didUpdateRawLocation: location)
    }

    func subscriberService(sender: AblySubscriberService, didReceiveEnhancedLocation location: CLLocation) {
        delegate?.subscriber(sender: self, didUpdateEnhancedLocation: location)
    }
}
