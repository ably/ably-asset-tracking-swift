import SwiftUI

@main
struct PublisherExampleSwiftUIApp: App {
    @StateObject private var locationManager = LocationManager.shared
    private let viewModelFactory = ViewModelFactory()
    
    var body: some Scene {
        WindowGroup {
            MainView(locationManager: locationManager, viewModelFactory: viewModelFactory)
        }
    }
}
