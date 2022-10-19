import SwiftUI

@main
struct PublisherExampleSwiftUIApp: App {
    var body: some Scene {
        WindowGroup {
            TabView {
                NavigationView {
                    CreatePublisherView()
                }
                .tabItem {
                    Label("Publisher", systemImage: "car")
                }
                /*
                This navigationViewStyle(.stack) prevents UINavigationBar-related "Unable to
                simultaneously satisfy constraints" log messages on iPhone simulators with iOS
                < 16 (specifically I saw it with 15.5).  I don’t know what caused this issue
                nor why this fixes it; it's just something I tried after seeing vaguely similar
                complaints on the Web, and it seems to do no harm.
                */
                .navigationViewStyle(.stack)
                NavigationView {
                    SettingsView()
                }
                // Same comment as above
                .navigationViewStyle(.stack)
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
            }
        }
    }
}
