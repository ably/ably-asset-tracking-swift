import Foundation
import MapKit

extension MKMapView {
    /// Calculate map zoom level in Google scale (0-20)
    /// - Returns: Zoom scale 
    func getZoomLevel() -> Double {
        let mercatorProjectionRadius = 85445659.44705395
        let maxZoomLevel: Double = 20

        let delta = region.span.longitudeDelta
        let mapWidth = Double(bounds.width)
        let zoomScale = delta * mercatorProjectionRadius * Double.pi / (180.0 * mapWidth)
        let googleZoomScale = maxZoomLevel - log2(zoomScale)

        return max(googleZoomScale, 0)
    }
}
