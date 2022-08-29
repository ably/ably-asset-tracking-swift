import UIKit
import Logging
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setupCrashlytics()

        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window

        let settingsVC = SettingsViewController()
        let navVC = UINavigationController(rootViewController: settingsVC)

        window.rootViewController = navVC
        window.makeKeyAndVisible()

        return true
    }
    
    private func setupCrashlytics() {
        guard let config = Bundle(for: Self.self).path(forResource: "GoogleService-Info", ofType: "plist") else {
            print("""
            [Crashlyics Info]
                Firebase Crashlytics won't work.
                Please add "GoogleService-Info.plist" to the project if you want to use the Crashlytics reporter.
                You can register your app here https://console.firebase.google.com/
            
            """)
            return
        }
        
        guard let options = FirebaseOptions(contentsOfFile: config) else {
            return
        }
        
        FirebaseApp.configure(options: options)
    }
}
