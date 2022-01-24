import SwiftUI

struct CustomText: View {
    @Environment(\.isEnabled) var isEnabled
    private let activeColor = Color(red: 1.00, green: 0.16, blue: 0.05)
    private let inactiveColor = Color.gray
    private let text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    var body: some View {
        Text(text)
            .foregroundColor(isEnabled ? activeColor : inactiveColor)
    }
}
