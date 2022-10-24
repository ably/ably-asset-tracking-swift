import SwiftUI
import MapKit
import AblyAssetTrackingCore

struct DestinationMapView: UIViewRepresentable {
    var center: CLLocationCoordinate2D
    private var span: MKCoordinateSpan?
    @Binding private var destination: LocationCoordinate?

    let mapView = MKMapView()
    
    init(center: CLLocationCoordinate2D, destination: Binding<LocationCoordinate?>) {
        self.center = center
        self._destination = destination
    }

    func makeUIView(context: Context) -> MKMapView {
        let startSpan = MKCoordinateSpan(
            latitudeDelta: 0.1,
            longitudeDelta: 0.1
        )
        
        let startRegion = MKCoordinateRegion(center: center, span: startSpan)
        
        mapView.delegate = context.coordinator
        mapView.region = startRegion
        return mapView
    }

    func updateUIView(_ view: MKMapView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    mutating func changeDestination(coordinates: CLLocationCoordinate2D) {
        mapView.removeAnnotations(mapView.annotations)
    
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinates
        mapView.addAnnotation(annotation)
        
        destination = LocationCoordinate(latitude: coordinates.latitude, longitude: coordinates.longitude)
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
            let selectedCoordinates = self.parent.mapView.convert(location, toCoordinateFrom: self.parent.mapView)
            
            parent.changeDestination(coordinates: selectedCoordinates)
            print("coordinates: \(selectedCoordinates)")
        }
    }
}
