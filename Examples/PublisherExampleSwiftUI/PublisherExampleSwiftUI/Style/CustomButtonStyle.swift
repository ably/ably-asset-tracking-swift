//

import SwiftUI

struct CustomButtonStyle: ButtonStyle {
    private let isEnabled: Bool
    private let activeOrangeColor = Color(red: 1.00, green: 0.16, blue: 0.05)
    private let inactiveOrangeColor = Color(red: 1.00, green: 0.16, blue: 0.05).opacity(0.2)
    
    init(isEnabled: Bool = true) {
        self.isEnabled = isEnabled
    }
    
    func makeBody(configuration: Configuration) -> some View {
        return configuration
            .label
            .padding(
                EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12)
            )
            .foregroundColor(isEnabled ? activeOrangeColor : inactiveOrangeColor)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(lineWidth: 1)
                    .foregroundColor(isEnabled ? activeOrangeColor : inactiveOrangeColor)
            )
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}
