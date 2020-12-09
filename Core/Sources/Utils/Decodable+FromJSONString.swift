import Foundation

extension Decodable {
    static func fromJSONString<T>(_ json: String) -> T? where T: Decodable {
        guard let data = json.data(using: .utf8),
              let result = try? JSONDecoder().decode(T.self, from: data)
        else { return nil }
        return result
    }
}
