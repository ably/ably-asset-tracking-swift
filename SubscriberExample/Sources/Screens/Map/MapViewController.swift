import UIKit
import MapKit
import Subscriber

class MapViewController: UIViewController {
    @IBOutlet private weak var assetStatusLabel: UILabel!
    @IBOutlet private weak var animationSwitch: UISwitch!
    @IBOutlet private weak var mapView: MKMapView!
    
    private let trackingId: String
    private var subscriber: AssetTrackingSubscriber?
    
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
}


extension MapViewController: AssetTrackingSubscriberDelegate {
    func assetTrackingSubscriber(sender: AssetTrackingSubscriber, didFailWithError error: Error) {
        
    }
    
    func assetTrackingSubscriber(sender: AssetTrackingSubscriber, didUpdateRawLocation location: CLLocation) {
        
    }
    
    func assetTrackingSubscriber(sender: AssetTrackingSubscriber, didUpdateEnhancedLocation location: CLLocation) {
        
    }
    
    func assetTrackingSubscriber(sender: AssetTrackingSubscriber, didChangeAssetConnectionStatus status: AssetTrackingConnectionStatus) {
        
    }
}
