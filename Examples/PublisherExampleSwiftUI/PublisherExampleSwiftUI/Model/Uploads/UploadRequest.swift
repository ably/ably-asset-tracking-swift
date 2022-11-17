import Foundation
import AblyAssetTrackingPublisher

struct UploadRequest {
    var data: LocationHistoryData
    var generatedAt: Date
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
    
    var filename: String {
        let formattedDate = Self.dateFormatter.string(from: generatedAt)
        return "\(data.version)_\(formattedDate)"
    }
}
