import UIKit
import AblyAssetTracking

class AccuracyPickerView: UIPickerView, UIPickerViewDelegate, UIPickerViewDataSource {
    private let options: [Accuracy] = [.minimum, .low, .balanced, .high, .maximum]
    private let titles = ["Minimum", "Low", "Balanced", "High", "Maximum"]

    private var currentRow: Int = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
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
        currentRow = row
    }
}
