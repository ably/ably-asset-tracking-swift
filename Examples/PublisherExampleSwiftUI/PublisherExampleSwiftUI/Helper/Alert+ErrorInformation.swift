import SwiftUI
import AblyAssetTrackingCore

extension Alert {
    init(title: String, errorInformation: ErrorInformation?) {
        self.init(
            title: Text(title),
            message: Text(errorInformation?.message ?? "")
        )
    }
}
