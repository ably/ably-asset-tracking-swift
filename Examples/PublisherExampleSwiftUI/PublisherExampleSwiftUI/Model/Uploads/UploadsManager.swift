import Foundation
import Combine
import AblyAssetTrackingPublisher
import Logging

class UploadsManager: ObservableObject {
    @MainActor @Published private(set) var uploads: [Upload]
    private let s3Helper: S3Helper?
    private let logger: Logger
    
    @MainActor init(s3Helper: S3Helper?, logger: Logger) {
        do {
            self.uploads = try Storage.allUploads
        } catch {
            logger.error("Failed to load uploads: \(error)")
            self.uploads = []
        }
        self.s3Helper = s3Helper
        self.logger = logger
    }
    
    enum Storage {
        private static let fileManager = FileManager.default
        
        static var allUploads: [Upload] {
            get throws {
                let contents = try fileManager.contentsOfDirectory(at: try uploadsDirectoryURL, includingPropertiesForKeys: nil)
                
                return try contents.map { url in
                    let uploadId = url.lastPathComponent
                    let storageDirectoryURL = try Storage.storageDirectoryURL(forUploadId: uploadId)
                    let metadataURL = Storage.metadataURL(forStorageDirectoryURL: storageDirectoryURL)
                    let metadata = try Data(contentsOf: metadataURL)
                    
                    let decoder = JSONDecoder()
                    return try decoder.decode(Upload.self, from: metadata)
                }
            }
        }
        
        static func ensureStorageDirectoryExists(atURL storageDirectoryURL: URL) throws {
            if !fileManager.fileExists(atPath: storageDirectoryURL.path, isDirectory: nil) {
                try fileManager.createDirectory(at: storageDirectoryURL, withIntermediateDirectories: true)
            }
        }
        
        static var uploadsDirectoryURL: URL {
            get throws {
                let applicationSupportURL = try fileManager.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                
                return applicationSupportURL
                    .appendingPathComponent("com.ably.tracking.example.publisher")
                    .appendingPathComponent("uploads")
            }
        }
        
        static func storageDirectoryURL(forUploadId uploadId: String) throws -> URL {
            return try uploadsDirectoryURL.appendingPathComponent(uploadId)
        }
        
        static func metadataURL(forStorageDirectoryURL storageDirectoryURL: URL) -> URL {
            return storageDirectoryURL.appendingPathComponent("upload")
        }
        
        static func dataURL(forStorageDirectoryURL storageDirectoryURL: URL) -> URL {
            return storageDirectoryURL.appendingPathComponent("data")
        }
    }
    
    @MainActor func upload(locationHistoryData: LocationHistoryData) {
        guard let s3Helper = s3Helper else {
            logger.info("Skipping upload of location history data since S3 is not configured")
            return
        }
        
        let uploadId = UUID()
        let dataFileURL: URL
        do {
            let storageDirectoryURL = try Storage.storageDirectoryURL(forUploadId: uploadId.uuidString)
            try Storage.ensureStorageDirectoryExists(atURL: storageDirectoryURL)
            dataFileURL = Storage.dataURL(forStorageDirectoryURL: storageDirectoryURL)
            
            let data = try JSONEncoder().encode(locationHistoryData)
            try data.write(to: dataFileURL)
            logger.debug("Wrote location history data to file: \(dataFileURL.path)")
        } catch {
            logger.error("Failed to write location history data to file: \(error)")
            return
        }
        
        let request = UploadRequest(type: .locationHistoryData(archiveVersion: LocationHistoryData.archiveVersion), generatedAt: Date())
        
        let upload = Upload(id: uploadId, request: request, status: .uploading)
        logger.info("Starting upload \(upload.id) of location history data")
        uploads.insert(upload, at: 0)
        do {
            try saveUpload(upload)
        } catch {
            logger.error("Failed to save upload \(upload.id): \(error)")
        }
        
        Task {
            do {
                try await s3Helper.upload(request, dataFileURL: dataFileURL)
            } catch {
                logger.error("Upload \(upload.id) of location history data failed: \(error.localizedDescription)")
                updateStatus(forUploadWithId: upload.id, status: .failed(error.localizedDescription))
                return
            }
            
            logger.info("Upload \(upload.id) of location history data succeeded.")
            updateStatus(forUploadWithId: upload.id, status: .uploaded)
        }
    }
    
    @MainActor private func updateStatus(forUploadWithId id: UUID, status: Upload.Status) {
        guard let index = uploads.firstIndex(where: { $0.id == id }) else {
            return
        }
        
        var upload = uploads[index]
        upload.status = status
        uploads[index] = upload
        do {
            try saveUpload(upload)
        } catch {
            logger.error("Failed to save upload \(upload.id): \(error)")
        }
    }
    
    private func saveUpload(_ upload: Upload) throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(upload)
        
        let storageDirectoryURL = try Storage.storageDirectoryURL(forUploadId: upload.id.uuidString)
        let metadataURL = Storage.metadataURL(forStorageDirectoryURL: storageDirectoryURL)
        try data.write(to: metadataURL)
    }
}
