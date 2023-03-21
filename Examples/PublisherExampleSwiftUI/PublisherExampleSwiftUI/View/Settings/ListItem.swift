//

import SwiftUI

struct ListItem<Content: View>: View {
    @Environment(\.isEnabled) var isEnabled
    let content: () -> Content
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    var body: some View {
        content()
            .opacity(isEnabled ? 1.0 : 0.3)
    }
}

struct ListItem_Previews: PreviewProvider {
    static var previews: some View {
        ListItem {
        }
    }
}
