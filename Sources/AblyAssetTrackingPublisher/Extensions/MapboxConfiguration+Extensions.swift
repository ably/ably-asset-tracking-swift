import AblyAssetTrackingCore
import MapboxDirections

extension MapboxConfiguration {
    func getCredentials() -> Credentials {
        Credentials(accessToken: self.mapboxKey, host: nil)
    }
}
