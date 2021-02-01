import UIKit

class AddTrackableToolbar: UIToolbar {
    let onNextButtonPress: (() -> Void)?

    init(onNextButtonPress: (() -> Void)?) {
        self.onNextButtonPress = onNextButtonPress
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        let spaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(nextPressed))
        items=[spaceItem, doneItem]
        self.backgroundColor = UIColor.white.withAlphaComponent(0.8)
    }

    @objc
    private func nextPressed() {
        onNextButtonPress?()
    }
}
