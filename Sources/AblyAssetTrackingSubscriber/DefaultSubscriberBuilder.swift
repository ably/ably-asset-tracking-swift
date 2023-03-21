import UIKit
import AblyAssetTrackingCore
import AblyAssetTrackingInternal

class DefaultSubscriberBuilder: SubscriberBuilder {
    private var connection: ConnectionConfiguration?
    private var trackingId: String?
    private var resolution: Resolution?
    private var logHandler: LogHandler?
    private weak var delegate: SubscriberDelegate?

    init() { }

    private init(connection: ConnectionConfiguration?,
                 trackingId: String?,
                 resolution: Resolution?,
                 logHandler: LogHandler?,
                 delegate: SubscriberDelegate?) {
        self.connection = connection
        self.trackingId = trackingId
        self.resolution = resolution
        self.delegate = delegate
        self.logHandler = logHandler
    }

    func start(completion: @escaping ResultHandler<Void>) -> Subscriber? {
        guard let connection
        else {
            let error = ErrorInformation(type: .incompleteConfiguration(missingProperty: "ConnectionConfiguration", forBuilderOption: "connection"))
            completion(.failure(error))
            return nil
        }

        guard let trackingId
        else {
            let error = ErrorInformation(type: .incompleteConfiguration(missingProperty: "TrackingId", forBuilderOption: "trackingId"))
            completion(.failure(error))
            return nil
        }
        
        let internalLogHandler = DefaultInternalLogHandler(logHandler: logHandler,
                                                           subsystems: [.assetTracking, .named("subscriber")])

        let defaultAbly = DefaultAbly(
            factory: AblyCocoaSDKRealtimeFactory(),
            configuration: connection,
            host: nil,
            mode: .subscribe,
            logHandler: internalLogHandler
        )
        let subscriber = DefaultSubscriber(
            ablySubscriber: defaultAbly,
            trackableId: trackingId,
            resolution: resolution,
            logHandler: internalLogHandler
        )
        subscriber.delegate = delegate
        subscriber.start(completion: completion)
        return subscriber
    }

    func connection(_ configuration: ConnectionConfiguration) -> SubscriberBuilder {
        return DefaultSubscriberBuilder(connection: configuration,
                                        trackingId: trackingId,
                                        resolution: resolution,
                                        logHandler: logHandler,
                                        delegate: delegate)
    }

    func trackingId(_ trackingId: String) -> SubscriberBuilder {
        return DefaultSubscriberBuilder(connection: connection,
                                        trackingId: trackingId,
                                        resolution: resolution,
                                        logHandler: logHandler,
                                        delegate: delegate)
    }

    func resolution(_ resolution: Resolution) -> SubscriberBuilder {
        return DefaultSubscriberBuilder(connection: connection,
                                        trackingId: trackingId,
                                        resolution: resolution,
                                        logHandler: logHandler,
                                        delegate: delegate)
    }

    func delegate(_ delegate: SubscriberDelegate) -> SubscriberBuilder {
        return DefaultSubscriberBuilder(connection: connection,
                                        trackingId: trackingId,
                                        resolution: resolution,
                                        logHandler: logHandler,
                                        delegate: delegate)
    }
    
    func logHandler(handler: LogHandler?) -> SubscriberBuilder {
        return DefaultSubscriberBuilder(connection: connection,
                                        trackingId: trackingId,
                                        resolution: resolution,
                                        logHandler: handler,
                                        delegate: delegate)
    }
}
