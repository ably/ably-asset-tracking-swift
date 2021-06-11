import UIKit
import MapKit
import AblyAssetTracking

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
        // Switch between authentication options using `AuthenticationMethod`
        let connectionConfiguration = createConnectionConfiguration(clientId: "Asset Tracking Cocoa Subscriber Example", authMethod: .tokenDetails)

        subscriber = SubscriberFactory.subscribers()
            .connection(connectionConfiguration)
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
    private func createConnectionConfiguration(clientId: String?,
                                               authMethod: AuthenticationMethod,
                                               callback: ( (TokenRequest?, Error?) -> Void)? = nil) -> ConnectionConfiguration {
        if (authMethod == .basicAuthentication) {
            return ConnectionConfiguration(apiKey: Environment.ABLY_API_KEY, clientId: clientId)
        }

        return ConnectionConfiguration(clientId: clientId) { tokenParams, resultHandler in
            var url = URL(string: "https://europe-west2-ably-testing.cloudfunctions.net/app")!
//            var url = URL(string: "http://localhost:8000/ably-testing/europe-west2/app/createTokenRequest")!
            switch(authMethod) {
            case .tokenRequest:
                url.appendPathComponent("createTokenRequest")
            case .tokenDetails:
                url.appendPathComponent("createTokenDetails")
            case .jwt:
                url.appendPathComponent("createJwt")
            case .basicAuthentication:
                fatalError("There is no server required for basic authentication")
            }

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

            URLSession(configuration: URLSessionConfiguration.default).dataTask(with: request, completionHandler: { data, _, requestError in
                guard let data = data else {
                    if let error = requestError {
                        resultHandler(.failure(error))
                        return
                    } else {
                        resultHandler(.failure(NSError(domain: "Unknown error", code: 400, userInfo: [:])))
                        return
                    }
                }
                do {
                    let decoder = JSONDecoder()
                    switch (authMethod) {
                    case .tokenRequest:
                        let tokenRequest = try decoder.decode(TokenRequest.self, from: data)
                        resultHandler(.success(.tokenRequest(tokenRequest)))
                    case .tokenDetails:
                        let tokenDetails = try decoder.decode(TokenDetails.self, from: data)
                        resultHandler(.success(.tokenDetails(tokenDetails)))
                    case .jwt:
                        let jwtString = try decoder.decode(String.self, from: data)
                        resultHandler(.success(.jwt(jwtString)))
                    case .basicAuthentication:
                        fatalError("There is no server required for basic authentication")
                    }
                } catch {
                    resultHandler(.failure(error))
                }
            }).resume()
        }
    }

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

enum AuthenticationMethod {
    case basicAuthentication
    case jwt
    case tokenDetails
    case tokenRequest
}
