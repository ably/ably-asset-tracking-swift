import AblyAssetTrackingPublisher
import Foundation

struct UploadRequest: Codable {
    enum UploadType: CustomStringConvertible, Codable {
        case locationHistoryData(archiveVersion: String)
        case rawMapboxHistory(originalFilename: String)

        var description: String {
            switch self {
            case .locationHistoryData:
                return "Location history data"
            case .rawMapboxHistory:
                return "Raw Mapbox history"
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
        let formattedDate = Self.dateFormatter.string(from: generatedAt)

        switch type {
        case let .locationHistoryData(archiveVersion):
            return "\(archiveVersion)_\(formattedDate)"
        case let .rawMapboxHistory(originalFilename):
            return "RawMapboxHistory/\(formattedDate)_\(originalFilename)"
        }
    }
}
