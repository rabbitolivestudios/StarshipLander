# 2026-02-06 — Session 51: v2.1.0 TestFlight + ASC Setup + GC Auth Fix

## Goals
- Version bump to 2.1.0, upload to TestFlight for device testing
- Create 12 leaderboards + 10 achievements in App Store Connect via API
- Fix Game Center auth bug found during device testing

## Changes Made

### 1. Version Bump + TestFlight Upload
**What:** Bumped version to 2.1.0 Build 31, archived, and uploaded to TestFlight
**Files:** `RocketLander/Info.plist`

### 2. setup_game_center.py (NEW)
**What:** Python script to create Game Center leaderboards and achievements via App Store Connect REST API
**Why:** Manual creation of 12 leaderboards + 10 achievements in ASC web UI is tedious and error-prone
**Files:** `Scripts/setup_game_center.py`
**Details:**
- JWT authentication with ES256 signing for ASC API
- Reads credentials from env vars (ASC_ISSUER_ID, ASC_KEY_ID, ASC_PRIVATE_KEY) or local .p8 files
- Creates 12 leaderboards: classic, campaign_1-10, galaxy_rank (INTEGER format, BEST_SCORE, DESC)
- Creates 10 achievements: eagle_has_landed through master_lander (200 total points)
- Adds en-US localizations for all resources
- Idempotent — checks existing resources before creating

### 3. App Store Connect Configuration
**What:** All 12 leaderboards and 10 achievements successfully created via API
**Details:**
- Used Vercel CLI to pull ASC credentials from starship-dashboard project env vars
- 10 achievements created on first run (all succeeded)
- 12 leaderboards initially failed with 409 errors — root cause was `defaultFormatter` needing string enum `"INTEGER"` not a nested object
- Fixed script and re-ran — all 12 leaderboards created with localizations
- Verified via API query: 12 leaderboards, 10 achievements confirmed

### 4. Game Center Auth Fix (Build 32)
**What:** Fixed GC auth completion and dashboard presentation
**Why:** Device testing of Build 31 showed "Sign in to Game Center" when tapping "View Global Rankings" despite being signed in
**Files:** `RocketLander/Models/GameCenterManager.swift`, `RocketLander/Views/LeaderboardView.swift`
**Details:**
- **Root cause**: `authenticateHandler`'s `viewController` parameter was silently dropped. When non-nil, this VC MUST be presented to complete per-app GC authentication. Without it, the device may have a GC account in Settings but the app never completes the handshake.
- **Fix 1**: Present auth `viewController` on topmost VC when provided (GameCenterManager.swift lines 60-65)
- **Fix 2**: Added `topViewController()` static helper that walks the presentation chain from root (GameCenterManager.swift lines 84-91)
- **Fix 3**: `GKGameCenterViewController` now presented from topmost VC (not raw rootVC) and initialized with `leaderboardID: galaxy_rank, playerScope: .global, timeScope: .allTime` (LeaderboardView.swift lines 98-105)
- Added `import UIKit` to GameCenterManager (needed for UIViewController/UIApplication)
- Build 32 uploaded to TestFlight with all fixes

## Technical Notes
- ASC API `defaultFormatter` for gameCenterLeaderboards requires a string enum value (`"INTEGER"`, `"DECIMAL_POINT_1_PLACE"`, etc.), NOT an object with `defaultValue`/`suffix`/`suffixSingular`
- 409 status from ASC API can mean "already exists" OR "entity validation error" (`ENTITY_ERROR.ATTRIBUTE.TYPE`) — must check error body, not just status code
- `GKLocalPlayer.local.authenticateHandler` can fire with: (1) viewController to present, (2) error, or (3) neither (check isAuthenticated). All three paths must be handled.
- In SwiftUI apps, `rootViewController` may already have a presented controller. Always walk up to the topmost presented VC before presenting.

## Decisions
1. **Script for ASC configuration** — automated via Python + ASC REST API instead of manual web UI. Script committed for reproducibility.
2. **INTEGER formatter** — leaderboard scores displayed as plain integers with " pts" suffix via localization
3. **Present auth VC from topmost controller** — shared `topViewController()` helper used by both auth handler and dashboard presentation

## Definition of Done
- [x] Version bumped to 2.1.0 Build 31, then Build 32
- [x] Build 31 + 32 uploaded to TestFlight
- [x] setup_game_center.py script created and committed
- [x] 12 leaderboards created in ASC (verified)
- [x] 10 achievements created in ASC (verified)
- [x] All en-US localizations added
- [x] Script defaultFormatter bug fixed
- [x] GC auth bug fixed (present authenticateHandler VC)
- [x] GC dashboard presented from topmost VC
- [x] Dashboard anchored to galaxy_rank leaderboard
- [x] All 7 documentation files updated
- [x] Session summary created
- [ ] Device testing on Build 32 (GC auth, score submission, achievements, Galaxy Rank, share card)

## Commits
- `3c91c96` — Bump version to 2.1.0 Build 31 for TestFlight
- `87125b4` — Add ASC Game Center setup script + session 51 documentation
- `b7580aa` — Fix Game Center auth: present sign-in VC + topmost presenter (Build 32)
- (this commit) — Documentation sweep for session 51

## Repo Housekeeping
- [x] Working tree clean after commit
- [x] .gitignore up to date
- [x] README.md project structure updated with new script
- [x] No secrets or credentials in tracked files

## Next Actions
- [ ] Device testing on TestFlight Build 32: GC auth, score submission, Galaxy Rank, achievements, share card
- [ ] App Store submission after device testing passes
