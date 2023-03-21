import Foundation

enum LocationSourceOption: Codable {
    case phone
    case s3File
}

extension LocationSourceOption {
    func description() -> String {
        switch self {
        case .phone:
            return "phone"
        case .s3File:
            return "S3 file"
        }
    }
    
    static func fromDescription(description: String) -> LocationSourceOption {
        switch description {
        case "phone":
            return .phone
        case "S3 file":
            return .s3File
        default:
            fatalError("Unknown \(Self.self) for description \(description)")
        }
    }
}
