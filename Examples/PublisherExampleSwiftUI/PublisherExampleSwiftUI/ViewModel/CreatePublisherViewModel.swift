//

import Foundation
import SwiftUI
import AblyAssetTrackingPublisher
import Logging

class CreatePublisherViewModel: ObservableObject {
    private let s3Helper: S3Helper?
    private let logger: Logger
    private let locationHistoryDataHandler: LocationHistoryDataHandlerProtocol?

    private var isS3Available: Bool {
        s3Helper != nil
    }

    init(logger: Logger, s3Helper: S3Helper?, locationHistoryDataHandler: LocationHistoryDataHandlerProtocol?) {
        self.s3Helper = s3Helper
        self.logger = logger
        self.locationHistoryDataHandler = locationHistoryDataHandler
    }

    @Published var areRawLocationsEnabled: Bool = SettingsModel.shared.areRawLocationsEnabled {
        didSet {
            SettingsModel.shared.areRawLocationsEnabled = areRawLocationsEnabled
        }
    }

    @Published var isConstantResolutionEnabled: Bool = SettingsModel.shared.isConstantResolutionEnabled {
        didSet {
            SettingsModel.shared.isConstantResolutionEnabled = isConstantResolutionEnabled
        }
    }

    @Published var vehicleProfile: VehicleProfile = SettingsModel.shared.vehicleProfile {
        didSet {
            SettingsModel.shared.vehicleProfile = vehicleProfile
        }
    }

    @Published var routingProfile: RoutingProfile = SettingsModel.shared.routingProfile {
        didSet {
            SettingsModel.shared.routingProfile = routingProfile
        }
    }

    @Published var locationSource: LocationSourceOption = SettingsModel.shared.locationSourceOption {
        didSet {
            SettingsModel.shared.locationSourceOption = locationSource
        }
    }

    @Published var s3FileName: String? = SettingsModel.shared.s3FileName {
        didSet {
            SettingsModel.shared.s3FileName = s3FileName
        }
    }

    @Published var constantResolutionMinimumDisplacement: String  = "\(SettingsModel.shared.constantResolution.minimumDisplacement)"

    var constantResolutionAccuracy: String = SettingsModel.shared.constantResolution.accuracy.rawValue
    var accuracies: [String] {
        [
            Accuracy.low,
            Accuracy.high,
            Accuracy.balanced,
            Accuracy.maximum,
            Accuracy.minimum
        ].sorted().map(\.rawValue)
    }

    var vehicleProfiles: [String] {
        [
            VehicleProfile.bicycle,
            VehicleProfile.car
        ].map { $0.description() }
    }

    var routingProfiles: [String] {
        [
            RoutingProfile.cycling,
            RoutingProfile.driving,
            RoutingProfile.drivingTraffic,
            RoutingProfile.walking
        ].map { $0.description() }
    }

    var locationSources: [String] {
        var sources: [LocationSourceOption] = [.phone]
        if isS3Available {
            sources.append(.s3File)
        }
        return sources.map { $0.description() }
    }

    func save() {
        if let constantAccuracy = Accuracy(rawValue: constantResolutionAccuracy),
           let constantDisplacement = Double(constantResolutionMinimumDisplacement) {
            SettingsModel.shared.constantResolution = .init(
                accuracy: constantAccuracy,
                desiredInterval: .zero,
                minimumDisplacement: constantDisplacement
            )
        }
    }

    @MainActor func createPublisher() async throws -> ObservablePublisher {
        let connectionConfiguration = ConnectionConfiguration(apiKey: EnvironmentHelper.ABLY_API_KEY, clientId: "Asset Tracking Publisher Example")
        let resolution = Resolution(accuracy: .balanced, desiredInterval: 5000, minimumDisplacement: 100)

        let constantResolution: Resolution? = SettingsModel.shared.isConstantResolutionEnabled ? SettingsModel.shared.constantResolution : nil
        let vehicleProfile = SettingsModel.shared.vehicleProfile
        let routingProfile = SettingsModel.shared.routingProfile
        let locationSourceOption = SettingsModel.shared.locationSourceOption

        let areRawLocationsEnabled = SettingsModel.shared.areRawLocationsEnabled

        let locationSource: AblyAssetTrackingPublisher.LocationSource?
        if let s3FileName = SettingsModel.shared.s3FileName, locationSourceOption == .s3File {
            guard let s3Helper else {
                // This ignores the case where we used to have S3 configured on a previous run of the app and still have something hanging around in user defaults, but will ignore that edge case for now.
                fatalError("Trying to use S3 when it has not been configured. This should not have been allowed by the UI.")
            }

            let locationHistoryData = try await s3Helper.downloadHistoryData(fileName: s3FileName)
            locationSource = .init(locationHistoryData: locationHistoryData)
        } else {
            locationSource = nil
        }

        var publisher = try PublisherFactory.publishers()
            .connection(connectionConfiguration)
            .mapboxConfiguration(MapboxConfiguration(mapboxKey: EnvironmentHelper.MAPBOX_ACCESS_TOKEN))
            .locationSource(locationSource)
            .routingProfile(routingProfile)
            .resolutionPolicyFactory(DefaultResolutionPolicyFactory(defaultResolution: resolution))
            .rawLocations(enabled: areRawLocationsEnabled)
            .constantLocationEngineResolution(resolution: constantResolution)
            .logHandler(handler: PublisherLogger(logger: logger))
            .vehicleProfile(vehicleProfile)
            .start()

        let configInfo = ObservablePublisher.PublisherConfigInfo(areRawLocationsEnabled: areRawLocationsEnabled, constantResolution: constantResolution)

        let observablePublisher = ObservablePublisher(publisher: publisher, configInfo: configInfo, locationHistoryDataHandler: locationHistoryDataHandler, logger: logger)
        publisher.delegate = observablePublisher

        return observablePublisher
    }
}
