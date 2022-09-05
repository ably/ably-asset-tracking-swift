import UIKit
import AblyAssetTrackingCore
import AblyAssetTrackingInternal
import Logging

class DefaultPublisherBuilder: PublisherBuilder {
    private var connection: ConnectionConfiguration?
    private var mapboxConfiguration: MapboxConfiguration?
    private var locationSource: LocationSource?
    private var routingProfile: RoutingProfile = .driving
    private var resolutionPolicyFactory: ResolutionPolicyFactory?
    private var areRawLocationsEnabled: Bool = false
    private var isSendResolutionEnabled: Bool = true
    private var constantLocationEngineResolution: Resolution?
    private weak var delegate: PublisherDelegate?
    
    init() { }
    
    private init(connection: ConnectionConfiguration?,
                 mapboxConfiguration: MapboxConfiguration?,
                 locationSource: LocationSource?,
                 routingProfile: RoutingProfile,
                 delegate: PublisherDelegate?,
                 resolutionPolicyFactory: ResolutionPolicyFactory?,
                 areRawLocationsEnabled: Bool = false,
                 isSendResolutionEnabled: Bool = true,
                 constantLocationEngineResolution: Resolution?) {
        self.connection = connection
        self.mapboxConfiguration = mapboxConfiguration
        self.locationSource = locationSource
        self.routingProfile = routingProfile
        self.delegate = delegate
        self.resolutionPolicyFactory = resolutionPolicyFactory
        self.areRawLocationsEnabled = areRawLocationsEnabled
        self.isSendResolutionEnabled = isSendResolutionEnabled
        self.constantLocationEngineResolution = constantLocationEngineResolution
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
        
        guard let resolutionPolicyFactory = resolutionPolicyFactory
        else {
            throw ErrorInformation(type: .incompleteConfiguration(missingProperty: "ResolutionPolicyFactory", forBuilderOption: "resolutionPolicyFactory"))
        }
        
        let defaultAbly = DefaultAbly(
            factory: AblyCocoaSDKRealtimeFactory(),
            configuration: connection,
            mode: .publish,
            logger: Logger(
                label: "com.ably.tracking.DefaultAbly-Publisher"
            )
        )
        
        let publisher =  DefaultPublisher(connectionConfiguration: connection,
                                          mapboxConfiguration: mapboxConfiguration,
                                          routingProfile: routingProfile,
                                          resolutionPolicyFactory: resolutionPolicyFactory,
                                          ablyPublisher: defaultAbly,
                                          locationService: DefaultLocationService(mapboxConfiguration: mapboxConfiguration, historyLocation: locationSource?.locationSource),
                                          routeProvider: DefaultRouteProvider(mapboxConfiguration: mapboxConfiguration),
                                          areRawLocationsEnabled: areRawLocationsEnabled,
                                          isSendResolutionEnabled: isSendResolutionEnabled,
                                          constantLocationEngineResolution: constantLocationEngineResolution)
        publisher.delegate = delegate
        return publisher
    }
    
    func connection(_ configuration: ConnectionConfiguration) -> PublisherBuilder {
        return DefaultPublisherBuilder(connection: configuration,
                                       mapboxConfiguration: mapboxConfiguration,
                                       locationSource: locationSource,
                                       routingProfile: routingProfile,
                                       delegate: delegate,
                                       resolutionPolicyFactory: resolutionPolicyFactory,
                                       areRawLocationsEnabled: areRawLocationsEnabled,
                                       isSendResolutionEnabled: isSendResolutionEnabled,
                                       constantLocationEngineResolution: constantLocationEngineResolution)
    }
    
    func mapboxConfiguration(_ mapboxConfiguration: MapboxConfiguration) -> PublisherBuilder {
        return DefaultPublisherBuilder(connection: connection,
                                       mapboxConfiguration: mapboxConfiguration,
                                       locationSource: locationSource,
                                       routingProfile: routingProfile,
                                       delegate: delegate,
                                       resolutionPolicyFactory: resolutionPolicyFactory,
                                       areRawLocationsEnabled: areRawLocationsEnabled,
                                       isSendResolutionEnabled: isSendResolutionEnabled,
                                       constantLocationEngineResolution: constantLocationEngineResolution)
    }
    
    func locationSource(_ source: LocationSource?) -> PublisherBuilder {
        return DefaultPublisherBuilder(connection: connection,
                                       mapboxConfiguration: mapboxConfiguration,
                                       locationSource: source,
                                       routingProfile: routingProfile,
                                       delegate: delegate,
                                       resolutionPolicyFactory: resolutionPolicyFactory,
                                       areRawLocationsEnabled: areRawLocationsEnabled,
                                       isSendResolutionEnabled: isSendResolutionEnabled,
                                       constantLocationEngineResolution: constantLocationEngineResolution)
    }
    
    func routingProfile(_ profile: RoutingProfile) -> PublisherBuilder {
        return DefaultPublisherBuilder(connection: connection,
                                       mapboxConfiguration: mapboxConfiguration,
                                       locationSource: locationSource,
                                       routingProfile: profile,
                                       delegate: delegate,
                                       resolutionPolicyFactory: resolutionPolicyFactory,
                                       areRawLocationsEnabled: areRawLocationsEnabled,
                                       isSendResolutionEnabled: isSendResolutionEnabled,
                                       constantLocationEngineResolution: constantLocationEngineResolution)
    }
    
    func delegate(_ delegate: PublisherDelegate) -> PublisherBuilder {
        return DefaultPublisherBuilder(connection: connection,
                                       mapboxConfiguration: mapboxConfiguration,
                                       locationSource: locationSource,
                                       routingProfile: routingProfile,
                                       delegate: delegate,
                                       resolutionPolicyFactory: resolutionPolicyFactory,
                                       areRawLocationsEnabled: areRawLocationsEnabled,
                                       isSendResolutionEnabled: isSendResolutionEnabled,
                                       constantLocationEngineResolution: constantLocationEngineResolution)
    }
    
    func resolutionPolicyFactory(_ resolutionPolicyFactory: ResolutionPolicyFactory) -> PublisherBuilder {
        return DefaultPublisherBuilder(connection: connection,
                                       mapboxConfiguration: mapboxConfiguration,
                                       locationSource: locationSource,
                                       routingProfile: routingProfile,
                                       delegate: delegate,
                                       resolutionPolicyFactory: resolutionPolicyFactory,
                                       areRawLocationsEnabled: areRawLocationsEnabled,
                                       isSendResolutionEnabled: isSendResolutionEnabled,
                                       constantLocationEngineResolution: constantLocationEngineResolution)
    }
    
    func rawLocations(enabled: Bool) -> PublisherBuilder {
        return DefaultPublisherBuilder(connection: connection,
                                       mapboxConfiguration: mapboxConfiguration,
                                       locationSource: locationSource,
                                       routingProfile: routingProfile,
                                       delegate: delegate,
                                       resolutionPolicyFactory: resolutionPolicyFactory,
                                       areRawLocationsEnabled: enabled,
                                       isSendResolutionEnabled: isSendResolutionEnabled,
                                       constantLocationEngineResolution: constantLocationEngineResolution)
    }
    
    func constantLocationEngineResolution(resolution: Resolution?) -> PublisherBuilder {
        return DefaultPublisherBuilder(connection: connection,
                                       mapboxConfiguration: mapboxConfiguration,
                                       locationSource: locationSource,
                                       routingProfile: routingProfile,
                                       delegate: delegate,
                                       resolutionPolicyFactory: resolutionPolicyFactory,
                                       areRawLocationsEnabled: areRawLocationsEnabled,
                                       isSendResolutionEnabled: isSendResolutionEnabled,
                                       constantLocationEngineResolution: resolution)
    }
    
    func sendResolution(enabled: Bool) -> PublisherBuilder {
        return DefaultPublisherBuilder(connection: connection,
                                       mapboxConfiguration: mapboxConfiguration,
                                       locationSource: locationSource,
                                       routingProfile: routingProfile,
                                       delegate: delegate,
                                       resolutionPolicyFactory: resolutionPolicyFactory,
                                       areRawLocationsEnabled: areRawLocationsEnabled,
                                       isSendResolutionEnabled: enabled,
                                       constantLocationEngineResolution: constantLocationEngineResolution)
    }
}
