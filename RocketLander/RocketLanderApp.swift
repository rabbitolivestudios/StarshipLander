import SwiftUI
import GoogleMobileAds
import AppTrackingTransparency

@main
struct RocketLanderApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                    requestTrackingPermission()
                }
        }
    }

    private func requestTrackingPermission() {
        // Delay to ensure app is fully active
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            ATTrackingManager.requestTrackingAuthorization { status in
                // Ads will work regardless of user choice
                // If denied, ads are just less personalized
                print("Tracking authorization status: \(status.rawValue)")
            }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Initialize Google Mobile Ads SDK
        MobileAds.shared.start(completionHandler: nil)
        return true
    }
}
