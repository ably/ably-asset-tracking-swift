import UIKit
import MapKit
import Publisher

class MapViewController: UIViewController {
    @IBOutlet private weak var mapView: MKMapView!
    @IBOutlet private weak var connectionStatusLabel: UILabel!

    private let assetAnnotationReuseIdentifier = "AssetAnnotationViewReuseIdentifier"
    private let trackingId: String
    private var publisher: Publisher?

    private var rawLocation: CLLocation?
    private var enhancedLocation: CLLocation?
    private var wasMapScrolled: Bool = false

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
        title = "Publishing \(trackingId)"
        setupPublisher()
        setupMapView()
    }

    // MARK: View setup
    private func setupPublisher() {
        publisher = try? PublisherFactory.publishers()
            .connection(ConnectionConfiguration(apiKey: PublisherKeys.ablyApiKey,
                                                clientId: PublisherKeys.ablyClientId))
            .log(LogConfiguration())
            .transportationMode(TransportationMode())
            .delegate(self)
            .start()

        publisher?.track(trackable: Trackable(id: trackingId))
    }

    private func setupMapView() {
        mapView.register(AssetAnnotationView.self, forAnnotationViewWithReuseIdentifier: assetAnnotationReuseIdentifier)
        mapView.delegate = self
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

    private func scrollToReceivedLocation() {
        guard let location = rawLocation ?? enhancedLocation,
              !wasMapScrolled
        else { return }

        wasMapScrolled = true
        let region = MKCoordinateRegion(center: location.coordinate,
                                        latitudinalMeters: 600,
                                        longitudinalMeters: 600)
        mapView.setRegion(region, animated: true)
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { return nil }

        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: assetAnnotationReuseIdentifier) ??
                            AssetAnnotationView(annotation: annotation, reuseIdentifier: assetAnnotationReuseIdentifier)
        let isRaw = annotation.title == "Raw"
        annotationView.backgroundColor = isRaw ? UIColor.yellow.withAlphaComponent(0.7) :
                                                 UIColor.blue.withAlphaComponent(0.7)
        return annotationView
    }
}

extension MapViewController: PublisherDelegate {
    func publisher(sender: Publisher, didFailWithError error: Error) {
    }

    func publisher(sender: Publisher, didUpdateRawLocation location: CLLocation) {
        rawLocation = location
        refreshAnnotations()
        scrollToReceivedLocation()
    }

    func publisher(sender: Publisher, didUpdateEnhancedLocation location: CLLocation) {
        enhancedLocation = location
        refreshAnnotations()
        scrollToReceivedLocation()
    }

    func publisher(sender: Publisher, didChangeConnectionState state: ConnectionState) {
        connectionStatusLabel.text = "Connection state: \(state)"
    }
}
