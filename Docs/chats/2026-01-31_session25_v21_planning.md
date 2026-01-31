# 2026-01-31 — Session 25: v2.1.0 Planning

## Goals
- Plan v2.1.0 scope: Game Center, Achievements, Remove Ads IAP, Share Score Card
- Research GameKit and StoreKit 2 APIs
- Document technical decisions and privacy impact
- Update all project documentation with the plan

## Changes Made

### 1. GameKit / Game Center Research
**What:** Comprehensive research of Game Center APIs for iOS 15+
**Why:** Need to understand authentication, score submission, achievements, and privacy requirements before implementation
**Key findings:**
- `GKLocalPlayer.local.authenticateHandler` — set once at launch, automatic sign-in
- `GKLeaderboard.submitScore()` — class method, built-in offline queue, best-score-only
- `GKAchievement.report()` — idempotent, percentComplete 0-100, safe to call multiple times
- `GKAccessPoint.shared` — 3 lines of code for native Game Center dashboard overlay
- Leaderboard IDs must be registered in App Store Connect before use (reverse-domain notation)
- Privacy: No ATT needed; add "Gameplay Content" under "Usage Data" in App Privacy
- Entitlement: "Game Center" capability in Xcode Signing & Capabilities

### 2. StoreKit 2 Research
**What:** Comprehensive research of StoreKit 2 for non-consumable IAP
**Why:** Need modern async/await approach for "Remove Ads" purchase
**Key findings:**
- `Product.purchase()` returns `.success/.userCancelled/.pending`
- On-device JWS verification — no server needed
- `Transaction.currentEntitlements` as source of truth for restore
- `AppStore.sync()` for explicit restore button
- UserDefaults cache for synchronous ad-hiding decisions
- Local StoreKit Configuration file for testing without App Store Connect
- Privacy: No additional declarations needed
- Entitlement: "In-App Purchase" capability in Xcode

### 3. Achievement Hook Point Analysis
**What:** Reviewed existing code to identify where achievements should be triggered
**Files reviewed:** `GameOverView.swift`, `GameScene+Scoring.swift`, `GameState.swift`, `CampaignState.swift`
**Key findings:**
- `saveScore()` in GameOverView (line 207) — best place for landing-based achievements
- `CampaignState.completedLevel()` — best for progression achievements
- `GameState` properties provide all needed data: `landed`, `starsEarned`, `landedPlatform`, `fuel`, `rotation`, `score`
- `BannerAdContainer` in ContentView/GameContainerView — conditionally hide for IAP

### 4. Documentation Updates
**What:** Updated CHANGELOG, DECISIONS, STATUS, PROJECT_LOG with v2.1.0 plan
**Why:** Document the plan and decisions before implementation begins
**Files:**
- `CHANGELOG.md` — added v2.1.0 Unreleased section
- `DECISIONS.md` — 4 new entries (Game Center strategy, achievement philosophy, StoreKit 2 approach, privacy impact)
- `STATUS.md` — updated phase to planning, updated next tasks and not-done statuses
- `PROJECT_LOG.md` — session entry, updated backlog to separate v2.1.0 planned items from v2.2+ backlog

## Research / Ideas Discussed

### v2.1.0 Scope (locked)
1. **Game Center Leaderboards** (11 total):
   - `com.tboliveira.starshiplander.classic`
   - `com.tboliveira.starshiplander.campaign.moon` (through `.jupiter`)
   - Score format: Integer, high-to-low, best score

2. **Game Center Achievements** (10 total):
   - First Star — land successfully (any platform)
   - Precision Landing — Platform B (2 stars)
   - Elite Landing — Platform C (3 stars)
   - Fuel Master — land with >=80% fuel
   - Precision Pilot — near-perfect rotation (<=0.01 radians)
   - Triple Elite — three 3-star landings (any planets)
   - Planet Conquered — 3 stars on a planet
   - First Try Perfection — 3 stars on first attempt (needs tracking)
   - Solar System Elite — 3 stars on all 10 planets
   - Master Lander (ULTIMATE) — 3 stars on all planets + best score recorded

3. **Remove Ads IAP**:
   - Product ID: `com.tboliveira.StarshipLander.removeAds`
   - Type: Non-consumable
   - StoreKit 2, on-device verification
   - UserDefaults cache (`adsRemoved` boolean)

4. **Share Score Card**:
   - SwiftUI-rendered card → UIImage → UIActivityViewController
   - Content: mode/planet, stars, platform, score, app branding

### Implementation Order (for future sessions)
1. Game Center authentication + leaderboards (requires Xcode capability + App Store Connect setup)
2. Game Center achievements (hooks into existing landing logic)
3. Share Score Card (SwiftUI image render + share sheet)
4. Pre-release testing + documentation finalization for v2.1.0
5. (v2.2.0) Remove Ads IAP (StoreKit Configuration + purchase flow + ad hiding)

### New Files Expected in v2.1.0 (Community)
- `RocketLander/GameCenterManager.swift` — GC auth, score submission, achievement reporting
- `RocketLander/Views/ShareScoreCard.swift` — Score card renderer + share button
- Updates to: `ContentView.swift`, `GameOverView.swift`, `LeaderboardView.swift`, `RocketLanderApp.swift`

### New Files Expected in v2.2.0 (Monetization)
- `RocketLander/StoreManager.swift` — StoreKit 2 purchase flow, entitlement checking
- `RocketLander/RemoveAds.storekit` — StoreKit Configuration for testing
- Updates to: `ContentView.swift`, `BannerAdView.swift`, `GameContainerView.swift`

## Technical Notes
- GameKit's built-in offline queue means we don't need to build our own score submission retry logic
- `GKAchievement.report()` only updates if new percentComplete > stored value — safe to call repeatedly
- StoreKit 2 `Transaction.currentEntitlements` handles refunds automatically — if Apple refunds a purchase, the entitlement disappears
- StoreKit testing only works when running through Xcode, not via `xcodebuild` CLI

## Decisions
1. Game Center auth: automatic with graceful fallback, no forced popups
2. 10 achievements, all binary (100% when triggered), no incremental/grind-based
3. StoreKit 2 with on-device JWS, UserDefaults cache for sync access
4. Privacy: add "Gameplay Content" declaration, no ATT changes
5. **Phase split**: v2.1.0 = Community (Game Center + achievements + share card), v2.2.0 = Monetization (Remove Ads IAP). Per CLAUDE.md phase discipline, unrelated phases must not be mixed in one version.
6. No gameplay, physics, or campaign balance changes in either version

## Definition of Done
- [x] GameKit API requirements researched and documented
- [x] StoreKit 2 API requirements researched and documented
- [x] Achievement hook points identified in existing code
- [x] Privacy impact documented
- [x] Technical decisions recorded in DECISIONS.md
- [x] CHANGELOG.md updated with Unreleased v2.1.0 section
- [x] STATUS.md updated with new phase and next tasks
- [x] PROJECT_LOG.md updated with session entry and backlog
- [x] Session summary created

## Commits
- `3303113` — Plan v2.1.0: Game Center, achievements, IAP, share card
- `67c5802` — Split v2.1 plan by phase: Community (v2.1.0) and Monetization (v2.2.0)
- (final commit with this updated session summary + GitHub releases)

## Repo Housekeeping
- [x] Working tree clean (no stale untracked files)
- [x] .gitignore up to date
- [x] README.md project structure matches actual files
- [x] No secrets or credentials in tracked files
- [x] GitHub repo description, topics, and homepage URL verified
- [x] GitHub releases created for all published versions (v1.0.0 through v1.1.5)
- [x] Installed Homebrew and `gh` CLI for GitHub repo management

## Next Actions

### v2.1.0 (Community)
- [ ] Implement Game Center authentication + leaderboards
- [ ] Implement Game Center achievements
- [ ] Implement Share Score Card
- [ ] Configure App Store Connect: leaderboard IDs, achievement IDs
- [ ] Update App Privacy declarations (add "Gameplay Content")
- [ ] Device testing: Game Center, share functionality

### v2.2.0 (Monetization)
- [ ] Implement Remove Ads IAP with StoreKit 2
- [ ] Configure App Store Connect: IAP product
- [ ] Device testing: IAP purchase, restore, ad hiding
