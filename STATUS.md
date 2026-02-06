# STATUS.md — Starship Lander

> **This file is the authoritative, compressed snapshot of the project.**
> Chat logs are historical input. This file defines current truth.
> Last reconciled: 2026-02-06 (Session 52)

---

## Project Snapshot

| Field | Value |
|-------|-------|
| App | Starship Lander |
| Bundle ID | com.tboliveira.StarshipLander |
| Platform | iOS (iPhone), iOS 15.0+ |
| Tech | SwiftUI + SpriteKit + CoreMotion |
| Current Version | 2.0.3 (Build 30) — live on App Store. v2.1.0 Build 32 on TestFlight — device tested, ready for App Store submission. |
| Version Status | **v2.0.3 Build 30 live on App Store** (approved 2026-02-06). **v2.1.0 Build 32 submitted for review** — GC device-tested and verified. Leaderboard scores reset before submission. |
| Last Published | v2.0.3 (Build 30) — on App Store (approved 2026-02-06) |
| Developer | Thiago Borges de Oliveira / Rabbit Olive Studios |
| Team ID | 6XK6BNVURL |
| Repo | github.com/rabbitolivestudios/StarshipLander |

---

## What Is Done

These features are fully implemented, build-verified, and included in v2.0.3:

- **Classic Mode**: Single-level arcade gameplay with gravity 2.0, thrust 12.0
- **Campaign Mode**: 10 levels (Moon, Mars, Titan, Europa, Earth, Venus, Mercury, Ganymede, Io, Jupiter) with progressive difficulty
- **Per-Planet Physics**: Unique gravity (1.6-4.8) and thrust (8.0-18.5) per level
- **Three Landing Platforms**: Training Zone (1x), Precision Target (2x), Elite Landing (5x) per level
- **Visual Effects**: Wind streaks, atmosphere haze, ice shimmer, heat distortion, volcanic eruptions
- **Level Mechanics**: Wind, dense atmosphere, cryogeysers (Europa), moving platforms, vertical updrafts (Venus), heat interference (Mercury), deep craters, deadly volcanic debris (Io), sudden gusts (Jupiter)
- **Star Rating**: 1-3 stars per landing based on platform (30 total)
- **Scoring**: Continuous scoring with fuel (1.0-2.2x) and platform (1x/2x/5x) multipliers, max 23,100. Components: Base(100), Soft Landing(550), Horizontal(450), Center(600), Rotation(250), Approach(150) = 2,100 subtotal. Velocity scoring uses hard threshold as denominator — smooth curve with HARD landing partial credit. Fuel consumption: thrust 0.27%/frame, rotation 0.07%/frame.
- **Per-Platform Speed Bands + Threshold Enforcement**: `LandingThresholds.swift` — SAFE/HARD/FAIL classification per platform. Thresholds tightened in v2.0.3: Platform A (V≤70/H≤50 safe), B (V≤50/H≤40), C (V≤33/H≤28). Tilt bands: ≤2.9° safe, ≤5.7° hard, >5.7° crash. `checkLanding()` uses `LandingThresholds.evaluate()` with post-thrust tracked velocities — speed and tilt now affect landing success (FAIL = crash).
- **Partial Platform Landing Detection**: Both rocket legs (47pt span) must be within platform bounds. Landing with one leg hanging off causes crash ("Missed the platform!").
- **Level-Specific Mechanics Enhanced**: Europa cryogeysers (intermittent upward-pushing ice plumes, replacing ice slide crash), Titan thrust reduction (75% efficiency), Jupiter wind overhaul (left→right with stronger force, gravity 5.2), Mercury enhanced shimmer with rising heat particles.
- **Celestial Bodies**: All 10 levels show astronomically-correct bodies visible from landing location (Earth from Moon, Saturn with rings from Titan, Jupiter with bands from Europa/Ganymede/Io, Sun with glow/corona from Mercury/Venus/Mars, Moon with craters from Earth, Europa from Jupiter).
- **Haptic Feedback**: Thrust, rotation, landing, crash
- **Dual Controls**: Button and accelerometer (tilt) modes
- **Landing Messages**: Contextual success feedback; deterministic cause-based crash diagnostics with actual failure values
- **HUD Tilt Display**: Real-time tilt angle in degrees with directional color coding (L/R). HUD freezes to final snapshot values on game-over.
- **Final Stats Panel**: HUD-style Flight Data with SF Symbol icons, OK/HARD/FAIL badge pills, 3-color value system (green/yellow/red), gray dividers, centered header. "HARD LANDING" / "RAPID UNSCHEDULED DISASSEMBLY" badges. Uses pre-contact velocity tracking to capture touchdown speeds (not post-collision zeroed values).
- **Randomized Crash Headlines**: Pool of 20 crash messages replacing static "CRASH!" text. SpaceX references, space mission quotes, Kerbal vibes, dry humor. Randomized each game over.
- **Campaign Reentry State**: Fixed 6.9° tilt + 15 pts/s drift on campaign start (prevents trivial thrust-only strategy). Ship visually tilted at spawn.
- **Per-Level High Scores**: Top-3 stored per campaign level, top-3 global for classic
- **Dedicated Leaderboard Screen**: Tap "TOP PILOTS" to view classic + all campaign level scores
- **Astronaut Easter Eggs**: Default leaderboard entries (Armstrong, Aldrin, etc.)
- **Ganymede Craters**: Rock pillar obstacles with collision physics
- **AdMob**: Banner ads on menu and gameplay, ATT prompt on first launch
- **16-Bit Sound Effects**: Thrust, rotation, landing, crash audio
- **App Store Screenshots**: 10 screenshots at 1284x2778, uploaded
- **How to Play Info Sheet**: Rich game documentation accessible from menu — covers Controls, Landing Platforms, Speed Bands, Scoring formula, and Campaign (all 10 levels). Adapts to button/accelerometer setting.
- **Unit Tests**: 91 XCTest cases across 10 test files (scoring formula, high scores, campaign state, level definitions, landing messages, game state, platform data, crash diagnostics, landing evaluation, scoring helper)
- **Codebase**: Split from 2 monolithic files into 21 organized files
- **Game Center Integration (v2.1.0 code complete)**: `GameCenterManager.swift` — automatic auth with graceful fallback, 12 leaderboards (1 classic + 10 campaign + 1 galaxy_rank aggregate), 10 achievements (skill + progression), Galaxy Rank on menu/leaderboard/campaign screens, GKAccessPoint on menu, fire-and-forget score submission, idempotent achievement reporting, persistent tracking state (UserDefaults). Game Center entitlement added.
- **Share Score Card (v2.1.0 code complete)**: `ShareScoreCardView.swift` — SwiftUI-rendered dark gradient card with game logo, mode/level, stars, score, platform+band badge, flight data. `ShareHelper` with `ImageRenderer` (iOS 16+) / `UIHostingController` snapshot (iOS 15) rendering. Native share sheet via `UIActivityViewController`. Share button on game-over screen (landing only).
- **Project Management**: CLAUDE.md, PR template, DECISIONS.md, session logging workflow
- **Perfect Landing Score Analysis**: Frame-by-frame physics simulation computing maximum achievable scores for all 33 level/platform combinations, including campaign reentry state (tilt + drift). Best: Classic C = 14,504 (via left screen wrap). All 33/33 land in SAFE band. Tilt bands: SAFE ≤2.9°, HARD ≤5.7°, FAIL >5.7°. Script: `Scripts/calculate_perfect_scores.py`

---

## What Is NOT Done

These are **not implemented**. Do not assume otherwise:

- ~~**Game Center integration**~~ — **DEVICE TESTED** for v2.1.0. All 12 leaderboards visible, scores submitted (Moon 3,323 pts, Galaxy Rank 12,323 pts), Galaxy Rank #1, 10 achievements visible, GKAccessPoint working. Ready for App Store submission. Note: VPN blocks GC network traffic (root cause of initial "Sign in" issue in Session 52).
- **In-App Purchases (IAP)** — planned for v2.2.0 (Monetization phase; approach TBD — alternatives to be discussed)
- ~~**Campaign per-level leaderboard viewing**~~ — **DONE in v2.0.1** (dedicated leaderboard screen)
- **iPad support** — iPhone only
- **Landscape orientation** — portrait only
- **Localization** — English only
- **Automated testing** — unit tests added (91 XCTest cases across 10 test files covering scoring, models, game state, crash diagnostics, landing evaluation); no UI tests (XCUITest) yet
- **CI/CD pipeline** — no GitHub Actions or automated builds
- **Device playtesting partially done** — haptics + ads verified on device via TestFlight. Accelerometer bug fixed in v2.0.2. Classic mode star rating verified on Build 16. Remaining: thrust vectoring feel, Venus/Jupiter/Mercury/Io mechanics, scoring feel, backward-compat leaderboard stars.
- ~~**v2.0.2 awaiting review**~~ — **APPROVED** 2026-02-03
- ~~**v2.0.3 submitted for review**~~ — **APPROVED** 2026-02-06, live on App Store

---

## Current Phase / Focus

**Phase: Community (v2.1.0) — Submitted for App Store review**

v2.0.3 (Build 30) live on App Store. v2.1.0 Build 32 submitted for review (Session 52): All Game Center features device-verified — 12 leaderboards, score submission, Galaxy Rank, 10 achievements, GKAccessPoint. GC leaderboard scores reset before submission. App Store screenshot added (Galaxy Rank caption). v2.2.0 planned: Monetization (approach TBD).

---

## Immediate Next Tasks (ordered)

1. ~~v2.0.3 Build 30 submitted for App Store review~~ — **APPROVED** 2026-02-06, live on App Store
2. ~~Implement v2.1.0 (Community): Game Center leaderboards, achievements, Share Score Card~~ — **CODE COMPLETE** (Session 50)
3. ~~v2.1.0: Version bump to 2.1.0 Build 31~~ — **DONE** (Session 51, uploaded to TestFlight)
4. ~~v2.1.0: App Store Connect leaderboard/achievement setup~~ — **DONE** (Session 51, 12 leaderboards + 10 achievements created via API)
5. ~~v2.1.0: Fix GC auth — present authenticateHandler viewController~~ — **DONE** (Session 51, Build 32)
6. ~~v2.1.0: Device testing (GC auth, score submission, achievements, Galaxy Rank, share card)~~ — **DONE** (Session 52, all GC features verified)
7. ~~v2.1.0: App Store submission~~ — **SUBMITTED** (Session 52, Build 32)
8. Plan v2.2.0 (Monetization): approach TBD — will discuss alternatives

---

## Non-Negotiable Principles

- STATUS.md is the authoritative project snapshot. Chat logs are input, not truth.
- Every session must produce a chat summary in `Docs/chats/` — no exceptions.
- Documentation updates are mandatory in the same commit as code changes.
- No version bumps without explicit user approval.
- No new SDKs without documenting privacy impact first.
- Build must succeed before committing. No broken code on main.
- No mixing unrelated development phases in one commit.

---

## How to Resume Work

1. Read `CLAUDE.md` — full project guidelines and session checklist
2. Read `STATUS.md` (this file) — authoritative current state
3. Read `PROJECT_LOG.md` — latest session entry and backlog
4. Read the **project history summary** at the top of `PROJECT_LOG_ARCHIVE.md` — older session context
5. Read latest file in `Docs/chats/` — detailed context from last session
6. Run `git log --oneline -10` — verify recent commits
7. Ask the user what to work on
8. Define "done checklist" before writing code

---

## Known Risks / Watchouts

- **v2.0.3 is the current live version** — approved 2026-02-06, scoring rebalance + tilt bands + Europa cryogeysers now on App Store
- ~~**Build 30 submitted for review**~~ — **APPROVED** 2026-02-06. Historical context: `Docs/DIAGNOSTIC_velocity_thresholds.md`
- **Velocity thresholds were dead code before Build 21** — SpriteKit collision resolution zeroed velocities before `didBegin(contact:)` fired in all builds through Build 18. All prior high scores were achieved under "speed doesn't matter" regime. **RESOLVED in Build 21** with post-thrust tracking and per-platform FAIL thresholds.
- **HUD threshold mismatch RESOLVED** — HUD previously showed V<50 H<30 with actual thresholds V<40 H<25. **Fixed in Build 21** — HUD now reads from `LandingThresholds.platformC` (V<35, H<30).
- **Unit tests have no integration coverage** — 91 tests all test isolated pure functions. No test simulates a physics collision to verify landing pass/fail decision. This is the test that would have caught the bug.
- **Scoring rebalanced (Session 48)** — velocity components now use hard thresholds as denominator (smooth curve with HARD partial credit). Subtotal max 2,100, fuel mult 1.0-2.2x, theoretical max 23,100. Fuel consumption reduced. Prior high scores may be lower than new achievable scores.
- **Device testing in progress** — Haptics and ads verified. Accelerometer fixed. Game Center verified (Session 52). Remaining: thrust vectoring, Venus/Jupiter/Mercury/Io mechanics, scoring feel, backward-compat leaderboard stars, Share Score Card.
- **VPN blocks Game Center** — VPN (`utun4` interface) blocks DNS for GC data servers. Auth may succeed (cached) but leaderboard/dashboard fetches fail. GKGameCenterViewController shows misleading "Sign in to Game Center" fallback. Always disable VPN during GC testing.
- **App Store description limit** — App Store Connect enforced a ~2,222 character limit (not the documented 4,000)
- **Git HTTP/2 broken pipe** — large pushes require `git config http.version HTTP/1.1`

---

## Ownership

- **Developer**: Thiago Borges de Oliveira
- **Studio**: Rabbit Olive Studios
- **AI Copilot**: Claude Code (Opus 4.6)
- **Repository**: github.com/rabbitolivestudios/StarshipLander
