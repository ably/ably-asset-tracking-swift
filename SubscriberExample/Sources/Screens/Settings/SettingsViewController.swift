import UIKit

class SettingsViewController: UIViewController {
    @IBOutlet private weak var trackingIdTextField: UITextField!
    @IBOutlet private weak var startTrackingButton: UIButton!

    // MARK: Initialization
    init() {
        let viewControllerType = SettingsViewController.self
        super.init(nibName: String(describing: viewControllerType), bundle: Bundle(for: viewControllerType))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Ably Asset Tracking Subscriber"

        startTrackingButton.layer.borderWidth = 1
        startTrackingButton.layer.borderColor = UIColor.systemBlue.cgColor
        startTrackingButton.layer.cornerRadius = startTrackingButton.bounds.height / 2
    }

    // MARK: Actions
    @IBAction private func onStartTrackingButtonPress(_ sender: Any) {
        guard let trackingId = trackingIdTextField.text,
              !trackingId.isEmpty
        else {
            let alert = UIAlertController(title: "No tracking ID",
                                          message: "Please enter tracking ID to continue.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        let mapVC = MapViewController(trackingId: trackingId)
        navigationController?.pushViewController(mapVC, animated: true)
    }
}
