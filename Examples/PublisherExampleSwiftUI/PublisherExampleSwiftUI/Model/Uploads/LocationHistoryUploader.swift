import AblyAssetTrackingPublisher
import Foundation

protocol LocationHistoryDataHandlerProtocol {
    func handleLocationHistoryData(_ locationHistoryData: LocationHistoryData)
    func handleRawMapboxData(inTemporaryFile temporaryFile: TemporaryFile)
}

class LocationHistoryDataUploader: LocationHistoryDataHandlerProtocol {
    private let uploadsManager: UploadsManager
    
    init(uploadsManager: UploadsManager) {
        self.uploadsManager = uploadsManager
    }
    
    func handleLocationHistoryData(_ locationHistoryData: LocationHistoryData) {
        Task { @MainActor in
            uploadsManager.upload(locationHistoryData: locationHistoryData)
        }
    }
    
    func handleRawMapboxData(inTemporaryFile temporaryFile: TemporaryFile) {
        Task { @MainActor in
            uploadsManager.uploadRawMapboxData(inTemporaryFile: temporaryFile)
        }
    }
}
