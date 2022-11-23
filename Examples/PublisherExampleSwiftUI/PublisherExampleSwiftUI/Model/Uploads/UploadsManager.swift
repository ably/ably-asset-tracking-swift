import Foundation
import Combine
import AblyAssetTrackingPublisher
import Logging

class UploadsManager: ObservableObject {
    @MainActor @Published private(set) var uploads: [Upload] = []
    private let s3Helper: S3Helper?
    private let logger: Logger
    
    init(s3Helper: S3Helper?, logger: Logger) {
        self.s3Helper = s3Helper
        self.logger = logger
    }
    
    @MainActor func upload(locationHistoryData: LocationHistoryData) {
        guard let s3Helper = s3Helper else {
            logger.info("Skipping upload of location history data since S3 is not configured")
            return
        }
        
        let request = UploadRequest(data: locationHistoryData, generatedAt: Date())
        
        let upload = Upload(request: request, status: .uploading)
        logger.info("Starting upload \(upload.id) of location history data")
        uploads.insert(upload, at: 0)
        
        Task {
            do {
                try await s3Helper.upload(request)
            } catch {
                logger.error("Upload \(upload.id) of location history data failed: \(error.localizedDescription)")
                updateStatus(forUploadWithId: upload.id, status: .failed(error))
            }
            
            logger.info("Upload \(upload.id) of location history data succeeded.")
            updateStatus(forUploadWithId: upload.id, status: .uploaded)
        }
    }
    
    @MainActor private func updateStatus(forUploadWithId id: UUID, status: Upload.Status) {
        guard let index = uploads.firstIndex(where: { $0.id == id }) else {
            return
        }
        
        uploads[index].status = status
    }
}
