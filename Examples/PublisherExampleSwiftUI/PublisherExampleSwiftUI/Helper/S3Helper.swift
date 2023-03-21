import Foundation
import AblyAssetTrackingPublisher
import Amplify
import AWSCognitoAuthPlugin
import AWSS3StoragePlugin

class S3Helper {
    struct File {
        let name: String
        let size: Int?

        var readableSize: String? {
            guard let size else {
                return nil
            }

            let formatter = ByteCountFormatter()
            formatter.allowedUnits = .useAll
            formatter.countStyle = .file

            return formatter.string(fromByteCount: Int64(size))
        }
    }

    enum Error: Swift.Error {
        /// The amplifyconfiguration.json file could not be found. If init() throws this error, this means that the S3 functionality is unavailable to the application, and the UI should reflect this fact.
        case couldNotFindConfiguration
    }

    private static var hasConfiguredAmplify = false

    init() throws {
        guard !Self.hasConfiguredAmplify else {
            return
        }

        // Trying to configure Amplify more than once gives an error
        Self.hasConfiguredAmplify = true

        try Amplify.add(plugin: AWSCognitoAuthPlugin())
        try Amplify.add(plugin: AWSS3StoragePlugin())
        guard let url = Bundle.main.url(
            forResource: "amplifyconfiguration",
            withExtension: "json",
            subdirectory: "Optional Resources"
        ) else {
            throw Error.couldNotFindConfiguration
        }
        let config = try AmplifyConfiguration(configurationFile: url)
        try Amplify.configure(config)
    }

    func fetchLocationHistoryFilenames() async throws -> [File] {
        let listResult = try await Amplify.Storage.list()
        return listResult.items.map({ File(name: $0.key, size: $0.size) })
    }

    func downloadHistoryData(fileName: String) async throws -> LocationHistoryData {
        let task = try await Amplify.Storage.downloadData(key: fileName)
        let data = try await task.value
        let object = try JSONDecoder().decode(LocationHistoryData.self, from: data)
        return object
    }

    func upload(_ request: UploadRequest, dataFileURL: URL) async throws {
        let data = try Data(contentsOf: dataFileURL)
        try await Amplify.Storage.uploadData(key: request.filename, data: data)
    }
}
