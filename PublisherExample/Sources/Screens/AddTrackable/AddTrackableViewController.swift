import AblyAssetTracking
import UIKit
import CoreLocation

protocol AddTrackableViewControllerDelegate: AnyObject {
    func addTrackableViewController(sender: AddTrackableViewController, onTrackableAdded trackable: Trackable)
}

// swiftlint:disable identifier_name
class AddTrackableViewController: UIViewController {
    @IBOutlet private weak var saveAsDefaultSwitch: UISwitch!
    @IBOutlet private weak var resolutionConstraintsSwitch: UISwitch!
    @IBOutlet private weak var resolutionConstraintsContainer: UIView!

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
        setupTextFields()

        resolutionConstraintsSwitch.isOn = false
        updateResolutionConstraintsSectionVisibility()
    }

    // MARK: View setup
    private func setupTextFields() {
        trackableIdTextField.keyboardType = .default
        trackableIdTextField.delegate = self
        trackableIdTextField.returnKeyType = .next

        setupForDecimal(textField: latitudeTextField, nextTextField: longitudeTextField)
        setupForDecimal(textField: longitudeTextField, nextTextField: nil)

        // Resolution constraints
        setupForDecimal(textField: batteryLevelThresholdTextField, nextTextField: lowBatteryMultiplierTextField)
        setupForDecimal(textField: lowBatteryMultiplierTextField, nextTextField: proximitySpatialTextField)
        setupForDecimal(textField: proximitySpatialTextField, nextTextField: proximityTemporalTextField)
        setupForDecimal(textField: proximityTemporalTextField, nextTextField: farWithoutSubscriberAccuracyTextField)

        farWithoutSubscriberAccuracyTextField.inputView = AccuracyPickerView()
        setupForDecimal(textField: farWithoutSubscriberAccuracyTextField, nextTextField: farWithoutSubscriberDesiredIntervalTextField)
        setupForDecimal(textField: farWithoutSubscriberDesiredIntervalTextField, nextTextField: farWithoutSubscriberMinimumDisplacementTextField)
        setupForDecimal(textField: farWithoutSubscriberMinimumDisplacementTextField, nextTextField: farWithSubscriberAccuracyTextField)

        farWithSubscriberAccuracyTextField.inputView = AccuracyPickerView()
        setupForDecimal(textField: farWithSubscriberAccuracyTextField, nextTextField: farWithSubscriberDesiredIntervalTextField)
        setupForDecimal(textField: farWithSubscriberDesiredIntervalTextField, nextTextField: farWithSubscriberMinimumDisplacementTextField)
        setupForDecimal(textField: farWithSubscriberMinimumDisplacementTextField, nextTextField: nearWithoutSubscriberAccuracyTextField)

        nearWithoutSubscriberAccuracyTextField.inputView = AccuracyPickerView()
        setupForDecimal(textField: nearWithoutSubscriberAccuracyTextField, nextTextField: nearWithoutSubscriberDesiredIntervalTextField)
        setupForDecimal(textField: nearWithoutSubscriberDesiredIntervalTextField, nextTextField: nearWithoutSubscriberMinimumDisplacementTextField)
        setupForDecimal(textField: nearWithoutSubscriberMinimumDisplacementTextField, nextTextField: nearWithSubscriberAccuracyTextField)

        nearWithSubscriberAccuracyTextField.inputView = AccuracyPickerView()
        setupForDecimal(textField: nearWithSubscriberAccuracyTextField, nextTextField: nearWithSubscriberDesiredIntervalTextField)
        setupForDecimal(textField: nearWithSubscriberDesiredIntervalTextField, nextTextField: nearWithSubscriberMinimumDisplacementTextField)
        setupForDecimal(textField: nearWithoutSubscriberMinimumDisplacementTextField, nextTextField: nil)
    }

    private func setupForDecimal(textField: UITextField, nextTextField: UITextField?) {
        textField.keyboardType = .decimalPad
        textField.inputAccessoryView = AddTrackableToolbar(onNextButtonPress: {
            if let nextTextField = nextTextField {
                nextTextField.becomeFirstResponder()
            } else {
                textField.endEditing(true)
            }
        })
        textField.inputAccessoryView?.sizeToFit()
    }

    // MARK: Actions
    @IBAction private func onResolutionConstraintsSwitchValueChanged(_ sender: Any) {
        updateResolutionConstraintsSectionVisibility()
    }

    @IBAction private func onAddButtonPress(_ sender: Any) {
        do {
            let trackable = try createTrackableFromCurrentData()
            delegate?.addTrackableViewController(sender: self, onTrackableAdded: trackable)
            dismiss(animated: true, completion: nil)
        } catch let err {
            let alert = UIAlertController(title: "Alert", message: err.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }

    @IBAction private func onCancelButtonPress(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    // MARK: Utils
    private func updateResolutionConstraintsSectionVisibility() {
        resolutionConstraintsZeroHeightConstraint.priority = resolutionConstraintsSwitch.isOn ? .defaultLow : .defaultHigh
    }

    // MARK: Trackable creation
    private func createTrackableFromCurrentData() throws -> Trackable {
        guard let trackableId = trackableIdTextField.text,
              !trackableId.isEmpty
        else { throw AddTrackableError(message: "Missing or incorrect TrackableId.") }
        let destination = try getDestination()

        if !resolutionConstraintsSwitch.isOn {
            return Trackable(id: trackableId, metadata: nil, destination: destination, constraints: nil)
        }

        guard let batteryLevelThresholdText = batteryLevelThresholdTextField.text,
              !batteryLevelThresholdText.isEmpty,
              let batteryLevelThreshold = Float(batteryLevelThresholdText)
        else { throw AddTrackableError(message: "Incorrect Battery Level Threshold value.") }

        guard let lowBatteryMultiplierText = lowBatteryMultiplierTextField.text,
              !lowBatteryMultiplierText.isEmpty,
              let lowBatteryMultiplier = Float(lowBatteryMultiplierText)
        else { throw AddTrackableError(message: "Incorrect Low Battery Multiplier value.") }

        let farWithoutSubscriberResolution = try getResolution(named: "Far Without Subscriber",
                                                               fromAccuracyTextField: farWithoutSubscriberAccuracyTextField,
                                                               desiredIntervalTextField: farWithoutSubscriberDesiredIntervalTextField,
                                                               minimumDisplacementTextField: farWithoutSubscriberMinimumDisplacementTextField)
        let farWithSubscriberResolution = try getResolution(named: "Far With Subscriber",
                                                               fromAccuracyTextField: farWithSubscriberAccuracyTextField,
                                                               desiredIntervalTextField: farWithSubscriberDesiredIntervalTextField,
                                                               minimumDisplacementTextField: farWithSubscriberMinimumDisplacementTextField)
        let nearWithoutSubscriberResolution = try getResolution(named: "Near Without Subscriber",
                                                               fromAccuracyTextField: nearWithoutSubscriberAccuracyTextField,
                                                               desiredIntervalTextField: nearWithoutSubscriberDesiredIntervalTextField,
                                                               minimumDisplacementTextField: nearWithoutSubscriberMinimumDisplacementTextField)
        let nearWithSubscriberResolution = try getResolution(named: "Near With Subscriber",
                                                               fromAccuracyTextField: nearWithSubscriberAccuracyTextField,
                                                               desiredIntervalTextField: nearWithSubscriberDesiredIntervalTextField,
                                                               minimumDisplacementTextField: nearWithSubscriberMinimumDisplacementTextField)

        let resolutionSet = DefaultResolutionSet(farWithoutSubscriber: farWithoutSubscriberResolution,
                                                 farWithSubscriber: farWithSubscriberResolution,
                                                 nearWithoutSubscriber: nearWithoutSubscriberResolution,
                                                 nearWithSubscriber: nearWithSubscriberResolution)
        let constraints = DefaultResolutionConstraints(resolutions: resolutionSet,
                                                       proximityThreshold: try getProximity(),
                                                       batteryLevelThreshold: batteryLevelThreshold,
                                                       lowBatteryMultiplier: lowBatteryMultiplier)
        return Trackable(id: trackableId, metadata: nil, destination: destination, constraints: constraints)
    }

    private func getProximity() throws -> Proximity {
        let proximitySpatial = proximitySpatialTextField.text == nil ? nil : Double(proximitySpatialTextField.text!)
        if proximitySpatial == nil && !(proximitySpatialTextField.text?.isEmpty ?? false) {
            throw AddTrackableError(message: "Incorrect Proximity Spatial value.")
        }

        let proximityTemporal = proximityTemporalTextField.text == nil ? nil : Double(proximityTemporalTextField.text!)
        if proximityTemporal == nil && !(proximityTemporalTextField.text?.isEmpty ?? false) {
            throw AddTrackableError(message: "Incorrect Proximity Temporal value.")
        }

        if proximitySpatial != nil && proximityTemporal != nil {
            throw AddTrackableError(message: "There can be only one (spatial or temporal) Proximity value set.")
        }

        if let spatial = proximitySpatial {
            return DefaultProximity(spatial: spatial)
        }

        if let temporal = proximityTemporal {
            return DefaultProximity(temporal: temporal)
        }

        throw AddTrackableError(message: "Missing Proximity (spatial or temporal) value.")
    }

    private func getResolution(named resolutionName: String,
                               fromAccuracyTextField accuracyTextField: UITextField,
                               desiredIntervalTextField: UITextField,
                               minimumDisplacementTextField: UITextField) throws -> Resolution {
        guard let accuracyText = accuracyTextField.text,
              let accuracy = AccuracyPickerView().accuracyWithTitle(accuracyText)
        else {
            throw AddTrackableError(message: "Incorrect Accuracy value for \(resolutionName) resolution.")
        }

        guard let desiredIntervalText = desiredIntervalTextField.text,
              !desiredIntervalText.isEmpty,
              let desiredInterval = Double(desiredIntervalText)
        else {
            throw AddTrackableError(message: "Incorrect Desired Interval value for \(resolutionName) resolution.")
        }

        guard let minimumDisplacementText = minimumDisplacementTextField.text,
              !minimumDisplacementText.isEmpty,
              let minimumDisplacement = Double(minimumDisplacementText)
        else {
            throw AddTrackableError(message: "Incorrect Minimum Displacement value for \(resolutionName) resolution.")
        }

        return Resolution(accuracy: accuracy, desiredInterval: desiredInterval, minimumDisplacement: minimumDisplacement)
    }

    private func getDestination() throws -> CLLocationCoordinate2D? {
        let latitude = latitudeTextField.text == nil ? nil : Double(latitudeTextField.text!)
        if latitude == nil && !(latitudeTextField.text?.isEmpty ?? false) {
            throw AddTrackableError(message: "Incorrect Latitude value.")
        }

        let longitude = longitudeTextField.text == nil ? nil : Double(longitudeTextField.text!)
        if longitude == nil && !(longitudeTextField.text?.isEmpty ?? false) {
            throw AddTrackableError(message: "Incorrect Longitude value.")
        }
        if latitude == nil && longitude != nil {
            throw AddTrackableError(message: "Missing Latitude. Add Latitude value or remove Longitude.")
        }
        if longitude == nil && latitude != nil {
            throw AddTrackableError(message: "Missing Longitude. Add Longitude value or remove Latitude.")
        }

        let destination: CLLocationCoordinate2D? = latitude != nil && longitude != nil ? CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!) : nil
        return destination
    }
}

extension AddTrackableViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == trackableIdTextField {
            latitudeTextField.becomeFirstResponder()
            return false
        }
        return true
    }
}
