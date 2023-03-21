import Foundation
import AblyAssetTrackingPublisher
import AblyAssetTrackingCore

struct PublisherInfoViewModel {
    var rawLocationsInfo: [StackedTextModel]
    var constantResolutionInfo: [StackedTextModel]
    var resolutionInfo: [StackedTextModel]
    var routingProfileInfo: [StackedTextModel]
    var errorInfo: String?
}

extension PublisherInfoViewModel {
    static func create(fromPublisherConfigInfo publisherConfigInfo: ObservablePublisher.PublisherConfigInfo, resolution: Resolution?, routingProfile: RoutingProfile?, lastError: ErrorInformation?) -> PublisherInfoViewModel {
        let rawLocationsInfo: [StackedTextModel] = [.init(label: "Publish raw locations: ", value: "\(publisherConfigInfo.areRawLocationsEnabled ? "enabled" : "disabled")")]

        var constantResolutionInfo: [StackedTextModel] = []
        if let constantResolution = publisherConfigInfo.constantResolution {
            constantResolutionInfo.append(.init(label: "Constant engine resolution", value: "", isHeader: true))
            constantResolutionInfo.append(.init(label: "Desired accuracy: ", value: "\(constantResolution.accuracy)"))
            constantResolutionInfo.append(.init(label: "Min displacement: ", value: "\(constantResolution.minimumDisplacement)m"))
        } else {
            constantResolutionInfo.append(.init(label: "Constant resolution: ", value: "disabled"))
        }

        var resolutionInfo: [StackedTextModel] = []
        resolutionInfo.append(.init(label: "Resolution policy", value: "", isHeader: true))
        if let resolution {
            resolutionInfo.append(StackedTextModel(label: "Accurancy:", value: " \(resolution.accuracy.asInfo())"))
            resolutionInfo.append(StackedTextModel(label: "Min. displacement:", value: " \(resolution.minimumDisplacement)m"))
            resolutionInfo.append(StackedTextModel(label: "Desired interval:", value: " \(resolution.desiredInterval)ms"))
        } else {
            resolutionInfo.append(StackedTextModel(label: "Accurancy:", value: " -"))
            resolutionInfo.append(StackedTextModel(label: "Min. displacement:", value: " -"))
            resolutionInfo.append(StackedTextModel(label: "Desired interval:", value: " -"))
        }

        let routingProfileInfo = [StackedTextModel(label: "Routing profile:", value: " \(routingProfile?.asInfo() ?? "-")")]

        let errorInfo: String?

        if let lastError {
            errorInfo = """
        Code: \(lastError.code)
        Status code: \(lastError.statusCode)

        \(lastError.message)
        """
        } else {
            errorInfo = nil
        }

        return .init(rawLocationsInfo: rawLocationsInfo, constantResolutionInfo: constantResolutionInfo, resolutionInfo: resolutionInfo, routingProfileInfo: routingProfileInfo, errorInfo: errorInfo)
    }
}

private extension Accuracy {
    func asInfo() -> String {
        switch self {
        case .minimum:
            return "Minimum"
        case .low:
            return "Low"
        case .balanced:
            return "Balanced"
        case .high:
            return "High"
        case .maximum:
            return "Maximum"
        }
    }
}
