import UIKit
import Subscriber
import CoreLocation

class ViewController: UIViewController {
    private var subscriber: AssetTrackingSubscriber?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubscriber()
    }
    
    private func setupSubscriber() {
        let configuration = AssetTrackingSubscriberConfiguration(apiKey: "",
                                                                 clientId: "",
                                                                 resolution: 0,
                                                                 trackingId: "")
        subscriber = DefaultSubscriber(configuration: configuration)
        subscriber?.delegate = self
        subscriber?.start()
    }
}

extension ViewController: AssetTrackingSubscriberDelegate {
    func assetTrackingSubscriber(sender: AssetTrackingSubscriber, didFailWithError error: Error) {
        
    }
    
    func assetTrackingSubscriber(sender: AssetTrackingSubscriber, didUpdateRawLocation location: CLLocation) {
        
    }
    
    func assetTrackingSubscriber(sender: AssetTrackingSubscriber, didUpdateEnhancedLocation location: CLLocation) {
        
    }
    
    func assetTrackingSubscriber(sender: AssetTrackingSubscriber, didChangeAssetConnectionStatus status: AssetTrackingConnectionStatus) {
        
    }
}
