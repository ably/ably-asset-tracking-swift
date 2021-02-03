import UIKit

class DefaultPublisherBuilder: PublisherBuilder {
    private var connection: ConnectionConfiguration?
    private var mapboxConfiguration: MapboxConfiguration?
    private var logConfiguration: LogConfiguration?
    private var routingProfile: RoutingProfile?
    private var resolutionPolicyFactory: ResolutionPolicyFactory?
    private weak var delegate: PublisherDelegate?

    init() { }

    private init(connection: ConnectionConfiguration?,
                 mapboxConfiguration: MapboxConfiguration?,
                 logConfiguration: LogConfiguration?,
                 routingProfile: RoutingProfile?,
                 delegate: PublisherDelegate?,
                 resolutionPolicyFactory: ResolutionPolicyFactory?) {
        self.connection = connection
        self.mapboxConfiguration = mapboxConfiguration
        self.logConfiguration = logConfiguration
        self.routingProfile = routingProfile
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

        guard let mapboxConfiguration = mapboxConfiguration
        else {
            throw AssetTrackingError.incompleteConfiguration(
                "Missing mandatory property: MapboxConfiguration. Did you forgot to call `mapboxConfiguration` on builder object?"
            )
        }

        guard let logConfiguration = logConfiguration
        else {
            throw AssetTrackingError.incompleteConfiguration(
                "Missing mandatory property: LogConfiguration. Did you forgot to call `log` on builder object?"
            )
        }

        guard let routingProfile = routingProfile
        else {
            throw AssetTrackingError.incompleteConfiguration(
                "Missing mandatory property: RoutingProfile. Did you forgot to call `routingProfile` on builder object?"
            )
        }

        guard let resolutionPolicyFactory = resolutionPolicyFactory
        else {
            throw AssetTrackingError.incompleteConfiguration(
                "Missing mandatory property: ResolutionPolicyFactory. Did you forgot to call `resolutionPolicyFactory` on builder object?"
            )
        }

        let publisher =  DefaultPublisher(connectionConfiguration: connection,
                                          mapboxConfiguration: mapboxConfiguration,
                                          logConfiguration: logConfiguration,
                                          routingProfile: routingProfile,
                                          resolutionPolicyFactory: resolutionPolicyFactory,
                                          ablyService: DefaultAblyPublisherService(configuration: connection),
                                          locationService: DefaultLocationService(mapboxConfiguration: mapboxConfiguration),
                                          routeProvider: DefaultRouteProvider(mapboxConfiguration: mapboxConfiguration))
        publisher.delegate = delegate
        return publisher
    }

    func connection(_ configuration: ConnectionConfiguration) -> PublisherBuilder {
        return DefaultPublisherBuilder(connection: configuration,
                                       mapboxConfiguration: mapboxConfiguration,
                                       logConfiguration: logConfiguration,
                                       routingProfile: routingProfile,
                                       delegate: delegate,
                                       resolutionPolicyFactory: resolutionPolicyFactory)
    }

    func mapboxConfiguration(_ mapboxConfiguration: MapboxConfiguration) -> PublisherBuilder {
        return DefaultPublisherBuilder(connection: connection,
                                       mapboxConfiguration: mapboxConfiguration,
                                       logConfiguration: logConfiguration,
                                       routingProfile: routingProfile,
                                       delegate: delegate,
                                       resolutionPolicyFactory: resolutionPolicyFactory)
    }

    func log(_ configuration: LogConfiguration) -> PublisherBuilder {
        return DefaultPublisherBuilder(connection: connection,
                                       mapboxConfiguration: mapboxConfiguration,
                                       logConfiguration: configuration,
                                       routingProfile: routingProfile,
                                       delegate: delegate,
                                       resolutionPolicyFactory: resolutionPolicyFactory)
    }

    func routingProfile(_ profile: RoutingProfile) -> PublisherBuilder {
        return DefaultPublisherBuilder(connection: connection,
                                       mapboxConfiguration: mapboxConfiguration,
                                       logConfiguration: logConfiguration,
                                       routingProfile: profile,
                                       delegate: delegate,
                                       resolutionPolicyFactory: resolutionPolicyFactory)
    }

    func delegate(_ delegate: PublisherDelegate) -> PublisherBuilder {
        return DefaultPublisherBuilder(connection: connection,
                                       mapboxConfiguration: mapboxConfiguration,
                                       logConfiguration: logConfiguration,
                                       routingProfile: routingProfile,
                                       delegate: delegate,
                                       resolutionPolicyFactory: resolutionPolicyFactory)
    }

    func resolutionPolicyFactory(_ resolutionPolicyFactory: ResolutionPolicyFactory) -> PublisherBuilder {
        return DefaultPublisherBuilder(connection: connection,
                                       mapboxConfiguration: mapboxConfiguration,
                                       logConfiguration: logConfiguration,
                                       routingProfile: routingProfile,
                                       delegate: delegate,
                                       resolutionPolicyFactory: resolutionPolicyFactory)
    }
}
