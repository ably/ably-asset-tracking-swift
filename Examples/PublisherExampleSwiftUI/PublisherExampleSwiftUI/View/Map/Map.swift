import SwiftUI
import MapKit

struct Map: View {
    @Binding private var center: CLLocationCoordinate2D
    @State private var span: MKCoordinateSpan?

    private var region: Binding<MKCoordinateRegion> {
        Binding {
            let span = span ?? MKCoordinateSpan(
                latitudeDelta: 0.2,
                longitudeDelta: 0.2
            )

            return MKCoordinateRegion(center: center, span: span)
        } set: { region in
            DispatchQueue.main.async {
                span = region.span
                center = region.center
            }
        }
    }

    init(center: Binding<CLLocationCoordinate2D>) {
        _center = center
    }

    var body: some View {
        MapKit.Map(
            coordinateRegion: region,
            showsUserLocation: true
        )
    }
}

struct Map_Previews: PreviewProvider {
    static var previews: some View {
        Map(center: .constant(CLLocationCoordinate2D(latitude: 0, longitude: 0)))
    }
}
