import UIKit
import Subscriber

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Temporary test to validate if we have access to Subscriber framework
        let configuration = AssetTrackingSubscriberConfiguration(apiKey: "", clientId: "", resolution: 1, trackingId: "")
        let _ = DefaultSubscriber(configuration: configuration)        
    }
}
