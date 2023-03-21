import UIKit
import MapboxMaps

class MapboxMapViewController: UIViewController {
    internal var mapView: MapboxMaps.MapView?

    var center: CLLocationCoordinate2D? {
        get {
            return _center
        }
        set {
            if newValue != _center {
                _center = newValue
                reload()
            }
        }
    }
    var _center: CLLocationCoordinate2D?

    var onCameraChange: ((CLLocationCoordinate2D) -> Void)?

    override public func viewDidLoad() {
        super.viewDidLoad()
        let resourceOptions = ResourceOptions(accessToken: EnvironmentHelper.MAPBOX_ACCESS_TOKEN)
        let cameraOptions = CameraOptions(center: center, zoom: 10)
        let mapInitOptions = MapInitOptions(resourceOptions: resourceOptions, cameraOptions: cameraOptions)

        let mapView = MapboxMaps.MapView(frame: view.bounds, mapInitOptions: mapInitOptions)
        mapView.location.options.puckType = .puck2D()
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.gestures.delegate = self
        self.view.addSubview(mapView)
        self.mapView = mapView
    }

    func reload() {
        guard let mapView else {
            return
        }
        mapView.mapboxMap.setCamera(to: CameraOptions(center: center))
    }
}

extension MapboxMapViewController: GestureManagerDelegate {

    func gestureManager(_ gestureManager: MapboxMaps.GestureManager, didBegin gestureType: MapboxMaps.GestureType) {
    }

    func gestureManager(_ gestureManager: MapboxMaps.GestureManager, didEnd gestureType: MapboxMaps.GestureType, willAnimate: Bool) {
        if let cameraCenter = mapView?.cameraState.center, center != cameraCenter {
            _center = cameraCenter
            onCameraChange?(cameraCenter)
        }
    }

    func gestureManager(_ gestureManager: MapboxMaps.GestureManager, didEndAnimatingFor gestureType: MapboxMaps.GestureType) {
    }
}
