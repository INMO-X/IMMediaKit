import IMMediaKit
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        try? IMMediaSDK.shared.start(configuration: .default)
        IMMediaSDK.shared.configure(userID: "example-user")
        return true
    }
}
