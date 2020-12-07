import UIKit
import Publisher


class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Temporary test to validate if we have access to Publisher data
        let configuration = AblyConfiguration(apiKey: "", clientId: "")
        let _ = AblyAssetTrackingPublisher(configuration: configuration)
    }
}
