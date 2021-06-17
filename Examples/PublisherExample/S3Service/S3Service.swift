import Amplify
import AmplifyPlugins
import CoreLocation
import AblyAssetTrackingPublisher

struct S3Error: Error {
    let message: String?
    
    init(error: Error) {
        message = error.localizedDescription
    }
    
    init(message: String) {
        self.message = message
    }
}

struct S3File {
    let name: String
    let size: Int?
    
    var sizeDescription: String {
        "\(size ?? 0) kB"
    }
}

struct S3FileEvents: Decodable {
    var events: [GeoJSONMessage]
}

class S3Service {
    private var isInitialized = false
    private var dateFormatter: DateFormatter?
    private let versionPrefix = "v1.0_"
    
    func configure(completion: ((Result<Void, S3Error>) -> Void)?) {
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
        
        setupDateFormatter()
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
    
    func getFilesList(completion: ((Result<[S3File], S3Error>) -> Void)?) {
        guard isInitialized else {
            completion?(.failure(S3Error(message: "Service not available.")))
            return
        }
        
        Amplify.Storage.list { result in
            switch result {
            case .success(let list):
                completion?(.success(list.items.compactMap { S3File(name: $0.key, size: $0.size) }))
            case .failure(let error):
                completion?(.failure(S3Error(message: error.errorDescription)))
            }
        }
    }
    
    func uploadHistoryData(_ historyData: String, completion: ((Result<Void, S3Error>) -> Void)?) {
        
        guard isInitialized,
              let fileName = dateFormatter?.string(from: Date()),
              let dataToUpload = historyData.data(using: .utf8)
        else {
            completion?(.failure(S3Error(message: "Cannot upload data.")))
            return
        }
        
        let fileKey = versionPrefix + fileName
        
        Amplify.Storage.uploadData(key: fileKey,
                                   data: dataToUpload,
                                   progressListener: { progress in
                                            print("Upload progress: \(progress)")
                                        },
                                   resultListener: { result in
                                                switch result {
                                                case .success(let data):
                                                    print("Upload completed: \(data)")
                                                    completion?(.success(()))
                                                case .failure(let error):
                                                    print("Upload failed: \(error.errorDescription)")
                                                    completion?(.failure(S3Error(message: error.errorDescription)))
                                                }
                                            }
        )
    }
    
    func downloadHistoryData(_ fileName: String, completion: ((Result<[CLLocation], S3Error>) -> Void)?) {
        guard isInitialized,
              !fileName.isEmpty else {
            return
        }
        
        Amplify.Storage.downloadData(key: fileName) { result in
            switch result {
            case .success(let data):
                print("Download completed: \(data)")
                do {
                    let events = try self.decode(data)
                    let locations = events.events.compactMap { $0.toCoreLocation() }
                    completion?(.success(locations))
                } catch {
                    completion?(.failure(S3Error(error: error)))
                }
            case .failure(let error):
                print("Download failed: \(error.errorDescription)")
                completion?(.failure(S3Error(message: error.errorDescription)))
            }
        }
    }
    
    private func decode(_ data: Data) throws -> S3FileEvents {
        return try JSONDecoder().decode(S3FileEvents.self, from: data)
    }
    
    private func setupDateFormatter() {
        dateFormatter = DateFormatter()
        dateFormatter?.dateFormat = "yyyy-MM-dd_HH:mm:ss"
    }
}
