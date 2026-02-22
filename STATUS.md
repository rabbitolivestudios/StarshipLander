# STATUS.md — Starship Lander

> **This file is the authoritative, compressed snapshot of the project.**
> Chat logs are historical input. This file defines current truth.
> Last reconciled: 2026-02-21 (Session 61)

---

## Project Snapshot

| Field | Value |
|-------|-------|
| App | Starship Lander |
| Bundle ID | com.tboliveira.StarshipLander |
| Platform | iOS (iPhone), iOS 15.0+ |
| Tech | SwiftUI + SpriteKit + CoreMotion |
| Current Version | **v2.1.0 (Build 32) live on App Store** (approved 2026-02-06). v2.1.1 Build 33 submitted for review. |
| Version Status | **v2.1.0 Build 32 live on App Store** (approved 2026-02-06). **v2.1.1 Build 33 submitted for App Store review** (2026-02-06). **v2.2.0 Build 36** — menu layout redesign (icons moved to top-right, safeAreaInset for ad), uploaded to TestFlight. |
| Last Published | v2.1.0 (Build 32) — on App Store (approved 2026-02-06) |
| Developer | Thiago Borges de Oliveira / Rabbit Olive Studios |
| Team ID | 6XK6BNVURL |
| Repo | github.com/rabbitolivestudios/StarshipLander |

---

## What Is Done

These features are fully implemented, build-verified, and included in the current codebase:

**(Everything from v2.1.0 and prior — see previous STATUS.md entries)**

**v2.2.0 — New Features (code complete, not yet submitted):**

- **Daily Challenge System**: 75 rotating challenge templates with rich constraint types (target platform, max tilt, max V/H speed, min fuel, time limit). Deterministic `dayOfYear % 75` cycling. Same challenge worldwide. Auto-computed difficulty 1-5 stars based on planet gravity/hazards, constraint count/tightness, time pressure. Pre-challenge briefing screen (`DailyChallengeBriefingView`) showing objectives, planet info, difficulty, global today's best (from Game Center), local best, streak info, and blue star reward preview. Challenge evaluation with per-constraint pass/fail breakdown on game-over. Distinct challenge failure UX (orange warning icon, "LANDED — BUT CHALLENGE FAILED" message, sad trombone sound) when landing but missing challenge criteria. Countdown timer with time bonus scoring for timed challenges. Daily Challenge leaderboard on Game Center.
- **Blue Star Currency**: `BlueStarManager.swift` — singleton with UserDefaults persistence. Earn blue stars through: daily challenge completion (+1), 5-day streak bonus (+3), campaign star milestones (10→+10, 20→+50, 30→+150). Idempotent reward claiming. Displayed on menu and game-over screens.
- **Global Rank on Game-Over Screen**: Per-leaderboard rank displayed after each landing (`lastLeaderboardRank` in GameCenterManager). Fetches rank ~1s after score submission. Works for classic, campaign, and daily challenge modes.
- **Interstitial Ads**: `InterstitialAdManager.swift` — shows ad every 7th Retry/Next Level tap. Never blocks gameplay on ad failure. Test ID in DEBUG, production ID (`ca-app-pub-3801339388353505/8269147180`) in RELEASE. Video ads disabled in AdMob console (text/image only). Uses existing `topViewController()` for presentation.
- **Modernized Menu**: Sci-fi title typography (monospaced, wide tracking, gradient). Settings gear and How to Play icons in top-right bar (next to version label). Banner ad pinned via `.safeAreaInset(edge: .bottom)`. Settings moved to gear sheet. Blue star count on menu. Streak display.
- **How To Play Expanded**: Added Daily Challenge section (6 constraint types explained) and Blue Stars section (5 earning methods documented).
- **Elapsed Time Tracking**: `gameStartTime` in GameScene, `elapsedTime` in GameState. Used for time-limited daily challenges.

---

## What Is NOT Done

These are **not implemented**. Do not assume otherwise:

- ~~**Game Center integration**~~ — **PUBLISHED** in v2.1.0
- **v2.2.0 submission** — Build 35 with bug fixes, needs TestFlight testing and App Store submission
- **`daily_challenge` leaderboard in App Store Connect** — must create via ASC API or console before v2.2.0 App Store submission
- **In-App Purchases (IAP)** — deferred (was planned for v2.2.0 Monetization, replaced by interstitial ads + blue stars)
- **iPad support** — iPhone only
- **Landscape orientation** — portrait only
- **Localization** — English only
- **UI tests (XCUITest)** — no automated UI tests
- **CI/CD pipeline** — no GitHub Actions

---

## Current Phase / Focus

**Phase: Retention + Monetization (v2.2.0) — Build 36 on TestFlight**

v2.2.0 adds three pillars: (1) Daily Challenge system with 75 templates, auto-computed difficulty, countdown timer, and blue star rewards for daily retention, (2) Interstitial ads every 7 attempts for monetization, (3) Global rank on game-over for competition visibility. Menu modernized with sci-fi typography and pinned footer. How To Play updated. Challenge failure UX distinguishes "landed but failed challenge" from crashes. Build 35 fixed interstitial ad frequency/duration and multi-touch thrust stuck. Build 36 redesigned menu layout: settings/help icons moved to top-right bar, banner ad uses safeAreaInset for proper space reservation.

---

## Immediate Next Tasks (ordered)

1. **v2.2.0: Device testing of Build 36** — verify menu layout (icons at top-right, ad at bottom), interstitial cadence, thrust multi-touch, daily challenge flow, blue star rewards
3. **v2.2.0: Create `daily_challenge` leaderboard in ASC** — needed before App Store submission
4. **v2.2.0: Submit for App Store review** — after testing + ASC leaderboard setup
6. Implement event-driven share triggers per growth plan
7. Create 5 high-converting App Store screenshots per growth plan

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

- **v2.1.0 is the current live version** — approved 2026-02-06
- **v2.1.1 submitted for review** — share card redesign + GC fix
- **v2.2.0 Build 36 on TestFlight** — menu layout redesigned (icons at top-right, safeAreaInset for ad), needs device testing
- **`daily_challenge` leaderboard doesn't exist in ASC yet** — score submissions will silently fail until created
- **Blue star currency has no spending mechanism yet** — earn-only for now, spending TBD in future version
- **VPN blocks Game Center** — always disable VPN during GC testing
- **ASC draft deletion removes releases** — must re-run `--create-releases` if draft is deleted
- **TestFlight masks GC issues** — TestFlight can access draft GC resources, App Store builds cannot
- **Git HTTP/2 broken pipe** — large pushes require `git config http.version HTTP/1.1`

---

## Ownership

- **Developer**: Thiago Borges de Oliveira
- **Studio**: Rabbit Olive Studios
- **AI Copilot**: Claude Code (Opus 4.6)
- **Repository**: github.com/rabbitolivestudios/StarshipLander
