import AblyAssetTrackingPublisher
import MapKit
import SwiftUI

struct MapView: View {
    var trackableId: String
    @ObservedObject var publisher: ObservablePublisher
    @Environment(\.presentationMode) private var presentationMode

    @StateObject private var viewModel = MapViewModel()
    @StateObject private var locationManager = LocationManager.shared
    @State private var isRemoving = false
    @State private var hasRemoved = false
    @State private var error: ErrorInformation?
    @State private var showAlert = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            StackedText(texts: MapViewModel.createViewModel(forConnectionState: publisher.trackables.first { key, _ in key.id == trackableId }?.value.connectionState))
                .padding(.leading, 10)
            // This padding is very bad - for some reason, I wasn't able to tap on the "Remove trackable" button without it. I'm probably doing something very very wrong but don't have time to look into it now. See https://github.com/ably/ably-asset-tracking-swift/issues/422
                .padding(.bottom, 25)

            HStack {
                Spacer()
                Button {
                    isRemoving = true
                    let trackable = publisher.trackables.first { key, _ in key.id == trackableId }?.key
                    guard let trackable else { return }
                    publisher.remove(trackable: trackable) { result in
                        isRemoving = false
                        switch result {
                        case .success:
                            hasRemoved = true
                            presentationMode.wrappedValue.dismiss()
                        case .failure(let error):
                            self.error = error
                            showAlert = true
                        }
                    }
                } label: {
                    Text("Remove trackable")
                        .accentColor(.red)
                }
                .disabled(isRemoving || hasRemoved)
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: "Failed to stop publisher",
                        errorInformation: error
                    )
                }
                .padding(.trailing)
                ProgressView()
                    .opacity(isRemoving ? 1 : 0)
                Spacer()
            }

            ZStack(alignment: .bottomTrailing) {
                if viewModel.useMapboxMap {
                    MapboxMap(center: $locationManager.currentRegionCenter)
                } else {
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
