import SwiftUI
import MapKit
import AblyAssetTrackingPublisher

struct MapView: View {
    var trackableId: String
    @ObservedObject var publisher: ObservablePublisher
    
    @StateObject private var viewModel = MapViewModel()
    @StateObject private var locationManager = LocationManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            StackedText(texts: MapViewModel.createViewModel(forConnectionState: publisher.trackables.first { key, _ in key.id == trackableId }?.value.connectionState))
                .padding(.leading, 10)
            
            ZStack(alignment: .bottomTrailing) {
                if viewModel.useMapboxMap {
                    MapboxMap(center: $locationManager.currentRegionCenter)
                }
                else {
                    Map(center: $locationManager.currentRegionCenter)
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
    }
}

struct MapView_Preview: PreviewProvider {
    static var previews: some View {
        let publisher = ObservablePublisher(publisher: DummyPublisher(), configInfo: .init(areRawLocationsEnabled: false))
        MapView(trackableId: "", publisher: publisher)
    }
}
