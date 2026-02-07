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

## Current Status (2026-02-06, Session 56)

| Version | Build | Status |
|---------|-------|--------|
| 1.0 | 2 | Rejected (Guideline 5.1.2 - tracking without ATT) |
| 1.1.0 | 4 | Published on App Store |
| 1.1.1 | 5 | Bug fixes (not uploaded - superseded) |
| 1.1.2 | 6 | Published - Accelerometer controls |
| 1.1.3 | 7 | Published - Partial bug fix + URL update |
| 1.1.4 | 10 | Published - Bug fix + new icon |
| 1.1.5 | 11 | Published on App Store - New scoring system + HUD fixes |
| 2.0.0 | 12 | ~~SUBMITTED FOR REVIEW~~ — replaced by v2.0.2 (never reviewed after 2 days) |
| 2.0.1 | 13 | Dedicated leaderboard screen, version label fix |
| 2.0.2 | 16 | Published (approved 2026-02-03) — Campaign Mode |
| 2.0.3 | 30 | Published (approved 2026-02-06) — scoring rebalance + tilt bands + Europa cryogeysers |
| 2.1.0 | 32 | **PUBLISHED** (approved 2026-02-06) — Game Center + Share Score Card. **Live on App Store.** |
| 2.1.1 | 33 | **UPLOADED TO APP STORE CONNECT** — Share card redesign (crash sharing, compact colored stats, App Store link). Ready for submission. |

**NEXT STEPS:**
1. ~~v2.1.0: App Store submission~~ — **APPROVED** 2026-02-06, live on App Store
2. ~~Share Score Card redesign~~ — **DONE** (Session 55)
3. ~~v2.1.1: Version bump + upload~~ — **DONE** (Session 56, Build 33)
4. v2.1.1: Submit for App Store review
5. Implement event-driven share triggers per growth plan
6. Create 5 high-converting App Store screenshots per growth plan
7. Plan v2.2.0 (Monetization): approach TBD

**v2.1.0 — Phase: Community (CODE COMPLETE):**
- [done] 12 Game Center leaderboards (1 classic + 10 campaign + 1 galaxy_rank)
- [done] 10 Game Center achievements
- [done] Share Score Card (SwiftUI render + native share sheet)
- [done] Galaxy Rank on menu/leaderboard/campaign screens
- [done] GKAccessPoint on menu
- [done] Version bump to 2.1.0 Build 31, uploaded to TestFlight
- [done] App Store Connect: 12 leaderboards + 10 achievements created via API script
- [done] Device testing — GC auth, 12 leaderboards, score submission, Galaxy Rank, 10 achievements verified (Session 52). VPN root cause found and documented.
- [done] Leaderboard scores reset before submission (setup_game_center.py --reset)
- [done] App Store submission — Build 32 submitted for review 2026-02-06

**v2.2.0 PLANNED — Phase: Monetization (approach TBD):**
- [planned] Monetization — alternatives to be discussed

**BACKLOG (v2.3+):**
- ~~Campaign per-level high scores display~~ — **DONE in v2.0.1**
- iPad support
- Localization
- ~~Automated tests (XCTest)~~ — **Unit tests DONE (Session 30)**; UI tests (XCUITest) still planned

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

> **Sessions 1-35** (2026-01-07 through 2026-02-01) have been archived to `PROJECT_LOG_ARCHIVE.md`.
> The archive includes a project history summary at the top for quick context restoration.
> Consult the archive when investigating decisions or changes from earlier sessions.

---

### Session 36 (2026-02-01) - Fix Menu Ad Banner Clipping + Build 22 Upload

**Goal:** Fix the banner ad on the menu screen being clipped by the home indicator safe area. Correct stale documentation. Upload Build 22 to TestFlight with all v2.0.3 changes including menu ad fix.

**What Changed:**
- Added `.padding(.bottom, 16)` to `BannerAdContainer()` in `MenuView` (`ContentView.swift` line 260)
- The ad was the last item in the ScrollView's VStack with no bottom padding, causing it to be clipped by the home indicator on iPhones without a home button
- `GameContainerView.swift` already had `.padding(.bottom, 5)` on its banner ad; menu needed more clearance due to ScrollView behavior
- Corrected stale documentation that incorrectly described velocity threshold enforcement as "pending" (it was implemented in Build 21, commit `1698220`)
- Bumped build number 21 → 22 in Info.plist
- Archived, exported, and uploaded Build 22 to TestFlight (includes menu ad fix + all Build 21 changes)

**Files Modified:**
- `RocketLander/ContentView.swift` — added bottom padding to BannerAdContainer
- `RocketLander/Info.plist` — build number 21 → 22
- `DECISIONS.md` — changed velocity threshold entry from PENDING to RESOLVED
- `STATUS.md`, `PROJECT_LOG.md`, `CHANGELOG.md` — corrected stale references, updated build info

**Key Decisions:**
- Used 16pt padding (vs 5pt in gameplay) because the menu ScrollView needs more clearance when scrolled to the bottom

#### Definition of Done:
- [x] Banner ad fully visible when scrolled to bottom on iPhone 16 Pro
- [x] Build succeeds
- [x] 90/90 tests pass
- [x] Build 22 archived, exported, and uploaded to TestFlight
- [x] All stale "pending" references corrected
- [x] All docs updated with accurate build info
- [x] Session summary created

---

### Session 37 (2026-02-01) - Code Housekeeping Pass

**Goal:** Remove dead code, fix imports, delete stale files. No behavior changes, no refactors, no features, no version bump.

#### Changes Made:

1. **Removed dead code (6 items)**:
   - `leftFlame`/`rightFlame` unused properties from `GameScene.swift` (always nil)
   - `crashMessage()`, `crashMessages`, `crashNudges` from `LandingMessages.swift` (legacy, replaced by `diagnosticCrashMessage()`)
   - `crashNudge` property from `GameState.swift` and its assignments in `GameScene.swift`
   - `getTopScore()` from `HighScoreManager.swift` (zero callers)
   - `Triangle` shape from `ShapeViews.swift` (zero references)
   - Unused `CrashCause` enum cases `terrainCollision` and `outOfBounds` + `CaseIterable` conformance

2. **Fixed imports (3 files)**:
   - `GameScene.swift`: `import SwiftUI` → `import Combine`
   - `GameState.swift`: `import SwiftUI` → `import Foundation` + `import Combine`
   - `HighScoreManager.swift`: `import SwiftUI` → `import Foundation` + `import Combine`
   - `ContentView.swift`: removed unused `import SpriteKit`

3. **Deleted stale file**: `SETUP.txt` (referenced nonexistent scripts/tools from initial scaffolding)

4. **Updated tests**:
   - Removed `testCrashMessageStructure` from `LandingMessagesTests.swift` (tested deleted function)
   - Removed checks for deleted arrays from `testAllMessageArraysNonEmpty`
   - Removed `crashNudge` references from `GameStateTests.swift`
   - Test count: 90 → 89 (1 test removed for deleted function)

#### Files Modified:
- `RocketLander/GameScene.swift` — removed leftFlame/rightFlame, crashNudge assignments, fixed import
- `RocketLander/Models/LandingMessages.swift` — removed crashMessage(), crashMessages, crashNudges, unused enum cases
- `RocketLander/Models/GameState.swift` — removed crashNudge, fixed import
- `RocketLander/Models/HighScoreManager.swift` — removed getTopScore(), fixed import
- `RocketLander/Views/ShapeViews.swift` — removed Triangle
- `RocketLander/ContentView.swift` — removed unused import SpriteKit
- `RocketLanderTests/LandingMessagesTests.swift` — removed test for deleted function, updated array checks
- `RocketLanderTests/GameStateTests.swift` — removed crashNudge references

#### Files Deleted:
- `SETUP.txt`

#### Build Status:
- Build succeeds, 89/89 tests pass
- 9 files changed, 284 deletions total

#### Commits:
- `75169bf` — Code housekeeping: remove dead code, fix imports, delete stale file

#### Definition of Done:
- [x] All dead code identified and removed
- [x] Unused imports fixed
- [x] Stale files deleted
- [x] Tests updated to match removals
- [x] Build succeeds, all 89 tests pass
- [x] No behavior changes
- [x] All 7 documentation files verified and updated
- [x] Session summary created
- [x] Repo housekeeping checklist completed

---

### Session 38 (2026-02-02) - Build 22 Device Testing Bug Fixes

**Goal:** Fix two bugs found during Build 22 device testing on iPhone 16: (1) landing/crash messages truncated, (2) menu ad banner still clipped despite Session 36 padding fix.

#### Changes Made:

1. **GameOverView Text Truncation Fix (`GameOverView.swift`)**:
   - Landing success message: added `.multilineTextAlignment(.center)` + `.fixedSize(horizontal: false, vertical: true)` so long messages wrap instead of truncating
   - Crash primary diagnostic: added `.fixedSize(horizontal: false, vertical: true)` (already had `.multilineTextAlignment(.center)`)
   - Crash secondary diagnostic: added `.fixedSize(horizontal: false, vertical: true)` (already had `.multilineTextAlignment(.center)`)
   - Wrapped body VStack in ScrollView for vertical overflow protection when content is tall (landing + new high score scenario)

2. **Menu Ad Banner Clipping Fix (Improved) (`ContentView.swift`)**:
   - Previous fix (16pt bottom padding, Session 36) was insufficient — banner still clipped on device
   - Restructured MenuView: moved `BannerAdContainer()` outside ScrollView into a `VStack(spacing: 0)` wrapper
   - Ad now pinned at bottom of screen where SwiftUI safe area layout naturally keeps it above the home indicator
   - Verified on iPhone 16 Pro simulator — ad fully visible

#### Files Modified:
- `RocketLander/Views/GameOverView.swift` — text wrapping fixes + ScrollView wrapper
- `RocketLander/ContentView.swift` — menu ad moved outside ScrollView

#### Build Status:
- Build succeeds, 89/89 tests pass
- Fix B verified on simulator (screenshot saved to `Screenshots/v2.0.3-bugs/fix_b_menu_ad_verified.png`)
- Fix A requires device testing (user will test on TestFlight)

#### Definition of Done:
- [x] Fix A: text wrapping modifiers applied to 3 text elements
- [x] Fix A: GameOverView body wrapped in ScrollView for overflow protection
- [x] Fix B: BannerAdContainer moved outside ScrollView
- [x] Fix B: verified on iPhone 16 Pro simulator — ad fully visible
- [x] Build succeeds
- [x] 89/89 tests pass
- [ ] Fix A: verified on device (pending TestFlight Build 23)
- [ ] Build 23 uploaded to TestFlight
- [x] All docs updated

---

### Session 39 (2026-02-02) - Build 23 Upload to TestFlight

**Goal:** Archive and upload Build 23 to TestFlight for device testing of Session 38 bug fixes. Previous session's archive/export failed due to Keychain access issues in Tailscale SSH session.

#### Changes Made:

1. **CLI Authentication Setup**:
   - Configured CLI authentication for headless uploads
   - Enables `xcodebuild -exportArchive` over SSH/Tailscale without Keychain access

2. **Build 23 Archived and Uploaded**:
   - Archive succeeded: v2.0.3 Build 23 (already bumped in Session 38)
   - Export + upload via CLI authentication — bypasses Keychain entirely
   - Build 23 confirmed processing and visible on TestFlight
   - dSYM warnings for GoogleMobileAds/UserMessagingPlatform (harmless, same as always)

3. **Screenshot Housekeeping**: Moved 4 JPEG screenshots from `Screenshots/` root to `Screenshots/v2.0.3-bugs/` with descriptive names (bug9–bug12). These were uploaded via GitHub web UI for Session 38 bug analysis.

4. **Credentials Rotated**: Credentials rotated after upload.

#### No app code changes. Screenshot renames only.

#### Definition of Done:
- [x] Build 23 archived (v2.0.3)
- [x] Build 23 exported and uploaded to App Store Connect
- [x] Build 23 visible on TestFlight
- [x] Credentials rotated after use
- [x] Bug screenshots organized into v2.0.3-bugs with descriptive names
- [x] All docs updated
- [x] Session summary created

---

### Session 40 (2026-02-02) - Menu Layout Fix + How To Play Info Sheet

**Goal:** Fix menu overflow issue where content (~700pt) exceeded most iPhone screens and the banner ad covered the bottom section. Replace the inline HOW TO PLAY section with a rich info sheet.

#### Changes Made:

1. **Menu Layout Fix (`ContentView.swift`)**:
   - Removed the inline "HOW TO PLAY" section (VStack with 3 Label items, ~85pt)
   - Replaced with a "How to Play >" text button (~22pt) — saves ~79pt of vertical space
   - Added `@State private var showingHowToPlay` state variable
   - Added `.sheet(isPresented:)` modifier presenting `HowToPlayView`
   - Added `.padding(.bottom, 60)` to ScrollView content to clear the banner ad on devices that still need scrolling
   - Menu now fits without scrolling on iPhone 12 mini (731pt) and larger

2. **How to Play Info Sheet (`Views/HowToPlayView.swift` — new file)**:
   - Scrollable SwiftUI sheet with dark theme matching the app
   - 5 sections with orange accent headers:
     - **Controls**: Thrust, Rotate (adapts to button/accelerometer setting), Land
     - **Landing Platforms**: Table showing A/B/C with names, widths, multipliers, stars, colors
     - **Speed Bands**: SAFE/HARD/FAIL explanation + per-platform threshold table (V and H)
     - **Scoring**: All 6 components with max points, fuel multiplier (1.0-2.0x), platform multiplier (1x/2x/5x), formula, max 20,000
     - **Campaign**: All 10 levels with gravity and special mechanic (reads from `LevelDefinition.levels`)
   - Dismiss button (X) at top right

3. **Project File (`project.pbxproj`)**:
   - Added `HowToPlayView.swift` file reference, build file, Views group entry, and Sources build phase entry

4. **Screenshot Housekeeping**:
   - Moved `Screenshots/WhatsApp Image 2026-02-02 at 15.29.22.jpeg` → `Screenshots/v2.0.3-bugs/bug13_menu_howtoplay_covered_by_ad.jpeg`
   - Device screenshot showing the menu overflow bug (HOW TO PLAY covered by banner ad) — bug evidence for this session's fix

#### Files Created:
- `RocketLander/Views/HowToPlayView.swift`

#### Files Modified:
- `RocketLander/ContentView.swift` — removed HOW TO PLAY, added button + sheet + padding
- `RocketLander.xcodeproj/project.pbxproj` — added new file to project

#### Files Moved:
- `Screenshots/WhatsApp Image 2026-02-02 at 15.29.22.jpeg` → `Screenshots/v2.0.3-bugs/bug13_menu_howtoplay_covered_by_ad.jpeg`

#### Build Status:
- Build succeeds on iPhone 16 Pro simulator
- 89/89 tests pass (no logic changes)
- Menu layout verified on simulator — fits without scrolling

#### Definition of Done:
- [x] Inline HOW TO PLAY section removed
- [x] "How to Play >" button opens sheet
- [x] HowToPlayView has all 5 sections with accurate game data
- [x] Controls section adapts to accelerometer/button setting
- [x] Bottom padding clears banner ad
- [x] Build succeeds
- [x] All docs updated
- [x] Build 24 archived and uploaded to TestFlight
- [ ] Simulator test on iPhone SE to verify scrolling behavior
- [ ] Device test on TestFlight Build 24

#### Commits:
- `edf13e1` — Session 40: Replace inline HOW TO PLAY with rich info sheet
- `37a0fa8` — Bump build number to 24 for TestFlight upload
- `4c03154` — Remove API key from repo — moved to ~/.appstoreconnect/private_keys/

---

### Session 41 (2026-02-02) - Build 24 TestFlight Upload

**Goal:** Commit Session 40 changes, archive Build 24, and upload to TestFlight for device testing.

#### Changes Made:

1. **Committed Session 40 work**: Menu layout fix (How to Play info sheet replacing inline section), HowToPlayView.swift, screenshot housekeeping, all documentation updates.

2. **Build 24 archived and uploaded to TestFlight**: Bumped build number 23 → 24. Archived and uploaded via CLI authentication. dSYM warnings for GoogleMobileAds/UserMessagingPlatform (harmless).

#### No app code changes (build bump only).

#### Commits:
- `edf13e1` — Session 40: Replace inline HOW TO PLAY with rich info sheet
- `37a0fa8` — Bump build number to 24 for TestFlight upload
- `4c03154` — Update CLI authentication setup

---

### Session 42 (2026-02-02) - Code Quality & Build Hygiene

**Goal:** Review codebase for build hygiene improvements. Harden .gitignore, clean up debug output and legacy files.

#### Changes Made:

1. **`.gitignore` hardened**: Added missing patterns for build artifacts and credential file types (`*.p8`, `*.key`, `*.pem`, `*.secret`, `.env`, `.env.*`, `.apple_id`, `*.ipa`, `*.dSYM`, `*.dSYM.zip`).

2. **Print statements wrapped in `#if DEBUG`**: 5 occurrences across `RocketLanderApp.swift` (ATT status) and `BannerAdView.swift` (4 ad lifecycle events). No output in release builds.

3. **Player name length limit**: Added `.onChange` modifier to TextField in `GameOverView.swift` to cap at 20 characters.

4. **ATT request optimized**: `requestTrackingPermission()` now checks `ATTrackingManager.trackingAuthorizationStatus == .notDetermined` before calling `requestTrackingAuthorization`. Eliminates wasted SDK calls on every foreground.

5. **Legacy Podfile deleted**: Project uses SPM exclusively. Podfile was confusing artifact.

#### No version bump. Build 24 unchanged (code-only changes, no behavioral impact in release builds).

#### Commits:
- `15a059e` — Code quality improvements — harden .gitignore, wrap prints in DEBUG, optimize ATT, cap player name

---

### Session 43 (2026-02-02) - Documentation Cleanup & Credential Protection Guardrails

**Goal:** Clean up documentation across all project files. Add credential protection guardrails to CLAUDE.md. Clean git history of narrative references.

#### Changes Made:

1. **Documentation cleanup (10 files)**: Reviewed and cleaned all session summaries and project documentation. Simplified authentication workflow descriptions, neutralized verbose narratives, and ensured consistent language.

2. **Credential & Secret Protection (CLAUDE.md)**: Added mandatory section with 6 hard rules: refuse credentials, never write to files, pre-commit scans, safe authentication patterns, and accidental share handling.

3. **Git history cleanup**: 7 passes of `git-filter-repo` (4 `--replace-text` + 3 `--message-callback`) to neutralize ~30 narrative phrases across all historical commits.

#### No app code changes. Documentation only.

#### Commits:
- `523f00b` — Documentation cleanup and add credential protection guardrails

---

### Session 44 (2026-02-02) - Build 25 TestFlight Upload

**Goal:** Bump build number to 25 and upload to TestFlight so the TestFlight build matches the current source (which includes Session 42 build hygiene changes and Session 43 documentation cleanup).

#### Changes Made:

1. **Build number bumped 24 → 25** (`Info.plist`): Aligns TestFlight build with current source code.

2. **Build 25 archived and uploaded to TestFlight**: Uploaded via Xcode Organizer GUI. dSYM warnings for GoogleMobileAds/UserMessagingPlatform (harmless, same as always).

#### No app code changes (build bump only).

#### Commits:
- `31c371a` — Bump build number to 25 for TestFlight upload

---

### Session 45 (2026-02-03) - Flight Data Panel Redesign & Crash Messages

**Goal:** Redesign Flight Data panel to match HUD design language. Add randomized crash headline easter eggs.

#### Changes Made:

1. **FinalStatsView HUD-style redesign** (`GameOverView.swift`): Complete rewrite with SF Symbol icons, OK/HARD/FAIL badge pills, 3-color value system, gray dividers, centered header. Band logic per metric (tilt safe/fail, speeds via LandingThresholds, fuel >20%/>0%/0%, center <20pt/<30pt/>=30pt). "HARD LANDING" / "RAPID UNSCHEDULED DISASSEMBLY" badges at bottom. Applied to both landing and crash game-over screens.

2. **Randomized crash headlines** (`GameOverView.swift`): Pool of 20 messages replacing static "CRASH!" text. SpaceX references, space mission quotes, Kerbal vibes, dry humor. Randomized each game over via `@State` property.

3. **High score sheet fix** (`GameOverView.swift`): Added `onChange` listeners for `gameState.score` and `gameState.landed` to handle race condition where `onAppear` fired before state propagated.

4. **GameContainerView overlay restructure** (`GameContainerView.swift`): Moved `GameOverView` from HUD VStack to ZStack root for proper full-screen layering.

5. **Build 26 uploaded to TestFlight** (`Info.plist`): Build number 25 → 26. Archived and uploaded via CLI.

6. **Bug screenshot organization** (`Screenshots/v2.0.3-bugs/`): Saved 3 device screenshots (bug14-16) documenting the game-over overlay scroll issue from Build 25 that this session's overlay restructure fixed.

7. **PROJECT_LOG archiving** (`PROJECT_LOG.md`, `PROJECT_LOG_ARCHIVE.md`, `CLAUDE.md`, `STATUS.md`, `README.md`): Moved sessions 1-35 to archive (1,768 → 410 lines). Archive includes project history summary. Archiving rules embedded in CLAUDE.md. Session start checklist updated.

#### Commits:
- `3b5934c` — Redesign Flight Data panel with HUD-style layout and randomized crash messages
- `21ac776` — Bump build number to 26 for TestFlight upload
- `a5a95be` — Add session 45 documentation — Flight Data redesign and crash messages
- `d850a26` — Archive PROJECT_LOG sessions 1-35 and establish archiving workflow
- `67d1ee6` — Finalize session 45 documentation — add archiving work to summaries
- `fc21e40` — Add bug screenshots for game-over overlay scroll issue (Build 25)

---

---

### Session 46 (2026-02-05) - v2.0.3 Gameplay Feedback Fixes

**Goal:** Process 10 user feedback items on v2.0.3 Build 26, implement all fixes for gameplay issues, celestial bodies, level mechanics, and UI.

#### Changes Made:

1. **Menu Button Truncation Fix** (`GameOverView.swift`): Reduced horizontal padding, added `.fixedSize()`.

2. **CENTER Badge Removal** (`GameOverView.swift`): CENTER row now shows value only without OK/HARD/FAIL badge.

3. **Speed Threshold Tightening** (`LandingThresholds.swift`): Tightened all thresholds ~15% for A/B, ~5% for C. Updated all 18 `LandingEvaluationTests` to match new values.

4. **Jupiter Wind Overhaul** (`GameScene.swift`, `GameScene+Effects.swift`, `LevelDefinition.swift`): Wind always pushes left→right with stronger force (base 20.0), ambient wind during calm, gravity increased from -4.8 to -5.2, particles reversed direction.

5. **Europa Ice Effect** (`GameScene.swift`): H.Speed > 20 causes crash ("Slid off the ice!").

6. **Titan Thrust Reduction** (`GameScene.swift`): Thrust reduced to 75% efficiency (replaces drag damping which made it easier).

7. **Earth Platform Collision Fix** (`GameScene.swift`): Zone-based movement — B stays in 5%-50%, C stays in 55%-95%, eliminates startup collision.

8. **Mercury Heat Shimmer** (`GameScene.swift`, `GameScene+Effects.swift`, `LevelDefinition.swift`): Increased perturbation wobble, added rising heat particles, fixed celestial body to sunLarge.

9. **Celestial Body Corrections** (`LevelDefinition.swift`, `GameScene+Setup.swift`): All 10 levels now show astronomically-correct celestial bodies (Earth from Moon, Saturn with rings from Titan, Jupiter with bands from moons, Sun with glow from inner planets, etc.). Added `addSunFeatures()` for Sun rendering.

10. **Partial Platform Landing Detection** (`GameScene.swift`): Both legs (47pt span) must be within platform bounds to land successfully.

#### Files Modified:
- `RocketLander/Views/GameOverView.swift` — Menu button, CENTER badge
- `RocketLander/Models/LandingThresholds.swift` — Tightened thresholds
- `RocketLander/Models/LevelDefinition.swift` — Celestial bodies, Jupiter gravity, Titan description
- `RocketLander/GameScene.swift` — Europa ice, Titan thrust, Earth platforms, Mercury shimmer, partial landing
- `RocketLander/GameScene+Effects.swift` — Jupiter particles, Mercury particles
- `RocketLander/GameScene+Setup.swift` — Sun features, celestial body rendering
- `RocketLanderTests/LandingEvaluationTests.swift` — Updated 18 tests for new thresholds

#### Build Status:
- Build succeeds, 89/89 tests pass (18 LandingEvaluationTests updated for new thresholds)

#### Definition of Done:
- [x] All 10 feedback items implemented
- [x] All tests updated and passing
- [x] Build succeeds
- [x] Build 27 uploaded to TestFlight
- [x] All docs updated
- [x] Session summary created

---

### Session 47 (2026-02-05) - Europa Cryogeysers + Build 28 TestFlight

**Goal:** Replace Europa's punishing ice slide crash (H.Speed > 20 = instant death) with cryogeyser eruptions — disruptive but survivable force-based plumes. Upload Build 28 to TestFlight.

#### Changes Made:

1. **Europa cryogeysers** (`LevelDefinition.swift`, `GameScene.swift`, `GameScene+Effects.swift`): Renamed `.iceSurface` → `.cryogeysers`. 3 fixed geyser positions with staggered active/calm cycling. Upward push force (base 18.0, tapering with height) when rocket is in plume zone. Blue/white/cyan particle columns. Vent markers on surface. Ice shimmer + low friction preserved.

2. **Ice slide crash removed** (`GameScene.swift`): Deleted the H.Speed > 20 crash check in `checkLanding()`.

3. **Test updated** (`LevelDefinitionTests.swift`): `.iceSurface` → `.cryogeysers` in expected mechanics map.

4. **Build 28 uploaded to TestFlight** (`Info.plist`): Build number 27 → 28.

#### Files Modified:
- `RocketLander/Models/LevelDefinition.swift` — enum rename, description update
- `RocketLander/GameScene.swift` — geyser state, setup, mechanics, ice crash removal, reset cleanup
- `RocketLander/GameScene+Effects.swift` — `createCryogeyserEffect()` particle system
- `RocketLanderTests/LevelDefinitionTests.swift` — mechanic name update
- `RocketLander/Info.plist` — Build 27 → 28

#### Commits:
- `42d953f` — Replace Europa ice slide with cryogeyser eruptions
- `167a024` — Bump build number to 28 for TestFlight upload

#### Build Status:
- Build succeeds, 89/89 tests pass

#### Definition of Done:
- [x] Ice slide crash removed
- [x] `.iceSurface` renamed to `.cryogeysers` everywhere
- [x] 3 geyser positions with active/calm cycling
- [x] Upward push force in plume zone
- [x] Blue/white/cyan particle columns
- [x] Vent markers on surface
- [x] Ice shimmer + low friction preserved
- [x] Build succeeds, all 89 tests pass
- [x] Build 28 uploaded to TestFlight
- [x] Docs updated (CHANGELOG, STATUS, DECISIONS, PROJECT_LOG)

---

### Session 48 (2026-02-05) - Scoring Rebalance + Tilt Bands

**Goal:** Address low score feedback (rarely >5,000) with comprehensive scoring improvements. Add tilt bands (SAFE/HARD/FAIL) matching speed band philosophy.

#### Root Cause Analysis (Scoring):
- Quadratic penalty curve zeroed velocity components in HARD band (0 pts instead of partial credit)
- Session 46 tightened thresholds ~15% compressed the scoring range
- Fuel multiplier range 1.0-2.0x too narrow; fuel consumption too high

#### Changes Made:

1. **Scoring formula overhaul** (`GameScene+Scoring.swift`, `ScoringHelper.swift`):
   - Velocity scoring denominator changed from safe to hard threshold — single smooth curve, HARD landings get partial credit
   - Soft Landing: 500→550 pts, Horizontal Precision: 400→450 pts (subtotal max 2000→2100)
   - Fuel multiplier: 1.0-2.0x → 1.0-2.2x (factor 1.0→1.2)
   - Theoretical max: 23,100 (was 20,000)

2. **Fuel consumption reduction** (`GameScene.swift`):
   - Thrust: 0.30→0.27%/frame
   - Rotation: 0.08→0.07%/frame
   - Accelerometer: 0.04→0.035×tilt

3. **Tilt bands** (`LandingThresholds.swift`, `GameScene+Scoring.swift`, `ScoringHelper.swift`, `GameOverView.swift`, `HUDViews.swift`, `LandingMessages.swift`, `HowToPlayView.swift`):
   - SAFE ≤0.05 rad (~2.9°), HARD ≤0.10 rad (~5.7°), FAIL >0.10 rad
   - Tilt band participates in overall landing band (worst of V/H/tilt wins)
   - Rotation scoring uses hardTilt (0.10) as denominator
   - HUD tilt color: green/yellow/red for safe/hard/fail
   - Crash message: "Land under 6°" (was 3°)
   - GameOverView tilt band uses `LandingThresholds.tiltBand()`

4. **HowToPlayView updated** (`HowToPlayView.swift`): New component values, subtotal, fuel range, max. Updated speed band thresholds to v2.0.3 values. Added tilt band explanation.

5. **Perfect score script updated** (`Scripts/calculate_perfect_scores.py`): New formula, fuel rates, tilt thresholds. Best: Classic C = 14,504.

6. **Tests updated** (`ScoringTests.swift`, `LandingEvaluationTests.swift`, `CrashDiagnosticTests.swift`):
   - ScoringTests: New theoretical max 23,100, new component values, HARD partial credit tests, discontinuity test
   - LandingEvaluationTests: 2 binary rotation tests → 4 tilt band tests + 1 classification test
   - CrashDiagnosticTests: Updated rotation value in determinism test (0.08→0.12, since 0.08 is now HARD not crash)

7. **Build 29 uploaded to TestFlight** (`Info.plist`): Build number 28→29.

8. **Build 30 bumped and uploaded to TestFlight** (`Info.plist`): Build number 29→30. Tilt band changes included.

9. **v2.0.3 Build 30 submitted for App Store review** (2026-02-06): What's New text, review notes, and promotional text finalized. Submitted via App Store Connect.

#### Files Modified:
- `RocketLander/GameScene+Scoring.swift` — scoring formula, rotation denominator
- `RocketLander/GameScene.swift` — fuel consumption rates
- `RocketLander/Models/LandingThresholds.swift` — tilt bands (safeTilt, hardTilt, tiltBand(), evaluate())
- `RocketLander/Models/LandingMessages.swift` — crash threshold hardTilt, "Land under 6°"
- `RocketLander/Views/GameOverView.swift` — tiltBand uses LandingThresholds.tiltBand()
- `RocketLander/Views/HUDViews.swift` — hardTiltDegrees, 3-color tiltColor
- `RocketLander/Views/HowToPlayView.swift` — scoring values, speed band thresholds, tilt band explanation
- `RocketLanderTests/ScoringHelper.swift` — test scoring replica
- `RocketLanderTests/ScoringTests.swift` — test assertions
- `RocketLanderTests/LandingEvaluationTests.swift` — tilt band tests
- `RocketLanderTests/CrashDiagnosticTests.swift` — determinism test rotation value
- `Scripts/calculate_perfect_scores.py` — scoring formula, fuel rates, tilt thresholds
- `RocketLander/Info.plist` — Build 28→29

#### Build Status:
- Build succeeds, 91/91 tests pass (was 89 — net +2 from tilt band tests)

#### Commits:
- `e1b2d61` — Rebalance scoring: HARD partial credit, component boost, fuel tuning
- `25cecde` — Bump build number to 29 for TestFlight upload
- `254bb30` — Add tilt bands (SAFE/HARD/FAIL) matching speed band philosophy
- `a906b72` — Bump build number to 30 for TestFlight upload
- `30ab29d` — Update docs for v2.0.3 Build 30 App Store submission
- `540de65` — Simplify v2.0.3 review notes
- `b70cdda` — Note v2.0.3 Build 30 submitted for review

---

### Session 49 (2026-02-06) - v2.0.3 Build 30 Approved

**Goal:** Note approval of v2.0.3 Build 30.

#### Changes Made:
- Updated documentation to note Build 30 approved and live on App Store (2026-02-06).

#### Commits:
- `2d70294` — Note v2.0.3 Build 30 approved and live on App Store

---

### Session 50 (2026-02-06) - v2.1.0 Community Phase Implementation

**Goal:** Implement v2.1.0 Community phase: Game Center integration (auth, 12 leaderboards, 10 achievements, Galaxy Rank) and Share Score Card.

#### Changes Made:

1. **GameCenterManager.swift (NEW)** — 283 lines. ObservableObject + singleton. Auth, 12 leaderboard IDs, score submission (fire-and-forget), Galaxy Rank fetch/display, 10 achievement checks, persistent tracking state (safePlatformCLevels, attemptsByLevel via UserDefaults).

2. **RocketLander.entitlements (NEW)** — Game Center capability.

3. **ShareScoreCardView.swift (NEW)** — 148 lines. SwiftUI card rendering (320pt, dark gradient, orange border). ShareHelper with ImageRenderer (iOS 16+) / UIHostingController snapshot (iOS 15). Native share sheet.

4. **ContentView.swift** — Added gameCenterManager StateObject, `.onAppear { authenticate() }`, passed to all child views. MenuView: Galaxy Rank badge, GKAccessPoint show/hide, fetchGalaxyRank on appear.

5. **GameContainerView.swift** — Added campaignState and gameCenterManager params, passed campaignState through to GameScene.

6. **GameScene.swift** — Added campaignState property, updated init. recordAttempt() in startGame(). GC score submission + achievement check in successfulLanding().

7. **LeaderboardView.swift** — Added gameCenterManager param, Galaxy Rank header, "View Global Rankings" button (GKGameCenterViewController), GKDismissHandler class.

8. **LevelSelectView.swift** — Added gameCenterManager param, Galaxy Rank explanation section after level grid.

9. **GameOverView.swift** — Share button (landing only), shareScoreCard() method building ShareScoreCardView from gameState.

10. **project.pbxproj** — Added GameCenterManager.swift, ShareScoreCardView.swift, RocketLander.entitlements, CODE_SIGN_ENTITLEMENTS.

#### Files Created:
- `RocketLander/Models/GameCenterManager.swift`
- `RocketLander/Views/ShareScoreCardView.swift`
- `RocketLander/RocketLander.entitlements`

#### Files Modified:
- `RocketLander/ContentView.swift`
- `RocketLander/GameScene.swift`
- `RocketLander/Views/GameContainerView.swift`
- `RocketLander/Views/LeaderboardView.swift`
- `RocketLander/Views/LevelSelectView.swift`
- `RocketLander/Views/GameOverView.swift`
- `RocketLander.xcodeproj/project.pbxproj`

#### Build Status:
- Build succeeds, 91/91 tests pass

#### Key Decisions:
- Galaxy Rank uses 12th leaderboard (galaxy_rank) = sum of best scores across 10 campaign levels
- Achievement checks use composite landing band (worst of V/H/tilt) not speedBand alone
- Tilt checks use radians internally (e.g., 2.0° = 2.0 × π/180)
- First Try Perfection is campaign-only, tracked via attemptsByLevel
- GC auth is non-intrusive — features hidden when not signed in
- Singleton pattern on GameCenterManager needed for fire-and-forget calls from GameScene

#### Definition of Done:
- [x] GameCenterManager with auth, leaderboards, achievements
- [x] 12 leaderboard IDs defined
- [x] 10 achievement IDs and check logic
- [x] Galaxy Rank on 3 UI layers (menu, campaign, leaderboard)
- [x] GKAccessPoint on menu
- [x] Share Score Card rendering + native share sheet
- [x] Share button on game-over (landing only)
- [x] Build succeeds
- [x] 91/91 tests pass
- [x] All documentation updated
- [x] Session summary created
- [ ] Version bump (pending user approval)
- [ ] App Store Connect configuration (manual)
- [ ] Device testing

---

### Session 51 (2026-02-06) - v2.1.0 TestFlight + ASC Setup + GC Auth Fix

**Goal:** Version bump to 2.1.0, upload to TestFlight, create GC resources in ASC via API, fix GC auth bug found during device testing.

#### Changes Made:

1. **Version bump** (`Info.plist`): v2.0.3 Build 30 → v2.1.0 Build 31. Archived and uploaded to TestFlight.

2. **setup_game_center.py (NEW)** (`Scripts/setup_game_center.py`): Python script to create Game Center leaderboards and achievements via App Store Connect REST API.
   - JWT authentication with ES256 signing
   - Reads credentials from env vars (ASC_ISSUER_ID, ASC_KEY_ID, ASC_PRIVATE_KEY) or local .p8 files
   - Creates 12 leaderboards with en-US localizations
   - Creates 10 achievements with en-US localizations
   - Idempotent — skips existing resources

3. **App Store Connect configured**: All 12 leaderboards and 10 achievements created successfully via API.
   - 12 leaderboards: classic, campaign_1-10, galaxy_rank (INTEGER format, BEST_SCORE, DESC sort)
   - 10 achievements: eagle_has_landed through master_lander (200 total points)
   - All with en-US localizations

4. **Game Center auth fix** (`GameCenterManager.swift`, `LeaderboardView.swift`): Device testing of Build 31 revealed "View Global Rankings" showed "Sign in to Game Center" despite being signed in.
   - **Root cause**: `authenticateHandler`'s `viewController` parameter was silently dropped. When non-nil, this VC must be presented to complete per-app GC authentication.
   - **Fix 1**: Present auth `viewController` on topmost VC when provided
   - **Fix 2**: Added `topViewController()` helper (walks presentation chain from root)
   - **Fix 3**: `GKGameCenterViewController` now presented from topmost VC (not root) and anchored to `galaxy_rank` leaderboard
   - Build 32 uploaded to TestFlight with fix

#### Bug Fixed in Script:
- `defaultFormatter` attribute requires string enum (`"INTEGER"`) not nested object. Fixed format and improved error reporting.

#### Files Created:
- `Scripts/setup_game_center.py`

#### Files Modified:
- `RocketLander/Info.plist` — v2.1.0, Build 31→32
- `RocketLander/Models/GameCenterManager.swift` — auth VC presentation, topViewController() helper, UIKit import
- `RocketLander/Views/LeaderboardView.swift` — topmost VC presenter, galaxy_rank anchor

#### Build Status:
- Build succeeds, 91/91 tests pass

#### Commits:
- `3c91c96` — Bump version to 2.1.0 Build 31 for TestFlight
- `87125b4` — Add ASC Game Center setup script + session 51 documentation
- `b7580aa` — Fix Game Center auth: present sign-in VC + topmost presenter (Build 32)

#### Definition of Done:
- [x] Version bumped to 2.1.0 Build 31, then Build 32
- [x] Build 31 + 32 uploaded to TestFlight
- [x] setup_game_center.py script created
- [x] 12 leaderboards created in ASC (verified)
- [x] 10 achievements created in ASC (verified)
- [x] All localizations (en-US) added
- [x] Script defaultFormatter bug fixed
- [x] GC auth bug fixed (present authenticateHandler VC)
- [x] GC dashboard presented from topmost VC
- [x] Dashboard anchored to galaxy_rank leaderboard
- [x] All documentation updated
- [ ] Device testing (GC auth, score submission, achievements, Galaxy Rank, share card)

---

### Session 52 (2026-02-06) - v2.1.0 Device Testing + VPN Root Cause + App Store Submission

**Goal:** Investigate and resolve "Sign in to Game Center" issue on device. Verify all GC features. Document findings, reset leaderboard scores, and submit v2.1.0 for App Store review.

#### Investigation & Root Cause:

1. **Initial investigation** (5 parallel agents): Analyzed auth state, GKAccessPoint, leaderboard ID matching, ASC version enablement, score submission flow. All IDs matched. GKAccessPoint bubble showed (confirming auth works). ASC resources in "Ready to Submit" state.

2. **Diagnostic build**: Added `[GC-DIAG]` logging throughout — auth handler, leaderboard probe (`GKLeaderboard.loadLeaderboards`), default leaderboard identifier, 3 dashboard buttons (generic, classic, galaxy_rank).

3. **ROOT CAUSE: VPN blocking GC network traffic**. Console showed `interface: utun4` (VPN tunnel) in network errors. Auth succeeded (cached) but all data fetching failed with "hostname could not be found."

4. **User disabled VPN → everything works**: All 12 leaderboards visible, scores submitted (Moon 3,323 pts, Galaxy Rank 12,323 pts, rank #1), 10 achievements visible, GKAccessPoint showing.

#### Changes Made:

1. **Diagnostic code removed** (`GameCenterManager.swift`, `LeaderboardView.swift`): All `[GC-DIAG]` logging and diagnostic buttons removed. Code restored to clean state.

2. **Defensive guard added** (`LeaderboardView.swift`): `openGameCenterDashboard()` now checks `GKLocalPlayer.local.isAuthenticated` before presenting GKGameCenterViewController.

3. **Setup script enhanced** (`Scripts/setup_game_center.py`): Added `gameCenterAppVersions` support — `get_current_app_store_version()` and `enable_gc_for_app_version()` functions. Needed for App Store submission (not TestFlight).

4. **v2.1.0 release notes prepared** (`RELEASE_NOTES.md`): App Store "What's New" copy and review team notes for v2.1.0.

#### Files Modified:
- `RocketLander/Views/LeaderboardView.swift` — defensive auth guard on dashboard
- `Scripts/setup_game_center.py` — gameCenterAppVersions support
- All 7 documentation files updated

#### Build Status:
- Build succeeds, 91/91 tests pass

5. **Leaderboard scores reset**: Ran `setup_game_center.py --reset` to delete all 12 leaderboards and recreate them fresh, clearing test scores (12,323 pts galaxy_rank) before App Store submission.

6. **App Store screenshot**: Created captioned screenshot `Screenshots/v2.1.0/11_galaxy_rank_captioned.png` (1284x2778) with caption "COMPETE GLOBALLY. CLIMB THE GALAXY RANK."

7. **v2.1.0 submitted for App Store review**: Build 32 submitted with comprehensive What's New (covering v2.1.0 + v2.0.3 + v2.0.2), updated review notes, new screenshot, and updated promotional text.

#### Files Modified:
- `Scripts/setup_game_center.py` — --reset flag, delete_all_leaderboards(), gameCenterAppVersions support
- `RocketLander/Views/LeaderboardView.swift` — defensive auth guard on dashboard
- `RELEASE_NOTES.md` — v2.1.0 What's New and review notes
- `Screenshots/v2.1.0/11_galaxy_rank_captioned.png` — new App Store screenshot
- All 7 documentation files updated

#### Definition of Done:
- [x] Root cause identified (VPN blocks GC network)
- [x] All diagnostic code removed
- [x] Defensive auth guard added to dashboard presentation
- [x] Setup script enhanced with gameCenterAppVersions and --reset
- [x] GC features verified on device (12 leaderboards, scores, rank, achievements)
- [x] Leaderboard scores reset before submission
- [x] App Store screenshot created (Galaxy Rank caption)
- [x] v2.1.0 release notes finalized (What's New + review notes)
- [x] v2.1.0 Build 32 submitted for App Store review
- [x] All 7 documentation files updated
- [x] Build succeeds
- [x] Session summary created

---

### Session 53 (2026-02-06) - GitHub GC Follow-Up: Fix Stale Tags + Reply to Support

**Goal:** Respond to GitHub Support request for sensitive commit SHAs. Audit and fix all stale references on GitHub blocking garbage collection.

#### Changes Made:

1. **Identified sensitive commit SHAs**: Used `.git/filter-repo/commit-map` to find the two old commits containing sensitive data: `17aebc66...` (introduced) and `4c031548...` (removed). Both fully deleted by filter-repo.

2. **Fixed 6 stale remote tags**: All tags (v1.0.0–v1.1.5) on GitHub still pointed to pre-rewrite SHA `67c5802a...`. Deleted and re-pushed all 6 tags. `git push --force` only updates branches, not tags — this was missed in Session 43.

3. **Full reference audit**: Verified no other stale references exist (no PRs, no extra branches, spam issue #1 has no commit refs, 6 releases reference updated tags).

4. **Prepared and sent reply email** to GitHub Support (Collins) with both SHAs, cleanup details, and request to run GC.

#### No code changes. Tag operations only.

#### Definition of Done:
- [x] Sensitive commit SHAs identified
- [x] Stale remote tags fixed (6 tags deleted and re-pushed)
- [x] Full GitHub reference audit completed
- [x] Reply email sent to GitHub Support
- [x] All docs updated
- [x] Session summary created

---

### Session 54 (2026-02-06) - Organic Growth Plan

**Goal:** Save the organic growth plan as a project document and integrate it into session continuity workflow.

#### Changes Made:

1. **Growth plan created** (`Docs/GROWTH_PLAN.md`): Comprehensive organic growth strategy for post-v2.1.0 approval. Covers ASO (top priority), screenshot strategy (5 screenshots, no custom art), event-driven share triggers (new personal best, achievement, Galaxy Rank improvement), Reddit-only social (r/iosgaming, r/IndieGames), and AI division of labor (Claude Code = growth hooks + stability, ChatGPT = ASO copy + drafts, Human = builds + approvals). Weekly challenges deferred until ~200+ DAU.

2. **CLAUDE.md updated**: Added `Docs/GROWTH_PLAN.md` to Session Continuity table, Quick Obligations table, and File Structure section. Future sessions will know to consult it when implementing growth-related features.

3. **README.md updated**: Added `Docs/GROWTH_PLAN.md` to project structure tree.

4. **STATUS.md updated**: Added growth plan to Current Phase description and Immediate Next Tasks (share triggers + screenshots as post-approval tasks).

#### Files Created:
- `Docs/GROWTH_PLAN.md`

#### Files Modified:
- `CLAUDE.md` — Session Continuity table, Quick Obligations, File Structure
- `README.md` — Project Structure tree
- `STATUS.md` — Current Phase description, Immediate Next Tasks, reconciliation date
- `PROJECT_LOG.md` — Session 54 entry

#### No code changes. Documentation only.

#### Key Decisions:
- Growth plan saved as project documentation (not external-only) for session continuity
- Canonical promotional text: "A skill-based landing game where precision beats luck. Master thrust, gravity, and control across the solar system."
- Share triggers are the primary code work item (implement after v2.1.0 approval)
- Weekly challenges deferred until DAU reaches ~200+

#### Definition of Done:
- [x] Growth plan saved as `Docs/GROWTH_PLAN.md`
- [x] CLAUDE.md references growth plan in 3 places
- [x] README.md project structure updated
- [x] STATUS.md updated with growth plan tasks
- [x] PROJECT_LOG.md session entry added
- [x] Session summary created
- [x] All 7 documentation files verified

---

### Session 55 (2026-02-06) - Share Score Card Redesign: Crash Sharing + Compact Stats

**Goal:** Redesign the Share Score Card per growth plan: add crash card variant, replace 5-row stats dump with compact colored stats row, add App Store link, enable sharing on crashes.

#### Changes Made:

1. **LandingMessages.swift** — Added `shortCrashCause()` static function (~20 lines). Returns compact cause strings: "Tilt (18.4°)", "V.Speed (547 m/s)", "H.Speed (89 m/s)", "Missed Platform", or "Ship Lost". Same priority logic as `diagnosticCrashMessage()`.

2. **ShareScoreCardView.swift** — Complete redesign with two variants via `isLanded` conditional:
   - **Landing card**: "STARSHIP LANDER" header → score hero (large mono) → stars → mode/level → platform+band badge → divider → compact stats row (V/H/Fuel with green/yellow/red band colors) → App Store footer
   - **Crash card**: "STARSHIP LANDER" header → crash headline hero (red) → mode/level → CRASH badge (red) → divider → "Cause: ..." diagnostic → App Store footer
   - Crash card border is red instead of orange
   - Removed old 5-row stats dump, `tiltDegrees`, `distanceFromCenter` parameters
   - Added `platform` parameter for band-aware stat coloring
   - `ShareHelper.shareImage()` now accepts text payload with App Store URL
   - `ShareHelper.appStoreURL` constant added
   - Footer legibility improved (semibold + higher opacity)

3. **GameOverView.swift** — Two changes:
   - Share button now visible on both landing AND crash game-over screens
   - `shareScoreCard()` rewritten to build either variant, passing crash headline and compact cause
   - Share text: "I scored X in Starship Lander! <URL>" or "<CRASH HEADLINE> <URL>"

#### Files Modified:
- `RocketLander/Models/LandingMessages.swift` — `shortCrashCause()` added
- `RocketLander/Views/ShareScoreCardView.swift` — complete redesign
- `RocketLander/Views/GameOverView.swift` — crash sharing enabled, data flow updated

#### Build Status:
- Build succeeds, 91/91 tests pass
- Tested on iPhone 16 Pro simulator — both landing and crash cards verified

#### Key Decisions:
- Single `ShareScoreCardView` with `isLanded` conditional (two variants share ~70% layout)
- Compact stats row: V, H, Fuel only — no tilt or center (poster, not telemetry)
- Crash diagnostic uses units: "V.Speed (547 m/s)"
- Stats values colored by band (green/yellow/red) matching HUD design language
- `hitTerrain` inferred from `crashDiagnosticPrimary` text — avoids GameState model changes
- App Store URL: https://apps.apple.com/us/app/starship-lander/id6757563869

#### Definition of Done:
- [x] Crash share card implemented with headline hero + cause diagnostic
- [x] Landing share card redesigned with compact colored stats
- [x] Share button enabled on both landing and crash
- [x] App Store link on card image + URL in share text payload
- [x] Crash diagnostic values include units (m/s)
- [x] Stats values colored by speed/fuel band
- [x] Footer legibility improved
- [x] Build succeeds, 91/91 tests pass
- [x] Simulator tested (landing + crash cards)
- [x] All 7 documentation files verified

---

### Session 56 (2026-02-06) - v2.1.1 Build 33 Version Bump + Upload

**Goal:** Bump version to v2.1.1 Build 33 (share card redesign), archive, and upload to App Store Connect. v2.1.0 approved by Apple.

#### Changes Made:

1. **v2.1.0 approved**: Apple approved v2.1.0 Build 32 for distribution (2026-02-06). Game Center + Share Score Card now live on App Store.

2. **Version bump** (`Info.plist`): v2.1.0 Build 32 → v2.1.1 Build 33.

3. **Build 33 archived and uploaded**: Archive succeeded, exported via `ExportOptions.plist` (app-store-connect method), uploaded to App Store Connect. dSYM warnings for GoogleMobileAds/UserMessagingPlatform (harmless, expected).

4. **Documentation updated**: STATUS.md, CHANGELOG.md, RELEASE_NOTES.md, README.md, PROJECT_LOG.md all updated to reflect v2.1.0 approval and v2.1.1 upload.

#### Files Modified:
- `RocketLander/Info.plist` — v2.1.1 Build 33
- `STATUS.md` — version status, phase, next tasks
- `CHANGELOG.md` — v2.1.1 entry, v2.1.0 marked published
- `RELEASE_NOTES.md` — v2.1.1 section, v2.1.0 marked published
- `README.md` — version, history table
- `PROJECT_LOG.md` — current status table, session entry

#### Build Status:
- Build succeeds, 91/91 tests pass
- Archive succeeded
- Upload succeeded (App Store Connect processing)

#### Commits:
- `2c43aac` — Bump to v2.1.1 Build 33: share card redesign

#### Definition of Done:
- [x] v2.1.0 approval noted in all docs
- [x] Version bumped to v2.1.1 Build 33
- [x] Build 33 archived and uploaded to App Store Connect
- [x] All documentation updated (7-file sweep)
- [x] Session summary created

---

*Last updated: 2026-02-06 (Session 56)*
