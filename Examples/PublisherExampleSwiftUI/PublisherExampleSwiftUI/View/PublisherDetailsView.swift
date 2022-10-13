import SwiftUI
import AblyAssetTrackingPublisher

struct PublisherDetailsView: View {
    @StateObject private var locationManager = LocationManager.shared
    @State private var isStoppingPublisher = false
    @State private var hasStoppedPublisher = false
    @State private var stopPublisherError: ErrorInformation?
    @State private var showStopPublisherErrorAlert = false
    @State private var changeRoutingProfileError: ErrorInformation?
    @State private var showChangeRoutingProfileErrorAlert = false
    @State private var showRoutingProfileSheet = false
    @State private var isChangingRoutingProfile = false
    @Environment(\.presentationMode) private var presentationMode
    
    @ObservedObject var publisher: ObservablePublisher
    
    var sortedTrackables: [(trackable: Trackable, state: ObservablePublisher.TrackableState)] {
        return publisher.trackables.sorted { pair1, pair2 in
            return pair1.key.id < pair2.key.id
        }.map { pair in
            (trackable: pair.key, state: pair.value)
        }
    }
    
    var body: some View {
        List {
            Section {
                if sortedTrackables.isEmpty {
                    Text("The publisher currently has no trackables in its list.")
                } else {
                    ForEach(sortedTrackables, id: \.trackable.id) { info in
                        NavigationLink {
                            MapView(trackableId: info.trackable.id, publisher: publisher)
                                .navigationTitle("Map")
                                .navigationBarTitleDisplayMode(.inline)
                        } label: {
                            HStack {
                                Text(info.trackable.id)
                                Spacer()
                                Text(info.state.connectionState?.asInfo() ?? "Connection state unknown")
                            }
                        }
                    }
                }
            } header: {
                Text("Current trackables")
            }
            
            Section {
                NavigationLink {
                    AddTrackableView(publisher: publisher)
                } label: {
                    Text("Add trackable")
                }
                
                Button {
                    showRoutingProfileSheet = true
                } label: {
                    HStack {
                        Text("Change routing profile")
                            .padding(.trailing)
                        ProgressView()
                            .opacity(isChangingRoutingProfile ? 1 : 0)
                    }
                }
                .disabled(isChangingRoutingProfile)
                .actionSheet(isPresented: $showRoutingProfileSheet) {
                    var buttons: [Alert.Button] = RoutingProfile.all.map { profile in
                        Alert.Button.default(Text(profile.asInfo())) {
                            isChangingRoutingProfile = true
                            publisher.changeRoutingProfile(profile: profile) { result in
                                isChangingRoutingProfile = false
                                switch result {
                                case .success:
                                    break
                                case .failure(let error):
                                    changeRoutingProfileError = error
                                    showChangeRoutingProfileErrorAlert = true
                                }
                            }
                        }
                    }
                    
                    buttons.append(.cancel())
                    
                    return ActionSheet(
                        title: Text("Routing profiles"),
                        message: Text("Select a profile"),
                        buttons: buttons
                    )
                }
                .alert(isPresented: $showChangeRoutingProfileErrorAlert) {
                    Alert(title: "Failed to change routing profile",
                          errorInformation: changeRoutingProfileError)
                }
                
                HStack {
                    Button {
                        isStoppingPublisher = true
                        publisher.stop { result in
                            isStoppingPublisher = false
                            switch result {
                            case .success:
                                hasStoppedPublisher = true
                                presentationMode.wrappedValue.dismiss()
                            case .failure(let error):
                                self.stopPublisherError = error
                                showStopPublisherErrorAlert = true
                            }
                        }
                    } label: {
                        Text("Stop publisher")
                    }
                    .accentColor(.red)
                    .disabled(isStoppingPublisher || hasStoppedPublisher)
                    .alert(isPresented: $showStopPublisherErrorAlert) {
                        Alert(title: "Failed to stop publisher",
                              errorInformation: stopPublisherError)
                    }
                    Spacer()
                    ProgressView()
                        .opacity(isStoppingPublisher ? 1 : 0)
                }
            } header: {
                Text("Actions")
            }
        }
        .navigationTitle("Publisher details")
        .navigationBarBackButtonHidden(true)
    }
}

struct PublisherDetailsView_Previews: PreviewProvider {    
    static var previews: some View {
        let publisher = ObservablePublisher(publisher: DummyPublisher(), configInfo: .init(areRawLocationsEnabled: false))
        NavigationView {
            PublisherDetailsView(publisher: publisher)
        }
    }
}
