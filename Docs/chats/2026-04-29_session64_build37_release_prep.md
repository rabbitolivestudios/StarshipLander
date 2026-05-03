# 2026-04-29 — Session 64: Build 37 Release Prep

## Goals
- Run simulator testing/screenshots for the current v2.2.0 build.
- Prepare the missing Daily Challenge Game Center leaderboard setup.
- Archive/export a replacement v2.2.0 build.
- Upload to App Store Connect if the Apple-side account state allows it.

## Changes Made

### 1. Build 37
**What:** Bumped `CFBundleVersion` from 36 to 37.
**Why:** Replacement build for v2.2.0 after progression/reward fixes and Starship art refresh.
**File:** `RocketLander/Info.plist`

### 2. Daily Challenge Leaderboard Setup
**What:** Added `daily_challenge` / "Daily Challenge" to the App Store Connect Game Center setup script.
**Why:** v2.2.0 needs the Daily Challenge leaderboard before App Store submission.
**File:** `Scripts/setup_game_center.py`

### 3. Simulator Smoke Test
**What:** Ran the app on iPhone 17 Pro simulator / iOS 26.4 and captured release-smoke screenshots.
**Covered:**
- Main menu
- Daily Challenge briefing
- Daily Challenge gameplay
- Campaign/level select
- Moon campaign gameplay

**Screenshots:** `Screenshots/simulator-2026-04-29-release-smoke/`

### 4. Archive and Export
**What:** Archived Build 37 and exported a local App Store IPA.
**Archive:** `build/RocketLander-Build37.xcarchive`
**IPA:** `build/export-build37-local/RocketLander.ipa`

## Verification
- `python3 -m py_compile Scripts/setup_game_center.py` passed.
- `xcodebuild test -project RocketLander.xcodeproj -scheme RocketLander -destination 'id=55C7603C-9E68-4657-8046-5EAA5733D34A'` passed: 94 tests, 0 failures.
- `xcodebuild ... archive` succeeded.
- Local App Store IPA export succeeded.

## Blockers
- App Store Connect upload failed with: "You do not have required contracts to perform an operation."
- `Scripts/setup_game_center.py --create-releases` could not run because `ASC_ISSUER_ID` is missing locally.
- Physical device install/test was not possible because `iPhone 16 TBO` appeared offline.

## Next Actions
1. Accept/clear the required App Store Connect contracts/agreements.
2. Provide/set `ASC_ISSUER_ID`.
3. Run `ASC_ISSUER_ID=<issuer-id> python3 Scripts/setup_game_center.py --create-releases`.
4. Upload `build/export-build37-local/RocketLander.ipa` or rerun the Build 37 upload export.
5. Test Build 37 through TestFlight, then submit v2.2.0 for App Store review.

## Commits
- None yet

## Repo Housekeeping
- [x] Build 37 generated and verified locally
- [x] Session summary created
- [x] Documentation updated
- [ ] Working tree clean — changes intentionally uncommitted
- [x] No credentials added
