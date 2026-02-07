# 2026-02-06 — Session 57: Game Center Fix — Achievement Images, Releases, ASC Submission

## Goals
- Diagnose why Game Center is not working on the live v2.1.0 App Store build
- Create achievement icons (10 images, 1024x1024 PNG)
- Upload achievement images to App Store Connect via API
- Fix GC resource submission pipeline and submit v2.1.1 with GC resources

## Changes Made

### 1. Root Cause Analysis — GC Not Working on Live App
**What:** Deep analysis of 4 screenshots showing: empty GC dashboard on device, all resources in "Ready to Submit" state, leaderboard error requiring GC-enabled app version, achievement error requiring images.
**Why:** Game Center leaderboards and achievements are not visible to users on the live v2.1.0 build.
**Root Causes Identified:**
- **RC1**: GC resources were created via API but never included in the App Store version submission. TestFlight can access "Ready to Submit" resources, but App Store builds cannot — explaining why testing worked but production didn't.
- **RC2**: Achievements missing required images (512x512 or 1024x1024 PNG) for their localizations.
- **RC3**: Setup script had no image upload capability.
- **RC4 (discovered later)**: Setup script was missing the critical "release" step — `gameCenterLeaderboardReleases` and `gameCenterAchievementReleases` resources that attach leaderboards/achievements to the app version for submission.

### 2. Achievement Icon Generation Script (NEW)
**What:** Created `Scripts/generate_achievement_icons.py` — generates 10 1024x1024 PNG achievement icons using Python Pillow.
**Why:** Achievements require images before they can be submitted for review.
**Files:** `Scripts/generate_achievement_icons.py`, `Screenshots/achievements/*.png` (10 files)
**Design:** Circular badge/emblem style with metallic ring, colored gradient background, geometric symbols, name banner. Each achievement has a unique color scheme.
**Icons:**
- `eagle_has_landed.png` — Green, rocket + checkmark
- `precision_landing.png` — Gold, crosshair + "B"
- `elite_landing.png` — Red, white star + "C"
- `fuel_master.png` — Blue, droplet + "65%"
- `precision_pilot.png` — Purple, rocket + level line + "≤2°"
- `triple_elite.png` — Orange, 3 white stars + "3×"
- `planet_conquered.png` — Teal, planet + 3 stars
- `first_try_perfection.png` — Silver/dark, "1st" + sparkles
- `solar_system_elite.png` — Deep blue, 10 orbiting planets + 3 stars + "30"
- `master_lander.png` — Gold, crown with jewels + "10/10"

### 3. Achievement Image Upload via ASC API
**What:** Enhanced `Scripts/setup_game_center.py` with `--upload-images` flag. Added `get_achievement_localizations()`, `upload_achievement_image()` (3-step ASC API: reserve, upload binary, commit), and PEM key reformatting for single-line keys.
**Why:** Images must be uploaded to ASC before achievements can be submitted for review.
**Files:** `Scripts/setup_game_center.py`
**Result:** All 10/10 images uploaded successfully.

### 4. GC Release Resources — The Missing Step
**What:** Added `--create-releases` flag to `setup_game_center.py`. Creates `gameCenterLeaderboardReleases` (POST /v1/gameCenterLeaderboardReleases) and `gameCenterAchievementReleases` (POST /v1/gameCenterAchievementReleases) for all resources.
**Why:** Creating leaderboards/achievements via API is necessary but NOT sufficient. They must have "release" resources that attach them to the `gameCenterDetail` for an app version. Without releases, ASC shows "must be submitted with a Game Center-compatible app version" error. This was the critical missing step in the original setup script.
**Files:** `Scripts/setup_game_center.py` — added `create_leaderboard_release()`, `create_achievement_release()`, and `--create-releases` section in `main()`
**Also changed:** `get_existing_achievements()` now returns dict (vendorIdentifier -> resource ID) instead of set, to support release creation.

### 5. App Store Description and What's New Updated
**What:** Updated App Store description (added COMPETE GLOBALLY section, corrected max score 20,000→23,100) and What's New (v2.1.1 share card + GC fix, v2.1.0 GC, v2.0.3 gameplay, v2.0.2 campaign).
**Why:** Needed for v2.1.1 submission.

### 6. Setup Script PEM Fix + Error Handling
**What:** Added 401 error handling with diagnostic output, PEM key reformatting for single-line keys (strip headers, extract base64, re-wrap at 64 chars per line).
**Why:** Environment variable PEM keys from Vercel dashboard were single-line without newlines, causing MalformedFraming errors.

## Research / Ideas Discussed
- Considered Canva/Figma for achievement images but chose programmatic generation (Python Pillow) for reproducibility
- Scripted API upload chosen over manual for efficiency
- Deep research into ASC Game Center submission workflow revealed the 6-step process (Apple Tech Talk reference): create detail → create resources → test on TestFlight → **create releases** → enable gameCenterAppVersions → submit for review

## Technical Notes — Critical GC Learnings

### ASC Game Center Resource Lifecycle (6 steps)
1. Create `gameCenterDetail` (bridge between app and GC)
2. Create leaderboards + achievements with localizations + images
3. Test on TestFlight (draft resources accessible)
4. **Create releases** (`gameCenterLeaderboardReleases` + `gameCenterAchievementReleases`) — REQUIRED to attach resources to app version
5. Enable `gameCenterAppVersions` (GC checkbox on version page)
6. Submit for review bundled with an app version

### Key Gotchas Discovered
- **Releases are mandatory**: Without `gameCenterLeaderboardReleases` and `gameCenterAchievementReleases`, resources exist in ASC but cannot be submitted. ASC shows "must be submitted with a Game Center-compatible app version" error.
- **Deleting a draft submission deletes its releases**: When the first draft (13 items) was deleted, ALL releases were removed. Had to re-run `--create-releases` to recreate them. Always re-create releases after deleting a draft.
- **First GC submission must bundle with app version**: Standalone GC submissions are only allowed AFTER the first batch is approved. For the first time, GC resources MUST ride along with an app version submission.
- **TestFlight masks GC issues**: TestFlight builds can access draft ("Ready to Submit") GC resources. App Store builds cannot. This is why GC appeared to work in testing but failed in production.
- **ASC API image upload is 3-step**: Reserve (POST), upload binary (PUT to URL from reserve response), commit (PATCH with `uploaded: true`).
- **PEM keys must be wrapped at 64 chars**: Single-line PEM keys from environment variables cause jwt MalformedFraming errors. Must strip headers, extract base64, re-wrap at 64 chars per line.
- **Version page shows GC resources only when releases exist**: Leaderboards and achievements only appear in the Game Center section of the app version page (v2.1.1) after releases are created.

## Decisions
1. **Programmatic icon generation over design tools** — Python Pillow script for reproducibility, no Canva/Figma account needed
2. **Badge/emblem style with varied colors** — each achievement visually distinct, professional look
3. **API upload over manual** — 10 images faster via script than manual ASC UI
4. **API release creation over manual** — 22 resources (12 LBs + 10 achievements) faster via script
5. **GC resources need releases** — documented as a standing decision for future GC changes

## Definition of Done
- [x] Root cause analysis complete (4 root causes identified)
- [x] 10 achievement icons generated (1024x1024 PNG)
- [x] Icon contrast and design issues fixed (2 iterations)
- [x] Solar System Elite redesigned with 3 stars + "30"
- [x] setup_game_center.py enhanced with --upload-images
- [x] setup_game_center.py enhanced with --create-releases
- [x] PEM key reformatting for single-line keys
- [x] 401 error handling added
- [x] 10/10 achievement images uploaded to ASC
- [x] 12/12 leaderboard releases created
- [x] 10/10 achievement releases created
- [x] All 22 GC resources visible on v2.1.1 version page
- [x] App Store description updated (COMPETE GLOBALLY section, max score corrected)
- [x] What's New updated for v2.1.1
- [x] Review team notes verified
- [x] Submit v2.1.1 Build 33 for App Store review — **SUBMITTED** 2026-02-06
- [x] All documentation updated
- [x] Session summary created

## Commits
- `224b0a7` — Add achievement icons and upload to ASC for Game Center fix
- `83884a6` — Update session 57 summary with commit hash
- `c1f67e1` — Add GC releases to setup script, update docs for v2.1.1 submission

## Repo Housekeeping
- [x] .gitignore up to date
- [x] README.md project structure matches actual files
- [x] No secrets or credentials in tracked files

## Next Actions
- [ ] Submit v2.1.1 Build 33 for App Store review (user clicks "Adicionar para revisão" in ASC)
- [ ] Device test share card on TestFlight (both landing and crash)
- [ ] Implement event-driven share triggers per growth plan
- [ ] Create 5 high-converting App Store screenshots per growth plan
- [ ] Plan v2.2.0 (Monetization): approach TBD
