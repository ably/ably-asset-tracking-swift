import Foundation
import AblyAssetTrackingCore

extension ErrorInformation {
    func isEqual(to error: ErrorInformation) -> Bool {
        self.code == error.code &&
        self.message == error.message &&
        self.href == error.href &&
        self.statusCode == error.statusCode
    }
}
