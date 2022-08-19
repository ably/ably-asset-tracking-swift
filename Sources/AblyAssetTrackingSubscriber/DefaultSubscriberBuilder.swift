import UIKit
import Logging
import AblyAssetTrackingCore
import AblyAssetTrackingInternal

class DefaultSubscriberBuilder: SubscriberBuilder {
    private var connection: ConnectionConfiguration?
    private var trackingId: String?
    private var resolution: Resolution?
    private weak var delegate: SubscriberDelegate?

    init() { }

    private init(connection: ConnectionConfiguration?,
                 trackingId: String?,
                 resolution: Resolution?,
                 delegate: SubscriberDelegate?) {
        self.connection = connection
        self.trackingId = trackingId
        self.resolution = resolution
        self.delegate = delegate
    }

    func start(completion: @escaping ResultHandler<Void>) -> Subscriber? {
        guard let connection = connection
        else {
            let error = ErrorInformation(type: .incompleteConfiguration(missingProperty: "ConnectionConfiguration", forBuilderOption: "connection"))
            completion(.failure(error))
            return nil
        }

        guard let trackingId = trackingId
        else {
            let error = ErrorInformation(type: .incompleteConfiguration(missingProperty: "TrackingId", forBuilderOption: "trackingId"))
            completion(.failure(error))
            return nil
        }

        let defaultAbly = DefaultAbly(
            configuration: connection,
            mode: .subscribe,
            logger: Logger(
                label: "com.ably.tracking.DefaultAbly-Subscriber"
            )
        )
        let subscriber = DefaultSubscriber(
            ablySubscriber: defaultAbly,
            trackableId: trackingId,
            resolution: resolution
        )
        subscriber.delegate = delegate
        subscriber.start(completion: completion)
        return subscriber
    }

    func connection(_ configuration: ConnectionConfiguration) -> SubscriberBuilder {
        return DefaultSubscriberBuilder(connection: configuration,
                                        trackingId: trackingId,
                                        resolution: resolution,
                                        delegate: delegate)
    }

    func trackingId(_ trackingId: String) -> SubscriberBuilder {
        return DefaultSubscriberBuilder(connection: connection,
                                        trackingId: trackingId,
                                        resolution: resolution,
                                        delegate: delegate)
    }

    func resolution(_ resolution: Resolution) -> SubscriberBuilder {
        return DefaultSubscriberBuilder(connection: connection,
                                        trackingId: trackingId,
                                        resolution: resolution,
                                        delegate: delegate)
    }

    func delegate(_ delegate: SubscriberDelegate) -> SubscriberBuilder {
        return DefaultSubscriberBuilder(connection: connection,
                                        trackingId: trackingId,
                                        resolution: resolution,
                                        delegate: delegate)
    }
}
