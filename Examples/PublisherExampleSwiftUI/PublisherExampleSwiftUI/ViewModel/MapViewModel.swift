import Foundation
import AblyAssetTrackingPublisher

class MapViewModel: ObservableObject {
    var useMapboxMap: Bool {
        SettingsModel.shared.useMapboxMap
    }

    static func createViewModel(forConnectionState connectionState: ConnectionState?) -> [StackedTextModel] {
        return [.init(label: "Connection status:", value: " \(connectionState?.asInfo() ?? "-")")]
    }
}
