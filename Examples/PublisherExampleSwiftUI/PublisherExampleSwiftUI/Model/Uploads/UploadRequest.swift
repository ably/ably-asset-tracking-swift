import Foundation
import AblyAssetTrackingPublisher

struct UploadRequest: Codable {
    enum UploadType: CustomStringConvertible, Codable {
        case locationHistoryData(archiveVersion: String)
        
        var description: String {
            switch self {
            case .locationHistoryData:
                return "Location history data"
            }
        }
    }
    
    var type: UploadType
    var generatedAt: Date
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
    
    var filename: String {
        switch type {
        case let .locationHistoryData(archiveVersion):
            let formattedDate = Self.dateFormatter.string(from: generatedAt)
            return "\(archiveVersion)_\(formattedDate)"
        }
    }
}
