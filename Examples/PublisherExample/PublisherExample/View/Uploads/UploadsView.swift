import SwiftUI

struct UploadsView: View {
    var uploads: [Upload]
    var retry: (Upload) -> Void

    var body: some View {
        List(uploads.sorted { $0.request.generatedAt > $1.request.generatedAt }) { upload in
            // swiftlint:disable:next trailing_closure
            UploadView(upload: upload, retry: {
                retry(upload)
            })
        }
        .navigationTitle("Uploads")
    }
}

struct UploadsView_Previews: PreviewProvider {
    static var previews: some View {
        let uploads = (1...10).map { _ in
            Upload(id: UUID(), request: .init(type: .locationHistoryData(archiveVersion: ""), generatedAt: Date()), status: .uploading)
        }

        NavigationView {
            UploadsView(uploads: uploads) { _ in }
        }
    }
}
