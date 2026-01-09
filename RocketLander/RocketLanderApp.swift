import SwiftUI
import GoogleMobileAds

@main
struct RocketLanderApp: App {

    init() {
        // Initialize Google Mobile Ads SDK
        MobileAds.shared.start(completionHandler: nil)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
