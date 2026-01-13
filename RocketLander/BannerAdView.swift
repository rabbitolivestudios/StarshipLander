import SwiftUI
import GoogleMobileAds

// MARK: - Ad Configuration
struct AdConfig {
    // Test ID for development, real ID for production
    #if DEBUG
    static let bannerAdUnitID = "ca-app-pub-3940256099942544/2934735716"  // Google's test banner ID
    #else
    static let bannerAdUnitID = "ca-app-pub-3801339388353505/4009394081"  // Production banner
    #endif
}

// MARK: - Banner Ad View
struct BannerAdView: UIViewRepresentable {
    let adUnitID: String

    init(adUnitID: String = AdConfig.bannerAdUnitID) {
        self.adUnitID = adUnitID
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> BannerView {
        let bannerView = BannerView(adSize: AdSizeBanner)
        bannerView.adUnitID = adUnitID
        bannerView.backgroundColor = UIColor.clear
        bannerView.delegate = context.coordinator

        // Get the root view controller
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootViewController = windowScene.windows.first?.rootViewController {
                bannerView.rootViewController = rootViewController
                bannerView.load(Request())
            }
        }

        return bannerView
    }

    func updateUIView(_ uiView: BannerView, context: Context) {
        // No updates needed
    }

    class Coordinator: NSObject, BannerViewDelegate {
        func bannerViewDidReceiveAd(_ bannerView: BannerView) {
            print("✅ Ad loaded successfully")
        }

        func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
            print("❌ Ad failed to load: \(error.localizedDescription)")
        }

        func bannerViewDidRecordImpression(_ bannerView: BannerView) {
            print("📊 Ad impression recorded")
        }

        func bannerViewDidRecordClick(_ bannerView: BannerView) {
            print("👆 Ad clicked")
        }
    }
}

// MARK: - Banner Container (with proper sizing)
struct BannerAdContainer: View {
    var body: some View {
        BannerAdView()
            .frame(width: 320, height: 50)
    }
}
