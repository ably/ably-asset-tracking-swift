import Foundation

// swiftlint:disable identifier_name
public enum Environment {
    private static let infoDictionary: [String: Any] = {
        guard let dict = Bundle.main.infoDictionary else {
            fatalError("Plist file not found")
        }
        return dict
    }()
    
    static let ABLY_API_KEY: String = {
        guard let ablyApiKey = Environment.infoDictionary["ABLY_API_KEY"] as? String else {
            fatalError("ABLY_API_KEY not set in plist for this environment")
        }
        return ablyApiKey
    }()
}
