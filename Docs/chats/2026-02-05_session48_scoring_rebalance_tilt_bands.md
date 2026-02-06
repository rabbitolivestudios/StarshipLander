# 2026-02-05 — Session 48: Scoring Rebalance + Tilt Bands + v2.0.3 Submission

## Goals
- Address low score feedback (rarely >5,000) with comprehensive scoring improvements
- Add tilt bands (SAFE/HARD/FAIL) matching speed band philosophy
- Upload to TestFlight and submit v2.0.3 for App Store review

## Changes Made

### 1. Scoring Formula Overhaul
**What:** Four-part hybrid scoring improvement: velocity scoring denominator changed from safe to hard threshold (smooth curve with HARD partial credit), component boost (Soft Landing 500→550, Horizontal 400→450, subtotal 2000→2100), fuel multiplier widened (1.0-2.0x → 1.0-2.2x), fuel consumption reduced (thrust 0.30→0.27%, rotation 0.08→0.07%, accelerometer 0.04→0.035×tilt).
**Why:** Quadratic penalty curve zeroed velocity components in HARD band. Tighter thresholds from Session 46 compressed scoring range. Fuel multiplier too narrow.
**Files:** `GameScene+Scoring.swift`, `GameScene.swift`, `ScoringHelper.swift`, `ScoringTests.swift`, `HowToPlayView.swift`, `calculate_perfect_scores.py`

### 2. Tilt Bands
**What:** Tilt changed from binary pass/fail (0.05 rad/~2.9°) to three bands: SAFE ≤0.05 rad (~2.9°), HARD ≤0.10 rad (~5.7°), FAIL >0.10 rad. Tilt band participates in overall landing band (worst of V/H/tilt wins). Rotation scoring uses hardTilt as denominator. HUD shows green/yellow/red. Crash message updated to "Land under 6°".
**Why:** Binary 2.9° gate was too strict and inconsistent with 3-band speed system. Campaign ships spawn at 6.9° tilt — narrow safe zone was punishing.
**Files:** `LandingThresholds.swift`, `GameScene+Scoring.swift`, `ScoringHelper.swift`, `GameOverView.swift`, `HUDViews.swift`, `LandingMessages.swift`, `HowToPlayView.swift`, `LandingEvaluationTests.swift`, `CrashDiagnosticTests.swift`, `calculate_perfect_scores.py`

### 3. Build 29 + Build 30 TestFlight Uploads
**What:** Build 29 uploaded with scoring rebalance. Build 30 uploaded with tilt bands added.
**Files:** `Info.plist`

### 4. v2.0.3 Build 30 Submitted for App Store Review
**What:** Finalized What's New text, review notes, and promotional text. Submitted via App Store Connect on 2026-02-06.
**Files:** `RELEASE_NOTES.md`

## Research / Ideas Discussed
- Initial two-segment scoring formula (safe curve + HARD partial credit at 25%) created a discontinuity where HARD scored HIGHER than SAFE at the boundary. Fixed by using single smooth curve with hard threshold as denominator.
- App Store description still says "up to 20,000 points" — kept as-is (rounder number). Actual max is 23,100.

## Technical Notes
- Test count: 89 → 91 (net +2 from splitting 2 binary rotation tests into 4 tilt band tests + 1 classification test, minus 2 old tests)
- Perfect score best: Classic C = 14,504 (was 14,331 before tilt bands — slight increase because rotation scoring denominator widened from 0.05 to 0.10)
- `XCTAssertEqual` with `accuracy` parameter doesn't work on Int — had to remove it
- dSYM warnings for GoogleMobileAds/UserMessagingPlatform on every upload (harmless)

## Decisions
1. Velocity scoring uses hard threshold as denominator (not safe) — creates single smooth curve, no discontinuity
2. Tilt bands match speed band philosophy: SAFE/HARD/FAIL instead of binary pass/fail
3. App Store description kept at "20,000 points" despite actual max being 23,100
4. Review notes kept concise matching v2.0.2 format (not detailed test steps)

## Definition of Done
- [x] Scoring formula overhauled — HARD partial credit, component boost, fuel tuning
- [x] Fuel consumption reduced
- [x] Tilt bands implemented across all files
- [x] HUD shows green/yellow/red for tilt
- [x] Crash message updated to "Land under 6°"
- [x] HowToPlayView updated with all new values
- [x] Perfect score script updated — Best: Classic C = 14,504
- [x] All 91 tests pass
- [x] Build succeeds
- [x] Build 29 uploaded to TestFlight (scoring rebalance)
- [x] Build 30 uploaded to TestFlight (+ tilt bands)
- [x] v2.0.3 Build 30 submitted for App Store review
- [x] All documentation updated (CHANGELOG, STATUS, DECISIONS, PROJECT_LOG, README, RELEASE_NOTES)

## Commits
- `e1b2d61` — Rebalance scoring: HARD partial credit, component boost, fuel tuning
- `25cecde` — Bump build number to 29 for TestFlight upload
- `254bb30` — Add tilt bands (SAFE/HARD/FAIL) matching speed band philosophy
- `a906b72` — Bump build number to 30 for TestFlight upload
- `30ab29d` — Update docs for v2.0.3 Build 30 App Store submission
- `540de65` — Simplify v2.0.3 review notes
- `b70cdda` — Note v2.0.3 Build 30 submitted for review
- `de258bd` — Update all log files for v2.0.3 Build 30 submission

## Repo Housekeeping
- [x] Working tree clean (no stale untracked files)
- [x] .gitignore up to date
- [x] README.md project structure matches actual files
- [x] No secrets or credentials in tracked files

## Next Actions
- [ ] v2.0.3 Build 30 awaiting App Store review approval
- [ ] Begin v2.1.0 (Community phase): Game Center leaderboards (11), achievements (10), Share Score Card
- [ ] v2.2.0 (Monetization phase): Remove Ads IAP (StoreKit 2)
