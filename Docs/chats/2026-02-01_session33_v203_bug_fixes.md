# 2026-02-01 — Session 33: v2.0.3 Device Testing Bug Fixes

## Goals
- Fix 4 bugs found during on-device testing of v2.0.3 Build 17 on TestFlight
- Save bug evidence screenshots in project folder
- Update all documentation
- Bump build number and upload to TestFlight

## Changes Made

### 1. Pre-Contact Velocity Tracking
**What:** Added synchronous velocity tracking in the update loop to capture accurate touchdown speeds.
**Why:** SpriteKit's `didBegin(contact:)` fires after collision resolution, which zeroes velocities. This caused V.Speed=0 on crash screens and mismatched approach speed diagnostics.
**Files:** `RocketLander/GameScene.swift`
**Details:**
- Added `lastTrackedVerticalSpeed`, `lastTrackedHorizontalSpeed`, `lastTrackedTilt` instance vars
- Updated every frame in `update()` before the async dispatch block
- `snapshotFinalStats()` reads from tracked values, not physics body
- `finalTiltAngle` now signed (preserves L/R direction)

### 2. HUD Display Consistency
**What:** Made HUD read from frozen `final*` values when `gameOver` is true.
**Why:** HUD showed live values while Flight Data showed frozen snapshot — two different numbers for the same metric on the game-over screen.
**Files:** `RocketLander/Views/HUDViews.swift`
**Details:**
- Added `displayVertical`, `displayHorizontal`, `displayTiltAngle` computed properties
- All color properties now use `display*` values
- Fixed tilt truncation: `minimumScaleFactor(0.7)` → `fixedSize()`, widened HUD 150→170pt
- Fixed fuel rounding: `Int()` → `"%.0f"` for consistency

### 3. Visual Campaign Start State
**What:** Campaign ships now appear visually tilted at spawn.
**Why:** The reentry tilt was only applied when the rocket became dynamic (first input), so the ship appeared upright until touched.
**Files:** `RocketLander/GameScene.swift` (`setupScene()`)

### 4. Signed Tilt in FinalStatsView
**What:** Added `abs()` on `finalTiltAngle` in FinalStatsView instantiations.
**Why:** `finalTiltAngle` changed from absolute to signed to preserve direction for HUD. Flight Data display needs absolute value.
**Files:** `RocketLander/Views/GameOverView.swift`

### 5. Bug Evidence Screenshots
**What:** Saved 5 device testing screenshots as bug evidence.
**Why:** Per user request, to document bugs for future reference.
**Files:** `Screenshots/v2.0.3-bugs/` (5 PNG files)

### 6. Landing Threshold Consistency (Build 19)
**What:** `checkLanding()` now uses pre-contact tracked values for threshold checks instead of reading from the physics body.
**Why:** Device testing of Build 18 revealed successful landings at V.Speed=71 (threshold is 50). SpriteKit's collision resolution absorbed impact energy before `checkLanding()` read the velocity, making the threshold check see lower values than the actual touchdown speed. The displayed value (from pre-contact tracking) was correct; the pass/fail decision was wrong.
**Files:** `RocketLander/GameScene.swift`
**Details:**
- `checkLanding()` now reads `lastTrackedVerticalSpeed`, `lastTrackedHorizontalSpeed`, `abs(lastTrackedTilt)` instead of `rocket.physicsBody?.velocity` and `rocket.zRotation`
- Same pre-contact values now used for: threshold checks, HUD display, Flight Data, crash diagnostics, and scoring
- Works identically in both Classic and Campaign modes (no mode-specific branching)

### 7. Build Number Bumps
**What:** Build 17 → 18 → 19 in Info.plist.
**Why:** Each TestFlight upload requires a unique build number.
**Files:** `RocketLander/Info.plist`

## Research / Ideas Discussed
- SpriteKit collision callbacks fire after physics resolution — velocities are already zeroed or reduced. This is a fundamental SpriteKit behavior that requires pre-contact tracking for accurate telemetry AND threshold checks.
- AppleScript/accessibility clicks don't translate to SpriteKit touch events, limiting automated UI testing of gameplay.
- dSYM warnings for GoogleMobileAds and UserMessagingPlatform during export are harmless — third-party frameworks ship without debug symbols.

## Technical Notes
- Pre-contact tracking adds 3 CGFloat assignments per frame — negligible overhead
- `fixedSize()` prevents SwiftUI text truncation but requires the container to be wide enough (widened to 170pt)
- `Int()` truncates (99.7→99) while `"%.0f"` rounds (99.7→100) — must use same method for display consistency
- The landing threshold bug was a deeper manifestation of the same root cause as the zeroed velocities bug: SpriteKit modifies physics state before collision callbacks fire. The fix for display (snapshotFinalStats) was applied in Build 18, but the fix for the pass/fail decision (checkLanding) required Build 19.

## Decisions
1. **Single authoritative telemetry snapshot**: All end-of-run data (HUD, Flight Data, crash diagnostics, landing threshold checks, scoring) must come from the same pre-contact tracked values captured in the update loop. Documented in DECISIONS.md.
2. **Signed finalTiltAngle**: Changed from absolute to signed to preserve L/R direction for HUD display on game-over. `abs()` applied explicitly where needed.

## Definition of Done
- [x] Bug #1 fixed: tilt HUD no longer truncates
- [x] Bug #2 fixed: V.Speed shows pre-contact touchdown speed
- [x] Bug #3 fixed: HUD and Flight Data show same values on game-over
- [x] Bug #4 fixed: campaign ships visually tilted at spawn
- [x] Bug #5 fixed: landing threshold uses pre-contact values (Build 19)
- [x] Fuel rounding consistency fixed
- [x] Fix works in both Classic and Campaign modes
- [x] 65/65 tests pass
- [x] Build succeeds
- [x] User confirmed Build 17 fixes work on device
- [x] Bug evidence screenshots saved to `Screenshots/v2.0.3-bugs/` (5 files)
- [x] All docs updated (CHANGELOG, STATUS, PROJECT_LOG, DECISIONS, session summary)
- [x] Build 19 archived and uploaded to TestFlight
- [x] Session summary created and finalized

## Commits
- `e6db4b5` — Fix v2.0.3 telemetry bugs: HUD truncation, snapshot timing, visual start state
- `d6befb5` — Bump to Build 18 + update all docs for v2.0.3 bug fixes
- `a177219` — End session 33: finalize docs with commit hashes and TestFlight status
- `361bf4f` — Fix landing threshold using post-collision velocity instead of pre-contact

## Repo Housekeeping
- [x] Working tree clean after commit
- [x] .gitignore up to date
- [x] README.md project structure includes Screenshots/v2.0.3-bugs/
- [x] No secrets or credentials in tracked files

## Next Actions
- [ ] Device testing of Build 19 on TestFlight (landing thresholds, both modes)
- [ ] Wait for App Store review response for v2.0.2
- [ ] Continue device testing: thrust vectoring, Venus/Jupiter/Mercury/Io mechanics
- [ ] Plan v2.1.0 (Community): Game Center + Achievements + Share Score Card
