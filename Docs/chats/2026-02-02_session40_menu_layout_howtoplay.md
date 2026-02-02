# 2026-02-02 — Session 40: Menu Layout Fix + How To Play Info Sheet

## Goals
- Fix menu content overflow (~700pt content on most iPhones with banner ad covering bottom section)
- Replace inline HOW TO PLAY section with a rich info sheet
- Document all changes

## Changes Made

### 1. Menu Layout Fix
**What:** Removed the inline "HOW TO PLAY" section from the menu and replaced it with a compact "How to Play >" text button that opens a sheet. Added 60pt bottom padding to ScrollView content to clear the banner ad on devices that still need scrolling.
**Why:** Menu content (~700pt) overflowed on most iPhones. The banner ad (50pt, pinned at bottom) covered the HOW TO PLAY section. Content required scrolling even on iPhone 16 Pro (709pt available above ad). The change saves ~79pt of vertical space — menu now fits without scrolling on iPhone 12 mini (731pt) and larger.
**Files:** `RocketLander/ContentView.swift`

### 2. How to Play Info Sheet (New File)
**What:** Created `HowToPlayView.swift` — a scrollable SwiftUI sheet with 5 comprehensive sections covering all game mechanics.
**Why:** The removed inline section only had 3 bullet points. The new sheet provides complete game documentation including platform tables, speed band thresholds, scoring formula details, and all 10 campaign levels.
**Files:** `RocketLander/Views/HowToPlayView.swift` (new)

Sections:
1. **Controls** — Thrust, Rotate (adapts to button/accelerometer setting), Land
2. **Landing Platforms** — Table: pad, name, width, multiplier, stars, color
3. **Speed Bands** — SAFE/HARD/FAIL explanation + per-platform V/H threshold table
4. **Scoring** — All 6 components, fuel multiplier (1.0-2.0x), platform multiplier (1x/2x/5x), formula, max 20,000
5. **Campaign** — All 10 levels from `LevelDefinition.levels` with gravity and special mechanic

### 3. Project File Update
**What:** Added `HowToPlayView.swift` to `project.pbxproj` (file reference C1000020, build file C2000020, Views group, Sources build phase).
**Why:** Required for Xcode to compile the new file.
**Files:** `RocketLander.xcodeproj/project.pbxproj`

### 4. Screenshot Housekeeping
**What:** Moved `Screenshots/WhatsApp Image 2026-02-02 at 15.29.22.jpeg` to `Screenshots/v2.0.3-bugs/bug13_menu_howtoplay_covered_by_ad.jpeg`.
**Why:** Device screenshot showing the menu overflow bug (HOW TO PLAY section covered by banner ad) — this is the bug evidence for the fix in this session. Was uploaded via GitHub/WhatsApp and left in the Screenshots root with a non-descriptive name.
**Files:** `Screenshots/v2.0.3-bugs/bug13_menu_howtoplay_covered_by_ad.jpeg` (renamed + moved)

## Research / Ideas Discussed
- Attempted to automate simulator taps to capture the How to Play sheet screenshot, but `simctl` does not support touch simulation and `cliclick`/PyObjC are not available. User should test manually.
- iPhone SE (597pt usable space) will still need slight scrolling on the menu, but content is fully accessible with the 60pt bottom padding ensuring nothing is hidden behind the banner ad.

## Technical Notes
- The `HowToPlayView` reads campaign data directly from `LevelDefinition.levels` — no duplication of level data
- The controls section adapts based on the `useAccelerometer` parameter passed from the menu
- Bottom padding of 60pt on the ScrollView content (not the ScrollView itself) ensures content clears the 50pt banner ad with margin

## Decisions
1. Replaced inline HOW TO PLAY with a sheet rather than just removing it — provides richer documentation accessible on demand
2. Used 60pt bottom padding (more than the 50pt banner) to provide comfortable clearance on all devices

## Definition of Done
- [x] Inline HOW TO PLAY section removed from menu
- [x] "How to Play >" button opens sheet
- [x] HowToPlayView has all 5 sections with accurate game data
- [x] Controls section adapts to accelerometer/button setting
- [x] Bottom padding clears banner ad
- [x] Build succeeds (verified on iPhone 16 Pro simulator)
- [x] Menu fits without scrolling on iPhone 16 Pro (verified via screenshot)
- [x] All documentation updated (CHANGELOG, STATUS, PROJECT_LOG, README, CLAUDE.md, session summary)
- [ ] Sheet UI verified visually (user should tap "How to Play >" in simulator)
- [ ] iPhone SE scrolling behavior verified
- [ ] Device test on TestFlight (requires new build upload)

## Commits
- (pending — changes not yet committed)

## Repo Housekeeping
- [x] Working tree clean (only expected modified/new files)
- [x] .gitignore up to date
- [x] README.md project structure updated (added HowToPlayView.swift)
- [x] CLAUDE.md file structure updated
- [x] No secrets or credentials in tracked files
- [x] Stale screenshot moved from Screenshots root to v2.0.3-bugs with descriptive name

## Next Actions
- [ ] User taps "How to Play >" in simulator to verify sheet content and layout
- [ ] Test on iPhone SE (3rd gen) simulator to verify scrolling behavior
- [ ] Commit and push changes
- [ ] Upload new TestFlight build if desired for device testing
- [ ] Continue with v2.1.0 planning (Game Center, achievements, share card)
