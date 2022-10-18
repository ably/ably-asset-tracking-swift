import SwiftUI
import MapboxMaps

struct MapboxMap: UIViewControllerRepresentable {
    @Binding var center: CLLocationCoordinate2D
    
    func makeUIViewController(context: Context) -> MapboxMapViewController {
        let viewController = MapboxMapViewController()
        viewController.center = center
        viewController.onCameraChange = { center in
            self.center = center
        }
        return viewController
    }
      
    func updateUIViewController(_ viewController: MapboxMapViewController, context: Context) {
        viewController.center = center
    }
}
