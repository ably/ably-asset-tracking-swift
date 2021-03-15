import Foundation

// swiftlint:disable identifier_name
// swiftlint:disable missing_docs
public enum Environment {
    private static let infoDictionary: [String: Any] = {
        guard let dict = Bundle.main.infoDictionary else {
            fatalError("Plist file not found")
        }
        return dict
    }()
    
    static let ABLY_API_KEY: String = {
        guard let key = Environment.infoDictionary["ABLY_API_KEY"] as? String else {
            fatalError("ABLY_API_KEY not set in plist for this environment")
        }
        return key
    }()
    
    static let MAPBOX_ACCESS_TOKEN: String = {
        guard let token = Environment.infoDictionary["MAPBOX_ACCESS_TOKEN"] as? String else {
            fatalError("MAPBOX_ACCESS_TOKEN not set in plist for this environment")
        }
        return token
    }()
}
