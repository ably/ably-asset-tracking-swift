import AblyAssetTrackingPublisher
import Foundation

class MapViewModel: ObservableObject {
    var useMapboxMap: Bool {
        SettingsModel.shared.useMapboxMap
    }

    static func createViewModel(forConnectionState connectionState: ConnectionState?) -> [StackedTextModel] {
        [.init(label: "Connection status:", value: " \(connectionState?.asInfo() ?? "-")")]
    }
}
