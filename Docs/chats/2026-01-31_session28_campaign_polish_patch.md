# 2026-01-31 — Session 28: v2.0.2 Campaign Polish Patch

## Goals
- Implement campaign gameplay tuning from device testing feedback (session 27)
- Scoring rebalance: weight center precision higher, reduce fuel multiplier cap
- Proportional thrust vectoring: replace binary RCS lateral assist
- Planet mechanic differentiation: Venus, Jupiter, Mercury, Io
- Leaderboard star metadata: store and display stars per high score entry
- Update level descriptions to match new mechanics

## Changes Made

### 1. Scoring Rebalance
**What:** Redistributed score components and lowered fuel cap
**Why:** Feedback that scoring didn't reward precision enough; fuel hoarding dominated
**Files:** `RocketLander/GameScene+Scoring.swift`
- Soft Landing: 700 → 500 points
- Platform Center: 350 → 600 points (now highest-weighted component)
- Approach Control: 200 → 150 points
- Subtotal unchanged at 2000
- Fuel multiplier: 1.0-2.5x → 1.0-2.0x
- Max theoretical score: 25,000 → 20,000

### 2. Proportional Thrust Vectoring
**What:** Replaced binary RCS lateral assist with smooth proportional correction
**Why:** Binary assist (2.0 units when tilted >5°) was too coarse; small lateral mistakes were unrecoverable without it, but it also gave free lateral movement without fuel cost
**Files:** `RocketLander/GameScene.swift`
- Removed: binary lateral assist block (tiltThreshold, lateralAssist, nudge)
- Added: `sin(rotation) × thrustPower × 0.15` inside thrust block
- Only active while thrusting (no free lateral assist)
- Proportional: small tilts = small corrections, large tilts = larger corrections
- Affects both classic and campaign modes (same update loop)

### 3. Venus — Vertical Updrafts
**What:** Changed Venus wind from horizontal to vertical
**Why:** Venus and Jupiter both used sine-wave horizontal wind at different magnitudes — not differentiated
**Files:** `RocketLander/GameScene.swift`, `RocketLander/GameScene+Effects.swift`
- Wind force now applies to dy (vertical) instead of dx (horizontal)
- Wind particles spawn at bottom and move upward (instead of right-to-left)
- Sine frequency: 1.5 (slower, heavier feel), magnitude: 4.0 + random ±0.5

### 4. Jupiter — Sudden Gusts with Calm Windows
**What:** Replaced smooth sine-wave wind with calm/gust cycle
**Why:** Jupiter should feel distinct from other wind levels — unpredictable and punishing
**Files:** `RocketLander/GameScene.swift`
- Added gust state properties: `gustActive`, `gustTimer`, `gustDirection`, `gustCalmDuration`, `gustActiveDuration`
- Calm: 2.5-4.0s with light residual wind (±1 random)
- Gust: 1.5-2.5s sharp directional force (15.0 × direction ± 2 random)
- Direction randomized each gust cycle

### 5. Mercury — Heat Interference
**What:** Added thrust control perturbation (in addition to existing visual shimmer)
**Why:** Heat shimmer was visual-only with no gameplay effect; description said "distorts your view" but didn't affect control
**Files:** `RocketLander/GameScene.swift`
- New case in `applyCampaignMechanics` for `.heatShimmer`
- Random velocity perturbation when thrusting: dx ±1.5, dy ±0.8
- Only active while thrusting with fuel > 0 (no interference when coasting)
- Visual shimmer effect unchanged

### 6. Io — Deadly Volcanic Debris
**What:** Gave volcanic eruption particles collision physics
**Why:** Eruptions were cosmetic — no gameplay consequence for flying through them
**Files:** `RocketLander/GameScene+Effects.swift`
- Eruption particles get `SKPhysicsBody` with `groundCategory` bitmask
- `contactTestBitMask = rocketCategory` — triggers crash on contact
- `isDynamic = false` — particles follow their scripted movement
- Physics body removed (`particle.physicsBody = nil`) before fade-out action
- Result: active rising particles are deadly, fading/falling particles are safe

### 7. Leaderboard Star Metadata
**What:** Added backward-compatible `stars` field to HighScoreEntry, displayed in leaderboard
**Why:** Feedback that leaderboard lacked context — couldn't tell if a score was 1-star safe landing or 3-star elite
**Files:** `RocketLander/Models/HighScoreManager.swift`, `RocketLander/Models/CampaignState.swift`, `RocketLander/Views/LeaderboardView.swift`
- `HighScoreEntry` gains `stars: Int = 0` with custom `CodingKeys` and `init(from:)` for backward compat
- `addScore()` gains `stars` parameter (default 0)
- `CampaignState.completedLevel()` passes stars through to HighScoreEntry
- `scoreRow()` in LeaderboardView gains optional `stars` parameter
- Small yellow star icons displayed between name and score when stars > 0
- Campaign card call sites pass `stars: levelScores[index].stars`
- Classic mode: **initially missed** — `saveScore()` didn't pass stars. Fixed: now passes `gameState.starsEarned` for both modes

### 8. Level Description Updates
**What:** Updated descriptions and display name for changed mechanics
**Why:** Descriptions must match actual gameplay behavior
**Files:** `RocketLander/Models/LevelDefinition.swift`
- Venus: "Heavy turbulence — variable winds." → "Vertical updrafts disrupt your descent."
- Mercury: "Heat shimmer distorts your view." → "Heat shimmer disrupts thrust control."
- Io: "Volcanic eruptions create hazards." → "Volcanic debris is deadly — time it."
- Jupiter: "Extreme gravity and wind gusts." → "Sudden gusts between calm windows."
- `.heavyTurbulence` display name: "Heavy Turbulence" → "Vertical Updrafts"

## Research / Ideas Discussed
- RELEASE_NOTES.md v2.0.0 section references old values (25,000 score, RCS thrusters). Since v2.0.0 is already submitted for review, those notes are frozen. A future v2.0.2 release notes section should be added when version is bumped.
- Classic mode is affected by thrust vectoring change (same update loop). This is intentional — classic mode benefits from the same improved control feel.

## Technical Notes
- HighScoreEntry backward compatibility: `decodeIfPresent` for `stars` and `id` fields means old serialized data loads without error (stars default to 0).
- Gust state properties are private instance vars on GameScene, reset implicitly when `setupScene()` recreates the scene (properties keep their default values through the class instance lifecycle).
- Volcanic particle physics bodies use `isDynamic = false` so they aren't affected by scene gravity — they follow their scripted SKAction movement.

## Decisions
1. **Scoring rebalance** — Center precision (600pts) now highest single component. Fuel cap 2.0x instead of 2.5x. Rationale: precision is the core skill expression, fuel hoarding shouldn't dominate.
2. **Thrust vectoring over RCS** — Proportional `sin(rotation) × 0.15` tied to thrust, replacing binary assist. Rationale: physics-based, proportional, requires fuel to correct.
3. **Planet differentiation** — Each planet gets a mechanically distinct challenge axis: Venus (vertical), Jupiter (timing), Mercury (control noise), Io (hazard avoidance). Rationale: same-axis wind at different magnitudes is not differentiation.

## Definition of Done
- [x] Scoring rebalance: center 600pts, fuel cap 2.0x, max 20,000
- [x] Thrust vectoring: proportional, thrust-only, replaces binary RCS
- [x] Venus: vertical updrafts + vertical particles
- [x] Jupiter: calm/gust alternation cycle
- [x] Mercury: thrust perturbation while thrusting
- [x] Io: deadly volcanic particles with physics bodies
- [x] Leaderboard star metadata: backward-compatible, displayed in campaign rows
- [x] Level descriptions updated to match new mechanics
- [x] Build succeeds (xcodebuild verified)
- [x] README.md scoring table, mechanics, lateral assist updated
- [x] CHANGELOG.md v2.0.2 section added
- [x] DECISIONS.md 3 new entries (scoring, thrust vectoring, planet differentiation)
- [x] STATUS.md updated (scoring, mechanics, device testing status, version)
- [x] PROJECT_LOG.md session 28 entry added
- [x] Session summary created
- [x] Version bumped to 2.0.2 (Build 14→15→16)
- [x] Archived and uploaded to App Store Connect / TestFlight (three times: Build 14, 15, 16)
- [x] Classic mode star rating save bug fixed (Build 15)
- [x] Classic mode star rating display bug fixed (Build 16)

## Commits
- `35de6a9` — Campaign polish: scoring rebalance, thrust vectoring, planet differentiation
- `1c754f8` — Bump version to 2.0.2 (Build 14), upload to TestFlight
- `4216f7e` — Update session 28 summary: commits, version bump, TestFlight upload
- `cf1afd8` — End session 28: update PROJECT_LOG with commits and status
- `e3ccdce` — Fix classic mode star rating not saved in high scores (Build 15)
- `2a4ecb8` — Fix classic mode star display in leaderboard and menu (Build 16)

## Repo Housekeeping
- [x] Working tree clean (no stale untracked files)
- [x] .gitignore up to date
- [x] README.md project structure matches actual files
- [x] README.md scoring/mechanics accuracy verified and fixed
- [x] No secrets or credentials in tracked files

## Version Bump & TestFlight
- Version bumped to 2.0.2 (Build 14) in Info.plist, later incremented to Build 15 for star fix
- All docs updated with new version: CHANGELOG, README, PROJECT_LOG, STATUS
- Archived and uploaded to App Store Connect via `xcodebuild -exportArchive` (twice)
- dSYM warnings for GoogleMobileAds and UserMessagingPlatform (harmless, known issue)

## Bug Fix: Classic Mode Star Rating
- **Bug:** Classic mode `saveScore()` in GameOverView didn't pass `stars` to `highScoreManager.addScore()` — always saved 0
- **Root cause:** When implementing leaderboard star metadata (Change 7), campaign path was updated but classic path was missed
- **Fix 1 (Build 15):** `GameOverView.swift:219` — added `stars: gameState.starsEarned` to the classic mode `addScore()` call
- **Fix 2 (Build 16):** Two display-side issues remained — `LeaderboardView` classic section and `ContentView` menu TOP PILOTS section both called `scoreRow` without passing `entry.stars`. Added `stars: entry.stars` to both call sites.
- **Found by:** Device testing on TestFlight (user landed 3-star in classic, stars not shown in leaderboard)

## Device Testing Results (Build 16)
- [x] Classic mode star rating saves and displays correctly — **VERIFIED**
- [ ] Verify thrust vectoring feel on device (both control modes)
- [ ] Verify Venus updrafts, Jupiter gusts, Mercury heat interference, Io deadly debris on device
- [ ] Verify leaderboard star display with existing save data (backward compat)
- [ ] Verify scoring changes feel right (center precision rewarded, fuel less dominant)

## Next Actions
- [ ] Continue device testing of campaign mechanics on TestFlight
- [ ] Wait for v2.0.0 App Store review response
