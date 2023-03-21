import Foundation

/**
 This enum contains global vars accesible from every place in the codebase.
 */
public enum Environment {
    private static let infoDictionary: [String: Any] = {
        guard let dict = Bundle.main.infoDictionary else {
            fatalError("Plist file not found")
        }
        return dict
    }()

    static let ablyApiKey: String = {
        guard let ablyApiKey = Environment.infoDictionary["ABLY_API_KEY"] as? String else {
            fatalError("ABLY_API_KEY not set in plist for this environment")
        }
        return ablyApiKey
    }()
}
