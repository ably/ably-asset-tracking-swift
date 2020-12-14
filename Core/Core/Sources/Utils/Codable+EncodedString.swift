import Foundation

extension Encodable {
    public func toJSONString() throws -> String {
        let data = try JSONEncoder().encode(self)
        if let result =  String(data: data, encoding: .utf8) {
            return result
        }
        throw AssetTrackingError.JSONCodingError("Unable to convert data object to string.")
    }
}
