import UIKit
import MapKit
import AblyAssetTracking
import Foundation

extension RoutingProfile {
    var description: String {
        switch self {
        case .driving: return "Driving"
        case .cycling: return "Cycling"
        case .walking: return "Walking"
        case .drivingTraffic: return "Driving traffic"
        }
    }
}

extension ConnectionState {
    var description: String {
        switch self {
        case .online: return "Online"
        case .offline: return "Offline"
        case .failed: return "Failed"
        }
    }
    
    var color: UIColor {
        switch self {
        case .online: return .systemGreen
        case .offline, .failed: return .systemRed
        }
    }
}

private enum LocationState {
    case active
    case pending
    case failed
    
    var color: UIColor {
        switch self {
        case .active:
            return .systemGreen
        case .pending:
            return .systemOrange
        case .failed:
            return .systemRed
        }
    }
}

private struct MapConstraints {
    static let regionLatitude: CLLocationDistance = 600
    static let regionLongitude: CLLocationDistance = 600
    static let minimumDistanceToCenter: CLLocationDistance = 300
}

class MapViewController: UIViewController {
    @IBOutlet private weak var mapView: MKMapView!
    @IBOutlet private weak var connectionStatusLabel: UILabel!
    @IBOutlet private weak var resolutionLabel: UILabel!
    @IBOutlet private weak var changeRoutingProfileButton: UIButton!
    @IBOutlet private weak var routingProfileLabel: UILabel!
    @IBOutlet private weak var routingProfileAvtivityIndicator: UIActivityIndicatorView!
    
    private let assetAnnotationReuseIdentifier = "AssetAnnotationViewReuseIdentifier"
    private let trackingId: String
    private let historyLocation: [CLLocation]?
    
    private var publisher: Publisher?

    private var location: CLLocation?
    private var locationState: LocationState = .pending {
        didSet {
            refreshAnnotations()
        }
    }
    
    private var wasMapScrolled: Bool = false
    private var currentResolution: Resolution?
    private var trackables: [Trackable] = []

    // MARK: Initialization
    init(trackingId: String, historyLocation: [CLLocation]?) {
        self.trackingId = trackingId
        self.historyLocation = historyLocation
        
        super.init(nibName: String(describing: MapViewController.self), bundle: Bundle(for: MapViewController.self))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Publishing \(trackingId)"
        updateResolutionLabel()
        setupNavigationBar()
        setupPublisher()
        setupMapView()
        routingProfileAvtivityIndicator.stopAnimating()
    }

    // MARK: View setup
    private func setupPublisher() {
        let resolution = Resolution(accuracy: .balanced, desiredInterval: 5000, minimumDisplacement: 100)
        currentResolution = resolution
        
        publisher = try! PublisherFactory.publishers()
            .connection(ConnectionConfiguration(apiKey: Environment.ABLY_API_KEY, clientId: "Asset Tracking Cocoa Publisher Example"))
            .mapboxConfiguration(MapboxConfiguration(mapboxKey: Environment.MAPBOX_ACCESS_TOKEN))
            .log(LogConfiguration())
            .locationSource(LocationSource(locationSource: historyLocation))
            .routingProfile(.driving)
            .delegate(self)
            .resolutionPolicyFactory(DefaultResolutionPolicyFactory(defaultResolution: resolution))
            .start()

        let destination = CLLocationCoordinate2D(latitude: 37.363152386314994, longitude: -122.11786987383525)
        let trackable = Trackable(id: trackingId, destination: destination)
        
        locationState = .pending
        
        publisher?.track(trackable: trackable) { [weak self] result in
            switch result {
            case .success:
                self?.trackables = [trackable]
                logger.info("Initial trackable tracked successfully.")
            case .failure(let error):
                self?.locationState = .failed
                self?.refreshAnnotations()
                
                let alertVC = UIAlertController(title: "Error", message: "Can't track trackable: \(error.message)", preferredStyle: .alert)
                alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self?.present(alertVC, animated: true, completion: nil)
            }
        }
    }

    private func setupMapView() {
        mapView.register(AssetAnnotationView.self, forAnnotationViewWithReuseIdentifier: assetAnnotationReuseIdentifier)
        mapView.delegate = self
        
        location = historyLocation?.first ?? CLLocationManager().location
        refreshAnnotations()
        scrollToReceivedLocation(isInitialLocation: true)
    }

    private func setupNavigationBar() {
        title = "Publishing \(trackingId)"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(onEditButtonPressed))
    }

    // MARK: Utils
    private func showError(error: ErrorInformation) {
        let alertVC = UIAlertController(title: "Error", message: "\(error.message)", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertVC, animated: true, completion: nil)
    }
    
    private func refreshAnnotations() {
        mapView.annotations.forEach { mapView.removeAnnotation($0) }

        if let location = self.location {
            let annotation = MKPointAnnotation()
            annotation.coordinate = location.coordinate
            annotation.title = "Location"
            mapView.addAnnotation(annotation)
        }
    }

    private func scrollToReceivedLocation(isInitialLocation: Bool = false) {
        guard let location = self.location else { return }
        
        let mapCenter = CLLocation(latitude: mapView.region.center.latitude,
                                   longitude: mapView.region.center.longitude)
        
        let region = MKCoordinateRegion(center: location.coordinate,
                                        latitudinalMeters: MapConstraints.regionLatitude,
                                        longitudinalMeters: MapConstraints.regionLongitude)
        
        if isInitialLocation {
            mapView.setRegion(region, animated: true)
            
            return
        }
        
        guard location.distance(from: mapCenter) > MapConstraints.minimumDistanceToCenter else { return }
        
        mapView.setRegion(region, animated: true)
    }

    private func updateResolutionLabel() {
        guard let resolution = currentResolution else {
            resolutionLabel.text = "Resolution: None"
            resolutionLabel.font = UIFont.systemFont(ofSize: 14)
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
    
    // MARK: - RoutingProfile
    @IBAction func onChangeRoutingProfileButtonTapped(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Choose routing profile", message: nil, preferredStyle: .actionSheet)
        let driving = UIAlertAction(title: RoutingProfile.driving.description, style: .default) { [weak self] _ in
            self?.changeRoutingProfile(.driving)
        }
        let cycling = UIAlertAction(title: RoutingProfile.cycling.description, style: .default) { [weak self] _ in
            self?.changeRoutingProfile(.cycling)
        }
        let walking = UIAlertAction(title: RoutingProfile.walking.description, style: .default) { [weak self] _ in
            self?.changeRoutingProfile(.walking)
        }
        let drivingTraffic = UIAlertAction(title: RoutingProfile.drivingTraffic.description, style: .default) { [weak self] _ in
            self?.changeRoutingProfile(.drivingTraffic)
        }

        alertController.addAction(driving)
        alertController.addAction(cycling)
        alertController.addAction(walking)
        alertController.addAction(drivingTraffic)

        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        navigationController?.present(alertController, animated: true, completion: nil)
    }
    
    private func changeRoutingProfile(_ routingProfile: RoutingProfile) {
        routingProfileAvtivityIndicator.startAnimating()
        publisher?.changeRoutingProfile(profile: routingProfile) { [weak self] result in
            self?.routingProfileAvtivityIndicator.stopAnimating()
            switch result {
            case .success:
                self?.routingProfileLabel.text = "Routing profile: \(routingProfile.description)"
            case .failure(let error):
                self?.showError(error: error)
            }
        }
    }
    
    @objc
    func onEditButtonPressed() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Edit Trackables",
                                                style: .default,
                                                handler: { [weak self] _ in self?.navigateToTrackablesScreen() }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        navigationController?.present(alertController, animated: true, completion: nil)
    }

    private func navigateToTrackablesScreen() {
        let viewController = TrackablesViewController(trackables: trackables)
        viewController.delegate = self
        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { return nil }

        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: assetAnnotationReuseIdentifier) ??
                            AssetAnnotationView(annotation: annotation, reuseIdentifier: assetAnnotationReuseIdentifier)
        
        annotationView.backgroundColor = locationState.color
        return annotationView
    }
}

extension MapViewController: PublisherDelegate {
    func publisher(sender: Publisher, didFailWithError error: ErrorInformation) {
        self.locationState = .failed
        refreshAnnotations()
    }

    func publisher(sender: Publisher, didUpdateEnhancedLocation location: CLLocation) {
        self.location = location
        self.locationState = .active
        self.refreshAnnotations()
        self.scrollToReceivedLocation()
    }

    func publisher(sender: Publisher, didChangeConnectionState state: ConnectionState) {
        connectionStatusLabel.textColor = state.color
        connectionStatusLabel.text = state.description
    }

    func publisher(sender: Publisher, didUpdateResolution resolution: Resolution) {
        currentResolution = resolution
        updateResolutionLabel()
    }
}

extension MapViewController: TrackablesViewControllerDelegate {
    func trackablesViewController(sender: TrackablesViewController, didAddTrackable trackable: Trackable) {
        publisher?.add(trackable: trackable) { [weak self] result in
            switch result {
            case .success:
                logger.info("Added trackable: \(trackable.id)")
                self?.trackables.append(trackable)
            case .failure(let error):
                let alertVC = UIAlertController(title: "Error", message: "Can't add trackable: \(error.localizedDescription)", preferredStyle: .alert)
                alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self?.present(alertVC, animated: true, completion: nil)
            }
        }
    }

    func trackablesViewController(sender: TrackablesViewController, didRemoveTrackable trackable: Trackable) {
        publisher?.remove(trackable: trackable) { [weak self] result in
            switch result {
            case .success(let wasPresent):
                self?.trackables.removeAll(where: { $0 == trackable })
                logger.info("Trackable removed: \(trackable.id). Was present: \(wasPresent)")
            case .failure(let error):
                self?.showError(error: error)
            }
        }
    }
}
