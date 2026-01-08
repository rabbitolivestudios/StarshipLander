import SwiftUI

// Placeholder banner for testing - replace with real AdMob when ready for App Store
struct BannerAdView: View {
    var body: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.3))
            .frame(height: 50)
            .overlay(
                Text("Ad Space")
                    .font(.caption)
                    .foregroundColor(.gray)
            )
    }
}

// MARK: - Ad Configuration (for App Store submission)
// After installing CocoaPods, uncomment the GoogleMobileAds version above
struct AdConfig {
    static let bannerAdUnitID = "YOUR_BANNER_AD_UNIT_ID"
    static let interstitialAdUnitID = "YOUR_INTERSTITIAL_AD_UNIT_ID"
    static let appID = "YOUR_ADMOB_APP_ID"
}
