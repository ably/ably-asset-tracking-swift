import Amplify
import AmplifyPlugins
import CoreLocation

struct S3Error: Error {
    let message: String?
    
    init(error: Error) {
        message = error.localizedDescription
    }
    
    init(message: String) {
        self.message = message
    }
}

class S3Service {
    private var isInitialized = false;
    private var dateFormatter: DateFormatter?
    
    init() {
        setupDateFormatter()
    }
    
    func configure(_ completion: ((Result<Void, S3Error>) -> Void)?) {
        if !isConfigurationFile() {
            completion?(.failure(S3Error(message: "Configuration file does not exist or is empty.")))
            return
        }
        
        do {
            try Amplify.add(plugin: AWSCognitoAuthPlugin())
            try Amplify.add(plugin: AWSS3StoragePlugin())
            try Amplify.configure()
        } catch {
            completion?(.failure(S3Error(error: error)))
        }
        
        isInitialized.toggle()
        completion?(.success(()))
    }
    
    private func isConfigurationFile() -> Bool {
        let fileManager =  FileManager()

        guard let configFilePath = Bundle.main.path(forResource: "amplifyconfiguration", ofType: "json"),
              fileManager.fileExists(atPath: configFilePath) else {
            return false
        }
        
        do {
            let attributes = try fileManager.attributesOfItem(atPath: configFilePath)
            if let size = attributes[FileAttributeKey.size] as? Float, size > 1 {
                return true
            }
            
            return false
        } catch {
            return false
        }
    }
    
    func uploadHistoryData(_ historyData: String, completion: ((Result<Void, S3Error>) -> Void)?) {
        
        guard isInitialized,
              let fileName = dateFormatter?.string(from: Date()),
              let dataToUpload = historyData.data(using: .utf8)
        else {
            return
        }
        
        Amplify.Storage.uploadData(key: fileName, data: dataToUpload, progressListener: { progress in
            print("Upload progress: \(progress)")
        }) { result in
            switch result {
            case .success(let data):
                print("Upload completed: \(data)")
                completion?(.success(()))
            case .failure(let error):
                print("Upload failed: \(error.errorDescription)")
                completion?(.failure(S3Error(message: error.errorDescription)))
            }
        }
    }
    
    func downloadHistoryData(_ fileName: String, completion: ((Result<String, S3Error>) -> Void)?) {
        guard isInitialized,
              !fileName.isEmpty else {
            return
        }
        
        
        Amplify.Storage.downloadData(key: fileName) { result in
            switch result {
            case .success(let data):
                print("Download completed: \(data)")
                completion?(.success(("")))
            case .failure(let error):
                print("Download failed: \(error.errorDescription)")
                completion?(.failure(S3Error(message: error.errorDescription)))
            }
        }
    }
    
    private func setupDateFormatter() {
        dateFormatter = DateFormatter()
        dateFormatter?.dateFormat = "yyyy-MM-dd_HH:mm:ss"
    }
}
