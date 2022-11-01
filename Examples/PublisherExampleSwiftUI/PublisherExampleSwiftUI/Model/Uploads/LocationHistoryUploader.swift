import AblyAssetTrackingPublisher
import Foundation

protocol LocationHistoryDataHandlerProtocol {
    func handleLocationHistoryData(_ locationHistoryData: LocationHistoryData)
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
}
