import SwiftUI

class S3FilesViewModel: ObservableObject {
    @Published var files: [S3Helper.File] = []
    @Published var errorMessage: String?
    @Published var isLoading = false
        
    init(s3Helper: S3Helper?) {
        guard let s3Helper else {
            self.errorMessage = "S3 is not configured."
            return
        }

        isLoading = true
        Task.init {
            do {
                let files = try await s3Helper.fetchLocationHistoryFilenames()
                DispatchQueue.main.async {
                    self.files = files
                }
            } catch {
                self.errorMessage = error.localizedDescription
            }
            
            isLoading = false
        }
    }
}
