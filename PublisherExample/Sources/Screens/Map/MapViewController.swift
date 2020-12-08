import UIKit

class MapViewController: UIViewController {
    private let trackingId: String
    
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
    }
}
