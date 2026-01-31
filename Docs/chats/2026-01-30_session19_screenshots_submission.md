# 2026-01-30 — Session 19: App Store Screenshots, Submission, Project Guidelines

## Goals
- Capture App Store screenshots for v2.0.0 (iPhone 16 Pro)
- Write detailed release notes for v2.0.0
- Resize screenshots to App Store Connect required dimensions
- Draft App Store description and "What's New" text
- Submit v2.0.0 for App Store review
- Establish project management guidelines for Claude Code session continuity

## Changes Made

### 1. App Store Screenshots
**What:** Captured 10 screenshots from the iPhone 16 Pro simulator covering all major game screens.
**Why:** v2.0.0 introduces campaign mode, new platforms, and visual effects — screenshots needed to showcase the new features.
**Location:** `Screenshots/v2.0.0/`

| # | File | Content |
|---|------|---------|
| 1 | `01_main_menu.png` | Main menu with TOP PILOTS leaderboard, Classic/Campaign buttons, 9/30 stars |
| 2 | `02_classic_gameplay.png` | Classic mode — rocket mid-flight at 59% fuel, tilted, three platforms below |
| 3 | `03_campaign_level_select.png` | Campaign grid — all 10 levels with gravity, mechanics, stars, best scores |
| 4 | `04_campaign_titan.png` | Titan — dense atmosphere haze, Saturn in background, high horizontal velocity |
| 5 | `05_campaign_ganymede.png` | Ganymede — rock pillar obstacles, crater terrain, Jupiter in background |
| 6 | `06_campaign_venus_crash.png` | Venus crash — "DESCENT UNSTABLE" game over with teaching tip |
| 7 | `07_campaign_earth.png` | Earth — moving platforms, high vertical velocity (60, marked HIGH) |
| 8 | `08_campaign_jupiter.png` | Jupiter — rocket firing thrust with visible flame, Great Red Spot |
| 9 | `09_campaign_io.png` | Io — volcanic eruption particles, rocket thrusting |
| 10 | `10_landing_success.png` | Europa — "CONTROLLED DESCENT" success, 1 star, NEW HIGH SCORE entry |

Screenshots captured with clean status bar override (9:41, full battery, full signal).

### 2. Screenshot Dimension Fix
**What:** Resized all screenshots from 1206×2622 (iPhone 16 Pro native) to 1284×2778 (iPhone 6.7" Pro Max).
**Why:** App Store Connect requires specific dimensions: 1284×2778px for iPhone 6.7" display class. Native iPhone 16 Pro resolution (1206×2622) was rejected.
**Tool:** `sips -z 2778 1284`

### 3. Detailed Release Notes
**What:** Expanded RELEASE_NOTES.md v2.0.0 section from ~30 lines to ~170 lines with comprehensive feature documentation.
**Why:** Major version update needs thorough documentation for internal reference and App Store submission.
**Sections added:**
- Overview paragraph
- Campaign Mode with full level table (gravity, thrust, mechanics)
- Per-Planet Physics explanation
- Three Landing Platforms table (size, multiplier, color)
- Visual Effects per planet (detailed descriptions)
- Star Rating System, Scoring System with formula
- Per-Level High Scores, Landing Messages, Haptic Feedback
- Improved Controls, Astronaut Easter Eggs table
- Level Select Screen, Ganymede Deep Craters, Menu Redesign
- Game Over Screen, Bug Fixes with root cause
- Architecture (file split documentation)
- Updated App Store Release Notes copy block

### 4. App Store Text
**What:** Drafted promotional text (166 chars), description (897 chars), and "What's New" text for App Store Connect.
**Why:** Needed copy for all App Store Connect text fields for v2.0.0 submission.

**Promotional Text (170 char limit):**
```
NEW: Campaign Mode! Land across 10 solar system worlds — Moon to Jupiter. Unique gravity, visual effects, and 3 landing platforms per level. Score up to 25,000 points!
```

**Description (under 2,222 chars):**
```
Land the Starship on the platform - if you can.

A physics-based landing game inspired by SpaceX. Control thrust and rotation to guide your rocket to a safe touchdown.

CAMPAIGN MODE
10 solar system destinations from Moon to Jupiter. Each world has unique gravity, engine thrust, and hazards - wind storms, dense atmosphere, ice surfaces, moving platforms, volcanic eruptions, and more.

THREE LANDING PLATFORMS
- Training Zone (1x) - wide and forgiving
- Precision Target (2x) - tighter landing
- Elite Landing (5x) - small platform, big reward

FEATURES
- Per-planet gravity and thrust physics
- Classic mode for quick arcade play
- 10-level campaign with progressive difficulty
- Star rating system (1-3 stars per landing)
- Score up to 25,000 points
- Haptic feedback
- Button or accelerometer controls
- Retro 16-bit sound effects
- Per-level high score leaderboards

Can you land on Jupiter?
```

### 5. App Store Submission
**What:** v2.0.0 (Build 12) submitted for App Store review.
**Status:** SUBMITTED FOR REVIEW as of 2026-01-30.

## Technical Notes
- **Screenshot capture method:** `xcrun simctl io "iPhone 16 Pro" screenshot <path>` with `xcrun simctl status_bar override` for clean status bar
- **Simulator interaction:** AppleScript `click at {x, y}` for navigation, but SpriteKit touch-hold (THRUST) required manual user interaction — AppleScript clicks don't translate to UITouch hold events
- **Git push issue:** HTTP/2 broken pipe error when pushing large screenshot commits (~18MB). Fixed by `git config http.version HTTP/1.1`.
- **App Store Connect dimension requirement:** iPhone 6.7" screenshots must be exactly 1284×2778px or 2778×1284px. iPhone 16 Pro native (1206×2622) is NOT accepted.

## Decisions
1. **Manual screenshot capture over automated:** Simulator touch-hold events can't be reliably scripted via AppleScript/CGEvent for SpriteKit games. User navigated the app manually while Claude captured via `xcrun simctl io` with 3-second countdown.
2. **1284×2778 over 1242×2688:** Both are accepted by App Store Connect. Used 1284×2778 (iPhone 6.7") as it's the newer standard.
3. **HTTP/1.1 for git push:** HTTP/2 fails with broken pipe on large payloads. Set `git config http.version HTTP/1.1` as workaround.

### 6. Project Management Guidelines (CLAUDE.md)
**What:** Created `CLAUDE.md` — persistent instructions automatically read by Claude Code at the start of every session.
**Why:** Sessions can expire or lose context. Need strict guidelines to ensure project continuity, consistent documentation, and clean development practices across sessions.
**Files:** `CLAUDE.md` (new, 357 lines)

Key sections:
- **Start of Session Checklist** — 10-step mandatory context restoration
- **Phase Discipline** — no mixing unrelated work phases in one commit
- **Definition of Done** — checklist before and after every task
- **Documentation Requirements** — mandatory updates per commit (CHANGELOG, PROJECT_LOG, RELEASE_NOTES, DECISIONS, README)
- **Cross-cutting rule** — version/ads/controls/privacy changes must update all related docs
- **Code Standards** — think-first process, no dead code, no breadcrumbs, monolith prevention
- **Testing Expectations** — simulator + device + edge cases, manual steps for ads/ATT
- **Privacy Guardrails** — must document data collection before adding SDKs
- **Change Summary** — mandatory output format after every task
- **Hard "Do Not" List** — 8 non-negotiable rules

Inspired by: [jessfraz/dotfiles AGENTS.md](https://github.com/jessfraz/dotfiles/blob/main/.codex/AGENTS.md) (quick obligations table, think-first process, no breadcrumbs, fix from first principles, search before pivoting) — adapted for iOS/Swift project context and session continuity needs.

### 7. GitHub PR Template
**What:** Created `.github/pull_request_template.md` — auto-fills every PR with a structured checklist.
**Why:** Enforces scope, build verification, regression safety, documentation, privacy, and testing checks on every pull request. Acts as a safety net for future contributions.
**Files:** `.github/pull_request_template.md` (new)

Checklist sections: Scope & Intent, Build & Run, Gameplay Regression Safety, Feature Acceptance Criteria, Documentation, Privacy/Compliance, Testing Notes, Risk Management, PR Summary.

## Decisions
1. **Manual screenshot capture over automated:** Simulator touch-hold events can't be reliably scripted via AppleScript/CGEvent for SpriteKit games. User navigated the app manually while Claude captured via `xcrun simctl io` with 3-second countdown.
2. **1284x2778 over 1242x2688:** Both are accepted by App Store Connect. Used 1284x2778 (iPhone 6.7") as it's the newer standard.
3. **HTTP/1.1 for git push:** HTTP/2 fails with broken pipe on large payloads. Set `git config http.version HTTP/1.1` as workaround.
4. **CLAUDE.md over AGENTS.md:** Claude Code natively reads `CLAUDE.md` from project root at session start. No extra configuration needed. More portable than `.codex/AGENTS.md` which is specific to Codex CLI.
5. **PR template in .github/:** GitHub auto-fills PR descriptions from `.github/pull_request_template.md`. Even as a solo developer, PRs serve as change records with attached discussions.

## Definition of Done
- [x] 10 screenshots captured and resized to 1284x2778
- [x] Screenshots uploaded to App Store Connect
- [x] Release notes expanded with full feature documentation
- [x] App Store description and "What's New" drafted
- [x] v2.0.0 submitted for App Store review
- [x] CLAUDE.md created with full project guidelines
- [x] PR template created at .github/pull_request_template.md
- [x] All documentation updated and committed

## Commits
- `098d2e4` — Add v2.0.0 App Store screenshots (iPhone 16 Pro)
- `3c385c8` — Expand v2.0.0 release notes with detailed feature documentation
- `878b148` — Resize screenshots to 1284x2778 for App Store Connect
- `14190f3` — Add session 19 chat summary
- `0cc2daf` — Add CLAUDE.md project guidelines and GitHub PR template

## Next Actions
- [ ] Wait for App Store review response
- [ ] If rejected, address feedback and resubmit
- [ ] If approved, verify live listing screenshots and description
- [ ] Follow CLAUDE.md guidelines in all future sessions
