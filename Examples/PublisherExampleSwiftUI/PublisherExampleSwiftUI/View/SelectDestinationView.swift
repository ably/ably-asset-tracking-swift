import SwiftUI
import AblyAssetTrackingCore
import MapKit

struct SelectDestinationView: View {
    @Binding var destination: LocationCoordinate?
    @StateObject private var viewModel = SelectDestinationViewModel()
    @StateObject private var locationManager = LocationManager.shared

    init(destination: Binding<LocationCoordinate?>) {
        self._destination = destination
    }
    
    var body: some View {
        if viewModel.useMapboxMap {
            MapboxMap(center: $locationManager.currentRegionCenter)
        }
        else {
            DestinationMapView(center: locationManager.currentRegionCenter, destination: $destination)
                .navigationTitle("Select Destination")
        }
    }
}

struct SelectDestinationView_Previews: PreviewProvider {
    static var previews: some View {
        SelectDestinationView(destination: .constant(nil))
    }
}
