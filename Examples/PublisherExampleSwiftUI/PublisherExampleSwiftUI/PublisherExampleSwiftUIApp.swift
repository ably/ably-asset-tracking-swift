import SwiftUI

@main
struct PublisherExampleSwiftUIApp: App {
    @StateObject private var locationManager = LocationManager.shared
    
    var body: some Scene {
        WindowGroup {
            MainView(locationManager: locationManager)
        }
    }
}
