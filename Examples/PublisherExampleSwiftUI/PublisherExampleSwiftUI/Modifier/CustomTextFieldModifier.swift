//

import SwiftUI

struct CustomTextFieldModifier: ViewModifier {
    @Environment(\.isEnabled) var isEnabled
    
    func body(content: Content) -> some View {
        content.textFieldStyle(CustomTextFieldStyle(isEnabled: isEnabled))
    }
}
