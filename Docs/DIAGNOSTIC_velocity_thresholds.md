# Diagnostic Report: Velocity Landing Thresholds Never Enforced

**Date:** 2026-02-01
**Session:** 34
**Severity:** Critical — affects core gameplay loop
**Discovered during:** Device testing of Build 19 (v2.0.3)
**Prepared by:** Claude Code (AI assistant) for developer review

---

## Executive Summary

The vertical speed (V<40) and horizontal speed (H<25) landing thresholds in Starship Lander have **never been functionally enforced** in any shipped or tested build. From the initial commit through Build 18, `checkLanding()` read velocity from `rocket.physicsBody?.velocity` inside SpriteKit's `didBegin(contact:)` callback. SpriteKit's collision resolution zeros or near-zeros velocities before this callback fires, meaning the threshold check always saw values close to 0 — effectively auto-passing.

Build 19 attempted to fix a related display bug by switching `checkLanding()` to use pre-contact tracked values. This was the **first time speed thresholds were actually enforced**, but the tracked values were captured before thrust was applied in the same frame, making them systematically too high. The result: no player can land.

Additionally, the HUD displays wrong threshold values (V<50, H<30) that have never matched the actual GameScene thresholds (V<40, H<25). This mismatch has existed since the HUD was created and was never caught.

---

## Timeline of the Bug

### Initial Commit (e8e9656) — Thresholds Created, Never Functional

```swift
// GameScene.swift — present since initial commit
static let maxSafeVerticalSpeed: CGFloat = 40.0
static let maxSafeHorizontalSpeed: CGFloat = 25.0
static let maxSafeRotation: CGFloat = 0.05
static let maxSafeApproachSpeed: CGFloat = 80.0
```

`checkLanding()` was called from `didBegin(contact:)` and read from `rocket.physicsBody?.velocity`:

```swift
private func checkLanding(contactNode: SKNode?) {
    guard let velocity = rocket.physicsBody?.velocity else { return }
    let verticalSpeed = max(0, -velocity.dy)
    let horizontalSpeed = abs(velocity.dx)
    // ...
    let verticalOK = verticalSpeed <= GameScene.maxSafeVerticalSpeed  // Always true
    let horizontalOK = horizontalSpeed <= GameScene.maxSafeHorizontalSpeed  // Always true
}
```

**Why it auto-passed:** SpriteKit's physics simulation cycle is:
1. `update()` — game logic
2. Physics simulation (gravity, forces, collision detection, **collision resolution**)
3. `didBegin(contact:)` — callback

By step 3, collision resolution has already absorbed impact energy. For a rocket landing on a platform, the vertical velocity is zeroed or near-zero because the collision has been resolved (the rocket is now resting on the platform). The threshold check in `didBegin(contact:)` sees V≈0, H≈0 — well under any threshold.

**Consequence:** The only thing that could fail a platform landing was **rotation** (which is not affected by collision resolution). Speed was irrelevant to landing success from day one.

### Builds 1–17 — All Shipped Versions

All builds through Build 17 (the first TestFlight build of v2.0.3) used the same post-collision velocity reading. Players could land at any speed as long as rotation was under 0.05 rad (~2.9°). The "V<40" and "H<25" thresholds were dead code.

Players achieved 3-star landings. Scoring components for speed (soft landing: 0-500 pts, horizontal precision: 0-400 pts) received near-zero velocity inputs, producing near-maximum scores. The scoring formula was effectively: `base + max_speed_scores + center_precision + rotation + approach × fuel_multiplier × platform_multiplier`.

### Session 32 (fede844) — HUD Created with Wrong Thresholds

The velocity HUD (`VelocityHUDView`) was added in commit `fede844` with hardcoded thresholds:

```swift
// HUDViews.swift — WRONG from creation
private let maxSafeVertical: CGFloat = 50.0    // GameScene uses 40.0
private let maxSafeHorizontal: CGFloat = 30.0  // GameScene uses 25.0
```

The "SAFE" label displayed: `V<50 H<30 T<3°`

These values **never matched** the GameScene thresholds. The HUD was written with incorrect constants and no reference to `GameScene.maxSafeVerticalSpeed` or `GameScene.maxSafeHorizontalSpeed`.

Because speed thresholds were never enforced anyway, this mismatch was invisible — the HUD showed "OK" for any speed, and the landing check also passed for any speed. Both were wrong for different reasons, but the user experience appeared consistent.

### Session 33, Build 18 (e6db4b5) — Display Fix, Threshold Still Dead

Build 18 added pre-contact velocity tracking in `update()` for **display purposes**:

```swift
// GameScene.swift update() — tracking added at line 272
lastTrackedVerticalSpeed = currentVerticalSpeed
lastTrackedHorizontalSpeed = abs(velocity.dx)
lastTrackedTilt = rocket.zRotation
```

`snapshotFinalStats()` was changed to read from tracked values (fixing the "V.Speed=0 on crash screen" display bug). But `checkLanding()` still read from `rocket.physicsBody?.velocity` — thresholds remained dead.

**Device test result:** A landing at V.Speed=71 (displayed correctly from tracked values) was accepted because the threshold check saw V≈0 (from physics body). The display showed a crash-worthy speed, but the game said "landed."

### Session 33, Build 19 (361bf4f) — Thresholds Enforced for First Time, Too Strict

Build 19 changed `checkLanding()` to use tracked values:

```swift
// GameScene.swift checkLanding() — Build 19
let verticalSpeed = lastTrackedVerticalSpeed      // from update() tracking
let horizontalSpeed = lastTrackedHorizontalSpeed   // from update() tracking
let rotation = abs(lastTrackedTilt)                // from update() tracking
```

This was the **first time in the project's history** that speed thresholds were actually enforced. But the tracked values were captured at line 272 of `update()`, **before** thrust application at line 286:

```
update() execution order:
  Line 260-283: Track velocity ← VALUES CAPTURED HERE
  Line 286-311: Apply thrust   ← THRUST REDUCES SPEED AFTER TRACKING
  Line 328-367: Apply rotation
  Line 374:     Campaign mechanics
  Line 376-386: Screen wrap, bounds check
```

When a player actively thrusts to decelerate, the tracked value is the velocity **before** that frame's thrust was applied. Thrust at power 12.0 reduces vertical speed by up to 12.0 pts/s per frame (when upright). The tracked value can be 10-15 units higher than the actual post-thrust velocity.

**Device test result:** Player decelerating carefully to land. Actual velocity at frame end: ~35. Tracked velocity (pre-thrust): ~48. Threshold: V<40. Landing rejected. The player sees HUD showing "OK" (because HUD uses V<50) but the game crashes them. The user reported: "I have not managed to land a single time after Build 19 was pushed to TestFlight."

---

## Why This Wasn't Caught

### 1. Unit Tests Never Tested Threshold Enforcement

The test suite has 65 tests across 8 files. None test the landing pass/fail decision:

| Test File | What It Tests | Why It Missed This |
|-----------|--------------|-------------------|
| `ScoringTests.swift` | Scoring formula math with given inputs | Assumes inputs are correct; doesn't test what values `checkLanding()` receives |
| `ScoringHelper.swift` | Replica of scoring formula | Pure math; no physics body interaction |
| `CrashDiagnosticTests.swift` | Crash message selection given inputs | Tests message logic, not what triggers a crash |
| `GameStateTests.swift` | GameState initial values and reset | No physics, no landing |
| `LandingMessagesTests.swift` | Message text selection | No physics |
| `CampaignStateTests.swift` | Campaign progression logic | No landing physics |
| `LevelDefinitionTests.swift` | Level data correctness | No landing physics |
| `HighScoreManagerTests.swift` | Score persistence | No landing physics |
| `LandingPlatformTests.swift` | Platform data correctness | No landing physics |

**Critical gap:** There is no integration test that simulates a physics body contact and verifies that `checkLanding()` makes the correct pass/fail decision based on actual velocity values. All tests operate on isolated components with manually provided inputs.

**Why this gap exists:** SpriteKit's `SKPhysicsContact` is created internally by the engine and cannot be easily mocked or constructed in unit tests. Testing the full landing flow requires either a running SpriteKit scene (integration test) or extracting the decision logic into a pure function (which was not done).

### 2. Scoring Simulation Assumed Thresholds Work

The Python simulation (`Scripts/calculate_perfect_scores.py`) models physics frame-by-frame and applies landing gates:

```python
# Line 363 — simulation assumes thresholds are enforced
if lv > MAX_SAFE_VERT or lh > MAX_SAFE_HORIZ or appr > MAX_SAFE_APPROACH:
    return None
```

The simulation correctly models that a landing at V>40 should fail. But it has no knowledge of SpriteKit's collision resolution behavior. It assumes the game engine correctly enforces the thresholds it checks — which it never did.

The simulation's "optimal" landing velocities (V≈28-39, H≈1-5) were achievable in-game, but the game would have accepted V=100 equally. The simulation validated the math but not the engine integration.

### 3. No SpriteKit Physics Integration Test

There is no test that:
1. Creates a `GameScene`
2. Spawns a rocket with known velocity
3. Triggers a platform collision
4. Verifies the landing was accepted or rejected based on velocity

This is the test that would have caught the bug immediately. It was never written because:
- SpriteKit collision callbacks are triggered by the engine, not by test code
- The test infrastructure focused on pure-function unit tests (scoring, messages, state management)
- The assumption was that "the game works because we tested it on device" — but device testing never specifically tested threshold enforcement at boundary values

### 4. Device Testing Never Tested Boundary Velocities

Device testing confirmed "I can land" and "the game crashes when it should." But landing was always successful for moderate approaches because the threshold check auto-passed. No test scenario involved deliberately approaching at V=45 to verify threshold enforcement. The visual feedback (HUD, Flight Data) showed low values (near zero) post-collision, which appeared correct.

### 5. HUD Threshold Mismatch Was Invisible

The HUD shows `V<50 H<30 T<3°`. The actual thresholds are `V<40 H<25 T<3°`. Because speed thresholds were never enforced:
- A player at V=45 would see HUD say "OK" (V<50), and the landing would succeed (V≈0 post-collision). Appeared consistent.
- A player at V=55 would see HUD say "HIGH" (V>50), and the landing would still succeed (V≈0 post-collision). But this is less likely to be noticed because V=55 is a fast approach.

The mismatch would only become visible when thresholds are actually enforced — which didn't happen until Build 19.

---

## Current State of Threshold Values Across Codebase

| Location | Vertical | Horizontal | Rotation | Approach | Purpose |
|----------|----------|------------|----------|----------|---------|
| `GameScene.swift:66-69` | **40.0** | **25.0** | 0.05 | 80.0 | Authoritative thresholds (pass/fail decision) |
| `HUDViews.swift:82-83` | **50.0** | **30.0** | 0.05 | — | HUD color coding + OK/HIGH labels |
| `HUDViews.swift:211` | "V<50" | "H<30" | "T<3°" | — | SAFE label text |
| `GameOverView.swift:11-13` | 40.0 | 25.0 | 0.05 | — | Flight Data panel color coding |
| `LandingMessages.swift:87-90` | 40.0 | 25.0 | 0.05 | 80.0 | Crash diagnostic messages |
| `ScoringHelper.swift:10-13` | 40.0 | 25.0 | 0.05 | 80.0 | Test-only scoring replica |
| `calculate_perfect_scores.py:54-57` | 40.0 | 25.0 | 0.05 | 80.0 | Scoring simulation |

**Discrepancies:** HUDViews uses 50.0/30.0 everywhere else uses 40.0/25.0. The HUD has been wrong since its creation in commit `fede844`.

---

## Impact Analysis

### On Gameplay Experience

**All builds through Build 18:** Speed was irrelevant to landing success. The game was effectively a rotation-control challenge where the player needed to land upright on a platform. Speed thresholds, despite being displayed and communicated to players, had zero effect.

**Build 19:** Speed suddenly matters but is measured too aggressively (pre-thrust values). The game becomes unplayable — no landings are possible even with careful approach.

### On Scoring

**All builds through Build 18:** The scoring formula received near-zero velocity inputs from `checkLanding()`, which passed these to `successfulLanding()`, which passed them to `calculateScore()`. This means:
- Soft Landing component (0-500 pts): Always near maximum (~500)
- Horizontal Precision component (0-400 pts): Always near maximum (~400)
- The score range was effectively compressed — skill differentiation came only from fuel, center precision, rotation, and platform choice

**Build 19:** `successfulLanding()` receives pre-contact tracked values, so scoring reflects actual approach speed. But since no landings succeed, this is untested.

### On High Scores

All existing high scores (local leaderboards, campaign completions) were achieved under the "speed doesn't matter" regime. If speed thresholds are properly enforced, the maximum achievable scores will **decrease** because the scoring formula penalizes higher velocities (which will now be non-zero).

### On the Perfect Score Simulation

The simulation calculated optimal scores assuming speed thresholds work. Its predicted scores are valid for a game where thresholds are enforced. But no player has ever experienced that game. The "achievement thresholds" derived from the simulation are based on a game that doesn't match any shipped build.

---

## Root Cause Chain

```
1. Initial design: checkLanding() reads from physics body in didBegin(contact:)
   └─ SpriteKit zeros velocities before callback → thresholds are dead code
      └─ Game works, but only rotation matters for landing
         └─ Nobody notices because the experience "feels right"

2. HUD added with wrong threshold values (50/30 instead of 40/25)
   └─ Invisible because thresholds are dead → HUD "OK" always matches landing success

3. Pre-contact tracking added for DISPLAY (Build 18)
   └─ Display shows real velocities. Threshold still reads post-collision (dead).
   └─ V=71 displayed but landing accepted → visible inconsistency

4. Tracking used for THRESHOLD CHECK (Build 19)
   └─ First time thresholds are enforced
   └─ But tracking position is before thrust → values too high
   └─ Combined with HUD showing wrong thresholds → player confusion
   └─ Result: impossible to land
```

---

## Decision Points for Resolution

The fix must address three separate issues simultaneously:

### Issue 1: What velocity values should `checkLanding()` use?

| Option | Source | Accuracy | Risk |
|--------|--------|----------|------|
| **A. Post-collision (Build 17 behavior)** | `rocket.physicsBody?.velocity` in `didBegin(contact:)` | Near zero — unreliable | Speed thresholds remain dead. V=100 landings accepted. |
| **B. Pre-thrust tracked (Build 19 current)** | `lastTrackedVerticalSpeed` captured before thrust in `update()` | Inflated — does not reflect player's thrust deceleration | Too strict. Player actively braking still gets rejected. |
| **C. Post-thrust tracked (proposed)** | Move tracking to after thrust/rotation/mechanics in `update()` | Accurate — reflects player's inputs before collision | First-ever real enforcement. Game becomes harder than all prior builds. |
| **D. Post-collision for threshold, tracked for display** | Split sources | Threshold: lenient (as before). Display: accurate. | Inconsistency between what's shown and what's enforced. Same problem as Build 18. |

### Issue 2: What should the threshold values be?

If Option C is chosen (real enforcement for the first time), the current V<40 / H<25 thresholds may or may not match actual gameplay velocities. They were never tested against real approaches. Options:

| Option | Values | Rationale |
|--------|--------|-----------|
| **Keep V<40, H<25** | Current constants | These are the documented, simulated values. But no player has ever been tested against them. |
| **Raise to V<60, H<40** | More forgiving | Accounts for the fact that players learned to land without speed constraints. Generous enough to not feel punishing. |
| **Data-driven tuning** | TBD | Add logging to track actual approach velocities, set thresholds based on real distribution. Requires a test build cycle. |

### Issue 3: HUD must match whatever thresholds are chosen

The HUD currently shows V<50 / H<30. Whatever threshold values are decided upon must be reflected identically in:
- `GameScene.swift` (authoritative constants)
- `HUDViews.swift` (display thresholds + SAFE label)
- `GameOverView.swift` (Flight Data color coding)
- `LandingMessages.swift` (crash diagnostic messages)
- `ScoringHelper.swift` (test replica)
- `calculate_perfect_scores.py` (simulation)

---

## What the Scoring Simulation Can Tell Us

The Python simulation models post-thrust physics (thrust is applied, then gravity, per frame). Its "landing velocity" at the final frame is a post-thrust, pre-collision value — equivalent to Option C above.

The simulation's optimal landings across all 33 level/platform combinations have these velocity ranges:

- **Vertical speed at landing:** 0-39 pts/s (the simulation targets staying under 40)
- **Horizontal speed at landing:** 0-5 pts/s
- **Typical "careful" descent speed:** 25-35 pts/s

This suggests that V<40 is achievable in the simulation's model. But the simulation uses a perfect reactive controller, not a human player with touch input latency and imprecise control. Real players will have higher variance.

---

## Recommendations

1. **Decide whether speed should matter for landing.** This is a game design decision, not a bug fix. Speed thresholds were created but never worked. The game was playable and enjoyable without them. Enforcing them changes the fundamental challenge.

2. **If speed should matter:** Use Option C (post-thrust tracking) with thresholds validated through device testing. Consider starting with generous thresholds (V<60, H<40) and tightening over time.

3. **If speed should not matter:** Revert to Option A (post-collision values) for the threshold check. Use pre-contact tracked values only for display. Accept that the display may show values above the "safe" range while the landing succeeds (which is arguably honest — "you landed despite high speed").

4. **Regardless of the above:** Fix the HUD threshold mismatch immediately. Whatever values are authoritative must appear in all locations.

5. **Add an integration test** for the landing decision, even if it requires a mock or a simplified physics simulation. The fact that 65 tests passed while the core gameplay loop was broken demonstrates a critical gap in test coverage.

6. **Reconsider existing high scores.** If threshold enforcement changes what scores are achievable, existing high scores may be unreproducible. This could be acceptable (scores are local-only) or problematic (if players notice their old scores are impossible to beat).

---

## Files Referenced

| File | Lines | Role |
|------|-------|------|
| `RocketLander/GameScene.swift` | 66-69, 260-283, 286-311, 328-374, 491-557 | Authoritative thresholds, velocity tracking, thrust, collision, checkLanding |
| `RocketLander/Views/HUDViews.swift` | 82-84, 211, 227-236, 246-252 | HUD display thresholds (WRONG), color logic |
| `RocketLander/Views/GameOverView.swift` | 11-13 | Flight Data thresholds (correct) |
| `RocketLander/Models/LandingMessages.swift` | 87-90, 106-121 | Crash diagnostic thresholds (correct) |
| `RocketLander/GameScene+Scoring.swift` | 6-54 | Scoring formula (receives velocities from checkLanding) |
| `RocketLanderTests/ScoringHelper.swift` | 10-13 | Test scoring replica thresholds |
| `RocketLanderTests/ScoringTests.swift` | 1-186 | Scoring tests (no integration tests) |
| `RocketLanderTests/CrashDiagnosticTests.swift` | 1-166 | Crash message tests (no physics) |
| `Scripts/calculate_perfect_scores.py` | 54-57, 363 | Simulation thresholds and landing gate |
| `DECISIONS.md` | Lines 256-263 | "Single Authoritative Telemetry Snapshot" decision |
| `Docs/chats/2026-02-01_session33_v203_bug_fixes.md` | Full file | Session that introduced the tracking changes |

---

## Appendix: Exact Code Paths

### Build 17 (and all prior builds) — Speed Never Enforced

```
Player approaches platform at V=60
  → SpriteKit collision resolution: V=60 → V≈0 (impact absorbed)
  → didBegin(contact:) called
  → checkLanding() reads rocket.physicsBody?.velocity → V≈0
  → V≈0 <= 40? YES ← threshold passes despite V=60 approach
  → Landing accepted
  → calculateScore() receives V≈0 → near-maximum speed scores
```

### Build 19 (current) — Speed Enforced But Too Strict

```
Player thrusting to decelerate, actual post-thrust V=35
  → update() line 272: tracks V before thrust → lastTrackedVerticalSpeed = 47
  → update() line 286: applies thrust → actual V becomes 35
  → SpriteKit collision resolution
  → didBegin(contact:) called
  → checkLanding() reads lastTrackedVerticalSpeed → V=47
  → V=47 <= 40? NO ← threshold fails despite safe landing
  → Crash triggered
  → HUD shows V<50, was showing "OK" → player confusion
```

### Proposed Fix (Option C) — Speed Enforced Correctly

```
Player thrusting to decelerate, actual post-thrust V=35
  → update() line 286: applies thrust → actual V becomes 35
  → update() line 374: campaign mechanics applied
  → update() NEW location: tracks V after all inputs → lastTrackedVerticalSpeed = 35
  → SpriteKit collision resolution
  → didBegin(contact:) called
  → checkLanding() reads lastTrackedVerticalSpeed → V=35
  → V=35 <= 40? YES ← threshold passes correctly
  → Landing accepted
  → calculateScore() receives V=35 → reduced but fair speed scores
```

---

*This document should be reviewed by the development team before any code changes are made. The resolution involves a game design decision (should speed matter?) that affects the entire player experience, scoring system, and existing high scores.*
