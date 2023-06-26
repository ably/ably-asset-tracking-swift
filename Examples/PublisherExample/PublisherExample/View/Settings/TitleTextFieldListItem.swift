import SwiftUI

struct TitleTextFieldListItem: View {
    let value: Binding<String>
    private let title: String
    private let placeholder: String
    private let keyboardType: UIKeyboardType

    init(title: String, value: Binding<String>, placeholder: String, keyboardType: UIKeyboardType) {
        self.title = title
        self.value = value
        self.placeholder = placeholder
        self.keyboardType = keyboardType
    }

    var body: some View {
        ListItem {
            HStack {
                Text(title)
                    .font(.body)
                TextField(placeholder, text: value)
                    .font(.caption)
                    .multilineTextAlignment(.trailing)
                    .keyboardType(keyboardType)
            }
            .frame(maxWidth: .infinity)
            .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
        }
    }
}
