import UIKit

class SelectDestinationViewModel: ObservableObject {
    var useMapboxMap: Bool {
        SettingsModel.shared.useMapboxMap
    }
}
