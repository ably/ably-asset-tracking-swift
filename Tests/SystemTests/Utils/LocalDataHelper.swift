//

import Foundation
import AblyAssetTrackingCore
import XCTest

class LocalDataHelper {
   
    enum ErrorInfo: Error {
        case fileNotFound(String)
    }
    
    static func parseJsonFromResources<T: Codable>(_ filename: String, type: T.Type) throws -> T {
        guard let fileURL = Bundle.module.url(forResource: filename, withExtension: "json") else {
            throw ErrorInfo.fileNotFound(filename)
        }
        
        let data = try Data(contentsOf: fileURL)
        let decoder = JSONDecoder()

        return try decoder.decode(type, from: data)
    }
}
