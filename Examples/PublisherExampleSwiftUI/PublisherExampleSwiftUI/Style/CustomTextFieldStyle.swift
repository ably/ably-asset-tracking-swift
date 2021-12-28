//

import SwiftUI

struct CustomTextFieldStyle: TextFieldStyle {
    private let isEnabled: Bool
    
    init(isEnabled: Bool = true) {
        self.isEnabled = isEnabled
    }
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        return configuration
            .disableAutocorrection(true)
            .autocapitalization(.none)
            .padding(
                EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
            )
            .foregroundColor(isEnabled ? Color.black : Color.gray.opacity(0.4))
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(lineWidth: 1)
                    .foregroundColor(isEnabled ? Color.gray : Color.gray.opacity(0.4))
            )
            .shadow(color: Color.gray.opacity(isEnabled ? 0.4 : 0), radius: 2, x: 1, y: 1)
    }
}
