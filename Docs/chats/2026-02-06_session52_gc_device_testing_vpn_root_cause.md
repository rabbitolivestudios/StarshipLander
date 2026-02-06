# 2026-02-06 — Session 52: GC Device Testing + VPN Root Cause + App Store Prep

## Goals
- Investigate and resolve persistent "Sign in to Game Center" issue on device (carried from Session 51)
- Verify all Game Center features on device
- Document findings, commit, and prepare v2.1.0 for App Store submission

## Changes Made

### 1. Game Center Investigation (5 Parallel Agents)
**What:** Launched 5 investigation agents in parallel to analyze the GC issue from different angles
**Why:** ChatGPT-provided investigation framework covering auth state, GKAccessPoint, ASC publishing, environment/account, and data existence
**Findings:**
- Auth state: No divergence possible — singleton pattern ensures single auth state
- GKAccessPoint: Works as control test (bubble visible on menu = auth OK)
- Leaderboard IDs: All 22 IDs match exactly between Swift code and Python setup script
- ASC version enablement: `gameCenterAppVersions` NOT required for TestFlight, only for App Store
- Score submission: Zero scores submitted before dashboard opens (expected for first-time use)

### 2. Diagnostic Build
**What:** Added comprehensive `[GC-DIAG]` logging throughout GC flow
**Why:** Needed console output to identify the exact failure point
**Details:**
- Auth handler: logs which path fires (VC, error, success)
- `probeLeaderboards()`: calls `GKLeaderboard.loadLeaderboards(IDs:)` for classic + galaxy_rank
- `loadDefaultLeaderboardIdentifier` probe
- Three dashboard buttons: Generic (no ID), Classic (control), Galaxy Rank (original)
- All with defensive `GKLocalPlayer.local.isAuthenticated` guard

### 3. ROOT CAUSE: VPN Blocking Game Center Network Traffic
**What:** Console output revealed `interface: utun4` (VPN tunnel) in all network errors
**Why:** VPN blocked DNS resolution for Game Center data-fetching servers
**Evidence:**
- `[GC-DIAG] AUTH SUCCESS` — auth worked (cached/local)
- `[GC-DIAG] DEFAULT LB: classic` — default LB identifier worked (cached)
- `[GC-DIAG] PROBE ERROR: A server with the specified hostname could not be found.` — data fetch failed
- `interface: utun4` in NSError details = VPN tunnel
**Fix:** User disabled VPN → everything works immediately

### 4. Device Testing Results (VPN off)
**What:** All Game Center features verified working on device
**Details:**
- All 12 leaderboards visible in GKGameCenterViewController
- Scores submitted: Moon 3,323 pts, Galaxy Rank 12,323 pts
- Galaxy Rank: #1 shown on menu
- 10 achievements visible in dashboard
- GKAccessPoint bubble showing on menu
- Console: `PROBE: found 2/2 leaderboards`, `DEFAULT LB: classic`

### 5. Diagnostic Code Cleanup
**What:** Removed all diagnostic code, restored clean state
**Files:** `RocketLander/Models/GameCenterManager.swift`, `RocketLander/Views/LeaderboardView.swift`
**Details:**
- Reverted 3 diagnostic buttons back to single "View Global Rankings" button
- Removed `probeLeaderboards()` method and all `[GC-DIAG]` print statements
- Restored clean auth handler with `#if DEBUG` guards only
- Added defensive `GKLocalPlayer.local.isAuthenticated` guard on dashboard presentation

### 6. Setup Script Enhancement
**What:** Added `gameCenterAppVersions` support to `Scripts/setup_game_center.py`
**Why:** Required for App Store submission (links GC config to app version)
**Files:** `Scripts/setup_game_center.py`
**Details:**
- `get_current_app_store_version()`: Finds latest editable/live app store version
- `enable_gc_for_app_version()`: Creates/enables gameCenterAppVersion resource
- Step 5 added to `main()`: called after achievements

### 7. v2.1.0 Release Notes
**What:** Prepared App Store "What's New" copy and review team notes
**Files:** `RELEASE_NOTES.md`

## Research / Ideas Discussed
- ASC `gameCenterAppVersions` resource is required for App Store submission but NOT for TestFlight
- GC "Prerelease" badge on ASC resources is normal — disappears after App Store review
- Game Center has no sandbox since iOS 9 — all builds hit production GC servers
- `@StateObject` with pre-existing singleton is an anti-pattern (should be `@ObservedObject`), but doesn't cause functional issues in this case

## Technical Notes
- **VPN detection**: Look for `utun4` (or any `utun*`) interface in NSError details — indicates VPN tunnel
- **GKGameCenterViewController fallback**: Shows "Sign in to Game Center" when it can't load ANY data — misleading when the real issue is network, not auth
- **GC auth caching**: `GKLocalPlayer.local.isAuthenticated` can return `true` even when network is blocked, because auth state is cached locally
- **gameCenterAppVersions**: Links GC config to a specific app version. Without it, first-time GC submission to App Store will fail

## Decisions
1. **VPN root cause documented** — added to DECISIONS.md, MEMORY.md, and STATUS.md Known Risks
2. **Defensive auth guard** — `openGameCenterDashboard()` now checks `GKLocalPlayer.local.isAuthenticated` before presenting VC
3. **gameCenterAppVersions in setup script** — needed for eventual App Store submission, not TestFlight

## Definition of Done
- [x] Root cause identified (VPN blocks GC network)
- [x] All diagnostic code removed
- [x] Defensive auth guard added to dashboard presentation
- [x] Setup script enhanced with gameCenterAppVersions and --reset flag
- [x] GC features verified on device (12 leaderboards, scores, rank, achievements)
- [x] Leaderboard scores reset before submission (--reset cleared test scores)
- [x] App Store screenshot created (Galaxy Rank caption, 1284x2778)
- [x] v2.1.0 release notes finalized (comprehensive What's New covering v2.1.0 + v2.0.3 + v2.0.2)
- [x] Review team notes updated
- [x] v2.1.0 Build 32 submitted for App Store review
- [x] All 7 documentation files updated
- [x] Build succeeds
- [x] Session summary created

## Commits
- `4892b5e` — Session 52: GC device testing verified, VPN root cause found, App Store prep
- `cca95a5` — Add --reset flag to setup_game_center.py for leaderboard score clearing
- (this commit) — Note v2.1.0 Build 32 submitted for review

## Repo Housekeeping
- [x] Working tree clean after commit
- [x] .gitignore up to date
- [x] README.md project structure matches actual files
- [x] No secrets or credentials in tracked files

## Next Actions
- [ ] Wait for v2.1.0 App Store review
- [ ] Test Share Score Card on device (was blocked by GC investigation)
- [ ] Implement v2.2.0 (Monetization): Remove Ads IAP (StoreKit 2)
