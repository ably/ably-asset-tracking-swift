import Foundation

public enum EnvironmentHelper {
    private static let infoDictionary: [String: Any] = {
        guard let dict = Bundle.main.infoDictionary else {
            fatalError("Plist file not found")
        }
        return dict
    }()

    static let ablyAPIKey: String = {
        guard let key = EnvironmentHelper.infoDictionary["ABLY_API_KEY"] as? String else {
            fatalError("ABLY_API_KEY not set in plist for this environment")
        }
        return key
    }()

    static let mapboxAccessToken: String = {
        guard let token = EnvironmentHelper.infoDictionary["MAPBOX_ACCESS_TOKEN"] as? String else {
            fatalError("MAPBOX_ACCESS_TOKEN not set in plist for this environment")
        }
        return token
    }()
}
