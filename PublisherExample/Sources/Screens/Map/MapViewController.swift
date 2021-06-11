import UIKit
import MapKit
import AblyAssetTracking
import Foundation

private struct MapConstraints {
    static let regionLatitude: CLLocationDistance = 600
    static let regionLongitude: CLLocationDistance = 600
    static let minimumDistanceToCenter: CLLocationDistance = 300
}

private struct Identifiers {
    static let assetAnnotation = "AssetAnnotationViewReuseIdentifier"
}

class MapViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet private weak var mapView: MKMapView!
    @IBOutlet private weak var connectionStatusLabel: UILabel!
    @IBOutlet private weak var resolutionLabel: UILabel!
    @IBOutlet private weak var changeRoutingProfileButton: UIButton!
    @IBOutlet private weak var routingProfileLabel: UILabel!
    @IBOutlet private weak var routingProfileAvtivityIndicator: UIActivityIndicatorView!

    // MARK: - Properties
    private let trackingId: String
    private let historyLocation: [CLLocation]?

    private var publisher: Publisher?

    private var currentLocation: CLLocation?
    private var locationState: LocationState = .pending {
        didSet {
            refreshAnnotations()
        }
    }

    private var wasMapScrolled: Bool = false
    private var currentResolution: Resolution?
    private var trackables: [Trackable] = []

    // MARK: - Initialization
    init(trackingId: String, historyLocation: [CLLocation]?) {
        self.trackingId = trackingId
        self.historyLocation = historyLocation

        super.init(nibName: String(describing: MapViewController.self), bundle: Bundle(for: MapViewController.self))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Publishing \(trackingId)"
        updateResolutionLabel()
        setupNavigationBar()
        setupControlsBehaviour()
        setupPublisher()
        setupMapView()
        setRoutingProfileAvtivityIndicatorState(isLoading: false)
        startTracking()
    }

    // MARK: View setup
    private func setupControlsBehaviour() {
        resolutionLabel.font = UIFont.systemFont(ofSize: 14)
    }

    private func setupMapView() {
        mapView.register(AssetAnnotationView.self, forAnnotationViewWithReuseIdentifier: Identifiers.assetAnnotation)
        mapView.delegate = self

        currentLocation = historyLocation?.first ?? CLLocationManager().location
        refreshAnnotations()
        scrollToReceivedLocation(isInitialLocation: true)
    }

    private func setupNavigationBar() {
        title = "Publishing \(trackingId)"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(onEditButtonPressed))

        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(onBackButtonPressed))
    }

    // MARK: - Publisher setup
    private func setupPublisher() {
        let resolution = Resolution(accuracy: .balanced, desiredInterval: 5000, minimumDisplacement: 100)
        currentResolution = resolution

        // Authentication to Ably with a private Ably API key
//        let connectionConfiguration = ConnectionConfiguration(apiKey: Environment.ABLY_API_KEY, clientId: "Asset Tracking Cocoa Publisher Example")

        // Authentication with Ably with an auth callback
        let connectionConfiguration = ConnectionConfiguration(clientId: "Asset Tracking Cocoa Publisher Example") { tokenParams, tokenRequestHandler in
            self.getTokenRequestJSONFromYourServer(tokenParams: tokenParams) { tokenRequest, error in
                if let tokenRequest = tokenRequest {
                    tokenRequestHandler(tokenRequest, nil, nil)
                    return
                }
                if let error = error as NSError? {
                    tokenRequestHandler(nil, nil, error)
                } else if error != nil {
                    tokenRequestHandler(nil, nil, NSError(domain: "Unknown error passed by Request function", code: 0, userInfo: [:]))
                }
            }
        }

//        // Or Alternatively, use a custom Auth endpoint
//        let connectionConfiguration = ConnectionConfiguration(authUrl: "https://authEndpoint.com/createTokenRequest", clientId: "Asset Tracking Cocoa Publisher Example")

        publisher = try! PublisherFactory.publishers()
                .connection(connectionConfiguration)
                .mapboxConfiguration(MapboxConfiguration(mapboxKey: Environment.MAPBOX_ACCESS_TOKEN))
                .log(LogConfiguration())
                .locationSource(LocationSource(locationSource: historyLocation))
                .routingProfile(.driving)
                .delegate(self)
                .resolutionPolicyFactory(DefaultResolutionPolicyFactory(defaultResolution: resolution))
                .start()
    }

    private func getTokenRequestJSONFromYourServer(tokenParams: TokenParams,
                                                   callback: @escaping (TokenRequest?, Error?) -> Void) {
        let url = URL(string: "https://europe-west2-ably-testing.cloudfunctions.net/app/createTokenRequest")!
        // Or use a local server (for debugging):
//        let url = URL(string: "http://localhost:8000/ably-testing/europe-west2/app/createTokenRequest")!

//        // Using GET Request and specifying the clientId via a query param
//        request.httpMethod = "GET"
//        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
//        components.queryItems = [URLQueryItem(name: "clientId", value: tokenParams.clientId)]

//        // Using POST Request and specifying the clientId (or TokenParams) via the HTTP body
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! JSONEncoder().encode(tokenParams)

        // Or Alternatively, just send the clientId to your server:
//        request.httpBody = try? JSONSerialization.data(withJSONObject: ["clientId": tokenParams.clientId])

        URLSession(configuration: URLSessionConfiguration.default).dataTask(with: request) { data, _, requestError in
            guard let data = data else {
                callback(nil, requestError)
                return
            }
            do {
                let decoder = JSONDecoder()
                let tokenRequest = try decoder.decode(TokenRequest.self, from: data)
                callback(tokenRequest, nil)
            } catch {
                print(error)
                callback(nil, error)
            }
        }.resume()
    }

    private func startTracking() {
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
                self?.showErrorDialog(error: error)
            }
        }
    }

    private func closePublisher(completion: ResultHandler<Void>?) {
        trackables.removeAll()
        publisher?.stop { [weak self] result in
            switch result {
            case .success:
                logger.info("Publisher closed successfully.")
                self?.locationState = .failed
                completion?(.success(()))
            case .failure(let error):
                logger.info("Publisher closing failed. Error: \(error.message).")
                self?.showErrorDialog(error: error)
                completion?(.failure(error))
            }
        }
    }

// MARK: - Actions
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

// MARK: - Utils
    private func setRoutingProfileAvtivityIndicatorState(isLoading: Bool) {
        isLoading
                ? self.routingProfileAvtivityIndicator.startAnimating()
                : self.routingProfileAvtivityIndicator.stopAnimating()
    }

    private func refreshAnnotations() {
        mapView.annotations.forEach {
            mapView.removeAnnotation($0)
        }

        if let location = self.currentLocation {
            let annotation = MKPointAnnotation()
            annotation.coordinate = location.coordinate
            annotation.title = "Location"
            mapView.addAnnotation(annotation)
        }
    }

    private func scrollToReceivedLocation(isInitialLocation: Bool = false) {
        guard let location = self.currentLocation else {
            return
        }

        let mapCenter = CLLocation(latitude: mapView.region.center.latitude,
                longitude: mapView.region.center.longitude)

        let region = MKCoordinateRegion(center: location.coordinate,
                latitudinalMeters: MapConstraints.regionLatitude,
                longitudinalMeters: MapConstraints.regionLongitude)

        if isInitialLocation {
            mapView.setRegion(region, animated: true)

            return
        }

        guard location.distance(from: mapCenter) > MapConstraints.minimumDistanceToCenter else {
            return
        }

        mapView.setRegion(region, animated: true)
    }

    private func updateResolutionLabel() {
        guard let resolution = currentResolution else {
            resolutionLabel.text = DescriptionsHelper.ResolutionStateHelper.getDescription(for: .none)
            return
        }

        resolutionLabel.text = DescriptionsHelper.ResolutionStateHelper.getDescription(for: .notEmpty(resolution))
    }

    private func changeRoutingProfile(_ routingProfile: RoutingProfile) {
        setRoutingProfileAvtivityIndicatorState(isLoading: true)
        publisher?.changeRoutingProfile(profile: routingProfile) { [weak self] result in
            self?.setRoutingProfileAvtivityIndicatorState(isLoading: false)
            switch result {
            case .success:
                self?.routingProfileLabel.text = DescriptionsHelper.RoutingProfileDescHelper.getDescription(for: routingProfile)
            case .failure(let error):
                self?.showErrorDialog(error: error)
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

    @objc
    func onBackButtonPressed() {
        closePublisher { result in
            switch result {
            case .success:
                self.navigationController?.popViewController(animated: true)
            default:
                return
            }
        }
    }

    private func navigateToTrackablesScreen() {
        let viewController = TrackablesViewController(trackables: trackables, publisher: publisher)
        viewController.delegate = self
        navigationController?.pushViewController(viewController, animated: true)
    }

    private func showErrorDialog(error: ErrorInformation) {
        let alertVC = UIAlertController(title: "Error", message: "\(error.message)", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertVC, animated: true, completion: nil)
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else {
            return nil
        }

        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: Identifiers.assetAnnotation) ??
                AssetAnnotationView(annotation: annotation, reuseIdentifier: Identifiers.assetAnnotation)

        annotationView.backgroundColor = AssetStateHelper.getColor(for: locationState)
        return annotationView
    }
}

extension MapViewController: PublisherDelegate {
    func publisher(sender: Publisher, didChangeConnectionState state: ConnectionState, forTrackable trackable: Trackable) {
        let stateColorAndDesc = DescriptionsHelper.ConnectionStateHelper.getDescriptionAndColor(for: state)
        connectionStatusLabel.textColor = stateColorAndDesc.color
        connectionStatusLabel.text = stateColorAndDesc.desc
    }

    func publisher(sender: Publisher, didFailWithError error: ErrorInformation) {
        locationState = .failed
        refreshAnnotations()
        showErrorDialog(error: error)
    }

    func publisher(sender: Publisher, didUpdateEnhancedLocation location: CLLocation) {
        currentLocation = location
        locationState = .active
        refreshAnnotations()
        scrollToReceivedLocation()
    }

    func publisher(sender: Publisher, didUpdateResolution resolution: Resolution) {
        currentResolution = resolution
        updateResolutionLabel()
    }
}

extension MapViewController: TrackablesViewControllerDelegate {
    func trackablesViewController(sender: TrackablesViewController, didAddTrackable trackable: Trackable) {
        logger.info("Added trackable: \(trackable.id)")
        self.trackables.append(trackable)
    }

    func trackablesViewController(sender: TrackablesViewController, didRemoveTrackable trackable: Trackable, wasPresent: Bool) {
        self.trackables.removeAll(where: { $0 == trackable })
        logger.info("Trackable removed: \(trackable.id). Was present: \(wasPresent)")
    }

    func trackablesViewController(sender: TrackablesViewController, didRemoveLastTrackable trackable: Trackable) {
        logger.info("Publisher did remove last trackable.")
        self.closePublisher(completion: nil)
    }
}
