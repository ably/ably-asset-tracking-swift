import UIKit
import MapKit
import Subscriber

class MapViewController: UIViewController {
    @IBOutlet private weak var assetStatusLabel: UILabel!
    @IBOutlet private weak var animationSwitch: UISwitch!
    @IBOutlet private weak var mapView: MKMapView!
    
    private let truckAnnotationViewIdentifier = "MapTruckAnnotationViewIdentifier"
    private let trackingId: String
    private var subscriber: AssetTrackingSubscriber?
    private var errors: [Error] = []
    
    private var rawLocation: CLLocation? { didSet { updateRawLocationAnnotation() }}
    private var enhancedLocation: CLLocation? { didSet { updateEnhancedLocationAnnotation() }}
    
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
        let configuration = AssetTrackingSubscriberConfiguration(apiKey: SubscriberKeys.ablyApiKey,
                                                                 clientId: SubscriberKeys.ablyClientId,
                                                                 resolution: 0,
                                                                 trackingId: trackingId)
        subscriber = DefaultSubscriber(configuration: configuration)
        subscriber?.delegate = self
        subscriber?.start()
    }
    
    // MARK: Utils
    private func updateRawLocationAnnotation() {
        updateAnnotation(withType: .raw, location: rawLocation)
    }
    
    private func updateEnhancedLocationAnnotation() {
        updateAnnotation(withType: .enhanced, location: rawLocation)
    }
    
    private func updateAnnotation(withType type: TruckAnnotationType, location: CLLocation?) {
        guard let location = location else {
            let annotationsToRemove = mapView.annotations.filter({ ($0 as? TruckAnnotation)?.type == type })
            mapView.removeAnnotations(annotationsToRemove)
            return
        }
        
        if let annotation = mapView.annotations.first(where: { $0.title == title }) as? TruckAnnotation {
            let isAnimated = animationSwitch.isOn
            UIView.animate(withDuration: isAnimated ? 0.5 : 1) {
                annotation.coordinate = location.coordinate
                annotation.bearing = location.course
            }
        } else {
            let annotation = TruckAnnotation()
            annotation.type = type
            annotation.coordinate = location.coordinate
            annotation.bearing = location.course
            mapView.addAnnotation(annotation)
        }
    }
    
    private func scrollToReceivedLocation() {
        let mapCenter = mapView.region.center
        let minimumCenterDistance: Double = 500
        guard let location = rawLocation ?? enhancedLocation,
              location.distance(from: CLLocation(latitude: mapCenter.latitude, longitude: mapCenter.longitude)) > minimumCenterDistance
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
        else { return nil}
        
        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: truckAnnotationViewIdentifier) as? TruckAnnotationView ??
            TruckAnnotationView(annotation: annotation, reuseIdentifier: truckAnnotationViewIdentifier)
        let isRaw = annotation.type == .raw
        annotationView.backgroundColor = isRaw ? UIColor.yellow.withAlphaComponent(0.7) :
            UIColor.blue.withAlphaComponent(0.7)
        annotationView.bearing = annotation.bearing
        
        return annotationView
    }
}

extension MapViewController: AssetTrackingSubscriberDelegate {
    func assetTrackingSubscriber(sender: AssetTrackingSubscriber, didFailWithError error: Error) {
        errors.append(error)
    }
    
    func assetTrackingSubscriber(sender: AssetTrackingSubscriber, didUpdateRawLocation location: CLLocation) {
        rawLocation = location
    }
    
    func assetTrackingSubscriber(sender: AssetTrackingSubscriber, didUpdateEnhancedLocation location: CLLocation) {
        enhancedLocation = location
    }
    
    func assetTrackingSubscriber(sender: AssetTrackingSubscriber, didChangeAssetConnectionStatus status: AssetTrackingConnectionStatus) {
        assetStatusLabel.text = status == .online ? "The asset is online" : "The asset is offline"
    }
}
