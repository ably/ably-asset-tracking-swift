import Foundation
import AblyAssetTrackingCore

public extension Encodable {
    /**
     Utility function to construct JSON string from given `Encodable` object.
     - Throws:
        - ErrorInformation of JSONCodingError type when we are not able to create `String` from coded `Data`
        - Any JSONDecoder error: Thrown by the `JSONEncoder` and just passed forward
     - Returns: JSON string encoded with UTF-8
     */
    func toJSONString() throws -> String {
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
    
    /**
     Utility function to construct given `Decodable` object from  Dictionary object.
     - Parameters:
        - dictionary: Dictinary (key:value) object]
     - Returns: Decodable object instance.
     */
    static func fromDictionary<T: Decodable>(_ dictionary: [AnyHashable: Any]) throws -> T {
        let data = try JSONSerialization.data(withJSONObject: dictionary, options: .fragmentsAllowed)
        
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    /**
     Helper function to construct given `Decodable` from `JSON string` or `Dictionary object`.
     - Parameters:
        - input: `String` or `Dictionary` object
     - Returns: Decodable object instance.
     */
    static func fromAny<T: Decodable>(_ input: Any) throws -> T {
        if let json = input as? String {
            return try Self.fromJSONString(json)
        } else if let dictionary = input as? [AnyHashable: Any] {
            return try Self.fromDictionary(dictionary)
        } else {
            throw ErrorInformation(type: .JSONCodingError(for: "Not supported input type\(type(of: input))"))
        }
    }
}
