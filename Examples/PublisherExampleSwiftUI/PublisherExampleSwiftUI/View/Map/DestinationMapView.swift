import SwiftUI
import MapKit
import AblyAssetTrackingCore

// Since SwiftUI's MapView has problems with capturing tap events (more specifically - getting the tap's latitude
// and longitude) I couldn't find a way to use it here. Instead I used the UIKit's MKMapView implementation.
// Heavily inspired by this solution: https://stackoverflow.com/a/63111267
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
        mapView.region = startRegion
        
        if let destination = destination {
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: destination.latitude, longitude: destination.longitude)
            mapView.addAnnotation(annotation)
        }
        
        return mapView
    }

    func updateUIView(_ view: MKMapView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    mutating func changeDestination(coordinate: CLLocationCoordinate2D) {
        if destination != nil {
            mapView.removeAnnotations(mapView.annotations)
            destination = nil
            return
        }
        
        mapView.removeAnnotations(mapView.annotations)
    
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        
        destination = LocationCoordinate(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }

    class Coordinator: NSObject, UIGestureRecognizerDelegate {
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
            let selectedCoordinate = self.parent.mapView.convert(location, toCoordinateFrom: self.parent.mapView)
            
            parent.changeDestination(coordinate: selectedCoordinate)
        }
    }
}
