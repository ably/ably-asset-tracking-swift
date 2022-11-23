import SwiftUI

struct UploadView: View {
    var upload: Upload
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("📄 \(upload.request.filename)")
                .fontWeight(.bold)
            HStack {
                Text(String(describing: upload.status))
            }
        }
    }
}

struct UploadView_Previews: PreviewProvider {
    static var previews: some View {
        UploadView(upload: .init(request: .init(data: .init(events: []), generatedAt: Date()), status: .uploading))
    }
}
