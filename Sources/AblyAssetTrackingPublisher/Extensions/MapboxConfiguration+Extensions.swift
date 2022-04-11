import MapboxDirections
import AblyAssetTrackingCore

extension MapboxConfiguration {
    func getCredentials() -> Credentials {
        return Credentials(accessToken: self.mapboxKey, host: nil)
    }
}
