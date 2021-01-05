import UIKit

class DefaultPublisherBuilder: PublisherBuilder {
    private var connection: ConnectionConfiguration?
    private var logConfiguration: LogConfiguration?
    private var transportationMode: TransportationMode?
    private var resolutionPolicyFactory: ResolutionPolicyFactory?
    private weak var delegate: PublisherDelegate?

    init() { }

    private init(connection: ConnectionConfiguration?,
                 logConfiguration: LogConfiguration?,
                 transportationMode: TransportationMode?,
                 delegate: PublisherDelegate?,
                 resolutionPolicyFactory: ResolutionPolicyFactory?) {
        self.connection = connection
        self.logConfiguration = logConfiguration
        self.transportationMode = transportationMode
        self.delegate = delegate
        self.resolutionPolicyFactory = resolutionPolicyFactory
    }

    func start() throws -> Publisher {
        guard let connection = connection
        else {
            throw AssetTrackingError.incompleteConfiguration(
                "Missing mandatory property: ConnectionConfiguration. Did you forgot to call `connection` on builder object?"
            )
        }

        guard let logConfiguration = logConfiguration
        else {
            throw AssetTrackingError.incompleteConfiguration(
                "Missing mandatory property: LogConfiguration. Did you forgot to call `log` on builder object?"
            )
        }

        guard let transportationMode = transportationMode
        else {
            throw AssetTrackingError.incompleteConfiguration(
                "Missing mandatory property: TransportationMode. Did you forgot to call `transportationMode` on builder object?"
            )
        }

        guard let resolutionPolicyFactory = resolutionPolicyFactory
        else {
            throw AssetTrackingError.incompleteConfiguration(
                "Missing mandatory property: ResolutionPolicyFactory. Did you forgot to call `resolutionPolicyFactory` on builder object?"
            )
        }

        let publisher =  DefaultPublisher(connectionConfiguration: connection,
                                          logConfiguration: logConfiguration,
                                          transportationMode: transportationMode,
                                          resolutionPolicyFactory: resolutionPolicyFactory,
                                          ablyService: DefaultAblyPublisherService(configuration: connection),
                                          locationService: DefaultLocationService())
        publisher.delegate = delegate
        return publisher
    }

    func connection(_ configuration: ConnectionConfiguration) -> PublisherBuilder {
        return DefaultPublisherBuilder(connection: configuration,
                                       logConfiguration: logConfiguration,
                                       transportationMode: transportationMode,
                                       delegate: delegate,
                                       resolutionPolicyFactory: resolutionPolicyFactory)
    }

    func log(_ configuration: LogConfiguration) -> PublisherBuilder {
        return DefaultPublisherBuilder(connection: connection,
                                       logConfiguration: configuration,
                                       transportationMode: transportationMode,
                                       delegate: delegate,
                                       resolutionPolicyFactory: resolutionPolicyFactory)
    }

    func transportationMode(_ transportationMode: TransportationMode) -> PublisherBuilder {
        return DefaultPublisherBuilder(connection: connection,
                                       logConfiguration: logConfiguration,
                                       transportationMode: transportationMode,
                                       delegate: delegate,
                                       resolutionPolicyFactory: resolutionPolicyFactory)
    }

    func delegate(_ delegate: PublisherDelegate) -> PublisherBuilder {
        return DefaultPublisherBuilder(connection: connection,
                                       logConfiguration: logConfiguration,
                                       transportationMode: transportationMode,
                                       delegate: delegate,
                                       resolutionPolicyFactory: resolutionPolicyFactory)
    }

    func resolutionPolicyFactory(_ resolutionPolicyFactory: ResolutionPolicyFactory) -> PublisherBuilder {
        return DefaultPublisherBuilder(connection: connection,
                                       logConfiguration: logConfiguration,
                                       transportationMode: transportationMode,
                                       delegate: delegate,
                                       resolutionPolicyFactory: resolutionPolicyFactory)
    }
}
