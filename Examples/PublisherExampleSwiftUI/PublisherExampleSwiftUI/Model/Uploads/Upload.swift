import Foundation

struct Upload: Identifiable {
    var id = UUID()
    var request: UploadRequest
    
    enum Status: CustomStringConvertible {
        case uploading
        case uploaded
        case failed(Error)
        
        var description: String {
            switch self {
            case .uploading: return "Uploading"
            case .uploaded: return "Uploaded"
            case .failed(let error): return "Failed: \(error.localizedDescription)"
            }
        }
    }
    
    var status: Status
}
