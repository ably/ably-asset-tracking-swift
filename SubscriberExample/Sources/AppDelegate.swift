import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window
        
        let settingsVC = SettingsViewController()
        let navVC = UINavigationController(rootViewController: settingsVC)
        
        window.rootViewController = navVC
        window.makeKeyAndVisible()
        
        return true
    }
}
