import SwiftUI

struct TitleValueListItem: View {
    private let title: String
    private let value: String

    init(title: String, value: String) {
        self.title = title
        self.value = value
    }

    var body: some View {
        ListItem {
            HStack {
                Text(title)
                    .font(.body)
                Spacer()
                Text(value)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity)
            .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
        }
    }
}

struct TitleValueListItem_Previews: PreviewProvider {
    static var previews: some View {
        TitleValueListItem(title: "Min Displacement", value: "100m")
    }
}
