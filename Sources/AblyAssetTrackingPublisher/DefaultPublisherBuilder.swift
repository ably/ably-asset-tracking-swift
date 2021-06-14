import UIKit
import AblyAssetTrackingCore

@objc
class DefaultPublisherBuilder: NSObject, PublisherBuilder {
    private var connection: ConnectionConfiguration?
    private var mapboxConfiguration: MapboxConfiguration?
    private var locationSource: LocationSource?
    private var logConfiguration: LogConfiguration?
    private var routingProfile: RoutingProfile?
    private var resolutionPolicyFactory: ResolutionPolicyFactory?
    private weak var delegate: PublisherDelegate?
    private weak var delegateObjectiveC: PublisherDelegateObjectiveC?

    override init() { }

    private init(connection: ConnectionConfiguration?,
                 mapboxConfiguration: MapboxConfiguration?,
                 logConfiguration: LogConfiguration?,
                 locationSource: LocationSource?,
                 routingProfile: RoutingProfile?,
                 delegate: PublisherDelegate?,
                 delegateObjectiveC: PublisherDelegateObjectiveC?,
                 resolutionPolicyFactory: ResolutionPolicyFactory?) {
        self.connection = connection
        self.mapboxConfiguration = mapboxConfiguration
        self.logConfiguration = logConfiguration
        self.locationSource = locationSource
        self.routingProfile = routingProfile
        self.delegate = delegate
        self.delegateObjectiveC = delegateObjectiveC
        self.resolutionPolicyFactory = resolutionPolicyFactory
    }

    func start() throws -> Publisher {
        guard let connection = connection
        else {
            throw ErrorInformation(type: .incompleteConfiguration(missingProperty: "ConnectionConfiguration", forBuilderOption: "connection"))
        }
        
        guard let mapboxConfiguration = mapboxConfiguration
        else {
            throw ErrorInformation(type: .incompleteConfiguration(missingProperty: "MapboxConfiguration", forBuilderOption: "mapboxConfiguration"))
        }

        guard let logConfiguration = logConfiguration
        else {
            throw ErrorInformation(type: .incompleteConfiguration(missingProperty: "LogConfiguration", forBuilderOption: "log"))
        }

        guard let routingProfile = routingProfile
        else {
            throw ErrorInformation(type: .incompleteConfiguration(missingProperty: "RoutingProfile", forBuilderOption: "routingProfile"))
        }

        guard let resolutionPolicyFactory = resolutionPolicyFactory
        else {
            throw ErrorInformation(type: .incompleteConfiguration(missingProperty: "ResolutionPolicyFactory", forBuilderOption: "resolutionPolicyFactory"))
        }
        
        let publisher =  DefaultPublisher(connectionConfiguration: connection,
                                          mapboxConfiguration: mapboxConfiguration,
                                          logConfiguration: logConfiguration,
                                          routingProfile: routingProfile,
                                          resolutionPolicyFactory: resolutionPolicyFactory,
                                          ablyService: DefaultAblyPublisherService(configuration: connection),
                                          locationService: DefaultLocationService(mapboxConfiguration: mapboxConfiguration, historyLocation: locationSource?.locationSource),
                                          routeProvider: DefaultRouteProvider(mapboxConfiguration: mapboxConfiguration))
        publisher.delegate = delegate
        publisher.delegateObjectiveC = nil
        return publisher
    }
    
    func connection(_ configuration: ConnectionConfiguration) -> PublisherBuilder {
        return DefaultPublisherBuilder(connection: configuration,
                                       mapboxConfiguration: mapboxConfiguration,
                                       logConfiguration: logConfiguration,
                                       locationSource: locationSource,
                                       routingProfile: routingProfile,
                                       delegate: delegate,
                                       delegateObjectiveC: delegateObjectiveC,
                                       resolutionPolicyFactory: resolutionPolicyFactory)
    }
    
    func mapboxConfiguration(_ mapboxConfiguration: MapboxConfiguration) -> PublisherBuilder {
        return DefaultPublisherBuilder(connection: connection,
                                       mapboxConfiguration: mapboxConfiguration,
                                       logConfiguration: logConfiguration,
                                       locationSource: locationSource,
                                       routingProfile: routingProfile,
                                       delegate: delegate,
                                       delegateObjectiveC: delegateObjectiveC,
                                       resolutionPolicyFactory: resolutionPolicyFactory)
    }
    
    func log(_ configuration: LogConfiguration) -> PublisherBuilder {
        return DefaultPublisherBuilder(connection: connection,
                                       mapboxConfiguration: mapboxConfiguration,
                                       logConfiguration: configuration,
                                       locationSource: locationSource,
                                       routingProfile: routingProfile,
                                       delegate: delegate,
                                       delegateObjectiveC: delegateObjectiveC,
                                       resolutionPolicyFactory: resolutionPolicyFactory)
    }
    
    func locationSource(_ source: LocationSource?) -> PublisherBuilder {
        return DefaultPublisherBuilder(connection: connection,
                                       mapboxConfiguration: mapboxConfiguration,
                                       logConfiguration: logConfiguration,
                                       locationSource: source,
                                       routingProfile: routingProfile,
                                       delegate: delegate,
                                       delegateObjectiveC: delegateObjectiveC,
                                       resolutionPolicyFactory: resolutionPolicyFactory)
    }
    
    func routingProfile(_ profile: RoutingProfile) -> PublisherBuilder {
        return DefaultPublisherBuilder(connection: connection,
                                       mapboxConfiguration: mapboxConfiguration,
                                       logConfiguration: logConfiguration,
                                       locationSource: locationSource,
                                       routingProfile: profile,
                                       delegate: delegate,
                                       delegateObjectiveC: delegateObjectiveC,
                                       resolutionPolicyFactory: resolutionPolicyFactory)
    }

    func delegate(_ delegate: PublisherDelegate) -> PublisherBuilder {
        return DefaultPublisherBuilder(connection: connection,
                                       mapboxConfiguration: mapboxConfiguration,
                                       logConfiguration: logConfiguration,
                                       locationSource: locationSource,
                                       routingProfile: routingProfile,
                                       delegate: delegate,
                                       delegateObjectiveC: nil,
                                       resolutionPolicyFactory: resolutionPolicyFactory)
    }
    
    func resolutionPolicyFactory(_ resolutionPolicyFactory: ResolutionPolicyFactory) -> PublisherBuilder {
        return DefaultPublisherBuilder(connection: connection,
                                       mapboxConfiguration: mapboxConfiguration,
                                       logConfiguration: logConfiguration,
                                       locationSource: locationSource,
                                       routingProfile: routingProfile,
                                       delegate: delegate,
                                       delegateObjectiveC: delegateObjectiveC,
                                       resolutionPolicyFactory: resolutionPolicyFactory)
    }
}

extension DefaultPublisherBuilder: PublisherBuilderObjectiveC {
    @objc
    func start() throws -> PublisherObjectiveC {
        guard let connection = connection
        else {
            throw ErrorInformation(type: .incompleteConfiguration(missingProperty: "ConnectionConfiguration", forBuilderOption: "connection"))
        }
        
        guard let mapboxConfiguration = mapboxConfiguration
        else {
            throw ErrorInformation(type: .incompleteConfiguration(missingProperty: "MapboxConfiguration", forBuilderOption: "mapboxConfiguration"))
        }

        guard let logConfiguration = logConfiguration
        else {
            throw ErrorInformation(type: .incompleteConfiguration(missingProperty: "LogConfiguration", forBuilderOption: "log"))
        }

        guard let routingProfile = routingProfile
        else {
            throw ErrorInformation(type: .incompleteConfiguration(missingProperty: "RoutingProfile", forBuilderOption: "routingProfile"))
        }

        guard let resolutionPolicyFactory = resolutionPolicyFactory
        else {
            throw ErrorInformation(type: .incompleteConfiguration(missingProperty: "ResolutionPolicyFactory", forBuilderOption: "resolutionPolicyFactory"))
        }
        
        let publisher =  DefaultPublisher(connectionConfiguration: connection,
                                          mapboxConfiguration: mapboxConfiguration,
                                          logConfiguration: logConfiguration,
                                          routingProfile: routingProfile,
                                          resolutionPolicyFactory: resolutionPolicyFactory,
                                          ablyService: DefaultAblyPublisherService(configuration: connection),
                                          locationService: DefaultLocationService(mapboxConfiguration: mapboxConfiguration, historyLocation: locationSource?.locationSource),
                                          routeProvider: DefaultRouteProvider(mapboxConfiguration: mapboxConfiguration))
        publisher.delegate = nil
        publisher.delegateObjectiveC = delegateObjectiveC
        return publisher
    }
    
    @objc
    func connection(_ configuration: ConnectionConfiguration) -> PublisherBuilderObjectiveC {
        return DefaultPublisherBuilder(connection: configuration,
                                       mapboxConfiguration: mapboxConfiguration,
                                       logConfiguration: logConfiguration,
                                       locationSource: locationSource,
                                       routingProfile: routingProfile,
                                       delegate: delegate,
                                       delegateObjectiveC: delegateObjectiveC,
                                       resolutionPolicyFactory: resolutionPolicyFactory)
    }
    
    @objc
    func mapboxConfiguration(_ mapboxConfiguration: MapboxConfiguration) -> PublisherBuilderObjectiveC {
        return DefaultPublisherBuilder(connection: connection,
                                       mapboxConfiguration: mapboxConfiguration,
                                       logConfiguration: logConfiguration,
                                       locationSource: locationSource,
                                       routingProfile: routingProfile,
                                       delegate: delegate,
                                       delegateObjectiveC: delegateObjectiveC,
                                       resolutionPolicyFactory: resolutionPolicyFactory)
    }
    
    @objc
    func log(_ configuration: LogConfiguration) -> PublisherBuilderObjectiveC {
        return DefaultPublisherBuilder(connection: connection,
                                       mapboxConfiguration: mapboxConfiguration,
                                       logConfiguration: configuration,
                                       locationSource: locationSource,
                                       routingProfile: routingProfile,
                                       delegate: delegate,
                                       delegateObjectiveC: delegateObjectiveC,
                                       resolutionPolicyFactory: resolutionPolicyFactory)
    }
    
    @objc
    func locationSource(_ source: LocationSource?) -> PublisherBuilderObjectiveC {
        return DefaultPublisherBuilder(connection: connection,
                                       mapboxConfiguration: mapboxConfiguration,
                                       logConfiguration: logConfiguration,
                                       locationSource: source,
                                       routingProfile: routingProfile,
                                       delegate: delegate,
                                       delegateObjectiveC: delegateObjectiveC,
                                       resolutionPolicyFactory: resolutionPolicyFactory)
    }
    
    @objc
    func routingProfile(_ profile: RoutingProfile) -> PublisherBuilderObjectiveC {
        return DefaultPublisherBuilder(connection: connection,
                                       mapboxConfiguration: mapboxConfiguration,
                                       logConfiguration: logConfiguration,
                                       locationSource: locationSource,
                                       routingProfile: profile,
                                       delegate: delegate,
                                       delegateObjectiveC: delegateObjectiveC,
                                       resolutionPolicyFactory: resolutionPolicyFactory)
    }
    
    @objc
    func resolutionPolicyFactory(_ factory: ResolutionPolicyFactory) -> PublisherBuilderObjectiveC {
        return DefaultPublisherBuilder(connection: connection,
                                       mapboxConfiguration: mapboxConfiguration,
                                       logConfiguration: logConfiguration,
                                       locationSource: locationSource,
                                       routingProfile: routingProfile,
                                       delegate: delegate,
                                       delegateObjectiveC: delegateObjectiveC,
                                       resolutionPolicyFactory: factory)
    }
    
    @objc
    func delegate(_ delegate: PublisherDelegateObjectiveC) -> PublisherBuilderObjectiveC {
        return DefaultPublisherBuilder(connection: connection,
                                       mapboxConfiguration: mapboxConfiguration,
                                       logConfiguration: logConfiguration,
                                       locationSource: locationSource,
                                       routingProfile: routingProfile,
                                       delegate: nil,
                                       delegateObjectiveC: delegate,
                                       resolutionPolicyFactory: resolutionPolicyFactory)
    }
}
