import Foundation

extension Encodable {
    /**
     Utility function to construct JSON string from given `Encodable` object.
     - Throws:
        - ErrorInformation of JSONCodingError type when we are not able to create `String` from coded `Data`
        - Any JSONDecoder error: Thrown by the `JSONEncoder` and just passed forward
     - Returns: JSON string encoded with UTF-8
     */
    public func toJSONString() throws -> String {
        let data = try JSONEncoder().encode(self)
        if let result =  String(data: data, encoding: .utf8) {
            return result
        }
        throw ErrorInformation(type: .JSONCodingError(for: "\(data.self)"))
    }
}
