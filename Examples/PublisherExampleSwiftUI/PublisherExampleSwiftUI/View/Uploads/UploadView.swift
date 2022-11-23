import SwiftUI

struct UploadView: View {
    var upload: Upload
    var retry: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("📄 \(upload.request.filename)")
                .fontWeight(.bold)
            Text(String(describing: upload.request.type))
                .italic()
            HStack {
                Text(String(describing: upload.status))
                if case .failed = upload.status {
                    Button() {
                        retry()
                    } label: {
                        Text("Retry")
                    }
                }
            }
        }
    }
}

struct UploadView_Previews: PreviewProvider {
    static var previews: some View {
        UploadView(upload: .init(id: UUID(), request: .init(type: .locationHistoryData(archiveVersion: ""), generatedAt: Date()), status: .uploading)) {}
    }
}
