import SwiftUI
import UIKit

extension UIApplication {
    static func endEditing(_ force: Bool) {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        window?.endEditing(force)
    }
}

struct ResignKeyboardOnTapGesture: ViewModifier {
    var gesture = TapGesture().onEnded { _ in
        UIApplication.endEditing(true)
    }
    func body(content: Content) -> some View {
        content.gesture(gesture)
    }
}

extension View {
    func resignKeyboardOnTapGesture() -> some View {
        modifier(ResignKeyboardOnTapGesture())
    }
}
