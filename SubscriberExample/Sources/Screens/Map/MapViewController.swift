import UIKit
import MapKit
import AblyAssetTracking
import Keys

class MapViewController: UIViewController {
    @IBOutlet private weak var assetStatusLabel: UILabel!
    @IBOutlet private weak var animationSwitch: UISwitch!
    @IBOutlet private weak var mapView: MKMapView!

    private let truckAnnotationViewIdentifier = "MapTruckAnnotationViewIdentifier"
    private let trackingId: String
    private var subscriber: Subscriber?
    private var errors: [Error] = []

    private var location: CLLocation? { didSet { updateLocationAnnotation() } }

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
        title = "Tracking \(trackingId)"
        assetStatusLabel.text = "The asset connection status is not determined"
        setupSubscriber()

        mapView.delegate = self
        mapView.register(TruckAnnotationView.self, forAnnotationViewWithReuseIdentifier: truckAnnotationViewIdentifier)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        subscriber?.stop()
    }

    private func setupSubscriber() {
        let keys = AblyAssetTrackingKeys.init()
        subscriber = try? SubscriberFactory.subscribers()
            .connection(ConnectionConfiguration(apiKey: keys.ablyApiKey,
                                                clientId: keys.ablyClientId))
            .trackingId(trackingId)
            .log(LogConfiguration())
            .resolution(Resolution(accuracy: .balanced, desiredInterval: 5000, minimumDisplacement: 100))
            .delegate(self)
            .start()
    }

    // MARK: Utils
    private func updateLocationAnnotation() {
        guard let location = location else {
            mapView.removeAnnotations(mapView.annotations)
            return
        }

        if let annotation = mapView.annotations.first as? TruckAnnotation {
            annotation.bearing = location.course

            // Delegate's "viewForAnnotation" method is not called when we're only updating coordinate or bearing, so AnnotationView is not updated.
            // That's why we need to set latest values in AnnotationView manually.
            if let view = mapView.view(for: annotation) as? TruckAnnotationView {
                view.bearing = annotation.bearing
            }

            let isAnimated = animationSwitch.isOn
            UIView.animate(withDuration: isAnimated ? 1 : 0) {
                annotation.coordinate = location.coordinate
            }
        } else {
            let annotation = TruckAnnotation()
            annotation.coordinate = location.coordinate
            annotation.bearing = location.course
            mapView.addAnnotation(annotation)
        }
    }

    private func scrollToReceivedLocation() {
        let minimumDistanceToCenter: Double = 300
        let mapCenter = CLLocation(latitude: mapView.region.center.latitude,
                                   longitude: mapView.region.center.longitude)
        guard let location = self.location,
              location.distance(from: mapCenter) > minimumDistanceToCenter
        else { return }

        let region = MKCoordinateRegion(center: location.coordinate,
                                        latitudinalMeters: 600,
                                        longitudinalMeters: 600)
        mapView.setRegion(region, animated: true)
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? TruckAnnotation
        else { return nil }

        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: truckAnnotationViewIdentifier) as? TruckAnnotationView ??
                             TruckAnnotationView(annotation: annotation, reuseIdentifier: truckAnnotationViewIdentifier)
        annotationView.bearing = annotation.bearing
        annotationView.backgroundColor = UIColor.blue.withAlphaComponent(0.7)
                                                 
        return annotationView
    }
}

extension MapViewController: SubscriberDelegate {
    func subscriber(sender: Subscriber, didFailWithError error: Error) {
        errors.append(error)
    }

    func subscriber(sender: Subscriber, didUpdateEnhancedLocation location: CLLocation) {
        self.location = location
        scrollToReceivedLocation()
    }

    func subscriber(sender: Subscriber, didChangeAssetConnectionStatus status: AssetConnectionStatus) {
        assetStatusLabel.text = status == .online ? "The asset is online" : "The asset is offline"
    }
}

