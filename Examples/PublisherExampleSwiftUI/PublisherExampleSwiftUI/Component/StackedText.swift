import SwiftUI

struct StackedText: View {
    var texts: [StackedTextModel]
    
    var body: some View {
        Group {
            ForEach(0..<texts.count, id: \.self) { i in
                Group {
                    Text(texts[i].label)
                        .foregroundColor(.gray)
                        .font(.system(size: 12)) +
                    Text(texts[i].value)
                        .font(.system(size: 12))
                        .bold()
                }
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 2, trailing: 0))
            }
        }
        
    }
}
