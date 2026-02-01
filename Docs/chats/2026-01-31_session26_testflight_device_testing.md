# 2026-01-31 — Session 26: TestFlight Setup + Device Testing + Accelerometer Fix

## Goals
- Set up TestFlight for physical device testing
- Test device-only features (haptics, accelerometer, ads)
- Fix any issues found during device testing

## Changes Made

### 1. TestFlight Upload
**What:** Archived and uploaded v2.0.1 (Build 13) to App Store Connect for TestFlight
**Why:** First device testing — haptics, accelerometer, and ads were never tested on real hardware
**Steps:**
- `xcodebuild archive` → `xcodebuild -exportArchive` (method: app-store-connect)
- Upload succeeded with minor dSYM warnings for GoogleMobileAds (cosmetic, non-blocking)
- Had to run `sudo xcode-select -s /Applications/Xcode.app/Contents/Developer` because Homebrew install (session 25) switched active tools to Command Line Tools

### 2. TestFlight Configuration
**What:** Created internal testing group and added personal Apple ID as tester
**Why:** Personal Apple ID on phone differs from Rabbit Olive Studios developer account
**Steps:**
- App Store Connect > Users and Access > added personal Apple ID as "Developer" role
- TestFlight > created "Developer Testing" group > added personal account
- Installed TestFlight app on iPhone > accepted invitation > installed build

### 3. Device Testing Results
**What:** Tested all device-dependent features on physical iPhone
**Results:**
| Feature | Status | Notes |
|---------|--------|-------|
| Haptics — thrust | Working | Light pulse felt while holding thrust |
| Haptics — rotation | Working | Medium tap on L/R press |
| Haptics — landing | Working | Success haptic on safe landing |
| Haptics — crash | Working | Heavy double-tap on crash |
| Ads — menu banner | Working | Banner loads and displays |
| Ads — gameplay banner | Working | Banner loads during play |
| Ads — ATT prompt | Working | Prompt appeared on first launch |
| Sound effects | Working | All 4 sounds playing correctly |
| Layout | Working | No issues on device |
| Version number | Working | Visible top-right corner |
| Accelerometer | **BUG** | Toggle had no effect — L/R buttons stayed, tilt didn't work |
| Campaign mode | In progress | User testing async, deferred to next session |

### 4. Accelerometer Bug Fix
**What:** Fixed dual-binding bug where accelerometer toggle didn't affect gameplay
**Why:** MenuView used `@AppStorage("useAccelerometer")` which wrote to UserDefaults directly, but `GameState.useAccelerometer` was only read from UserDefaults once at `init()`. The game scene and controls read from GameState, so they never saw the toggle change.
**Fix:** Removed `@AppStorage` from MenuView, replaced all `useAccelerometer` references with `gameState.useAccelerometer`. Now the toggle, controls view, and game scene all share a single source of truth via the `@ObservedObject var gameState`.
**Files:** `RocketLander/ContentView.swift`
**Status:** Committed locally, needs new TestFlight build to verify on device

## Research / Ideas Discussed
- TestFlight internal testing does not require Apple review — only external testing does
- Personal Apple ID can be added as a team member (Developer role) to access TestFlight
- `xcode-select` must point to full Xcode (not Command Line Tools) for archive operations

## Technical Notes
- dSYM warnings for GoogleMobileAds and UserMessagingPlatform during export are cosmetic — these are prebuilt frameworks without debug symbols, won't affect TestFlight or App Store submission
- The accelerometer bug likely existed since v1.1.2 when accelerometer was first added — it would have appeared to work in simulator (where `@AppStorage` and `GameState` are initialized in the same process) but the dual-binding was always fragile

## Decisions
1. TestFlight for device testing before App Store submission — reduces rejection risk
2. Accelerometer fix is a bug fix, not a feature — included in v2.0.1 scope

## Definition of Done
- [x] TestFlight build uploaded and installed on device
- [x] Haptics verified working (all 4 types)
- [x] Ads verified working (menu + gameplay + ATT)
- [x] Sound effects verified working
- [x] Layout verified (no issues)
- [x] Accelerometer bug identified and fixed
- [x] Build succeeds with fix
- [ ] Accelerometer fix verified on device (needs new TestFlight build — next session)
- [ ] Campaign mode device testing (user testing async)

## Commits
- `3e09d9f` — Fix accelerometer toggle not affecting gameplay
- (final commit with docs + session summary)

## Repo Housekeeping
- [x] Working tree clean (no stale untracked files)
- [x] .gitignore up to date
- [x] README.md project structure matches actual files
- [x] No secrets or credentials in tracked files

## Next Actions
- [ ] Bump build number, re-archive, upload new TestFlight build with accelerometer fix
- [ ] Verify accelerometer on device
- [ ] Complete campaign mode device testing
- [ ] Collect all device testing feedback and address any issues
- [ ] Begin v2.1.0 implementation (Game Center)
