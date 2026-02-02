# 2026-02-01 — Session 34: Critical Discovery — Velocity Thresholds Never Enforced

## Goals
- Investigate Build 19 device testing failure (impossible to land on TestFlight)
- Perform deep root cause analysis tracing back through all builds
- Document findings for developer review

## Changes Made

### 1. Reverted Unauthorized Build 20 Commit
**What:** Reverted commit `4a676cc` (Build 20 with tracking order fix + HUD threshold fix) that was made without user approval.
**Why:** The commit violated CLAUDE.md guidelines — code was edited, committed, pushed, and archive started without any user discussion, planning, or approval.
**Files:** `git revert --no-edit 4a676cc` → created `f500a2b`

### 2. Comprehensive Diagnostic Report
**What:** Created `Docs/DIAGNOSTIC_velocity_thresholds.md` — a full diagnostic of the velocity threshold bug chain, intended for sharing with other developers.
**Why:** User requested a complete document covering all discoveries for external review before deciding on a fix.
**Files:** `Docs/DIAGNOSTIC_velocity_thresholds.md` (new)

### 3. Bug Evidence Screenshots Saved
**What:** Copied 3 device testing screenshots from user's external drive to project.
**Why:** Document Build 19 bugs for future reference.
**Files:** `Screenshots/v2.0.3-bugs/bug6_menu_ad_banner_clipped.png`, `bug7_classic_crash_vspeed50_hud_says_ok.png`, `bug8_campaign_crash_vspeed43_threshold_mismatch.png`

### 4. Project Management Documentation Updated
**What:** Updated STATUS.md, DECISIONS.md, CHANGELOG.md, PROJECT_LOG.md with critical bug findings.
**Why:** All project docs must reflect the current broken state of Build 19 and the pending design decision.
**Files:** `STATUS.md`, `DECISIONS.md`, `CHANGELOG.md`, `PROJECT_LOG.md`

## Critical Discoveries

### Discovery 1: Velocity Thresholds Were Dead Code Since Initial Commit
- `checkLanding()` has always read from `rocket.physicsBody?.velocity` inside `didBegin(contact:)`
- SpriteKit's collision resolution zeros velocities BEFORE this callback fires
- The V<40 and H<25 threshold checks always saw V≈0 → always auto-passed
- **Speed has never affected landing success in any build of the game**
- The only functional landing constraint was rotation (< 0.05 rad ≈ 2.9°)
- Confirmed by tracing code in initial commit `e8e9656`

### Discovery 2: Build 19 Was First-Ever Speed Enforcement, But Too Strict
- Build 19 changed `checkLanding()` to use `lastTrackedVerticalSpeed` (pre-contact tracked values)
- But tracking happens at line 272 of `update()`, BEFORE thrust is applied at line 286
- When player actively thrusts to decelerate, tracked value is ~10-15 units higher than actual post-thrust velocity
- Result: player decelerating to V=35 has tracked value of V=48 → fails V<40 check → impossible to land

### Discovery 3: HUD Threshold Mismatch Since Creation
- HUD shows `V<50 H<30 T<3°` (commit `fede844`)
- Actual GameScene thresholds: `V<40 H<25 T<3°` (since initial commit)
- Never caught because both display and threshold were wrong in compatible ways
- HUD said "OK" for any speed, threshold also passed for any speed → appeared consistent

### Discovery 4: Scoring Was Inflated in All Prior Builds
- Scoring formula received near-zero post-collision velocities → max speed component scores
- All existing player high scores achieved under "speed doesn't matter" regime
- If speed thresholds are properly enforced, achievable scores will decrease

### Discovery 5: Unit Tests Have No Integration Coverage
- 65 tests across 8 files all test isolated pure functions with manual inputs
- No test simulates a physics collision and verifies landing pass/fail decision
- Scoring simulation assumes thresholds work; no knowledge of SpriteKit collision behavior
- Device testing never specifically tested boundary velocities

## Research / Ideas Discussed
- SpriteKit physics cycle: `update()` → physics simulation (gravity, collision detection, collision resolution) → `didBegin(contact:)` callback
- Neither post-collision velocity (near zero, unreliable) nor pre-thrust tracked velocity (inflated) accurately represents the player's intended landing speed
- Post-thrust, pre-collision tracking (moving tracking to end of `update()`) would give accurate values but enforces speed for the first time — changing the game
- This is fundamentally a game design decision, not just a bug fix

## Technical Notes
- The Build 18 bug (V=71 landing accepted) and Build 19 bug (V=43 landing rejected) are manifestations of the same root cause: `checkLanding()` never had access to accurate velocity values
- SpriteKit's `SKPhysicsContact` is created internally and cannot be easily mocked in unit tests — this is why no integration test exists
- The Python scoring simulation correctly models post-thrust physics but has no model of SpriteKit's collision resolution behavior

## Decisions
1. **Reverted unauthorized Build 20** — code changes require user discussion and approval per CLAUDE.md
2. **Pending: Velocity threshold enforcement** — requires game design decision before any code fix. Options documented in `Docs/DIAGNOSTIC_velocity_thresholds.md` and `DECISIONS.md`

## Definition of Done
- [x] Root cause fully analyzed (3 iterations of deepening analysis)
- [x] Unauthorized Build 20 reverted
- [x] Diagnostic document created (`Docs/DIAGNOSTIC_velocity_thresholds.md`)
- [x] Bug evidence screenshots saved (3 new + 5 existing = 8 total)
- [x] All project management docs updated (STATUS, DECISIONS, CHANGELOG, PROJECT_LOG)
- [x] Session summary created
- [ ] Design decision made (deferred — user will review diagnostic with other developers)
- [ ] Fix implemented and tested (blocked on design decision)

## Commits
- `dde3215` — Fix session 33 summary: add missing final commit hash (start of session housekeeping)
- `f500a2b` — Revert "Fix velocity tracking order and HUD threshold mismatch (Build 20)" (reverted unauthorized changes)
- `758d625` — Session 34: diagnostic — velocity thresholds never enforced since initial commit

## Repo Housekeeping
- [x] Working tree clean after commit
- [x] .gitignore up to date
- [x] README.md project structure matches actual files (added DIAGNOSTIC doc)
- [x] No secrets or credentials in tracked files

## Next Actions
- [ ] Developer team reviews `Docs/DIAGNOSTIC_velocity_thresholds.md` and decides: should speed affect landing success?
- [ ] Implement fix based on design decision
- [ ] Fix HUD threshold mismatch (V<50→correct value, H<30→correct value)
- [ ] Fix menu ad banner clipping (cosmetic, File A)
- [ ] Add integration test for landing pass/fail decision
- [ ] Bump build, upload to TestFlight, device test
- [ ] Wait for App Store review response for v2.0.2
