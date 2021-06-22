import UIKit

class AddTrackableError: Error, LocalizedError {
    var errorDescription: String?

    init(message: String) {
        errorDescription = message
    }
}
