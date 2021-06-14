import MapboxDirections
import AblyAssetTrackingCore

extension MapboxConfiguration {
    func getCredentians() -> DirectionsCredentials {
        return DirectionsCredentials(accessToken: self.mapboxKey, host: nil)
    }
}
