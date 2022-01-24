import SwiftUI

extension Button {
    func styled() -> some View {
        ModifiedContent(content: self, modifier: CustomButtonModifier())
    }
}
