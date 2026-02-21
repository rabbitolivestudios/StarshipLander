# 2026-02-21 — Session 60: v2.2.0 Build 35 TestFlight Bug Fixes

## Goals
- Fix three bugs found during TestFlight testing of Build 34
- Deploy Build 35 to TestFlight

## Changes Made

### 1. Menu Layout Overlap Fix
**What:** Footer toolbar (gear + help icons) was hidden behind banner ad and play buttons on the menu screen.
**Why:** Footer was inside the ScrollView, and the 60px bottom padding wasn't enough to keep it above the BannerAdContainer positioned outside the ScrollView.
**Fix:** Moved footer HStack outside the ScrollView, pinned between scroll content and BannerAdContainer. Reduced bottom padding from 60px to 16px.
**Files:** `RocketLander/ContentView.swift`

### 2. Interstitial Ad Frequency
**What:** Interstitial ads appeared every 3rd Retry/Next Level tap — too aggressive for short game sessions.
**Why:** Users reported ads were too frequent, driving them away.
**Fix:** Changed `frequency` from 3 to 7 in `InterstitialAdManager.swift`.
**Files:** `RocketLander/InterstitialAdManager.swift`

### 3. Interstitial Ad Duration (Manual — AdMob Console)
**What:** Video interstitial ads played for 15-30 seconds — too long.
**Why:** Users reported ads were too long.
**Fix:** Disabled video ad format in AdMob console for the "Game Over Interstitial" ad unit. Now text/image/rich media only.
**Files:** None (AdMob console change)

### 4. Multi-Touch Thrust Stuck Bug
**What:** Pressing thrust with one finger, then tapping with a second finger caused thrust to get stuck active (or inactive).
**Why:** `DragGesture(minimumDistance: 0)` with `.onChanged`/`.onEnded` doesn't properly handle multi-touch. The second finger's `.onEnded` fires and sets `isPressed = false` while the first finger is still down.
**Fix:** Replaced `DragGesture` with `.onLongPressGesture(minimumDuration: .infinity, pressing:, perform:)` on both ThrustButton and ControlButton. The `pressing` callback tracks a single touch lifecycle correctly.
**Files:** `RocketLander/Views/ControlViews.swift`

### 5. Build Number Bump
**What:** Info.plist build number 34 → 35.
**Files:** `RocketLander/Info.plist`

## Research / Ideas Discussed
- `onLongPressGesture(minimumDuration: .infinity)` is a clean SwiftUI-only solution for press-and-hold buttons that need correct multi-touch handling
- Video ads can be re-enabled in AdMob console later when user base grows and tolerance can be A/B tested
- Interstitial frequency of 7 gives roughly one ad per 2-4 minutes of gameplay

## Technical Notes
- `DragGesture` with `minimumDistance: 0` is a common SwiftUI pattern for press-and-hold buttons, but it breaks under multi-touch because `onEnded` fires for any finger lift, not just the original pressing finger
- `onLongPressGesture(pressing:)` with `minimumDuration: .infinity` never triggers the `perform` closure — the button works as a pure press-and-hold with correct single-touch lifecycle tracking
- AdMob ad duration is controlled by the AdMob console (ad type selection), not programmatically in the SDK

## Decisions
1. Interstitial frequency changed from 3 to 7 — balance between revenue and UX
2. Video ads disabled in AdMob — text/image only for now
3. `onLongPressGesture` chosen over UIKit touch handler — pure SwiftUI, minimal code change

## Definition of Done
- [x] Menu layout overlap fixed — footer pinned above banner ad
- [x] Interstitial frequency changed to 7
- [x] Video ads disabled in AdMob console (manual step noted)
- [x] Multi-touch thrust stuck fixed on ThrustButton and ControlButton
- [x] Build number bumped to 35
- [x] Build succeeds
- [x] Git commit and push (`ca961cc`)
- [x] Archive + upload to TestFlight (Build 35)

## Commits
- `ca961cc` — Fix TestFlight bugs: menu layout, ad frequency, thrust multi-touch (Build 35)

## Repo Housekeeping
- [x] Working tree clean (only expected changes)
- [x] .gitignore up to date
- [x] README.md project structure matches actual files
- [x] No secrets or credentials in tracked files

## Next Actions
- [ ] Device testing of Build 35 on TestFlight
- [ ] Create `daily_challenge` leaderboard in ASC
- [ ] ASO, screenshots, App Store preparation
- [ ] Submit v2.2.0 for App Store review
