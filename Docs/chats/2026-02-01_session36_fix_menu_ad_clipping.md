# 2026-02-01 — Session 36: Fix Menu Ad Banner Clipping + Build 22 Upload

## Goals
- Fix the banner ad on the menu screen being clipped by the home indicator safe area on iPhones without a home button
- Correct stale documentation that incorrectly described velocity threshold enforcement as "pending"
- Upload Build 22 to TestFlight with all v2.0.3 changes including menu ad fix

## Changes Made

### 1. Menu Ad Banner Bottom Padding
**What:** Added `.padding(.bottom, 16)` to `BannerAdContainer()` in `MenuView`
**Why:** The banner ad was the last item in the ScrollView's VStack with no bottom padding. When scrolled to the bottom on iPhones without a home button, the ad sat right at the safe area boundary and was clipped by the home indicator. Only the top edge of the ad was visible (confirmed in `Screenshots/v2.0.3-bugs/bug6_menu_ad_banner_clipped.png`).
**Files:** `RocketLander/ContentView.swift` (line 260)

**Technical detail:** `GameContainerView.swift` already had `.padding(.bottom, 5)` on its `BannerAdContainer()`. The menu needs more clearance (16pt) because the ScrollView allows the user to scroll the ad right to the safe area edge, while the gameplay view has a fixed layout.

### 2. Documentation Corrections — Velocity Threshold Enforcement Is RESOLVED
**What:** Fixed all documentation that incorrectly described the velocity threshold enforcement design decision as "PENDING."
**Why:** Session 35 (commit `1698220`, Build 21) implemented the full velocity threshold enforcement system:
- `checkLanding()` was rewritten to use `LandingThresholds.evaluate()` with per-platform SAFE/HARD/FAIL bands
- Velocity tracking was moved to post-thrust position (fixing the Build 19 "too strict" problem)
- Old hardcoded constants (V<40/H<25) were removed
- HUD was updated to show Platform C safe values (V<35, H<30)

However, session 35's documentation incorrectly stated "this session's changes only affect the scoring formula, not the landing pass/fail check" — the actual git diff proves `checkLanding()` was rewritten in that same commit. This error propagated to DECISIONS.md, STATUS.md, and PROJECT_LOG.md.

**Files corrected:**
- `DECISIONS.md` — changed "PENDING" entry to "RESOLVED" with full implementation details
- `STATUS.md` — removed all "pending design decision" references, updated Current Version, Current Phase, Immediate Next Tasks, Known Risks
- `PROJECT_LOG.md` — updated v2.0.3 status row and NEXT STEPS
- `CHANGELOG.md` — updated Per-Platform Speed Bands entry to include threshold enforcement

### 3. Build 22 Uploaded to TestFlight
**What:** Bumped build number 21 → 22, archived, exported, and uploaded to App Store Connect.
**Why:** Build 21 on TestFlight did not include the menu ad banner clipping fix (committed after Build 21 upload). Build 22 includes all v2.0.3 changes: scoring overhaul, threshold enforcement, AND the menu ad fix.
**Files:** `RocketLander/Info.plist` (build number 21 → 22)

## Research / Ideas Discussed
- Deep dive through all code and documentation confirmed velocity threshold enforcement IS implemented in current code
- `GameScene.swift` lines 504-554: `checkLanding()` uses `LandingThresholds.evaluate()` — speed exceeding FAIL threshold causes crash
- `GameScene.swift` lines 345-368: tracking happens post-thrust, post-rotation, post-mechanics
- `LandingThresholds.swift` lines 84-111: `evaluate()` classifies speeds and returns success/fail
- All consumers (scoring, HUD, GameOverView, LandingMessages) use `LandingThresholds`

## Technical Notes
- The VStack containing the ad only had `.padding(.horizontal)` (line 262), no vertical padding after the last item
- 16pt provides comfortable clearance for the home indicator when fully scrolled
- The documentation error in session 35 likely occurred because the session was framed as a "scoring overhaul" — the threshold enforcement changes were part of the same commit but weren't called out separately
- dSYM warnings during upload (GoogleMobileAds, UserMessagingPlatform) are known and harmless — third-party SDK symbols

## Decisions
1. Used 16pt bottom padding (vs 5pt in gameplay view) because ScrollView behavior requires more clearance at the bottom edge
2. Corrected all stale documentation — velocity threshold enforcement is RESOLVED, not pending

## Definition of Done
- [x] Banner ad fully visible when scrolled to bottom on iPhone 16 Pro simulator
- [x] Build succeeds
- [x] 90/90 tests pass
- [x] All stale "pending" references corrected across DECISIONS.md, STATUS.md, PROJECT_LOG.md, CHANGELOG.md
- [x] Build 22 archived, exported, and uploaded to TestFlight
- [x] All docs updated with accurate build info (Build 22 = Build 21 + menu ad fix)
- [x] Session summary created

## Commits
- `3356fc3` — Fix menu ad banner clipped by home indicator safe area
- `f6f114b` — Documentation updates + session summary
- `71fc211` — Update session 36 summary with commit hash
- `5051587` — Correct stale docs: velocity threshold enforcement is resolved, not pending
- `a36bbb9` — Fix docs: menu ad fix is on main, not in Build 21 on TestFlight
- `7e22dd5` — Build 22 uploaded to TestFlight — includes menu ad clipping fix
- `65bdf7f` — Update session 36 summary with Build 22 commit hash
- `58f646a` — Final session 36 summary — add missing commit hash
- `5a51222` — Update README landing thresholds + version history for v2.0.3
- `d02b07b` — Add mandatory documentation sweep checklist to CLAUDE.md

## Repo Housekeeping
- [x] Working tree clean (no stale untracked files)
- [x] .gitignore up to date
- [x] README.md project structure matches actual files
- [x] No secrets or credentials in tracked files

## Next Actions
- [ ] Device test Build 22 on TestFlight (scoring feel, HARD landing scores, threshold enforcement, menu ad fix)
- [ ] Wait for App Store review response for v2.0.2
- [ ] If approved, decide whether to submit v2.0.3 (Build 22) or wait for v2.1.0
- [ ] Implement v2.1.0 (Community): Game Center leaderboards, achievements, Share Score Card
