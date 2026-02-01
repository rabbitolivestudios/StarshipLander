# 2026-02-01 — Session 33: v2.0.3 Device Testing Bug Fixes

## Goals
- Fix 4 bugs found during on-device testing of v2.0.3 Build 17 on TestFlight
- Save bug evidence screenshots in project folder
- Update all documentation
- Bump build number and upload Build 18 to TestFlight

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
**What:** Saved 4 device testing screenshots as bug evidence.
**Why:** Per user request, to document bugs for future reference.
**Files:** `Screenshots/v2.0.3-bugs/` (4 PNG files)

### 6. Build Number Bump
**What:** Build 17 → 18 in Info.plist.
**Why:** Can't upload same build number twice to TestFlight.
**Files:** `RocketLander/Info.plist`

## Research / Ideas Discussed
- SpriteKit collision callbacks fire after physics resolution — velocities are already zeroed. This is a fundamental SpriteKit behavior that requires pre-contact tracking for accurate telemetry.
- AppleScript/accessibility clicks don't translate to SpriteKit touch events, limiting automated UI testing of gameplay.

## Technical Notes
- Pre-contact tracking adds 3 CGFloat assignments per frame — negligible overhead
- `fixedSize()` prevents SwiftUI text truncation but requires the container to be wide enough (widened to 170pt)
- `Int()` truncates (99.7→99) while `"%.0f"` rounds (99.7→100) — must use same method for display consistency

## Decisions
1. **Single authoritative telemetry snapshot**: All end-of-run data (HUD, Flight Data, crash diagnostics) must come from the same frozen frame captured via pre-contact tracking. Documented in DECISIONS.md.
2. **Signed finalTiltAngle**: Changed from absolute to signed to preserve L/R direction for HUD display on game-over. `abs()` applied explicitly where needed.

## Definition of Done
- [x] Bug #1 fixed: tilt HUD no longer truncates
- [x] Bug #2 fixed: V.Speed shows pre-contact touchdown speed
- [x] Bug #3 fixed: HUD and Flight Data show same values on game-over
- [x] Bug #4 fixed: campaign ships visually tilted at spawn
- [x] Fuel rounding consistency fixed
- [x] 65/65 tests pass
- [x] Build succeeds
- [x] User confirmed fixes work on device
- [x] Bug evidence screenshots saved to `Screenshots/v2.0.3-bugs/`
- [x] All docs updated (CHANGELOG, STATUS, PROJECT_LOG, DECISIONS, README)
- [x] Build number bumped to 18
- [ ] Build 18 archived and uploaded to TestFlight
- [x] Session summary created

## Commits
- `e6db4b5` — Fix v2.0.3 telemetry bugs: HUD truncation, snapshot timing, visual start state
- (pending) — Documentation + build bump + TestFlight upload

## Repo Housekeeping
- [x] Working tree clean after commit
- [x] .gitignore up to date
- [x] README.md project structure includes Screenshots/v2.0.3-bugs/
- [x] No secrets or credentials in tracked files

## Next Actions
- [ ] Upload Build 18 to TestFlight
- [ ] Wait for App Store review response for v2.0.2
- [ ] Continue device testing on TestFlight
- [ ] Plan v2.1.0 (Community): Game Center + Achievements + Share Score Card
