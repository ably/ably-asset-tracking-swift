import SwiftUI
import AblyAssetTrackingPublisher

struct PublisherDetailsView: View {
    @StateObject private var locationManager = LocationManager.shared
    
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
