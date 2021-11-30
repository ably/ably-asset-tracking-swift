import UIKit
import AblyAssetTrackingCore

class DefaultSubscriberBuilder: SubscriberBuilder {
    private var connection: ConnectionConfiguration?
    private var logConfiguration: LogConfiguration?
    private var trackingId: String?
    private var resolution: Resolution?
    private weak var delegate: SubscriberDelegate?

    init() { }

    private init(connection: ConnectionConfiguration?,
                 logConfiguration: LogConfiguration?,
                 trackingId: String?,
                 resolution: Resolution?,
                 delegate: SubscriberDelegate?) {
        self.connection = connection
        self.logConfiguration = logConfiguration
        self.trackingId = trackingId
        self.resolution = resolution
        self.delegate = delegate
    }

    func start(completion: @escaping ResultHandler/*Void*/) -> Subscriber? {
        guard let connection = connection
        else {
            let error = ErrorInformation(type: .incompleteConfiguration(missingProperty: "ConnectionConfiguration", forBuilderOption: "connection"))
            completion(.failure(error))
            return nil
        }

        guard let logConfiguration = logConfiguration
        else {
            let error = ErrorInformation(type: .incompleteConfiguration(missingProperty: "LogConfiguration", forBuilderOption: "log"))
            completion(.failure(error))
            return nil
        }

        guard let trackingId = trackingId
        else {
            let error = ErrorInformation(type: .incompleteConfiguration(missingProperty: "TrackingId", forBuilderOption: "trackingId"))
            completion(.failure(error))
            return nil
        }

        let ablyService = DefaultAblySubscriberService(configuration: connection,
                                                trackingId: trackingId,
                                                resolution: resolution)
        let subscriber = DefaultSubscriber(logConfiguration: logConfiguration,
                                           ablyService: ablyService)
        subscriber.delegate = delegate
        subscriber.start(completion: completion)
        
        return subscriber
    }

    func connection(_ configuration: ConnectionConfiguration) -> SubscriberBuilder {
        return DefaultSubscriberBuilder(connection: configuration,
                                        logConfiguration: logConfiguration,
                                        trackingId: trackingId,
                                        resolution: resolution,
                                        delegate: delegate)
    }

    func log(_ configuration: LogConfiguration) -> SubscriberBuilder {
        return DefaultSubscriberBuilder(connection: connection,
                                        logConfiguration: configuration,
                                        trackingId: trackingId,
                                        resolution: resolution,
                                        delegate: delegate)
    }

    func trackingId(_ trackingId: String) -> SubscriberBuilder {
        return DefaultSubscriberBuilder(connection: connection,
                                        logConfiguration: logConfiguration,
                                        trackingId: trackingId,
                                        resolution: resolution,
                                        delegate: delegate)
    }

    func resolution(_ resolution: Resolution) -> SubscriberBuilder {
        return DefaultSubscriberBuilder(connection: connection,
                                        logConfiguration: logConfiguration,
                                        trackingId: trackingId,
                                        resolution: resolution,
                                        delegate: delegate)
    }

    func delegate(_ delegate: SubscriberDelegate) -> SubscriberBuilder {
        return DefaultSubscriberBuilder(connection: connection,
                                        logConfiguration: logConfiguration,
                                        trackingId: trackingId,
                                        resolution: resolution,
                                        delegate: delegate)
    }
}
