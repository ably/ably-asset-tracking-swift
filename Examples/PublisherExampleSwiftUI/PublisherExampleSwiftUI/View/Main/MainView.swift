import SwiftUI

struct MainView: View {
    @StateObject private var locationManager = LocationManager.shared
    @State var trackableId: String = ""
    @State var settingsOpened = false
    
    var body: some View {
        GeometryReader { proxy in
            VStack(alignment: .leading, spacing: 20) {
                Image("ably-logo", bundle: nil)
                    .resizable()
                    .scaledToFit()
                    .frame(
                        width: proxy.size.width * 0.5,
                        height: 30,
                        alignment: .leading
                    )
                
                TextField("Trackable ID", text: $trackableId)
                    .styled()
                    .disabled(locationManager.isLocationAuthorizationDenied)
                NavigationLink {
                    MapView(trackableId: trackableId)
                        .navigationTitle("Map")
                        .navigationBarTitleDisplayMode(.inline)
                } label: {
                    CustomText("Start publishing")
                }
                .disabled(trackableId.isEmpty || locationManager.isLocationAuthorizationDenied)
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
            .padding()
            .frame(
                width: proxy.size.width,
                height: proxy.size.height
            )
            NavigationLink(destination: PublisherSettingsView(), isActive: $settingsOpened) { EmptyView() }.hidden()
        }
        .onAppear() {
            locationManager.requestAuthorization()
        }
        .toolbar {
            ToolbarItem {
                Button("Settings") {
                    self.settingsOpened = true
                }
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MainView()
        }
    }
}
