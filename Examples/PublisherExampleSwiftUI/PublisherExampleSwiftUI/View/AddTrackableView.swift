import SwiftUI
import AblyAssetTrackingCore

struct AddTrackableView: View {
    @ObservedObject var publisher: ObservablePublisher
    
    @Environment(\.presentationMode) private var presentationMode
    @StateObject private var locationManager = LocationManager.shared
    @State private var trackableId: String = ""
    @State private var error: ErrorInformation?
    @State private var showAlert = false
    @State private var isAdding = false
    @State private var hasAdded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Form {
                Section(header: Text("Trackable ID")) {
                    TextField("Trackable ID", text: $trackableId)
                        .disabled(locationManager.isLocationAuthorizationDenied)
                }
                
                Section {
                    Button {
                        let trackable = Trackable(id: trackableId)
                        isAdding = true
                        publisher.track(trackable: trackable) { result in
                            isAdding = false
                            switch result {
                            case .success:
                                presentationMode.wrappedValue.dismiss()
                                hasAdded = true
                            case .failure(let error):
                                self.error = error
                                showAlert = true
                            }
                        }
                    } label: {
                        HStack {
                            Text("Add trackable")
                                .padding(.trailing)
                            ProgressView()
                                .opacity(isAdding ? 1 : 0)
                        }
                    }
                    .disabled(trackableId.isEmpty || locationManager.isLocationAuthorizationDenied ||
                              isAdding ||
                              hasAdded)
                    .alert(isPresented: $showAlert) {
                        Alert(title: "Failed to add trackable",
                              errorInformation: error)
                    }
                    
                }
                
                Section {
                    Text("Location permission status:")
                        .foregroundColor(.gray)
                        .font(.system(size: 10)) +
                    Text(locationManager.statusTitle)
                        .font(.system(size: 10))
                        .bold()
                    if locationManager.isLocationAuthorizationDenied {
                        Button("Open system preferences") {
                            guard
                                let settingsURL = URL(string: UIApplication.openSettingsURLString),
                                UIApplication.shared.canOpenURL(settingsURL)
                            else {
                                return
                            }
                            
                            UIApplication.shared.open(settingsURL)
                        }
                        .font(.system(size: 10))
                    }
                    
                }
            }
        }
        .onAppear() {
            locationManager.requestAuthorization()
        }
        .navigationTitle("Add trackable")
    }
}

struct AddTrackableView_Previews: PreviewProvider {
    static var previews: some View {
        let publisher = ObservablePublisher(publisher: DummyPublisher(), configInfo: .init(areRawLocationsEnabled: false))
        NavigationView {
            AddTrackableView(publisher: publisher)
        }
    }
}
