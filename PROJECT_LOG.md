# Starship Lander - Project Log

This file documents the development history and decisions for the Starship Lander project. Use this to continue work in future sessions.

---

## Project Overview

- **App Name:** Starship Lander
- **Bundle ID:** com.tboliveira.StarshipLander
- **Platform:** iOS (iPhone)
- **Framework:** SwiftUI + SpriteKit
- **Developer:** Thiago Borges de Oliveira
- **Team ID:** 6XK6BNVURL

---

## Current Status (2026-01-08)

| Version | Build | Status |
|---------|-------|--------|
| 1.0 | 2 | Under review by Apple |
| 1.1 | 3 | Uploaded, waiting to submit (after 1.0 approval) |

**IMPORTANT:** Do NOT submit v1.1 until v1.0 is approved. Submitting a new version cancels the current review.

---

## AdMob Configuration

| Setting | Value |
|---------|-------|
| Publisher ID | pub-3801339388353505 |
| App ID | ca-app-pub-3801339388353505~8476936917 |
| Banner Ad Unit ID | ca-app-pub-3801339388353505/4009394081 |

**Implementation:**
- Test ads shown in DEBUG builds
- Production ads in RELEASE builds
- Banner ads on menu screen and during gameplay
- SDK: Google Mobile Ads via Swift Package Manager (v12.14.0)

---

## Development History

### Session 1 (2026-01-07) - Initial Development
- Created core game with SpriteKit physics
- Implemented thrust and rotation controls
- Added fuel management system
- Created landing detection logic
- Built procedurally generated terrain
- Added high score leaderboard (top 3)
- Created placeholder for AdMob ads

### Session 2 (2026-01-08) - v1.0 Enhancements
- **Starship Redesign:** Changed rocket visual to resemble SpaceX Starship
  - Cylindrical silver body with dome nose
  - 2 forward flaps, 2 aft flaps (dark gray)
  - 3 engine nozzles with landing legs
  - Updated menu illustration to match

- **Sound Effects:** Added 16-bit retro sounds
  - `thrust.wav` - Engine loop while thrusting
  - `rotate.wav` - Blip on rotation input
  - `land_success.wav` - Victory fanfare
  - `explosion.wav` - Crash sound
  - Generated via Python script (`Scripts/generate_sounds.py`)

- **Scoring System Revamp:**
  - Base: 100 points
  - Fuel efficiency: 0-500 points (exponential, main differentiator)
  - Soft landing: 0-300 points
  - Horizontal precision: 0-200 points
  - Platform center: 0-150 points
  - Rotation precision: 0-100 points
  - Approach control: 0-100 points
  - Max possible: ~1450 points

- **High Score Flow:** Simplified - name input appears directly when score qualifies

- **Bug Fix:** Thrust sound not playing - fixed with URL-based SKAudioNode initializer

### Session 3 (2026-01-08) - v1.0 Submission
- Removed ad placeholders for clean initial release
- Updated bundle ID to com.tboliveira.StarshipLander
- Configured Xcode signing with Apple Developer account
- Registered test device (iPhone 16 TBO)
- Successfully archived and uploaded v1.0 (build 2) to App Store Connect
- Submitted for Apple review

### Session 4 (2026-01-08) - v1.1 AdMob Integration
- User added Google Mobile Ads SDK via Swift Package Manager
- Updated `BannerAdView.swift` with real GADBannerView implementation
- Updated `RocketLanderApp.swift` to initialize Mobile Ads SDK
- Added banner ads to menu and game screens in `ContentView.swift`
- Configured Info.plist with AdMob App ID
- Updated API calls for latest SDK (BannerView, Request, AdSizeBanner)
- Updated version to 1.1 (build 3)
- Successfully archived and uploaded to App Store Connect
- **Waiting for v1.0 approval before submitting v1.1**

---

## Key Files

| File | Purpose |
|------|---------|
| `RocketLander/GameScene.swift` | Core game logic, physics, rocket drawing, sounds |
| `RocketLander/ContentView.swift` | SwiftUI UI, menus, controls, high scores |
| `RocketLander/BannerAdView.swift` | AdMob banner implementation |
| `RocketLander/RocketLanderApp.swift` | App entry point, SDK initialization |
| `RocketLander/Info.plist` | App config, version, AdMob IDs |
| `RocketLander/Sounds/` | 4 WAV sound effect files |
| `Scripts/generate_sounds.py` | Python script to regenerate sounds |
| `CHANGELOG.md` | Version history (Keep a Changelog format) |
| `RELEASE_NOTES.md` | App Store release notes |
| `README.md` | Project documentation |
| `SETUP.txt` | App Store submission guide |

---

## Git Information

- **Repository:** Local git repo
- **Current Branch:** main
- **Latest Tag:** v1.1.0

```
f09f225 v1.1.0: Add AdMob integration for ad revenue
e8e9656 Initial Commit
```

---

## Known Issues / Future Work

1. **dSYM Warnings:** Upload shows warnings about missing dSYM for GoogleMobileAds.framework - harmless, only affects crash symbolication for Google's code

2. **Future Features to Consider:**
   - Interstitial ads between games
   - More levels/difficulty settings
   - Game Center integration
   - iPad support
   - Landscape mode

---

## Troubleshooting Notes

### Thrust Sound Not Playing
- **Problem:** SKAudioNode with `fileNamed:` initializer didn't work
- **Solution:** Use URL-based initializer and explicit `SKAction.play()`
```swift
if let url = Bundle.main.url(forResource: "thrust", withExtension: "wav") {
    thrustSound = SKAudioNode(url: url)
    thrustSound?.run(SKAction.play())
}
```

### CocoaPods Installation Failed
- **Problem:** System Ruby 2.6 too old for latest CocoaPods
- **Solution:** Used Swift Package Manager instead for Google Mobile Ads

### Xcode Signing "Communication with Apple failed"
- **Problem:** No registered devices
- **Solution:** Connect iPhone, trust computer, register device UDID in Apple Developer portal

### Google Mobile Ads API Changes
- **Problem:** `GADBannerView` renamed to `BannerView`
- **Solution:** Update class names: `BannerView`, `Request`, `AdSizeBanner`, `MobileAds.shared`

---

## Contact / Accounts

- **Apple Developer Account:** Thiago Borges de Oliveira
- **AdMob Account:** Associated with Google account
- **App Store Connect:** https://appstoreconnect.apple.com

---

*Last updated: 2026-01-08*
