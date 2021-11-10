import MapboxDirections
import AblyAssetTrackingCore

extension MapboxConfiguration {
    func getCredentials() -> DirectionsCredentials {
        return DirectionsCredentials(accessToken: self.mapboxKey, host: nil)
    }
}
