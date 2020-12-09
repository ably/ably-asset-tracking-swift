import UIKit
import CoreLocation

class SettingsViewController: UIViewController {
    @IBOutlet private weak var locationPermissionButton: UIButton!
    @IBOutlet private weak var trackingIdTextField: UITextField!
    @IBOutlet private weak var startButton: UIButton!
    
    private let locationManager = CLLocationManager()
    
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
        setupView()
    }
    
    private func setupView() {
        self.title = "Ably Asset Tracking Publisher"
        locationPermissionButton.layer.borderWidth = 1
        locationPermissionButton.layer.borderColor = UIColor.systemBlue.cgColor
        locationPermissionButton.layer.cornerRadius = locationPermissionButton.bounds.height / 2
        
        startButton.layer.borderWidth = 1
        startButton.layer.borderColor = UIColor.systemBlue.cgColor
        startButton.layer.cornerRadius = locationPermissionButton.bounds.height / 2
    }
    
    // MARK: Actions
    @IBAction private func onLocationPermissionButtonPress(_ sender: Any) {
        let status = CLLocationManager.authorizationStatus()
        if status == .denied {
            showPermissionSettingsAlert()
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    @IBAction private func onStartButtonPress(_ sender: Any) {
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
        
        let vc = MapViewController(trackingId: trackingId)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: Utils
    private func showPermissionSettingsAlert() {
        let alert = UIAlertController(
            title: "Missing Location Services",
            message: "No location permission. You can enable it in the app settings.",
            preferredStyle: UIAlertController.Style.alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        alert.addAction(UIAlertAction(title: "Go to settings", style: .default, handler: { _ in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString),
                  UIApplication.shared.canOpenURL(settingsUrl)
            else { return }
            UIApplication.shared.open(settingsUrl, completionHandler: nil)
        }))
        
        present(alert, animated: true, completion: nil)
    }
}
