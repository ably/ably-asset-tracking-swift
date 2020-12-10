import Foundation

extension Encodable {
    func toJSONString() throws -> String {
        let data = try JSONEncoder().encode(self)
        if let result =  String(data: data, encoding: .utf8) {
            return result
        }
        throw AblyError.JSONCodingError("Unable to convert data object to string.")
    }
}
