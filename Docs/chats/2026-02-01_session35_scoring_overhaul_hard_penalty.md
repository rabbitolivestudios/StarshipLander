# 2026-02-01 — Session 35: Scoring Overhaul — HARD Penalty Removal + Per-Platform Speed Bands

## Goals
- Remove the overly harsh 0.4× HARD landing penalty from the scoring formula
- Commit per-platform speed bands system (LandingThresholds.swift)
- Add scoring constraint tests (HARD-C > SAFE-B)
- Update and run the perfect landing score simulation
- Upload Build 21 to TestFlight
- Fully document all changes

## Changes Made

### 1. Per-Platform Speed Bands (LandingThresholds.swift)
**What:** New file establishing per-platform SAFE/HARD/FAIL speed thresholds as the single source of truth.
**Why:** Previous system used hardcoded values scattered across GameScene. Centralized thresholds enable consistent evaluation by scoring, landing checks, HUD, and tests.
**Files:** `RocketLander/Models/LandingThresholds.swift` (new), `RocketLanderTests/LandingEvaluationTests.swift` (new, 20 tests)

Platform thresholds:
| Platform | V Safe | V Hard | H Safe | H Hard |
|----------|--------|--------|--------|--------|
| A | ≤80 | ≤120 | ≤60 | ≤100 |
| B | ≤55 | ≤85 | ≤45 | ≤75 |
| C | ≤35 | ≤55 | ≤30 | ≤50 |

### 2. Removed Explicit HARD Landing Penalty
**What:** Removed `if speedBand == .hard { subtotal *= 0.4 }` from GameScene+Scoring.swift, ScoringHelper.swift, and calculate_perfect_scores.py.
**Why:** The 0.4× penalty was too severe. Combined with the natural velocity component loss (900/2000 pts = 45%), it produced a 78% total reduction and a scoring discontinuity (valley) at the SAFE/HARD boundary. Analysis showed the natural penalty alone is sufficient — HARD-C (subtotal 1100 × 5.0x = 5,500 at 0% fuel) beats perfect SAFE-B (2000 × 2.0x = 4,000) at all fuel levels.
**Files:** `RocketLander/GameScene+Scoring.swift`, `RocketLanderTests/ScoringHelper.swift`, `Scripts/calculate_perfect_scores.py`

### 3. New Scoring Constraint Tests
**What:** 5 new tests in ScoringTests.swift + renamed existing test.
**Why:** Verify the HARD-C > SAFE-B constraint, no scoring discontinuity, and approach speed component range.
**Files:** `RocketLanderTests/ScoringTests.swift`

New tests:
- `testHardLandingNaturalPenalty` — renamed from testHardLandingPenalty
- `testHardCBeatsSafeB` — at 5 fuel levels (0%, 25%, 50%, 75%, 100%)
- `testHardCBeatsSafeA` — at 5 fuel levels
- `testNoPenaltyDiscontinuity` — V=34 vs V=36 on C within 100 pts
- `testApproachSpeedImpact` — 0 vs max approach shows ~150 pt difference

### 4. Perfect Score Simulation Updated
**What:** Ran updated script with HARD penalty removed. All 33/33 optimal landings are in SAFE band.
**Why:** Provides achievement thresholds and validates the scoring system.
**Files:** `Scripts/calculate_perfect_scores.py`

Key results:
- Best: Classic C = 12,077 (30% fuel, left screen wrap)
- Worst: Europa A = 2,663 (43% fuel)
- All 33 optimal landings in SAFE band (HARD never optimal)
- 11/33 use left screen wrap (all Platform C)
- 0/33 off-center (center always optimal)

### 5. Build 21 Uploaded to TestFlight
**What:** Bumped build 19 → 21 (skipping 20 which was reverted), archived, exported, uploaded.
**Why:** For device testing of the scoring overhaul.
**Files:** `RocketLander/Info.plist`

### 6. Decision Documented
**What:** Added DECISIONS.md entry for HARD penalty removal.
**Why:** Per CLAUDE.md, scoring formula changes must be documented.
**Files:** `DECISIONS.md`

## Research / Ideas Discussed

### Scoring Valley Problem (from planning phase)
Any explicit HARD penalty multiplier creates a scoring discontinuity at the SAFE/HARD boundary. Analysis showed:
- At V=34 (just under SAFE on C): velocity components ≈ 0, subtotal ≈ 1,100
- At V=36 (just into HARD on C): velocity components = 0, subtotal = 1,100, then × penalty
- With 0.85× penalty: 1,451 pt valley
- With 0.90× penalty: 969 pt valley
- With 1.0× (none): 7 pt gap — essentially continuous

The recommendation was to remove the penalty entirely (1.0×), and this was implemented.

### HARD Landing Differentiation
Within the HARD band, velocity components are always 0. Score differentiation comes from:
- Center precision (600 pts)
- Rotation (250 pts)
- Approach speed (150 pts)
- Fuel remaining (1.0× to 2.0× multiplier)

This makes HARD landings about precision and control rather than speed — the right signal for players who exceeded safe speeds.

### Score Hierarchy (75% fuel, perfect center/rotation/approach)
| Scenario | Final Score |
|----------|-------------|
| Perfect SAFE-C | 17,500 |
| Good SAFE-C (V=10, H=5) | 14,289 |
| Borderline SAFE-C (V=34) | 9,632 |
| HARD-C (V=36+) | 9,625 |
| Perfect SAFE-B | 7,000 |
| Perfect SAFE-A | 3,500 |

## Technical Notes
- The `speedBand` parameter remains in the `calculateScore()` function signature — callers still pass it for UI/messaging purposes, but it no longer affects the score calculation.
- Build 20 was reverted in Session 34, so Build 21 skips that number.
- The dSYM warnings during TestFlight upload (GoogleMobileAds, UserMessagingPlatform) are harmless and known.
- Velocity threshold enforcement (whether speed affects landing success) is still a pending design decision from Session 34. This session's changes only affect the scoring formula, not the landing pass/fail check.

## Decisions
1. **Removed explicit HARD landing penalty (0.4× → 1.0×)** — natural velocity loss (45% of subtotal) IS the penalty. Creates continuous scoring curve, satisfies HARD-C > SAFE-B constraint.
2. **Per-platform scoring denominators** — velocity components use platform-specific safe thresholds as denominators (was already the case from the speed bands work; this session commits it).

## Definition of Done
- [x] HARD penalty removed from all 3 scoring implementations
- [x] Per-platform speed bands committed (LandingThresholds.swift + 20 tests)
- [x] 5 new scoring constraint tests pass
- [x] All 90/90 tests pass
- [x] Build succeeds
- [x] Build 21 uploaded to TestFlight
- [x] Perfect score simulation updated (33/33 SAFE, best 12,077)
- [x] DECISIONS.md entry added
- [x] CHANGELOG.md updated
- [x] STATUS.md updated
- [x] PROJECT_LOG.md updated
- [x] README.md project structure updated
- [x] Session summary created
- [x] Repo housekeeping complete

## Commits
- `1698220` — Scoring overhaul: per-platform speed bands + remove HARD penalty (Build 21)

## Repo Housekeeping
- [x] Working tree clean (all files tracked or committed)
- [x] .gitignore up to date
- [x] README.md project structure matches actual files (added LandingThresholds.swift, LandingEvaluationTests.swift)
- [x] No secrets or credentials in tracked files

## Next Actions
- [ ] Device test Build 21 on TestFlight (scoring feel, HARD landing behavior)
- [ ] Make game design decision: should speed affect landing success?
- [ ] Fix velocity threshold enforcement based on decision
- [ ] Fix HUD threshold display to match per-platform bands
- [ ] Fix menu ad banner clipping (cosmetic)
- [ ] Wait for App Store review response for v2.0.2
