# 2026-04-29 — Session 63: v2.2.0 Progression and Reward Fixes

## Goals
- Fix code-review findings before v2.2.0 submission.
- Preserve campaign progress even when the high-score sheet is skipped.
- Keep Daily Challenge scoring/rewards isolated from Classic scores.
- Fix Earth moving-platform center logic.
- Update tests and documentation.

## Changes Made

### 1. Campaign Progress Persistence
**What:** Added `personalBestScoresByLevel`, `recordCompletion(...)`, and `addNamedScore(...)` to `CampaignState`.
**Why:** Stars, unlocks, and personal bests must persist on landing, not only when a player enters a name.
**Files:** `RocketLander/Models/CampaignState.swift`, `RocketLander/GameScene.swift`, `RocketLander/Views/GameOverView.swift`

### 2. Campaign Attempt Tracking
**What:** Normal auto-start now records campaign attempts.
**Why:** `startGame()` was not used by the SwiftUI control flow, so first-attempt achievement accounting could stay empty.
**Files:** `RocketLander/GameScene.swift`

### 3. Earth Moving Platform Scoring
**What:** Landing leg bounds, final center distance, and center precision scoring now use the contacted platform node's live X position.
**Why:** Earth platforms move, but checks/scoring previously used static platform fractions.
**Files:** `RocketLander/GameScene.swift`, `RocketLander/GameScene+Scoring.swift`

### 4. Daily Challenge and Blue Stars
**What:** Failed Daily Challenge landings no longer trigger high-score save; successful new daily bests still prompt for a name; reward display uses the actual `BlueStarManager` result; Daily Challenge and streak dates use UTC.
**Why:** Prevent Classic score pollution, avoid showing rewards not granted, and make “same worldwide” true.
**Files:** `RocketLander/Views/GameOverView.swift`, `RocketLander/Models/DailyChallenge.swift`, `RocketLander/Models/BlueStarManager.swift`, `RocketLander/Models/GameState.swift`

### 5. Tests
**What:** Added focused coverage to existing test files for anonymous campaign completion, named-score separation, reward reset state, and live platform center scoring.
**Files:** `RocketLanderTests/CampaignStateTests.swift`, `RocketLanderTests/GameStateTests.swift`, `RocketLanderTests/ScoringHelper.swift`, `RocketLanderTests/ScoringTests.swift`

### 6. Documentation
**What:** Updated project status, changelog, release notes, decisions, README, project log, and this session summary.
**Why:** Local fixes are not yet uploaded to TestFlight, and docs need to reflect that accurately.
**Files:** `STATUS.md`, `CHANGELOG.md`, `RELEASE_NOTES.md`, `README.md`, `DECISIONS.md`, `PROJECT_LOG.md`, `Docs/chats/2026-04-29_session63_v220_progression_reward_fixes.md`

### 7. Default Starship Art Refresh
**What:** Refreshed both Starship renderers: SpriteKit gameplay art and SwiftUI menu illustration. The new default keeps the current arcade/vector style while adding a more recognizable Starship silhouette: stainless body shading, black heat-shield tile strip, four flaps, engine skirt, three Raptor-style nozzles, landing legs, and a cleaner flame.
**Why:** Improve the default ship art without introducing bitmap asset complexity or changing gameplay collision behavior.
**Files:** `RocketLander/GameScene+Setup.swift`, `RocketLander/Views/ShapeViews.swift`

## Technical Notes
- `xcodebuild test -project RocketLander.xcodeproj -scheme RocketLander -destination 'platform=iOS Simulator,name=iPhone 16 Pro'` could not run on this machine because no eligible iOS simulator runtime is installed. Xcode reports `iOS 26.4 is not installed`.
- `xcodebuild build -project RocketLander.xcodeproj -scheme RocketLander -destination 'generic/platform=iOS'` failed for the same missing iOS platform reason.
- Initial sandboxed build attempt also hit cache permissions; escalated run resolved packages successfully before hitting the missing-runtime blocker.
- Partial sanity check passed: `xcrun swiftc -typecheck` on the pure model layer.
- Later in the session, the missing iOS 26.4 simulator runtime was installed and full simulator tests passed.
- Generated realistic Starship concept art is a future premium/unlockable skin candidate, not implemented as a default bitmap asset.
- Default art remains vector/SpriteKit/SwiftUI and uses the same `SKPhysicsBody(rectangleOf: CGSize(width: 54, height: 85))` as before.

## Decisions
1. Gameplay progress is recorded from gameplay events, not optional UI sheets.
2. Named top-3 campaign scores are separate from personal campaign best scores.
3. Daily Challenge date boundaries use UTC for worldwide consistency.
4. The default ship remains stylized vector art; realistic generated art is better suited to a future skin/store system.

## Definition of Done
- [x] Campaign progress persists without name entry
- [x] Campaign attempt tracking fixed
- [x] Daily Challenge failed landings isolated from Classic scores
- [x] Blue Star reward display uses actual reward result
- [x] UTC daily challenge/streak dates
- [x] Moving-platform live center scoring
- [x] Default Starship art refreshed without physics body change
- [x] Focused tests updated
- [x] Full build/test verification — 94 simulator tests passed after installing runtime
- [x] Docs updated

## Commits
- None yet

## Repo Housekeeping
- [ ] Working tree clean — changes intentionally uncommitted
- [x] `.gitignore` already ignores `starship-dashboard/`
- [x] README project structure checked
- [x] No credentials added

## Next Actions
- [x] Install the missing iOS simulator runtime
- [x] Run full `xcodebuild test` on iPhone 17 Pro simulator (94 tests, 0 failures)
- [x] Capture simulator screenshots for ATT prompt, menu, Classic mode, and THRUST tap
- [x] Capture refreshed Starship art screenshots for menu and Classic mode
- [ ] Device-test Daily Challenge, campaign unlocks, blue star rewards, interstitial cadence, and Earth moving platforms
- [ ] Create `daily_challenge` leaderboard in App Store Connect
- [ ] Upload replacement v2.2.0 build after verification
