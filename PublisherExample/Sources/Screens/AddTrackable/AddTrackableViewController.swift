import AblyAssetTracking
import UIKit

protocol AddTrackableViewControllerDelegate: AnyObject {
    func addTrackableViewController(sender: AddTrackableViewController, onTrackableAdded trackable: Trackable)
}

class AddTrackableViewController: UIViewController {
    @IBOutlet private weak var saveAsDefaultSwitch: UISwitch!
    @IBOutlet private weak var resolutionConstraintsSwitch: UISwitch!
    @IBOutlet weak var resolutionConstraintsContainer: UIView!

    @IBOutlet private weak var trackableIdTextField: UITextField!
    @IBOutlet private weak var latitudeTextField: UITextField!
    @IBOutlet private weak var longitudeTextField: UITextField!
    @IBOutlet private weak var batteryLevelThresholdTextField: UITextField!

    @IBOutlet private weak var lowBatteryMultiplierTextField: UITextField!
    @IBOutlet private weak var proximitySpatialTextField: UITextField!
    @IBOutlet private weak var proximityTemporalTextField: UITextField!

    @IBOutlet private weak var farWithoutSubscriberAccuracyTextField: UITextField!
    @IBOutlet private weak var farWithoutSubscriberDesiredIntervalTextField: UITextField!
    @IBOutlet private weak var farWithoutSubscriberMinimumDisplacementTextField: UITextField!

    @IBOutlet private weak var farWithSubscriberAccuracyTextField: UITextField!
    @IBOutlet private weak var farWithSubscriberDesiredIntervalTextField: UITextField!
    @IBOutlet private weak var farWithSubscriberMinimumDisplacementTextField: UITextField!

    @IBOutlet private weak var nearWithoutSubscriberAccuracyTextField: UITextField!
    @IBOutlet private weak var nearWithoutSubscriberDesiredIntervalTextField: UITextField!
    @IBOutlet private weak var nearWithoutSubscriberMinimumDisplacementTextField: UITextField!

    @IBOutlet private weak var nearWithSubscriberAccuracyTextField: UITextField!
    @IBOutlet private weak var nearWithSubscriberDesiredIntervalTextField: UITextField!
    @IBOutlet private weak var nearWithSubscriberMinimumDisplacementTextField: UITextField!

    @IBOutlet weak var resolutionConstraintsZeroHeightConstraint: NSLayoutConstraint!

    weak var delegate: AddTrackableViewControllerDelegate?

    // MARK: Initialization
    init() {
        let viewControllerType = AddTrackableViewController.self
        super.init(nibName: String(describing: viewControllerType), bundle: Bundle(for: viewControllerType))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: Actions
    @IBAction func onResolutionConstraintsSwitchValueChanged(_ sender: Any) {
        self.resolutionConstraintsZeroHeightConstraint.priority = self.resolutionConstraintsSwitch.isOn ? .defaultLow : .defaultHigh        
    }
}
