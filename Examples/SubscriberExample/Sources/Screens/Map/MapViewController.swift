import UIKit
import MapKit
import AblyAssetTrackingSubscriber
import AblyAssetTrackingUI
import CoreLocation

private struct MapConstraints {
    static let regionLatitude: CLLocationDistance = 400
    static let regionLongitude: CLLocationDistance = 400
    static let minimumDistanceToCenter: CLLocationDistance = 100
}

class MapViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet private weak var assetStatusLabel: UILabel!
    @IBOutlet private weak var animationSwitch: UISwitch!
    @IBOutlet private weak var mapView: MKMapView!
    @IBOutlet private weak var subscriberResolutionAccuracyLabel: UILabel!
    @IBOutlet private weak var subscriberResolutionMinDisplacementlabel: UILabel!
    @IBOutlet private weak var subscriberResolutionIntervalLabel: UILabel!
    @IBOutlet private weak var publisherResolutionAccuracyLabel: UILabel!
    @IBOutlet private weak var publisherResolutionMinDisplacementlabel: UILabel!
    @IBOutlet private weak var publisherResolutionIntervalLabel: UILabel!

    // MARK: - Properties
    private let zPriorityForeground = MKAnnotationViewZPriority(1.0)
    private let zPriorityBackground = MKAnnotationViewZPriority(0.0)
    private let resolution = Resolution(accuracy: .balanced, desiredInterval: 10000, minimumDisplacement: 500)
    private let trackingId: String
    private let locationAnimator: LocationAnimator
    private var subscriber: Subscriber?
    private var errors: [ErrorInformation] = []
    private var locationUpdateInterval: TimeInterval = .zero

    private var currentResolution: Resolution?
    private var resolutionDebounceTimer: Timer?
    
    private let subscriberLogger = SubscriberLogger()

    private var location: CLLocation?
    
    private var lastReceivedLocationUpdate: LocationUpdate?

    // MARK: - Initialization
    init(trackingId: String) {
        self.trackingId = trackingId
        self.locationAnimator = DefaultLocationAnimator()
        self.locationUpdateInterval = resolution.desiredInterval

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
        updateSubscriberResolutionLabels()
        
        locationAnimator.subscribeForPositionUpdates { [weak self] position in
            guard self?.animationSwitch.isOn == true else {
                return
            }
            
            if let lastReceivedLocationUpdate = self?.lastReceivedLocationUpdate {
                let lastReceivedLocation = CLLocation(latitude: lastReceivedLocationUpdate.location.coordinate.latitude, longitude: lastReceivedLocationUpdate.location.coordinate.longitude)
                let animatedLocation = CLLocation(latitude: position.latitude, longitude: position.longitude)
                
                let distance = animatedLocation.distance(from: lastReceivedLocation)
                self?.subscriberLogger.logMessage(level: .info, message: "Distance from animatedLocation to lastReceivedLocation is \(distance)", error: nil)
            }
            
            self?.updateTruckAnnotation(position: position)
            self?.updateHorizontalAccuracyAnnotation(position: position)
        }
        
        locationAnimator.subscribeForCameraPositionUpdates { [weak self] position in
            guard self?.animationSwitch.isOn == true else {
                return
            }
            
            self?.scrollToReceivedLocation(position: position)
        }
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
        mapView.register(TruckAnnotationView.self, forAnnotationViewWithReuseIdentifier: TruckAnnotationView.identifier)
        mapView.register(HorizontalAccuracyAnnotationView.self, forAnnotationViewWithReuseIdentifier: HorizontalAccuracyAnnotationView.identifier)
    }

    private func setupControlsBehaviour() {
        assetStatusLabel.font = UIFont.systemFont(ofSize: 14)
    }
    
    // MARK: - Subscriber setup
    private func setupSubscriber() {
        // An example of using AuthCallback is shown in the PublisherExample's MapViewController.swift
        let connectionConfiguration = ConnectionConfiguration(apiKey: Environment.ablyApiKey, clientId: "Asset Tracking Subscriber Example")

        subscriber = SubscriberFactory.subscribers()
            .connection(connectionConfiguration)
            .trackingId(trackingId)
            .resolution(resolution)
            .logHandler(handler: subscriberLogger)
            .delegate(self)
            .start { [weak self] result in
                switch result {
                case .success:
                    self?.subscriberLogger.i(message: "Subscriber started successfully", error: nil)
                case .failure(let error):
                    self?.showErrorDialog(withMessage: error.message)
                }
            }
    }
    
    // MARK: Utils
    private func updateTruckAnnotation(position: Position) {
        let coordinate = CLLocationCoordinate2D(latitude: position.latitude, longitude: position.longitude)
        
        let annotation: TruckAnnotation = createAnnotationIfNeeded()
        annotation.bearing = position.bearing
        annotation.coordinate = coordinate
        
        if let view = mapView.view(for: annotation) as? TruckAnnotationView {
            view.bearing = position.bearing
        }
    }
    
    private func updateHorizontalAccuracyAnnotation(position: Position) {
        let coordinate = CLLocationCoordinate2D(latitude: position.latitude, longitude: position.longitude)
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: position.accuracy, longitudinalMeters: position.accuracy)
        let rect = mapView.convert(region, toRectTo: mapView)

        let annotation: HorizontalAccuracyAnnotation = createAnnotationIfNeeded()
        annotation.accuracy = position.accuracy
        annotation.coordinate = coordinate
        
        if let view = mapView.view(for: annotation) as? HorizontalAccuracyAnnotationView {
            view.accuracy = Double(rect.size.width)
        }
    }
    
    private func createAnnotationIfNeeded<T: MKPointAnnotation>() -> T {
        if let annotation = mapView.annotations.first(where: { $0 is T }) as? T {
            return annotation
        } else {
            let annotation = T()
            mapView.addAnnotation(annotation)
            
            return annotation
        }
    }

    private func scrollToReceivedLocation(position: Position) {
        let region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: position.latitude,
                longitude: position.longitude
            ),
            latitudinalMeters: MapConstraints.regionLatitude,
            longitudinalMeters: MapConstraints.regionLongitude
        )
        
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
                self?.updateSubscriberResolutionLabels()
                self?.subscriberLogger.i(message: "Updated resolution to: \(resolution)", error: nil)
            case .failure(let error):
                let errorDescription = DescriptionsHelper.ResolutionStateHelper.getDescription(for: .changeError(error))
                self?.showErrorDialog(withMessage: errorDescription)
            }
        }
    }

    private func updateSubscriberResolutionLabels() {
        guard let resolution = currentResolution else {
            subscriberResolutionAccuracyLabel.text = "-"
            subscriberResolutionIntervalLabel.text = "-"
            subscriberResolutionMinDisplacementlabel.text = "-"
            return
        }
        
        subscriberResolutionAccuracyLabel.text = "\(resolution.accuracy)"
        subscriberResolutionIntervalLabel.text = "\(resolution.desiredInterval)ms"
        subscriberResolutionMinDisplacementlabel.text = "\(resolution.minimumDisplacement)m"
    }
    
    private func updatePublisherResolutionLabels(resolution: Resolution?) {
        guard let resolution = resolution else {
            publisherResolutionAccuracyLabel.text = "-"
            publisherResolutionIntervalLabel.text = "-"
            publisherResolutionMinDisplacementlabel.text = "-"
            return
        }
        
        publisherResolutionAccuracyLabel.text = "\(resolution.accuracy)"
        publisherResolutionIntervalLabel.text = "\(resolution.desiredInterval)ms"
        publisherResolutionMinDisplacementlabel.text = "\(resolution.minimumDisplacement)m"
    }
    
    private func showErrorDialog(withMessage message: String) {
        let alertVC = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertVC, animated: true, completion: nil)
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? TruckAnnotation {
            
            return createTruckAnnotationView(for: annotation)
        } else if let annotation = annotation as? HorizontalAccuracyAnnotation {
            
            return createHorizontalAccuracyView(for: annotation)
        }
        
        return nil
    }

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let zoom = mapView.getZoomLevel()
        subscriberLogger.d(message: "Current map zoom level: \(zoom)", error: nil)
        scheduleResolutionUpdate()
    }
    
    private func createTruckAnnotationView(for annotation: TruckAnnotation) -> TruckAnnotationView {
        let annotationView: TruckAnnotationView = getAnnotationView(for: annotation)
        annotationView.bearing = annotation.bearing
        annotationView.zPriority = zPriorityForeground

        return annotationView
    }
    
    private func createHorizontalAccuracyView(for annotation: HorizontalAccuracyAnnotation) -> HorizontalAccuracyAnnotationView {
        let annotationView: HorizontalAccuracyAnnotationView = getAnnotationView(for: annotation)
        annotationView.zPriority = zPriorityBackground

        return annotationView
    }
        
    private func getAnnotationView<T: MKAnnotationView & Identifiable>(for annotation: MKPointAnnotation) -> T {
        guard let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: T.identifier) as? T else {
            return T(annotation: annotation, reuseIdentifier: T.identifier)
        }
        
        return annotationView
    }
}

extension MapViewController: SubscriberDelegate {
    func subscriber(sender: Subscriber, didFailWithError error: ErrorInformation) {
        showErrorDialog(withMessage: error.description)
        errors.append(error)
    }

    func subscriber(sender: Subscriber, didUpdateEnhancedLocation locationUpdate: LocationUpdate) {
        lastReceivedLocationUpdate = locationUpdate
        
        if animationSwitch.isOn {
            locationAnimator.animateLocationUpdate(location: locationUpdate, expectedIntervalBetweenLocationUpdatesInMilliseconds: locationUpdateInterval / 1000.0)
        } else {
            updateTruckAnnotation(position: locationUpdate.location.toPosition())
            scrollToReceivedLocation(position: locationUpdate.location.toPosition())
        }
        
        self.location = locationUpdate.location.toCoreLocation()
    }

    func subscriber(sender: Subscriber, didChangeAssetConnectionStatus status: ConnectionState) {
        let statusDescAndColor = DescriptionsHelper.AssetStateHelper.getDescriptionAndColor(for: .connectionState(status))
        assetStatusLabel.textColor = statusDescAndColor.color
        assetStatusLabel.text = statusDescAndColor.desc
    }
    
    func subscriber(sender: Subscriber, didUpdateResolution resolution: Resolution) {
        updatePublisherResolutionLabels(resolution: resolution)
    }
    
    func subscriber(sender: Subscriber, didUpdateDesiredInterval interval: Double) {
        locationUpdateInterval = interval
    }
}
