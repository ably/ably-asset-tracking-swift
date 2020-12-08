import UIKit
import MapKit
import Publisher

class MapViewController: UIViewController {
    @IBOutlet private weak var mapView: MKMapView!
    private let trackingId: String
    private var publisher: AssetTrackingPublisher?
    
    private var rawLocation: CLLocation?
    private var enhancedLocation: CLLocation?
    
    // MARK: Initialization
    init(trackingId: String) {
        self.trackingId = trackingId
        let viewControllerType = MapViewController.self
        super.init(nibName: String(describing: viewControllerType), bundle: Bundle(for: viewControllerType))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPublisher()
        
    }
    
    // MARK: View setup
    private func setupPublisher() {
        let configuration = AssetTrackingPublisherConfiguration(apiKey: "", clientId: "")
        let trackable = DefaultTrackable(id: trackingId,
                                         metadata: "Metadata",
                                         latitude: 0,
                                         longitude: 0)
        
        publisher = DefaultPublisher(configuration: configuration)
        publisher?.track(trackable: trackable)
    }
    
    // MARK: Utils
    private func refreshAnnotations() {
        mapView.annotations.forEach { mapView.removeAnnotation($0) }
        
        if let location = rawLocation {
            let annotation = MKPointAnnotation()
            annotation.coordinate = location.coordinate
            annotation.title = "Raw"
            mapView.addAnnotation(annotation)
        }
        if let location = enhancedLocation {
            let annotation = MKPointAnnotation()
            annotation.title = "Enhanced"
            annotation.coordinate = location.coordinate
            mapView.addAnnotation(annotation)
        }
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { return nil }

        let identifier = "Annotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView!.canShowCallout = false
        } else {
            annotationView!.annotation = annotation
        }

        return annotationView
    }
}

extension MapViewController: AssetTrackingPublisherDelegate {
    func assetTrackingPublisher(sender: AssetTrackingPublisher, didFailWithError error: Error) {
        
    }
    
    func assetTrackingPublisher(sender: AssetTrackingPublisher, didUpdateRawLocation location: CLLocation) {
        rawLocation = location
        refreshAnnotations()
    }
    
    func assetTrackingPublisher(sender: AssetTrackingPublisher, didUpdateEnhancedLocation location: CLLocation) {
        enhancedLocation = location
        refreshAnnotations()
    }
    
    func assetTrackingPublisher(sender: AssetTrackingPublisher, didChangeConnectionStatus status: AblyConnectionStatus) {
        
    }
}
