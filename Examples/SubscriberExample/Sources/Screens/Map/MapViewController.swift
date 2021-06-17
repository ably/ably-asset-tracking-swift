import UIKit
import MapKit
import AblyAssetTrackingCore
import AblyAssetTrackingSubscriber

private struct MapConstraints {
    static let regionLatitude: CLLocationDistance = 600
    static let regionLongitude: CLLocationDistance = 600
    static let minimumDistanceToCenter: CLLocationDistance = 300
}

private struct Identifiers {
    static let truckAnnotation = "MapTruckAnnotationViewIdentifier"
}

class MapViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet private weak var assetStatusLabel: UILabel!
    @IBOutlet private weak var animationSwitch: UISwitch!
    @IBOutlet private weak var mapView: MKMapView!
    @IBOutlet private weak var resolutionLabel: UILabel!

    // MARK: - Properties
    private let trackingId: String
    private var subscriber: Subscriber?
    private var errors: [ErrorInformation] = []

    private var currentResolution: Resolution?
    private var resolutionDebounceTimer: Timer?

    private var location: CLLocation? { didSet { updateLocationAnnotation() } }

    // MARK: - Initialization
    init(trackingId: String) {
        self.trackingId = trackingId

        let viewControllerType = MapViewController.self
        super.init(nibName: String(describing: viewControllerType), bundle: Bundle(for: viewControllerType))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Tracking \(trackingId)"
        assetStatusLabel.text = DescriptionsHelper.AssetStateHelper.getDescriptionAndColor(for: .none).desc
        setupSubscriber()
        setupMapView()
        setupControlsBehaviour()
        updateResolutionLabel()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        subscriber?.stop { [weak self] _ in
            self?.resolutionDebounceTimer?.invalidate()
            self?.resolutionDebounceTimer = nil
        }
    }

    // MARK: - View setup
    private func setupMapView() {
        mapView.delegate = self
        mapView.register(TruckAnnotationView.self, forAnnotationViewWithReuseIdentifier: Identifiers.truckAnnotation)
    }

    private func setupControlsBehaviour() {
        resolutionLabel.font = UIFont.systemFont(ofSize: 14)
        assetStatusLabel.font = UIFont.systemFont(ofSize: 14)
    }
    
    // MARK: - Subscriber setup
    private func setupSubscriber() {        
        subscriber = SubscriberFactory.subscribers()
            .connection(ConnectionConfiguration(apiKey: Environment.ABLY_API_KEY,
                                                clientId: "Asset Tracking Cocoa Subscriber Example"))
            .trackingId(trackingId)
            .log(LogConfiguration())
            .resolution(Resolution(accuracy: .balanced, desiredInterval: 10000, minimumDisplacement: 500))
            .delegate(self)
            .start { [weak self] result in
                switch result {
                case .success:
                    logger.info("Subscriber started successfully.")
                case .failure(let error):
                    self?.showErrorDialog(withMessage: error.message)
                }
            }
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
        let mapCenter = CLLocation(latitude: mapView.region.center.latitude,
                                   longitude: mapView.region.center.longitude)
        
        guard let location = self.location,
              location.distance(from: mapCenter) > MapConstraints.minimumDistanceToCenter
        else { return }

        let region = MKCoordinateRegion(center: location.coordinate,
                                        latitudinalMeters: MapConstraints.regionLatitude,
                                        longitudinalMeters: MapConstraints.regionLongitude)
        
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
        let resolution = ResolutionHelper.createResolution(forZoom: mapView.getZoomLevel())
        
        guard resolution != currentResolution else {
            return
        }

        subscriber?.resolutionPreference(resolution: resolution) { [weak self] result in
            switch result {
            case .success:
                self?.currentResolution = resolution
                self?.updateResolutionLabel()
                logger.info("Updated resolution to: \(resolution)")
            case .failure(let error):
                let errorDescription = DescriptionsHelper.ResolutionStateHelper.getDescription(for: .changeError(error))
                self?.showErrorDialog(withMessage: errorDescription)
            }
        }
    }

    private func updateResolutionLabel() {
        guard let resolution = currentResolution else {
            resolutionLabel.text = DescriptionsHelper.ResolutionStateHelper.getDescription(for: .none)
            return
        }
        
        resolutionLabel.text = DescriptionsHelper.ResolutionStateHelper.getDescription(for: .notEmpty(resolution))
    }
    
    private func showErrorDialog(withMessage message: String) {
        let alertVC = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertVC, animated: true, completion: nil)
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? TruckAnnotation else { return nil }

        return createAnnotationView(for: annotation)
    }

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let zoom = mapView.getZoomLevel()
        logger.debug("Current map zoom level: \(zoom)")
        scheduleResolutionUpdate()
    }
    
    private func createAnnotationView(for annotation: TruckAnnotation) -> MKAnnotationView {
        let annotationView = getAnnotationView(for: annotation)
        annotationView.bearing = annotation.bearing
        annotationView.backgroundColor = UIColor.blue.withAlphaComponent(0.7)
        return annotationView
    }
        
    private func getAnnotationView(for annotation: TruckAnnotation) -> TruckAnnotationView {
        guard let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: Identifiers.truckAnnotation) as? TruckAnnotationView else {
            return TruckAnnotationView(annotation: annotation, reuseIdentifier: Identifiers.truckAnnotation)
        }
        
        return annotationView
    }
}

extension MapViewController: SubscriberDelegate {
    func subscriber(sender: Subscriber, didFailWithError error: ErrorInformation) {
        showErrorDialog(withMessage: error.description)
        errors.append(error)
    }

    func subscriber(sender: Subscriber, didUpdateEnhancedLocation location: CLLocation) {
        self.location = location
        scrollToReceivedLocation()
    }

    func subscriber(sender: Subscriber, didChangeAssetConnectionStatus status: ConnectionState) {
        let statusDescAndColor = DescriptionsHelper.AssetStateHelper.getDescriptionAndColor(for: .connectionState(status))
        assetStatusLabel.textColor = statusDescAndColor.color
        assetStatusLabel.text = statusDescAndColor.desc
    }
}
