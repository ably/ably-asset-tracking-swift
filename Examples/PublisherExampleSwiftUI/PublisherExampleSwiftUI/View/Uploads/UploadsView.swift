import SwiftUI

struct UploadsView: View {
    var uploads: [Upload]
    
    var body: some View {
        List(uploads.sorted(by: { $0.request.generatedAt > $1.request.generatedAt })) { upload in
            UploadView(upload: upload)
        }
        .navigationTitle("Uploads")
    }
}

struct UploadsView_Previews: PreviewProvider {
    static var previews: some View {
        let uploads = (1...10).map { _ in
            Upload(request: .init(data: .init(events: []), generatedAt: Date()), status: .uploading)
        }
        
        NavigationView {
            UploadsView(uploads: uploads)
        }
    }
}
