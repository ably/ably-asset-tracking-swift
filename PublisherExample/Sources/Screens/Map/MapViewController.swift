import UIKit
import MapKit
import AblyAssetTracking
import Keys

class MapViewController: UIViewController {
    @IBOutlet private weak var mapView: MKMapView!
    @IBOutlet private weak var connectionStatusLabel: UILabel!
    @IBOutlet private weak var resolutionLabel: UILabel!

    private let assetAnnotationReuseIdentifier = "AssetAnnotationViewReuseIdentifier"
    private let trackingId: String
    private var publisher: Publisher?

    private var rawLocation: CLLocation?
    private var enhancedLocation: CLLocation?
    private var wasMapScrolled: Bool = false
    private var currentResolution: Resolution?

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
        updateResolutionLabel()
        setupPublisher()
        setupMapView()
    }

    // MARK: View setup
    private func setupPublisher() {
        let resolution = Resolution(accuracy: .balanced, desiredInterval: 5000, minimumDisplacement: 100)
        currentResolution = resolution
        
        let keys = AblyAssetTrackingKeys.init()
        
        publisher = try! PublisherFactory.publishers()
            .connection(ConnectionConfiguration(apiKey: keys.ablyApiKey, clientId: keys.ablyClientId))
            .log(LogConfiguration())
            .routingProfile(.driving)
            .delegate(self)
            .resolutionPolicyFactory(DefaultResolutionPolicyFactory(defaultResolution: resolution))
            .start()

        let destination = CLLocationCoordinate2D(latitude: 37.363152386314994, longitude: -122.11786987383525)
        publisher?.track(trackable: Trackable(id: trackingId, destination: destination), onSuccess: {  }, onError: { _ in })
    }

    private func setupMapView() {
        mapView.register(AssetAnnotationView.self, forAnnotationViewWithReuseIdentifier: assetAnnotationReuseIdentifier)
        mapView.delegate = self
    }

    // MARK: Utils
    private func changeRoutingProfile(to routingProfile: RoutingProfile) {
        publisher?.changeRoutingProfile(profile: routingProfile, onSuccess: { }, onError: { _ in })
    }

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
    
    private func updateResolutionLabel() {
        guard let resolution = currentResolution else {
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
    
    func publisher(sender: Publisher, didUpdateResolution resolution: Resolution) {
        currentResolution = resolution
        updateResolutionLabel()
    }
}
