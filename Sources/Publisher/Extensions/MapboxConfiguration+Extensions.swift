import MapboxDirections

extension MapboxConfiguration {
    func getCredentians() -> DirectionsCredentials {
        return DirectionsCredentials(accessToken: self.mapboxKey, host: nil)
    }
}
