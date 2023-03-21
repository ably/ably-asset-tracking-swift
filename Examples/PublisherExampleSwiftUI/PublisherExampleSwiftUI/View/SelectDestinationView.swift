import SwiftUI
import AblyAssetTrackingCore
import MapKit

struct SelectDestinationView: View {
    @Binding var destination: LocationCoordinate?
    @StateObject private var locationManager = LocationManager.shared

    var body: some View {
        DestinationMapView(center: locationManager.currentRegionCenter, destination: $destination)
                .navigationTitle("Select Destination")
    }
}

struct SelectDestinationView_Previews: PreviewProvider {
    static var previews: some View {
        SelectDestinationView(destination: .constant(nil))
    }
}
