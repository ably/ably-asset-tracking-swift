import XCTest
@testable import AblyAssetTrackingPublisher
import AblyAssetTrackingTesting
import AblyAssetTrackingPublisherTesting

final class NetworkConnectivityTests: XCTestCase {
    private let faultProxyExpectationTimeout: TimeInterval = 10

    struct PublisherTestEnvironment {
        var publisher: Publisher
        var delegate: MockPublisherDelegate
    }

    private func createPublisher() -> PublisherTestEnvironment {
        // This publisher setup is copied from Android at commit 7f05c3c.
        /*
         val resolution = Resolution(Accuracy.BALANCED, 1000L, 0.0)
         val ablySdkFactory = object : AblySdkFactory<DefaultAblySdkChannelStateListener> {
             override fun createRealtime(clientOptions: ClientOptions) =
                 DefaultAblySdkRealtime(proxyClientOptions)

             override fun wrapChannelStateListener(
                 underlyingListener: AblySdkFactory.UnderlyingChannelStateListener<DefaultAblySdkChannelStateListener>
             ) = DefaultAblySdkChannelStateListener(underlyingListener)
         }
         val connectionConfiguration = ConnectionConfiguration(
             Authentication.basic(
                 proxyClientOptions.clientId,
                 proxyClientOptions.key
             )
         )
         val coroutineScope = CoroutineScope(Dispatchers.IO + SupervisorJob())
         return DefaultPublisher(
             DefaultAbly(
                 ablySdkFactory,
                 connectionConfiguration,
                 Logging.aatDebugLogger,
                 coroutineScope
             ),
             DefaultMapbox(
                 context,
                 MapConfiguration(MAPBOX_ACCESS_TOKEN),
                 connectionConfiguration,
                 LocationSourceFlow(createAblyLocationSource(locationChannelName)),
                 logHandler = Logging.aatDebugLogger,
                 object : PublisherNotificationProvider {
                     override fun getNotification(): Notification =
                         NotificationCompat.Builder(context, NOTIFICATION_CHANNEL_ID)
                             .setContentTitle("TEST")
                             .setContentText("Test")
                             .setSmallIcon(R.drawable.aat_logo)
                             .build()
                 },
                 notificationId = 12345,
                 rawHistoryCallback = null,
                 resolution,
                 VehicleProfile.BICYCLE
             ),
             resolutionPolicyFactory = DefaultResolutionPolicyFactory(resolution, context),
             routingProfile = RoutingProfile.CYCLING,
             logHandler = Logging.aatDebugLogger,
             areRawLocationsEnabled = true,
             sendResolutionEnabled = true,
             constantLocationEngineResolution = resolution
         )
         */

        let resolution = Resolution(accuracy: .balanced, desiredInterval: 1000, minimumDisplacement: 0)

        // TODO we need to connect to the proxy
        let connectionConfiguration = ConnectionConfiguration(apiKey: Secrets.ablyApiKey, clientId: "TODO")
        let mapboxConfiguration = MapboxConfiguration(mapboxKey: Secrets.mapboxAccessToken)
        let resolutionPolicyFactory = DefaultResolutionPolicyFactory(defaultResolution: resolution)

        let delegate = MockPublisherDelegate()

        let publisher = buildPublisher(usingProperties: .init(delegate: delegate,
                                                              mapboxConfiguration: mapboxConfiguration,
                                                              resolutionPolicyFactory: resolutionPolicyFactory))

        return .init(publisher: publisher, delegate: delegate)
    }

    private struct BuilderProperties {
        var delegate: PublisherDelegate
        var mapboxConfiguration: MapboxConfiguration
        var resolutionPolicyFactory: ResolutionPolicyFactory
    }

    private func buildPublisher(usingProperties properties: BuilderProperties) -> Publisher {
        // These are copied from DefaultPublisherBuilder
        let defaultPublisherBuilderProperties = (
            routingProfile: RoutingProfile.driving,
            areRawLocationsEnabled: false,
            isSendResolutionEnabled: true,
            vehicleProfile: VehicleProfile.car
        )

        let internalLogHandler = TestLogging.sharedInternalLogHandler

        /*
        let defaultAbly = DefaultAbly(
            factory: AblyCocoaSDKRealtimeFactory(),
            configuration: connection,
            mode: .publish,
            logHandler: hierarchicalLogHandler
        )
         */

        /*
        let locationService = DefaultLocationService(mapboxConfiguration: mapboxConfiguration,
                                                     historyLocation: locationSource?.locations,
                                                     logHandler: hierarchicalLogHandler,
                                                     vehicleProfile: vehicleProfile)
         */

        let routeProvider = DefaultRouteProvider(mapboxConfiguration: properties.mapboxConfiguration)

        let publisher =  DefaultPublisher(routingProfile: defaultPublisherBuilderProperties.routingProfile,
                                          resolutionPolicyFactory: properties.resolutionPolicyFactory,
                                          ablyPublisher: defaultAbly,
                                          locationService: locationService,
                                          routeProvider: routeProvider,
                                          areRawLocationsEnabled: defaultPublisherBuilderProperties.areRawLocationsEnabled,
                                          isSendResolutionEnabled: defaultPublisherBuilderProperties.isSendResolutionEnabled,
                                          constantLocationEngineResolution: properties.constantLocationEngineResolution,
                                          logHandler: internalLogHandler)
        publisher.delegate = properties.delegate
        return publisher
    }

    func testConnectToProxy() {
        continueAfterFailure = false

        let testEnvironment = createPublisher()

        let onlineStateExpectation = expectation(description: "trackable state changes to online")
        testEnvironment.delegate.publisherDidChangeTrackableConnectionStateCallback = {
            // TODO why is this never called? (until I stop the publisher)
            NSLog("Got state \(testEnvironment.delegate.publisherDidChangeTrackableConnectionStateParamState!)")

            if testEnvironment.delegate.publisherDidChangeTrackableConnectionStateParamState == .online {
                onlineStateExpectation.fulfill()
            }
        }

        // TODO this is no good now, the publisher is gonna start before the delegate has a chance to do anything

        let trackable = Trackable(id: UUID().uuidString)

        let trackExpectation = expectation(description: "trackable track completes")

        // TODO what is this completion handler? this is different to Android. there's also no way of knowing the initial state of the trackable
        testEnvironment.publisher.track(trackable: trackable) { result in
            do {
                try result.get()
            } catch {
                XCTFail("Trackable track failed: \(error))")
            }
            trackExpectation.fulfill()
        }

        wait(for: [trackExpectation, onlineStateExpectation], timeout: 10)

        let stopExpectation = expectation(description: "publisher stop completes")
        testEnvironment.publisher.stop { result in
            stopExpectation.fulfill()
        }

        wait(for: [stopExpectation], timeout: 10)
    }

    // This test is just a temporary one to demonstrate that the SDK test proxy client is working.
    func testSDKTestProxyClient() {
        let client = SDKTestProxyClient()

        // Get names of all faults

        let getAllFaultsExpectation = expectation(description: "get all faults")
        var faultNames: [String]!

        client.getAllFaults { result in
            do {
                faultNames = try result.get()
            } catch {
                XCTFail("Failed to getAllFaults (\(error))")
            }

            getAllFaultsExpectation.fulfill()
        }

        wait(for: [getAllFaultsExpectation], timeout: faultProxyExpectationTimeout)

        // Create a fault simulation

        let faultName = faultNames[0]

        let createFaultSimulationExpectation = expectation(description: "create fault simulation")
        var faultSimulationDto: FaultSimulationDTO!

        client.createFaultSimulation(withName: faultName) { result in
            do {
                faultSimulationDto = try result.get()
            } catch {
                XCTFail("Failed to create fault simulation (\(error))")
            }

            createFaultSimulationExpectation.fulfill()
        }

        wait(for: [createFaultSimulationExpectation], timeout: faultProxyExpectationTimeout)

        // Enable the fault simulation

        let enableFaultSimulationExpectation = expectation(description: "enable fault simulation")

        client.enableFaultSimulation(withID: faultSimulationDto.id) { result in
            do {
                try result.get()
            } catch {
                XCTFail("Failed to enable fault simulation (\(error))")
            }

            enableFaultSimulationExpectation.fulfill()
        }

        wait(for: [enableFaultSimulationExpectation], timeout: faultProxyExpectationTimeout)

        // Resolve the fault simulation

        let resolveFaultSimulationExpectation = expectation(description: "resolve fault simulation")

        client.resolveFaultSimulation(withID: faultSimulationDto.id) { result in
            do {
                try result.get()
            } catch {
                XCTFail("Failed to resolve fault simulation (\(error))")
            }

            resolveFaultSimulationExpectation.fulfill()
        }

        wait(for: [resolveFaultSimulationExpectation], timeout: faultProxyExpectationTimeout)

        // Clean up the fault simulation

        let cleanUpFaultSimulationExpectation = expectation(description: "clean up fault simulation")

        client.cleanUpFaultSimulation(withID: faultSimulationDto.id) { result in
            do {
                try result.get()
            } catch {
                XCTFail("Failed to clean up fault simulation (\(error))")
            }

            cleanUpFaultSimulationExpectation.fulfill()
        }

        wait(for: [cleanUpFaultSimulationExpectation], timeout: faultProxyExpectationTimeout)
    }
}
