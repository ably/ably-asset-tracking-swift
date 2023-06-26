import AblyAssetTrackingPublisher
import Foundation

class MapViewModel: ObservableObject {
    var useMapboxMap: Bool {
        SettingsModel.shared.useMapboxMap
    }

    static func createViewModel(forTrackableState trackableState: TrackableState?) -> [StackedTextModel] {
        [.init(label: "Trackable state:", value: " \(trackableState?.asInfo() ?? "-")")]
    }
}
