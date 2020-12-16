import Foundation

public extension Decodable {
    /**
     Utility function to construct given `Decodable` object from  the JSON string.
     - Parameters:
        - json: JSON string encoded with UTF-8
     - Throws:
        - AssetTrackingError.JSONCodingError: Thrown when we are not able to create `Data`object from string
        - Any JSONDecoder error: Thrown by the `JSONDecoder` and just passed forward
     - Returns: Decodable object instance.
     */
    static func fromJSONString<T>(_ json: String) throws -> T where T: Decodable {
        guard let data = json.data(using: .utf8)
        else {
            throw AssetTrackingError.JSONCodingError("Unable to convert given json string to data. json: \(json)")
        }
        return try JSONDecoder().decode(T.self, from: data)
    }
}