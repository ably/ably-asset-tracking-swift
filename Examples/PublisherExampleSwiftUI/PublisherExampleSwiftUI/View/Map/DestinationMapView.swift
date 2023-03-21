import SwiftUI
import MapKit
import AblyAssetTrackingCore

// Since SwiftUI's MapView has problems with capturing tap events (more specifically - getting the tap's latitude
// and longitude) I couldn't find a way to use it here. Instead I used the UIKit's MKMapView implementation.
// Heavily inspired by this solution: https://stackoverflow.com/a/63111267
struct DestinationMapView: UIViewRepresentable {
    var center: CLLocationCoordinate2D
    var span: MKCoordinateSpan?
    @Binding var destination: LocationCoordinate?

    fileprivate let centerAnnotationTitle = "Current Location"
    fileprivate let destinationAnnotationTitle = "Destination"

    let mapView = MKMapView()

    func makeUIView(context: Context) -> MKMapView {
        let startSpan = MKCoordinateSpan(
            latitudeDelta: 0.1,
            longitudeDelta: 0.1
        )

        let startRegion = MKCoordinateRegion(center: center, span: startSpan)
        mapView.region = startRegion

        if let destination {
            let destinationAnnotation = MKPointAnnotation()
            destinationAnnotation.coordinate = CLLocationCoordinate2D(latitude: destination.latitude, longitude: destination.longitude)
            destinationAnnotation.title = destinationAnnotationTitle
            mapView.addAnnotation(destinationAnnotation)
        }

        let centerAnnotation = MKPointAnnotation()
        centerAnnotation.coordinate = center
        centerAnnotation.title = centerAnnotationTitle
        mapView.addAnnotation(centerAnnotation)
        mapView.delegate = context.coordinator
        return mapView
    }

    func updateUIView(_ view: MKMapView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    func changeDestination(coordinate: CLLocationCoordinate2D) {
        removeDestinationAnnotation()

        if destination != nil {
            destination = nil
            return
        }

        let destinationAnnotation = MKPointAnnotation()
        destinationAnnotation.coordinate = coordinate
        destinationAnnotation.title = destinationAnnotationTitle
        mapView.addAnnotation(destinationAnnotation)

        destination = LocationCoordinate(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }

    private func removeDestinationAnnotation() {
        for annotation in mapView.annotations where annotation.title == destinationAnnotationTitle {
            mapView.removeAnnotation(annotation)
        }
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

        @objc
        func tapHandler(_ gesture: UITapGestureRecognizer) {
            // position on the screen, CGPoint
            let location = gRecognizer.location(in: self.parent.mapView)
            // position on the map, CLLocationCoordinate2D
            let selectedCoordinate = self.parent.mapView.convert(location, toCoordinateFrom: self.parent.mapView)

            parent.changeDestination(coordinate: selectedCoordinate)
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "centerAnnotation")
            if annotation.title == parent.centerAnnotationTitle {
                annotationView.markerTintColor = .blue
            }
            if annotation.title == parent.destinationAnnotationTitle {
                annotationView.markerTintColor = .red
            }
            return annotationView
        }
    }
}
