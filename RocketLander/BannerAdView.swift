import SwiftUI
import GoogleMobileAds

// MARK: - Ad Configuration
struct AdConfig {
    // Test ID for development, real ID for production
    #if DEBUG
    static let bannerAdUnitID = "ca-app-pub-3940256099942544/2934735716"  // Google's test banner ID
    static let interstitialAdUnitID = "ca-app-pub-3940256099942544/4411468910"  // Google's test interstitial ID
    #else
    static let bannerAdUnitID = "ca-app-pub-3801339388353505/4009394081"  // Production banner
    static let interstitialAdUnitID = "ca-app-pub-3801339388353505/8269147180"  // Production interstitial
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
            #if DEBUG
            print("Ad loaded successfully")
            #endif
        }

        func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
            #if DEBUG
            print("Ad failed to load: \(error.localizedDescription)")
            #endif
        }

        func bannerViewDidRecordImpression(_ bannerView: BannerView) {
            #if DEBUG
            print("Ad impression recorded")
            #endif
        }

        func bannerViewDidRecordClick(_ bannerView: BannerView) {
            #if DEBUG
            print("Ad clicked")
            #endif
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
