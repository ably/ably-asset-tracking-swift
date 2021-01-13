import UIKit

class AccuracyPickerToolbar: UIToolbar {
    let onDoneButtonPress: (() -> Void)?

    init(onDoneButtonPress: (() -> Void)?) {
        self.onDoneButtonPress = onDoneButtonPress
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        let doneItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donePressed))
        items=[doneItem]
        self.backgroundColor = UIColor.white.withAlphaComponent(0.8)
    }

    @objc
    private func donePressed() {
        onDoneButtonPress?()
    }
}
