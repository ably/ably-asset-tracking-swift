import Foundation

extension Encodable {
    /**
     Utility function to construct JSON string from given `Encodable` object.
     - Throws:
        - AssetTrackingError.JSONCodingError: Thrown when we are not able to create `String` from coded `Data`
        - Any JSONDecoder error: Thrown by the `JSONEncoder` and just passed forward
     - Returns: JSON string encoded with UTF-8
     */
    public func toJSONString() throws -> String {
        let data = try JSONEncoder().encode(self)
        if let result =  String(data: data, encoding: .utf8) {
            return result
        }
        throw AssetTrackingError.JSONCodingError("Unable to convert data object to string.")
    }
}
