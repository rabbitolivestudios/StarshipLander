# 2026-02-06 — Session 51: v2.1.0 Build 31 TestFlight + ASC Game Center Setup

## Goals
- Version bump to 2.1.0, upload to TestFlight for device testing
- Create 12 leaderboards + 10 achievements in App Store Connect via API

## Changes Made

### 1. Version Bump + TestFlight Upload
**What:** Bumped version to 2.1.0 Build 31, archived, and uploaded to TestFlight
**Files:** `RocketLander/Info.plist`

### 2. setup_game_center.py (NEW)
**What:** Python script to create Game Center leaderboards and achievements via App Store Connect REST API
**Why:** Manual creation of 12 leaderboards + 10 achievements in ASC web UI is tedious and error-prone
**Files:** `Scripts/setup_game_center.py`
**Details:**
- JWT authentication with ES256 signing for ASC API
- Reads credentials from env vars (ASC_ISSUER_ID, ASC_KEY_ID, ASC_PRIVATE_KEY) or local .p8 files
- Creates 12 leaderboards: classic, campaign_1-10, galaxy_rank (INTEGER format, BEST_SCORE, DESC)
- Creates 10 achievements: eagle_has_landed through master_lander (200 total points)
- Adds en-US localizations for all resources
- Idempotent — checks existing resources before creating

### 3. App Store Connect Configuration
**What:** All 12 leaderboards and 10 achievements successfully created via API
**Details:**
- Used Vercel CLI to pull ASC credentials from starship-dashboard project env vars
- 10 achievements created on first run (all succeeded)
- 12 leaderboards initially failed with 409 errors — root cause was `defaultFormatter` needing string enum `"INTEGER"` not a nested object
- Fixed script and re-ran — all 12 leaderboards created with localizations
- Verified via API query: 12 leaderboards, 10 achievements confirmed

## Technical Notes
- ASC API `defaultFormatter` for gameCenterLeaderboards requires a string enum value (`"INTEGER"`, `"DECIMAL_POINT_1_PLACE"`, etc.), NOT an object with `defaultValue`/`suffix`/`suffixSingular`
- 409 status from ASC API can mean "already exists" OR "entity validation error" (`ENTITY_ERROR.ATTRIBUTE.TYPE`) — must check error body, not just status code
- Vercel CLI (`npx vercel`) can pull env vars from linked projects; useful for accessing ASC credentials stored in Vercel project settings
- Localization `formatterOverride` also takes the string enum format, with `formatterSuffix` / `formatterSuffixSingular` as separate string attributes

## Decisions
1. **Script for ASC configuration** — automated via Python + ASC REST API instead of manual web UI. Script committed for reproducibility.
2. **INTEGER formatter** — leaderboard scores displayed as plain integers with " pts" suffix via localization

## Definition of Done
- [x] Version bumped to 2.1.0 Build 31
- [x] Build 31 uploaded to TestFlight
- [x] setup_game_center.py script created and committed
- [x] 12 leaderboards created in ASC (verified)
- [x] 10 achievements created in ASC (verified)
- [x] All en-US localizations added
- [x] Script defaultFormatter bug fixed
- [x] All 7 documentation files updated
- [x] Session summary created
- [ ] Device testing (GC auth, score submission, achievements, Galaxy Rank, share card)

## Commits
- `3c91c96` — Bump version to 2.1.0 Build 31 for TestFlight
- `0132730` — Implement v2.1.0 Community phase: Game Center + Share Score Card
- (this session) — Add setup_game_center.py + documentation updates

## Repo Housekeeping
- [x] Working tree clean after commit (only setup_game_center.py untracked — being added)
- [x] .gitignore up to date
- [x] README.md project structure updated with new script
- [x] No secrets or credentials in tracked files

## Next Actions
- [ ] Device testing on TestFlight Build 31: GC auth, score submission, Galaxy Rank, achievements, share card
- [ ] App Store submission after device testing passes
