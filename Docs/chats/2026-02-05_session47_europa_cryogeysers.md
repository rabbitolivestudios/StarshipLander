# 2026-02-05 — Session 47: Europa Cryogeysers

## Goals
- Replace Europa's punishing ice slide crash mechanic with cryogeyser eruptions
- Upload Build 28 to TestFlight for testing
- Update all documentation

## Changes Made

### 1. Europa Cryogeysers (replacing ice slide)
**What:** Replaced the ice slide instant-crash mechanic (H.Speed > 20 = "Slid off the ice!") with cryogeyser eruptions — intermittent force-based ice/water plumes that push the rocket upward.
**Why:** Build 27 device testing feedback: ice slide was too punishing with no skill-based counterplay. Cryogeysers create a timing/positioning challenge that's disruptive but survivable, inspired by real plumes detected by Hubble on Europa.
**Files:**
- `RocketLander/Models/LevelDefinition.swift` — `.iceSurface` → `.cryogeysers`, display name "Cryogeysers", description "Cryogeysers erupt from the ice — time your descent."
- `RocketLander/GameScene.swift` — Added geyser state properties (positions, active flags, timers, durations), `setupCryogeysers()` with 3 fixed positions + vent markers, `.cryogeysers` case in `applyCampaignMechanics()` with active/calm cycling and upward push force, removed ice slide crash check, added reset cleanup
- `RocketLander/GameScene+Effects.swift` — `createCryogeyserEffect()` with blue/white/cyan particle columns
- `RocketLanderTests/LevelDefinitionTests.swift` — `.iceSurface` → `.cryogeysers`

### 2. Build 28 TestFlight Upload
**What:** Bumped build number 27 → 28, archived, exported, and uploaded to TestFlight.
**Why:** New build for device testing of cryogeyser mechanic.
**Files:** `RocketLander/Info.plist`

## Technical Notes
- Geyser state properties had to be `var` (not `private var`) because the effects extension in `GameScene+Effects.swift` reads `geyserPositions` and `geyserActive` — `private` prevents cross-file extension access.
- Follows the Io volcanic eruption pattern (closest analog) but uses force-based disruption instead of deadly contact particles.
- Key tuning values: force=18.0, horizontal range=±30pt, plume height=180-480pt, active=2-3s, calm=3-5s, 3 geysers at 8%/34%/66% screen width.

## Decisions
1. **Cryogeysers over ice slide** — force-based disruption (survivable) over binary speed threshold (instant death). Documented in DECISIONS.md.

## Definition of Done
- [x] Ice slide crash check removed
- [x] `.iceSurface` renamed to `.cryogeysers` everywhere
- [x] 3 fixed geyser positions with staggered active/calm cycling
- [x] Upward push force when rocket is in plume zone
- [x] Blue/white/cyan particle columns during active phase
- [x] Vent markers on surface
- [x] Ice shimmer + low platform friction preserved
- [x] Europa description updated
- [x] Build succeeds, all 89 tests pass
- [x] Build 28 uploaded to TestFlight
- [x] Documentation updated (CHANGELOG, STATUS, DECISIONS, PROJECT_LOG, README)
- [x] Session summary created

## Commits
- `42d953f` — Replace Europa ice slide with cryogeyser eruptions
- `167a024` — Bump build number to 28 for TestFlight upload
- `28ed08b` — Add session 47 summary
- `155dade` — Fix stale ice surface references in comments and STATUS

## Repo Housekeeping
- [x] Working tree clean
- [x] .gitignore up to date
- [x] README.md project structure matches actual files
- [x] No secrets or credentials in tracked files

## Next Actions
- [ ] User tests Build 28 on device — verify cryogeyser visuals, force effect, and that landing with moderate H.Speed no longer crashes
- [ ] Verify Io eruptions still work (no regression)
- [ ] Tune geyser force/timing values if needed based on device testing
- [ ] Decide whether to submit v2.0.3 or continue to v2.1.0
