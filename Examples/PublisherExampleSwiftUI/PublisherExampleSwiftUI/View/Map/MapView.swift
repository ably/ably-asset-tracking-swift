import SwiftUI
import MapKit
import AblyAssetTrackingPublisher

struct MapView: View {
    @StateObject private var viewModel = MapViewModel()
    @StateObject private var locationManager = LocationManager.shared
    @State private var showRoutingProfileSheet: Bool = false
    
    private let trackableId: String
    
    init(trackableId: String) {
        self.trackableId = trackableId
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 3) {
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    StackedText(texts: viewModel.connectionStatusAndProfileInfo)
                    if viewModel.isDestinationAvailable {
                        Button {
                            showRoutingProfileSheet = true
                        } label: {
                            HStack(spacing: 3) {
                                Text("Change profile")
                                    .font(.system(size: 12))
                                Image(systemName: "info.circle.fill")
                                    .resizable()
                                    .frame(width: 10, height: 10, alignment: .center)
                            }
                        }
                        .disabled(!viewModel.isConnected || !viewModel.didChangeRoutingProfile)
                        .actionSheet(isPresented: $showRoutingProfileSheet) {
                            var buttons: [Alert.Button] = RoutingProfile.all.map { profile in
                                Alert.Button.default(Text(profile.asInfo())) {
                                    viewModel.routingProfile = profile
                                }
                            }
                            
                            buttons.append(.cancel())
                            
                            return ActionSheet(
                                title: Text("Routing profiles"),
                                message: Text("Select a profile"),
                                buttons: buttons
                            )
                        }
                    }
                }
                .padding(5)
                Spacer()
                VStack(alignment: .leading) {
                    StackedText(texts: viewModel.resolutionInfo)
                }
                .padding(5)
            }
            Divider()
                .padding(4)
            HStack {
                StackedText(texts: viewModel.rawLocationsInfo)
                    .padding(EdgeInsets(top: 2, leading: 4, bottom: 2, trailing: 10))
                Spacer()
            }
            Divider()
                .padding(4)
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    StackedText(texts: viewModel.constantResolutionInfo)
                        .padding(EdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 0))
                }
                Spacer()
            }
            ZStack(alignment: .bottomTrailing) {
                if viewModel.useMapboxMap {
                    MapboxMap(center: $locationManager.currentRegionCenter)
                        .edgesIgnoringSafeArea(.bottom)
                }
                else {
                    Map(center: $locationManager.currentRegionCenter)
                        .edgesIgnoringSafeArea(.bottom)
                }
                
                
                Button {
                    locationManager.updateRegion(true)
                } label: {
                    Image(systemName: "location.circle.fill")
                        .resizable()
                        .frame(width: 20, height: 20, alignment: .topLeading)
                        .padding(10)
                }
                .foregroundColor(Color.blue)
                .alignmentGuide(VerticalAlignment.bottom) { d in
                    d.height + 40
                }
                .alignmentGuide(HorizontalAlignment.trailing) { d in
                    d.width + 10
                }
            }
        }
        .onAppear {
            viewModel.connectPublisher(trackableId: trackableId)
        }
        .onDisappear {
            viewModel.disconnectPublisher()
        }
    }
}

struct MapView_Preview: PreviewProvider {
    static var previews: some View {
        MapView(trackableId: "")
    }
}
