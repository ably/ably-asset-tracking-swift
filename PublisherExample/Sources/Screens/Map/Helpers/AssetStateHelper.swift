import UIKit

enum LocationState {
    case active
    case pending
    case failed
}
    
class AssetStateHelper {
    static func getColor(for state: LocationState) -> UIColor {
        switch state {
        case .active:
            return .systemGreen
        case .pending:
            return .systemOrange
        case .failed:
            return .systemRed
        }
    }
}
