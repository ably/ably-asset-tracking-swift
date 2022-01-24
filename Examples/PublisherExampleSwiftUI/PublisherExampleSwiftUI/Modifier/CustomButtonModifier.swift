import SwiftUI

struct CustomButtonModifier: ViewModifier {
    @Environment(\.isEnabled) var isEnabled
    
    func body(content: Content) -> some View {
        content.buttonStyle(CustomButtonStyle(isEnabled: isEnabled))
    }
}
