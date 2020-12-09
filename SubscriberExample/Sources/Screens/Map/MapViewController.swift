import UIKit
import MapKit
import Subscriber

class MapViewController: UIViewController {
    @IBOutlet private weak var assetStatusLabel: UILabel!
    @IBOutlet private weak var animationSwitch: UISwitch!
    @IBOutlet private weak var mapView: MKMapView!
    
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
    }
    
    private func setupSubscriber() {
        let configuration = AssetTrackingSubscriberConfiguration(apiKey: "",
                                                                 clientId: "",
                                                                 resolution: 0,
                                                                 trackingId: trackingId)
        subscriber = DefaultSubscriber(configuration: configuration)
        subscriber?.delegate = self
        subscriber?.start()
    }
    
    // MARK: Utils
    private func updateRawLocationAnnotation() {
        updateAnnotation(withTitle: "Raw", location: rawLocation)
    }
    
    private func updateEnhancedLocationAnnotation() {
        updateAnnotation(withTitle: "Enhanced", location: rawLocation)
    }
    
    private func updateAnnotation(withTitle: String, location: CLLocation?) {
        guard let location = location else {
            let annotationsToRemove = mapView.annotations.filter({ $0.title == title })
            mapView.removeAnnotations(annotationsToRemove)
            return
        }
        
        if let annotation = mapView.annotations.first(where: { $0.title == title }) as? MKPointAnnotation {
            let animated = animationSwitch.isOn
            UIView.animate(withDuration: animated ? 0.5 :1) {
                annotation.coordinate = location.coordinate
            }
        } else {
            let annotation = MKPointAnnotation()
            annotation.title = title
            annotation.coordinate = location.coordinate
            mapView.addAnnotation(annotation)
        }
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
