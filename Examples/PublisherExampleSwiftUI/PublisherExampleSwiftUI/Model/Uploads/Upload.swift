import Foundation

struct Upload: Identifiable, Codable {
    var id: UUID
    var request: UploadRequest
    
    enum Status: CustomStringConvertible, Codable {
        case uploading
        case uploaded
        case failed(String)
        
        var description: String {
            switch self {
            case .uploading: return "Uploading"
            case .uploaded: return "Uploaded"
            case .failed(let errorDescription): return "Failed: \(errorDescription)"
            }
        }
    }
    
    var status: Status
}
