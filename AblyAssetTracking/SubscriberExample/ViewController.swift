import UIKit
import Subscriber

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Temporary test to validate if we have access to Subscriber framework
        let _ = AblyAssetTrackingSubscriber()
    }
}
