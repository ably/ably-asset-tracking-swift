import UIKit
import CoreLocation

enum LocationSourceType: String, CaseIterable {
    case s3File = "S3 File"
    case phone = "Phone"
}

class SettingsViewController: UIViewController {
    @IBOutlet private weak var locationPermissionButton: UIButton!
    @IBOutlet private weak var trackingIdTextField: UITextField!
    @IBOutlet private weak var startButton: UIButton!
    @IBOutlet private weak var locationSourceButton: UIButton!
    @IBOutlet private weak var locationSourceLabel: UILabel!
    @IBOutlet private weak var fileS3Button: UIButton!
    @IBOutlet private weak var fileS3Label: UILabel!
    
    private let awsS3Service: S3Service?
    private let locationManager = CLLocationManager()
    private var locationSource: LocationSourceType = .phone {
        didSet {
            if locationSource != oldValue {
                handleLocationSourceChange()
            }
        }
    }
    
    private var selectedS3FileName: String?

    // MARK: Initialization
    init() {
        let viewControllerType = SettingsViewController.self
        awsS3Service = S3Service()
        super.init(nibName: String(describing: viewControllerType), bundle: Bundle(for: viewControllerType))
        setupS3Service()
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
        setButtonBorder(locationPermissionButton)
        setButtonBorder(startButton)
        setButtonBorder(locationSourceButton)
        setButtonBorder(fileS3Button)
    }
    
    private func setButtonBorder(_ button: UIButton) {
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemBlue.cgColor
        button.layer.cornerRadius = button.bounds.height / 2
    }
    
    private func setupS3Service() {
        awsS3Service?.configure { result in
            switch result {
            case .success:
                logger.info("AWS S3 configured successfully.")
            case .failure(let error):
                logger.error("AWS S3 configuration error: \(error.message ?? "Unknown")")
            }
        }
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
        
        locationSource == .s3File
            ? showMapWithForS3file(trackingId)
            : showMapWithTrackableId(trackingId)
    }
    
    private func showMapWithForS3file(_ trackableId: String) {
        guard let selectedFileName = selectedS3FileName else {
            return
        }
        awsS3Service?.downloadHistoryData(selectedFileName) { result in
            switch result {
            case .success(let locations):
                logger.info("AWS S3 \(selectedFileName) downloaded successfully.")
                DispatchQueue.main.async {
                    let mapVC = MapViewController(trackingId: trackableId, historyLocation: locations)
                    self.navigationController?.pushViewController(mapVC, animated: true)
                }
            case .failure(let error):
                logger.error("AWS S3 downloading error: \(error.message ?? "Unknown")")
            }
        }
    }
    
    private func showMapWithTrackableId(_ trackableId: String) {
        let mapVC = MapViewController(trackingId: trackableId, historyLocation: nil)
        navigationController?.pushViewController(mapVC, animated: true)
    }

    @IBAction func onLocationSourceButtonTapped(_ sender: UIButton) {
        showLocationSourceAlert()
    }
    
    @IBAction func onFileS3ButtonTapped(_ sender: UIButton) {
        showS3FilesListViewController()
    }
    
    // MARK: Private
    private func handleLocationSourceChange() {
        locationSourceLabel.text = locationSource.rawValue
        fileS3Button.isHidden = locationSource != .s3File
        fileS3Label.isHidden = locationSource != .s3File
        trackingIdTextField.text = ""
        if locationSource == .phone {
            selectedS3FileName = nil
        }
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
    
    private func showLocationSourceAlert() {
        let alertController = UIAlertController(title: "Choose location source", message: "", preferredStyle: .actionSheet)
        
        LocationSourceType.allCases.forEach { locationSource in
            let action = UIAlertAction(title: locationSource.rawValue, style: .default) { _ in
                self.locationSource = locationSource
            }
            alertController.addAction(action)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func showS3FilesListViewController() {
        guard let awsS3Service = awsS3Service else {
            return
        }
        
        let listVC = S3FilesListViewController(awsS3Service: awsS3Service) { [weak self] selectedFile in
            self?.fileS3Label.text = selectedFile.name
            self?.selectedS3FileName = selectedFile.name
            self?.trackingIdTextField.text = "simulation_id"
        }
        
        navigationController?.pushViewController(listVC, animated: true)
    }
}
