import Foundation

extension UserDefaults {
    func save<T: Codable>(_ object: T, forKey: String) {
        let encoder = JSONEncoder()
        guard let encoded = try? encoder.encode(object) else {
            return
        }

        UserDefaults.standard.set(encoded, forKey: forKey)
    }

    func get<T: Codable>(_ forKey: String) -> T? {
        guard let objectData = UserDefaults.standard.value(forKey: forKey) as? Data else {
            return nil
        }
        let decoder = JSONDecoder()

        return try? decoder.decode(T.self, from: objectData)
    }
}
