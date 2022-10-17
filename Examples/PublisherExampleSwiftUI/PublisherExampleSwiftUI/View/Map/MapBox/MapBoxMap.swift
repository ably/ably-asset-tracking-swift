import SwiftUI
import MapboxMaps

struct MapBoxMap: UIViewControllerRepresentable {
    @Binding var center: CLLocationCoordinate2D
    
    func makeUIViewController(context: Context) -> MapBoxMapViewController {
        let viewController = MapBoxMapViewController()
        viewController.center = center
        viewController.onCameraChange = { center in
            self.center = center
        }
        return viewController
    }
      
    func updateUIViewController(_ viewController: MapBoxMapViewController, context: Context) {
        viewController.center = center
    }
}
