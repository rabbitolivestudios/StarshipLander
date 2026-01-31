# STATUS.md — Starship Lander

> **This file is the authoritative, compressed snapshot of the project.**
> Chat logs are historical input. This file defines current truth.
> Last reconciled: 2026-01-31

---

## Project Snapshot

| Field | Value |
|-------|-------|
| App | Starship Lander |
| Bundle ID | com.tboliveira.StarshipLander |
| Platform | iOS (iPhone), iOS 15.0+ |
| Tech | SwiftUI + SpriteKit + CoreMotion |
| Current Version | 2.0.0 (Build 12) |
| Version Status | **SUBMITTED FOR APP STORE REVIEW** (2026-01-30) |
| Last Published | v1.1.5 (Build 11) — on App Store |
| Developer | Thiago Borges de Oliveira / Rabbit Olive Studios |
| Team ID | 6XK6BNVURL |
| Repo | github.com/rabbitolivestudios/StarshipLander |

---

## What Is Done

These features are fully implemented, build-verified, and included in the v2.0.0 submission:

- **Classic Mode**: Single-level arcade gameplay with gravity 2.0, thrust 12.0
- **Campaign Mode**: 10 levels (Moon, Mars, Titan, Europa, Earth, Venus, Mercury, Ganymede, Io, Jupiter) with progressive difficulty
- **Per-Planet Physics**: Unique gravity (1.6-4.8) and thrust (8.0-18.5) per level
- **Three Landing Platforms**: Training Zone (1x), Precision Target (2x), Elite Landing (5x) per level
- **Visual Effects**: Wind streaks, atmosphere haze, ice shimmer, heat distortion, volcanic eruptions
- **Level Mechanics**: Wind, dense atmosphere, ice surfaces, moving platforms, turbulence, deep craters, extreme wind
- **Star Rating**: 1-3 stars per landing based on platform (30 total)
- **Scoring**: Continuous scoring with fuel (1.0-2.5x) and platform (1x/2x/5x) multipliers, max 25,000
- **Haptic Feedback**: Thrust, rotation, landing, crash
- **Dual Controls**: Button and accelerometer (tilt) modes
- **Landing Messages**: Contextual success/crash feedback with teaching tips
- **Per-Level High Scores**: Top-3 stored per campaign level, top-3 global for classic
- **Astronaut Easter Eggs**: Default leaderboard entries (Armstrong, Aldrin, etc.)
- **Ganymede Craters**: Rock pillar obstacles with collision physics
- **AdMob**: Banner ads on menu and gameplay, ATT prompt on first launch
- **16-Bit Sound Effects**: Thrust, rotation, landing, crash audio
- **App Store Screenshots**: 10 screenshots at 1284x2778, uploaded
- **Codebase**: Split from 2 monolithic files into 21 organized files
- **Project Management**: CLAUDE.md, PR template, DECISIONS.md, session logging workflow

---

## What Is NOT Done

These are **not implemented**. Do not assume otherwise:

- **Game Center integration** — not started
- **In-App Purchases (IAP)** — not started
- **Campaign per-level leaderboard viewing** — top-3 scores stored but only #1 visible on level cards (backlog)
- **iPad support** — iPhone only
- **Landscape orientation** — portrait only
- **Localization** — English only
- **Automated testing** — no unit or UI tests
- **CI/CD pipeline** — no GitHub Actions or automated builds
- **Device playtesting of v2.0.0** — tested on simulator only; haptics, accelerometer, and ads unverified on device
- **v2.0.0 App Store approval** — submitted, not yet approved

---

## Current Phase / Focus

**Phase: Release — Awaiting App Store Review**

v2.0.0 (Build 12) was submitted to App Store Connect on 2026-01-30. No code changes are in progress. The project is in a holding state pending Apple's review response.

---

## Immediate Next Tasks (ordered)

1. Wait for App Store review response for v2.0.0
2. If rejected: address feedback, fix, resubmit
3. If approved: verify live listing (screenshots, description, metadata)
4. Plan v2.0.1: campaign per-level high scores display (backlog item)
5. Device playtesting: haptics, accelerometer, ads on physical iPhone

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

- **v2.0.0 not yet approved** — Apple may reject. Common risks: ad compliance, screenshot accuracy, privacy declarations
- **v1.1.5 is the current live version** — published on App Store (Build 11)
- **No device testing for v2.0.0** — haptics, accelerometer controls, and ad loading are unverified on physical hardware
- **App Store description limit** — App Store Connect enforced a ~2,222 character limit (not the documented 4,000)
- **Git HTTP/2 broken pipe** — large pushes require `git config http.version HTTP/1.1`

---

## Ownership

- **Developer**: Thiago Borges de Oliveira
- **Studio**: Rabbit Olive Studios
- **AI Copilot**: Claude Code (Opus 4.5)
- **Repository**: github.com/rabbitolivestudios/StarshipLander
