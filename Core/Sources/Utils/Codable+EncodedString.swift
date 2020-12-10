import Foundation

extension Encodable {
    func toEncodedJSONString()-> String? {
        guard let data = try? JSONEncoder().encode(self)
        else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
