import MapboxDirections
import AblyAssetTrackingCore

extension MapboxConfiguration {
    func getCredentials() -> Credentials {
        Credentials(accessToken: self.mapboxKey, host: nil)
    }
}
