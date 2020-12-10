import Foundation

extension Decodable {
    static func fromJSONString<T>(_ json: String) throws -> T where T: Decodable {
        guard let data = json.data(using: .utf8)
        else {
            throw AblyError.JSONCodingError("Unable to convert given json string to data. json: \(json)")
        }
        return try JSONDecoder().decode(T.self, from: data)
    }
}
