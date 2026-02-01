# STATUS.md — Starship Lander

> **This file is the authoritative, compressed snapshot of the project.**
> Chat logs are historical input. This file defines current truth.
> Last reconciled: 2026-02-01 (Session 32)

---

## Project Snapshot

| Field | Value |
|-------|-------|
| App | Starship Lander |
| Bundle ID | com.tboliveira.StarshipLander |
| Platform | iOS (iPhone), iOS 15.0+ |
| Tech | SwiftUI + SpriteKit + CoreMotion |
| Current Version | 2.0.3 (Build 17) |
| Version Status | In development (v2.0.2 Build 16 submitted for App Store review) |
| Last Published | v1.1.5 (Build 11) — on App Store |
| Developer | Thiago Borges de Oliveira / Rabbit Olive Studios |
| Team ID | 6XK6BNVURL |
| Repo | github.com/rabbitolivestudios/StarshipLander |

---

## What Is Done

These features are fully implemented, build-verified, and included in v2.0.2:

- **Classic Mode**: Single-level arcade gameplay with gravity 2.0, thrust 12.0
- **Campaign Mode**: 10 levels (Moon, Mars, Titan, Europa, Earth, Venus, Mercury, Ganymede, Io, Jupiter) with progressive difficulty
- **Per-Planet Physics**: Unique gravity (1.6-4.8) and thrust (8.0-18.5) per level
- **Three Landing Platforms**: Training Zone (1x), Precision Target (2x), Elite Landing (5x) per level
- **Visual Effects**: Wind streaks, atmosphere haze, ice shimmer, heat distortion, volcanic eruptions
- **Level Mechanics**: Wind, dense atmosphere, ice surfaces, moving platforms, vertical updrafts (Venus), heat interference (Mercury), deep craters, deadly volcanic debris (Io), sudden gusts (Jupiter)
- **Star Rating**: 1-3 stars per landing based on platform (30 total)
- **Scoring**: Continuous scoring with fuel (1.0-2.0x) and platform (1x/2x/5x) multipliers, max 20,000. Center precision weighted highest (600pts).
- **Haptic Feedback**: Thrust, rotation, landing, crash
- **Dual Controls**: Button and accelerometer (tilt) modes
- **Landing Messages**: Contextual success feedback; deterministic cause-based crash diagnostics with actual failure values
- **HUD Tilt Display**: Real-time tilt angle in degrees with directional color coding (L/R)
- **Final Stats Panel**: Frozen flight data (tilt, speeds, fuel, center distance) on game-over screen
- **Campaign Reentry State**: Fixed 6.9° tilt + 15 pts/s drift on campaign start (prevents trivial thrust-only strategy)
- **Per-Level High Scores**: Top-3 stored per campaign level, top-3 global for classic
- **Dedicated Leaderboard Screen**: Tap "TOP PILOTS" to view classic + all campaign level scores
- **Astronaut Easter Eggs**: Default leaderboard entries (Armstrong, Aldrin, etc.)
- **Ganymede Craters**: Rock pillar obstacles with collision physics
- **AdMob**: Banner ads on menu and gameplay, ATT prompt on first launch
- **16-Bit Sound Effects**: Thrust, rotation, landing, crash audio
- **App Store Screenshots**: 10 screenshots at 1284x2778, uploaded
- **Unit Tests**: 65 XCTest cases across 8 test files (scoring formula, high scores, campaign state, level definitions, landing messages, game state, platform data, crash diagnostics)
- **Codebase**: Split from 2 monolithic files into 21 organized files
- **Project Management**: CLAUDE.md, PR template, DECISIONS.md, session logging workflow
- **Perfect Landing Score Analysis**: Frame-by-frame physics simulation computing maximum achievable scores for all 33 level/platform combinations, including campaign reentry state (tilt + drift). Best: Classic C = 12,132 (via left screen wrap). Script: `Scripts/calculate_perfect_scores.py`

---

## What Is NOT Done

These are **not implemented**. Do not assume otherwise:

- **Game Center integration** — planned for v2.1.0 (Community phase; research complete, decisions documented)
- **In-App Purchases (IAP)** — planned for v2.2.0 (Monetization phase; StoreKit 2 approach decided, decisions documented)
- ~~**Campaign per-level leaderboard viewing**~~ — **DONE in v2.0.1** (dedicated leaderboard screen)
- **iPad support** — iPhone only
- **Landscape orientation** — portrait only
- **Localization** — English only
- **Automated testing** — unit tests added (65 XCTest cases across 8 test files covering scoring, models, game state, crash diagnostics); no UI tests (XCUITest) yet
- **CI/CD pipeline** — no GitHub Actions or automated builds
- **Device playtesting partially done** — haptics + ads verified on device via TestFlight. Accelerometer bug fixed in v2.0.2. Classic mode star rating verified on Build 16. Remaining: thrust vectoring feel, Venus/Jupiter/Mercury/Io mechanics, scoring feel, backward-compat leaderboard stars.
- **v2.0.2 awaiting review** — submitted 2026-02-01, replacing v2.0.0 which was never reviewed

---

## Current Phase / Focus

**Phase: Campaign Engagement — v2.0.3, then v2.1.0 (Community)**

v2.0.2 (Build 16) submitted for App Store Review on 2026-02-01. v2.0.3 (Build 17) adds campaign engagement features: fixed reentry start state (tilt + drift), HUD tilt angle display, final stats panel, and deterministic crash messages. These features improve the gameplay feedback loop without changing physics or scoring. v2.1.0 planned: Game Center leaderboards + achievements, Share Score Card. v2.2.0 planned: Remove Ads IAP.

---

## Immediate Next Tasks (ordered)

1. Test v2.0.3 on simulator (reentry state, tilt HUD, final stats, crash diagnostics)
2. Wait for App Store review response for v2.0.2 (submitted 2026-02-01)
3. If approved: decide whether to submit v2.0.3 or wait for v2.1.0
4. Implement v2.1.0 (Community): Game Center leaderboards (11), achievements (10), Share Score Card
5. Implement v2.2.0 (Monetization): Remove Ads IAP (StoreKit 2)
6. Device playtesting: v2.0.3 campaign reentry + feedback features on TestFlight

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
4. Read latest file in `Docs/chats/` — detailed context from last session
5. Run `git log --oneline -10` — verify recent commits
6. Ask the user what to work on
7. Define "done checklist" before writing code

---

## Known Risks / Watchouts

- **v2.0.0 never reviewed** — submitted 2026-01-30, still "Waiting for Review" on 2026-02-01. Decision: replace with v2.0.2 (Build 16) to avoid shipping outdated gameplay
- **v1.1.5 is the current live version** — published on App Store (Build 11)
- **Device testing in progress** — TestFlight Build 16 (v2.0.2) is latest. Haptics and ads verified working. Accelerometer fixed. Classic mode star rating verified on device. Remaining device tests: thrust vectoring feel (both control modes), Venus updrafts, Jupiter gusts, Mercury heat interference, Io deadly debris, scoring feel, backward-compat leaderboard stars.
- **App Store description limit** — App Store Connect enforced a ~2,222 character limit (not the documented 4,000)
- **Git HTTP/2 broken pipe** — large pushes require `git config http.version HTTP/1.1`

---

## Ownership

- **Developer**: Thiago Borges de Oliveira
- **Studio**: Rabbit Olive Studios
- **AI Copilot**: Claude Code (Opus 4.5)
- **Repository**: github.com/rabbitolivestudios/StarshipLander
