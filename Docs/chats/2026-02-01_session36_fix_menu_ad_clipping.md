# 2026-02-01 — Session 36: Fix Menu Ad Banner Clipping

## Goals
- Fix the banner ad on the menu screen being clipped by the home indicator safe area on iPhones without a home button

## Changes Made

### 1. Menu Ad Banner Bottom Padding
**What:** Added `.padding(.bottom, 16)` to `BannerAdContainer()` in `MenuView`
**Why:** The banner ad was the last item in the ScrollView's VStack with no bottom padding. When scrolled to the bottom on iPhones without a home button, the ad sat right at the safe area boundary and was clipped by the home indicator. Only the top edge of the ad was visible (confirmed in `Screenshots/v2.0.3-bugs/bug6_menu_ad_banner_clipped.png`).
**Files:** `RocketLander/ContentView.swift` (line 260)

**Technical detail:** `GameContainerView.swift` already had `.padding(.bottom, 5)` on its `BannerAdContainer()`. The menu needs more clearance (16pt) because the ScrollView allows the user to scroll the ad right to the safe area edge, while the gameplay view has a fixed layout.

## Research / Ideas Discussed
- None — straightforward one-line fix

## Technical Notes
- The VStack containing the ad only had `.padding(.horizontal)` (line 262), no vertical padding after the last item
- 16pt provides comfortable clearance for the home indicator when fully scrolled

## Decisions
1. Used 16pt bottom padding (vs 5pt in gameplay view) because ScrollView behavior requires more clearance at the bottom edge

## Definition of Done
- [x] Banner ad fully visible when scrolled to bottom on iPhone 16 Pro simulator
- [x] Build succeeds
- [x] 90/90 tests pass
- [x] CHANGELOG.md updated
- [x] STATUS.md updated
- [x] PROJECT_LOG.md updated
- [x] Session summary created

## Commits
- `3356fc3` — Fix menu ad banner clipped by home indicator safe area
- `_pending_` — Documentation updates + session summary

## Repo Housekeeping
- [x] Working tree clean (no stale untracked files)
- [x] .gitignore up to date
- [x] README.md project structure matches actual files
- [x] No secrets or credentials in tracked files

## Next Actions
- [ ] Game design decision: should speed affect landing success?
- [ ] Fix velocity threshold enforcement based on decision
- [ ] Fix HUD threshold display to match per-platform bands
- [ ] Device test Build 21 on TestFlight
