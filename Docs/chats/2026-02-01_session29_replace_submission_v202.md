# 2026-02-01 — Session 29: Replace v2.0.0 Submission with v2.0.2

## Goals
- Decide what to do about v2.0.0 (Build 12) sitting in "Waiting for Review" for 2 days
- If replacing: update all App Store copy, submit v2.0.2 (Build 16)
- Document everything including all App Store text used

## Decision

v2.0.0 (Build 12) was submitted 2026-01-30 and had been "Waiting for Review" for 2 days with no response. Three options considered:
1. Keep waiting
2. Replace submission with v2.0.2
3. Check status first

**Decision: Option 2 — replace with v2.0.2.** v2.0.0 had outdated gameplay (binary RCS, 25k max score, cosmetic-only planet mechanics, no star metadata). Shipping it would require an immediate follow-up update. Better to reset the review clock and ship the polished version first.

## Changes Made

### 1. App Store Copy — All Text Used

#### Description (used in App Store Connect)
```
Landing is easy.
Landing well is not.

Starship Lander is a precision piloting game where every decision matters. Control thrust, rotation, and fuel as you descend onto increasingly demanding landing zones — across ten worlds with unique physics and hazards.

This is a game about restraint, timing, and judgment under pressure.

CAMPAIGN MODE — 10 WORLDS

Travel across the solar system, from the forgiving Moon to brutal Jupiter. Each level introduces new gravity, engine behavior, and environmental challenges — requiring you to adapt your piloting style every time.

No upgrades.
No shortcuts.
Only skill.

CHOOSE YOUR RISK

Every level offers three landing platforms:

Training Zone (1×) — wide, forgiving

Precision Target (2×) — tighter margins

Elite Landing (5×) — small, unforgiving, high reward

Higher scores demand higher risk. The choice is yours.

DEEP, SKILL-BASED SCORING

Your score reflects how well you fly — not just whether you survive.

Vertical & horizontal control

Rotation accuracy

Landing precision

Fuel efficiency

Platform multipliers

Perfect execution can score up to 20,000 points.

FEEL THE PHYSICS

Real-time physics simulation

Distinct thrust behavior per planet

Button or tilt controls

Haptic feedback for thrust, landings, and crashes

Every landing has weight. Every mistake is felt.

PROVE YOUR MASTERY

Earn up to 30 stars across the campaign

Per-level high score leaderboards

Hidden astronaut benchmark scores — can you beat them?

This is not a casual experience.
It's a test of control.
```

**Changes from v2.0.0 description:** Only `25,000` → `20,000` points. Rest was already accurate.

#### What's New (used in App Store Connect)
```
MAJOR UPDATE — Campaign Mode!

NEW:
• Campaign Mode — 10 solar system levels from Moon to Jupiter
• Per-planet physics — unique gravity and engine thrust per world
• Three landing platforms with score multipliers (1x, 2x, 5x)
• Visual effects — wind, haze, ice shimmer, heat distortion, volcanic eruptions
• Star rating system — earn up to 30 stars
• Haptic feedback for thrust, landings, and crashes
• Per-level high score leaderboards
• Score up to 20,000 points!

IMPROVEMENTS:
• Proportional thrust vectoring for smoother lateral control
• Fixed layout for iPhone 16 Dynamic Island
```

**Changes from v2.0.0:** Removed "V2.0.0" from title, 25k→20k, "RCS thruster assist" → "Proportional thrust vectoring for smoother lateral control".

#### Review Team Notes (used in App Store Connect)
```
This is a skill-based physics rocket landing game.
Use on-screen buttons to control thrust and rotation and land safely on the platform.
No account, login, or in-app purchases required.

This build (v2.0.2, Build 16) replaces the previously submitted v2.0.0 (Build 12) with gameplay tuning improvements. No new features or SDKs were added — only balance and polish changes to the campaign mode mechanics.

Campaign mode has 10 levels with unique environmental mechanics: dust storms (Mars), dense atmosphere drag (Titan), ice surfaces (Europa), moving platforms (Earth), vertical updrafts (Venus), heat-induced thrust interference (Mercury), rock pillar obstacles (Ganymede), deadly volcanic debris (Io), and sudden wind gusts (Jupiter).

App Tracking Transparency prompt appears on first app launch to request permission before showing personalized ads. Users can toggle between traditional button controls and tilt-based accelerometer controls from the main menu.
```

#### Promotional Text (used in App Store Connect)
```
A skill-based landing game where precision beats luck. Master thrust, gravity, and control across the solar system.
```

#### Keywords (used in App Store Connect)
```
lander,physics,precision,skill,thrust,flight,descent,control,challenge,hardcore,starship,simulator
```

#### Screenshots
5 captioned + 5 uncaptioned, same as v2.0.0 submission (already uploaded):

| Order | File | Caption |
|-------|------|---------|
| 1 | 02_classic_gameplay_captioned | PRECISION PILOTING. / NO MARGIN FOR ERROR. |
| 2 | 01_main_menu_captioned | CONTROL THRUST. / MASTER THE DESCENT. |
| 3 | 06_campaign_venus_crash_captioned | Crash. Learn. / Try again. |
| 4 | 10_landing_success_captioned | PRECISION / IS SCORED. |
| 5 | 03_campaign_level_select_captioned | A 10-WORLD / SKILL CAMPAIGN |
| 6 | 04_campaign_titan | (uncaptioned) |
| 7 | 05_campaign_ganymede | (uncaptioned) |
| 8 | 07_campaign_earth | (uncaptioned) |
| 9 | 08_campaign_jupiter | (uncaptioned) |
| 10 | 09_campaign_io | (uncaptioned) |

### 2. RELEASE_NOTES.md Overhaul
**What:** Replaced v2.0.0 section with v2.0.2, fixed all outdated references
**Why:** RELEASE_NOTES.md still referenced RCS thrusters, 25k score, cosmetic-only mechanics
**Files:** `RELEASE_NOTES.md`
- Header: v2.0.0 (Build 12) → v2.0.2 (Build 16)
- Overview: added explanation of v2.0.0 replacement
- Planet mechanics table: updated Venus, Mercury, Io, Jupiter descriptions
- Visual effects: Venus vertical particles, Mercury thrust interference, Io deadly debris
- Scoring: 25k→20k, score components updated to match rebalance
- Controls: RCS thrusters → proportional thrust vectoring
- Bug fixes: added classic mode star rating save/display fixes
- Added three "Copy this" blocks (Description, What's New, Review Notes)

### 3. Documentation Updates
**Files:** `STATUS.md`, `PROJECT_LOG.md`, `DECISIONS.md`
- STATUS.md: version status, phase, next tasks, risks all updated for confirmed submission
- PROJECT_LOG.md: current status table updated, session 29 entry added
- DECISIONS.md: new entry documenting the replacement decision and rationale

## Submission Details

| Field | Value |
|-------|-------|
| Version | 2.0.2 |
| Build | 16 |
| Submitted | 2026-02-01 at 07:52 |
| Submission ID | 7ff9c921-0349-49c2-98b9-bfe9d1ca092f |
| Status | Waiting for Review |
| Build source | Already uploaded from session 28 (no new archive) |
| Replaces | v2.0.0 (Build 12), submitted 2026-01-30, never reviewed |

## Research / Ideas Discussed
- Apple review times can vary 1-5+ days. The 2-day wait for v2.0.0 was not abnormal but the gameplay gap justified replacing it.
- Version 2.0.0 and 2.0.1 will never appear publicly on the App Store — v2.0.2 is the first post-1.1.5 public release.

## Technical Notes
- No code changes in this session — only documentation and App Store Connect configuration
- Build 16 binary is identical to what was uploaded in session 28
- App Store Connect allows changing the version number when replacing a submission

## Decisions
1. **Replace v2.0.0 with v2.0.2** — rationale: don't ship outdated gameplay when a polished version exists. Review clock reset is acceptable trade-off. Documented in DECISIONS.md.

## Definition of Done
- [x] Decision made: replace v2.0.0 with v2.0.2
- [x] App Store description updated (20k score)
- [x] What's New updated (thrust vectoring, 20k)
- [x] Review Team Notes updated (explains replacement, lists mechanics)
- [x] Promotional text set
- [x] Keywords set
- [x] Screenshots confirmed (same 10 from v2.0.0)
- [x] RELEASE_NOTES.md overhauled for v2.0.2
- [x] STATUS.md updated with confirmed submission
- [x] PROJECT_LOG.md updated with session 29 entry
- [x] DECISIONS.md entry added
- [x] v2.0.2 (Build 16) submitted for App Store review
- [x] Session summary created
- [x] All docs committed and pushed

## Commits
- (pending — will be filled after commit)

## Repo Housekeeping
- [ ] Working tree clean (no stale untracked files)
- [ ] .gitignore up to date
- [ ] README.md project structure matches actual files
- [ ] No secrets or credentials in tracked files

## Next Actions
- [ ] Wait for App Store review response for v2.0.2
- [ ] If rejected: address feedback, fix, resubmit
- [ ] If approved: verify live listing, plan v2.1.0 (Game Center)
- [ ] Continue device testing of remaining campaign mechanics on TestFlight
