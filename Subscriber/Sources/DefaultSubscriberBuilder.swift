import UIKit

class DefaultSubscriberBuilder: SubscriberBuilder {
    private var connection: ConnectionConfiguration?
    private var logConfiguration: LogConfiguration?
    private var trackingId: String?
    private var resolution: Resolution?
    private weak var delegate: SubscriberDelegate?
    private weak var delegateObjectiveC: SubscriberDelegateObjectiveC?

    init() { }

    private init(connection: ConnectionConfiguration?,
                 logConfiguration: LogConfiguration?,
                 trackingId: String?,
                 resolution: Resolution?,
                 delegate: SubscriberDelegate?,
                 delegateObjectiveC: SubscriberDelegateObjectiveC?) {
        self.connection = connection
        self.logConfiguration = logConfiguration
        self.trackingId = trackingId
        self.resolution = resolution
        self.delegate = delegate
        self.delegateObjectiveC = delegateObjectiveC
    }

    func start() throws -> Subscriber {
        guard let connection = connection
        else {
            throw ErrorInformation(type: .incompleteConfiguration(missingProperty: "ConnectionConfiguration", forBuilderOption: "connection"))
        }

        guard let logConfiguration = logConfiguration
        else {
            throw ErrorInformation(type: .incompleteConfiguration(missingProperty: "LogConfiguration", forBuilderOption: "log"))
        }

        guard let trackingId = trackingId
        else {
            throw ErrorInformation(type: .incompleteConfiguration(missingProperty: "TrackingId", forBuilderOption: "trackingId"))
        }

        let subscriber = DefaultSubscriber(connectionConfiguration: connection,
                                           logConfiguration: logConfiguration,
                                           trackingId: trackingId,
                                           resolution: resolution)
        subscriber.delegate = delegate
        subscriber.delegateObjectiveC = nil
        subscriber.start()
        return subscriber
    }

    func connection(_ configuration: ConnectionConfiguration) -> SubscriberBuilder {
        return DefaultSubscriberBuilder(connection: configuration,
                                        logConfiguration: logConfiguration,
                                        trackingId: trackingId,
                                        resolution: resolution,
                                        delegate: delegate,
                                        delegateObjectiveC: nil)
    }

    func log(_ configuration: LogConfiguration) -> SubscriberBuilder {
        return DefaultSubscriberBuilder(connection: connection,
                                        logConfiguration: configuration,
                                        trackingId: trackingId,
                                        resolution: resolution,
                                        delegate: delegate,
                                        delegateObjectiveC: nil)
    }

    func trackingId(_ trackingId: String) -> SubscriberBuilder {
        return DefaultSubscriberBuilder(connection: connection,
                                        logConfiguration: logConfiguration,
                                        trackingId: trackingId,
                                        resolution: resolution,
                                        delegate: delegate,
                                        delegateObjectiveC: nil)
    }

    func resolution(_ resolution: Resolution) -> SubscriberBuilder {
        return DefaultSubscriberBuilder(connection: connection,
                                        logConfiguration: logConfiguration,
                                        trackingId: trackingId,
                                        resolution: resolution,
                                        delegate: delegate,
                                        delegateObjectiveC: nil)
    }

    func delegate(_ delegate: SubscriberDelegate) -> SubscriberBuilder {
        return DefaultSubscriberBuilder(connection: connection,
                                        logConfiguration: logConfiguration,
                                        trackingId: trackingId,
                                        resolution: resolution,
                                        delegate: delegate,
                                        delegateObjectiveC: nil)
    }
}

extension DefaultSubscriberBuilder: SubscriberBuilderObjectiveC {
    func start() throws -> SubscriberObjectiveC {
        guard let connection = connection
        else {
            throw ErrorInformation(type: .incompleteConfiguration(missingProperty: "ConnectionConfiguration", forBuilderOption: "connection"))
        }

        guard let logConfiguration = logConfiguration
        else {
            throw ErrorInformation(type: .incompleteConfiguration(missingProperty: "LogConfiguration", forBuilderOption: "log"))
        }

        guard let trackingId = trackingId
        else {
            throw ErrorInformation(type: .incompleteConfiguration(missingProperty: "TrackingId", forBuilderOption: "trackingId"))
        }

        let subscriber = DefaultSubscriber(connectionConfiguration: connection,
                                           logConfiguration: logConfiguration,
                                           trackingId: trackingId,
                                           resolution: resolution)
        subscriber.delegate = nil
        subscriber.delegateObjectiveC = delegateObjectiveC
        subscriber.start()
        return subscriber
    }
    
    func connection(_ configuration: ConnectionConfiguration) -> SubscriberBuilderObjectiveC {
        return DefaultSubscriberBuilder(connection: configuration,
                                        logConfiguration: logConfiguration,
                                        trackingId: trackingId,
                                        resolution: resolution,
                                        delegate: nil,
                                        delegateObjectiveC: delegateObjectiveC)
    }
    
    func trackingId(_ trackingId: String) -> SubscriberBuilderObjectiveC {
        return DefaultSubscriberBuilder(connection: connection,
                                        logConfiguration: logConfiguration,
                                        trackingId: trackingId,
                                        resolution: resolution,
                                        delegate: nil,
                                        delegateObjectiveC: delegateObjectiveC)
    }
    
    func resolution(_ resolution: Resolution) -> SubscriberBuilderObjectiveC {
        return DefaultSubscriberBuilder(connection: connection,
                                        logConfiguration: logConfiguration,
                                        trackingId: trackingId,
                                        resolution: resolution,
                                        delegate: nil,
                                        delegateObjectiveC: delegateObjectiveC)
    }
    
    func delegate(_ delegate: SubscriberDelegateObjectiveC) -> SubscriberBuilderObjectiveC {
        return DefaultSubscriberBuilder(connection: connection,
                                        logConfiguration: logConfiguration,
                                        trackingId: trackingId,
                                        resolution: resolution,
                                        delegate: nil,
                                        delegateObjectiveC: delegate)
    }
    
    func log(_ configuration: LogConfiguration) -> SubscriberBuilderObjectiveC {
        return DefaultSubscriberBuilder(connection: connection,
                                        logConfiguration: configuration,
                                        trackingId: trackingId,
                                        resolution: resolution,
                                        delegate: nil,
                                        delegateObjectiveC: delegateObjectiveC)
    }
}
