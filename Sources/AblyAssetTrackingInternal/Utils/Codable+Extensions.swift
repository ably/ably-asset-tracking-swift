import Foundation

public extension Encodable {
    /**
     Utility function to construct JSON string from given `Encodable` object.
     - Throws:
        - ErrorInformation of JSONCodingError type when we are not able to create `String` from coded `Data`
        - Any JSONDecoder error: Thrown by the `JSONEncoder` and just passed forward
     - Returns: JSON string encoded with UTF-8
     */
    static func toJSONString() throws -> String {
        let data = try JSONEncoder().encode(self)
        if let result =  String(data: data, encoding: .utf8) {
            return result
        }
        throw ErrorInformation(type: .JSONCodingError(for: "\(data.self)"))
    }
}

public extension Decodable {
    /**
     Utility function to construct given `Decodable` object from  the JSON string.
     - Parameters:
        - json: JSON string encoded with UTF-8
     - Throws:
        - ErrorInformation of JSONCodingError type when we are not able to create `Data`object from string
        - Any JSONDecoder error: Thrown by the `JSONDecoder` and just passed forward
     - Returns: Decodable object instance.
     */
    static func fromJSONString<T>(_ json: String) throws -> T where T: Decodable {
        guard let data = json.data(using: .utf8)
        else {
            throw ErrorInformation(type: .JSONCodingError(for: "\(json)"))
        }
        return try JSONDecoder().decode(T.self, from: data)
    }
}
