import UIKit
import MapKit
import AblyAssetTracking

class MapViewController: UIViewController {
    @IBOutlet private weak var assetStatusLabel: UILabel!
    @IBOutlet private weak var animationSwitch: UISwitch!
    @IBOutlet private weak var mapView: MKMapView!
    @IBOutlet private weak var resolutionLabel: UILabel!

    private let truckAnnotationViewIdentifier = "MapTruckAnnotationViewIdentifier"
    private let trackingId: String
    private var subscriber: Subscriber?
    private var errors: [ErrorInformation] = []

    private var currentResolution: Resolution?
    private var resolutionDebounceTimer: Timer?

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

        updateResolutionLabel()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        subscriber?.stop()
        resolutionDebounceTimer?.invalidate()
        resolutionDebounceTimer = nil
    }

    // MARK: View setup

    private func setupSubscriber() {
        subscriber = try? SubscriberFactory.subscribers()
            .connection(ConnectionConfiguration(apiKey: Environment.ABLY_API_KEY,
                                                clientId: "Asset Tracking Cocoa Subscriber Example"))
            .trackingId(trackingId)
            .log(LogConfiguration())
            .resolution(Resolution(accuracy: .balanced, desiredInterval: 10000, minimumDisplacement: 500))
            .delegate(self)
            .start()
    }

    // MARK: Utils
    private func updateLocationAnnotation() {
        guard let location = self.location else {
            mapView.annotations.forEach { mapView.removeAnnotation($0) }
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

    // MARK: Request new resolution based on zoom
    private func scheduleResolutionUpdate() {
        resolutionDebounceTimer?.invalidate()
        resolutionDebounceTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { [weak self] _ in
            self?.performResolutionUpdate()
        })
    }

    private func performResolutionUpdate() {
        let resolution = resolutionForCurrentMapZoom()
        if resolution == currentResolution { return }

        subscriber?.sendChangeRequest(resolution: resolution) { [weak self] result in
            switch result {
            case .success:
                self?.currentResolution = resolution
                self?.updateResolutionLabel()
                logger.info("Updated resolution to: \(resolution)")
            case .failure(let error):
                let alertVC = UIAlertController(title: "Error", message: "Can't change resolution: \(error.localizedDescription)", preferredStyle: .alert)
                alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self?.present(alertVC, animated: true, completion: nil)
            }
        }
    }

    private func resolutionForCurrentMapZoom() -> Resolution {
        let zoom = mapView.getZoomLevel()
        if zoom < 10 {
            return Resolution(accuracy: .minimum, desiredInterval: 120 * 1000, minimumDisplacement: 10000)
        } else if 10.0...12.0 ~= zoom {
            return Resolution(accuracy: .low, desiredInterval: 60 * 1000, minimumDisplacement: 5000)
        } else if 12.0...14.0 ~= zoom {
            return Resolution(accuracy: .balanced, desiredInterval: 30 * 1000, minimumDisplacement: 100)
        } else if 14.0...16.0 ~= zoom {
            return Resolution(accuracy: .high, desiredInterval: 10 * 1000, minimumDisplacement: 30)
        }
        return Resolution(accuracy: .maximum, desiredInterval: 5 * 1000, minimumDisplacement: 1)
    }

    private func updateResolutionLabel() {
        guard let resolution = currentResolution
        else {
            resolutionLabel.text = "Resolution: None"
            resolutionLabel.font = UIFont.systemFont(ofSize: 17)
            return
        }
        resolutionLabel.font = UIFont.systemFont(ofSize: 14)
        resolutionLabel.text = """
            Resolution:
            Accuracy: \(resolution.accuracy)
            Minimum displacement: \(resolution.minimumDisplacement)
            Desired interval: \(resolution.desiredInterval)
            """
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

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let zoom = mapView.getZoomLevel()
        logger.debug("Current map zoom level: \(zoom)")
        scheduleResolutionUpdate()
    }
}

extension MapViewController: SubscriberDelegate {
    func subscriber(sender: Subscriber, didFailWithError error: ErrorInformation) {
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
