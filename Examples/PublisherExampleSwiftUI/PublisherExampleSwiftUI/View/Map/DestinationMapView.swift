import SwiftUI
import MapKit

struct DestinationMapView: UIViewRepresentable {
    @Binding var centerCoordinate: CLLocationCoordinate2D

    let mapView = MKMapView()

    func makeUIView(context: Context) -> MKMapView {
        mapView.delegate = context.coordinator
        return mapView
    }

    func updateUIView(_ view: MKMapView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate, UIGestureRecognizerDelegate {
        var parent: DestinationMapView

        var gRecognizer = UITapGestureRecognizer()

        init(_ parent: DestinationMapView) {
            self.parent = parent
            super.init()
            self.gRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapHandler))
            self.gRecognizer.delegate = self
            self.parent.mapView.addGestureRecognizer(gRecognizer)
        }

        @objc func tapHandler(_ gesture: UITapGestureRecognizer) {
            // position on the screen, CGPoint
            let location = gRecognizer.location(in: self.parent.mapView)
            // position on the map, CLLocationCoordinate2D
            let coordinates = self.parent.mapView.convert(location, toCoordinateFrom: self.parent.mapView)
            
            print("coordinates: \(coordinates)")
        }
    }
}
