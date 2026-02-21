import GoogleMobileAds
import UIKit

// MARK: - Interstitial Ad Manager
// Shows an interstitial ad every N attempts (Retry / Next Level).
// Fails silently — never blocks gameplay if the ad isn't ready.

class InterstitialAdManager: NSObject {
    static let shared = InterstitialAdManager()

    private var interstitialAd: InterstitialAd?
    private var attemptCount = 0
    private var pendingAction: (() -> Void)?

    /// How many attempts between interstitial ads
    private let frequency = 7

    override init() {
        super.init()
        preloadAd()
    }

    // MARK: - Preload

    private func preloadAd() {
        InterstitialAd.load(with: AdConfig.interstitialAdUnitID, request: Request()) { [weak self] ad, error in
            if let error = error {
                #if DEBUG
                print("Interstitial failed to load: \(error.localizedDescription)")
                #endif
                return
            }
            self?.interstitialAd = ad
            self?.interstitialAd?.fullScreenContentDelegate = self
        }
    }

    // MARK: - Record Attempt & Show

    /// Call on Retry / Next Level. Increments counter, shows ad every `frequency` attempts,
    /// then executes `action` after dismissal (or immediately if no ad).
    func recordAttempt(then action: @escaping () -> Void) {
        attemptCount += 1

        guard attemptCount % frequency == 0 else {
            action()
            return
        }

        guard let ad = interstitialAd,
              let vc = GameCenterManager.topViewController() else {
            // No ad ready or no VC — just run the action
            action()
            preloadAd()
            return
        }

        pendingAction = action
        ad.present(from: vc)
    }
}

// MARK: - FullScreenContentDelegate

extension InterstitialAdManager: FullScreenContentDelegate {
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        // Fire the pending gameplay action
        pendingAction?()
        pendingAction = nil
        // Preload next ad
        preloadAd()
    }

    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        #if DEBUG
        print("Interstitial present failed: \(error.localizedDescription)")
        #endif
        // Don't block gameplay
        pendingAction?()
        pendingAction = nil
        preloadAd()
    }
}
