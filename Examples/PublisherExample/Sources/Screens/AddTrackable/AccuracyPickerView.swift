import UIKit
import AblyAssetTrackingPublisher

class AccuracyPickerView: UIPickerView, UIPickerViewDelegate, UIPickerViewDataSource {
    private let options: [Accuracy] = [.minimum, .low, .balanced, .high, .maximum]
    private let titles = ["Minimum", "Low", "Balanced", "High", "Maximum"]
    private let onSelectionChanged: ((Accuracy, String) -> Void)?

    init(onSelectionChanged: ((Accuracy, String) -> Void)?) {
        self.onSelectionChanged = onSelectionChanged
        super.init(frame: .zero)
        self.delegate = self
        self.dataSource = self
        self.backgroundColor = UIColor.white.withAlphaComponent(0.9)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func accuracyWithTitle(_ title: String) -> Accuracy? {
        guard let index = titles.firstIndex(of: title)
        else { return nil }
        return options[index]
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        precondition(titles.count == options.count)
        return titles.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return titles[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        onSelectionChanged?(options[row], titles[row])
    }
}
