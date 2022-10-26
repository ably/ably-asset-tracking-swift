import SwiftUI

struct S3FilesView: View {
    @Binding var fileName: String?
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = S3FilesViewModel()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.files, id: \.name) { file in
                    TitleValueListItem(title: file.name, value: file.readableSize ?? "")
                        .onTapGesture {
                            fileName = file.name
                            presentationMode.wrappedValue.dismiss()
                        }
                }
                if viewModel.errorMessage != nil {
                    Text("Failed to load list of files: \(viewModel.errorMessage ?? "")")
                }
                if viewModel.isLoading {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                }
            }
            .navigationTitle("S3 Files")
            .listStyle(.grouped)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Clear") {
                        fileName = nil
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

struct S3FilesView_Previews: PreviewProvider {
    static var previews: some View {
        S3FilesView(fileName: .constant(nil))
    }
}
