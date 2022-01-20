//

import SwiftUI

extension TextField {
    func styled() -> some View {
        ModifiedContent(content: self, modifier: CustomTextFieldModifier())
    }
}
