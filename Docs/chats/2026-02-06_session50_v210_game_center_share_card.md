# 2026-02-06 — Session 50: v2.1.0 Game Center + Share Score Card

## Goals
- Implement v2.1.0 Community phase: Game Center integration (auth, leaderboards, achievements, Galaxy Rank) and Share Score Card

## Changes Made

### 1. GameCenterManager.swift (NEW — 283 lines)
**What:** Central Game Center manager with auth, 12 leaderboards, 10 achievements, Galaxy Rank
**Why:** v2.1.0 requires Game Center integration for competitive play and social engagement
**Files:** `RocketLander/Models/GameCenterManager.swift`
**Details:**
- ObservableObject + singleton pattern (singleton needed for fire-and-forget calls from GameScene)
- `authenticate()` — sets GKLocalPlayer.local.authenticateHandler
- 12 leaderboard IDs: `classic`, `campaign_1`...`campaign_10`, `galaxy_rank`
- `submitClassicScore()`, `submitCampaignScore()` — fire-and-forget via GKLeaderboard.submitScore()
- `fetchGalaxyRank()` — loads player rank from galaxy_rank leaderboard
- Galaxy Rank = sum of best scores across all 10 campaign levels
- 10 achievement IDs + `checkAchievements()` evaluating all criteria
- `recordAttempt()` for First Try Perfection tracking
- Persistent state: safePlatformCLevels, attemptsByLevel saved to UserDefaults

### 2. RocketLander.entitlements (NEW)
**What:** Game Center capability entitlement
**Files:** `RocketLander/RocketLander.entitlements`

### 3. ShareScoreCardView.swift (NEW — 148 lines)
**What:** SwiftUI score card rendering + share helper
**Why:** Players want to share landing results on social media
**Files:** `RocketLander/Views/ShareScoreCardView.swift`
**Details:**
- 320pt dark gradient card with orange border, game logo, mode/level, stars, score, platform+band badge, flight data
- ShareHelper.renderScoreCard(): ImageRenderer (iOS 16+) with UIHostingController snapshot fallback (iOS 15)
- ShareHelper.shareImage(): UIActivityViewController from topmost VC

### 4. ContentView + MenuView
**What:** Game Center auth, Galaxy Rank badge, GKAccessPoint
**Files:** `RocketLander/ContentView.swift`
**Details:**
- Added gameCenterManager StateObject, `.onAppear { authenticate() }`
- Passed gameCenterManager to all child views
- Galaxy Rank badge between campaign stars and play buttons
- GKAccessPoint show/hide on menu appear/disappear
- fetchGalaxyRank() on menu appear

### 5. GameContainerView
**What:** Pass campaignState and gameCenterManager through to GameScene
**Files:** `RocketLander/Views/GameContainerView.swift`

### 6. GameScene
**What:** GC integration hooks in game lifecycle
**Files:** `RocketLander/GameScene.swift`
**Details:**
- Added campaignState property, updated init
- recordAttempt() in startGame()
- GC score submission + achievement check in successfulLanding()

### 7. LeaderboardView
**What:** Galaxy Rank header + View Global Rankings button
**Files:** `RocketLander/Views/LeaderboardView.swift`
**Details:**
- Galaxy Rank header with rank/score display
- "View Global Rankings" opens GKGameCenterViewController
- GKDismissHandler class for GC delegate

### 8. LevelSelectView
**What:** Galaxy Rank explanation section
**Files:** `RocketLander/Views/LevelSelectView.swift`

### 9. GameOverView
**What:** Share button + shareScoreCard() method
**Files:** `RocketLander/Views/GameOverView.swift`
**Details:**
- Share button in action buttons (only visible when landed)
- shareScoreCard() builds ShareScoreCardView from gameState, renders to image, triggers share sheet

### 10. project.pbxproj
**What:** Added new files, entitlements, CODE_SIGN_ENTITLEMENTS
**Files:** `RocketLander.xcodeproj/project.pbxproj`

## Technical Notes
- GKLeaderboard.loadEntries callback has 3 params (localEntry, entries, error), not 4 — the totalPlayerCount param shown in some docs doesn't exist
- SourceKit shows cross-file "Cannot find type X in scope" errors during editing — these are indexing artifacts that resolve at build time
- GameScene required init gets `@available(*, unavailable)` since campaignState has no default for coder init
- GC auth error in simulator is expected (no Game Center account configured)

## Decisions
1. **Singleton + ObservableObject hybrid** for GameCenterManager — singleton needed for fire-and-forget from SpriteKit, ObservableObject for reactive SwiftUI
2. **Galaxy Rank as 12th leaderboard** — sum of best campaign scores, recalculated each landing
3. **Composite band for achievement checks** — worst of V/H/tilt, not speedBand alone
4. **Tilt checks in radians internally** — e.g., 2.0° = 2.0 × π/180
5. **First Try Perfection is campaign-only** — tracked via attemptsByLevel persisted to UserDefaults

## Definition of Done
- [x] GameCenterManager with auth, leaderboards, achievements
- [x] 12 leaderboard IDs defined (classic, campaign_1-10, galaxy_rank)
- [x] 10 achievement IDs and check logic
- [x] Galaxy Rank on 3 UI layers (menu, campaign, leaderboard)
- [x] GKAccessPoint on menu
- [x] Share Score Card rendering + native share sheet
- [x] Share button on game-over (landing only)
- [x] Build succeeds
- [x] 91/91 tests pass
- [x] All documentation updated (STATUS, CHANGELOG, DECISIONS, PROJECT_LOG, README, session summary)
- [ ] Version bump (pending user approval)
- [ ] App Store Connect: create 12 leaderboards + 10 achievements (manual)
- [ ] Device testing (GC auth, score submission, achievements, share card)

## Commits
- (pending — all changes uncommitted, ready for commit)

## Repo Housekeeping
- [x] Working tree has expected changes only (7 modified + 3 new files)
- [x] .gitignore up to date
- [x] README.md project structure updated with new files
- [x] No secrets or credentials in tracked files

## Next Actions
- [ ] Commit all v2.1.0 code + documentation
- [ ] Version bump to 2.1.0 (needs user approval)
- [ ] App Store Connect: create 12 leaderboards + 10 achievements (manual step)
- [ ] Device testing: GC auth, score submission, Galaxy Rank, achievements, share card
- [ ] Build number bump + TestFlight upload
- [ ] App Store submission
