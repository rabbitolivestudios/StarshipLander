# 2026-05-03 — Session 67: Live Campaign Crash Hotfix

## Goals
- Diagnose the live App Store crash reported after v2.2.0 Build 37 was approved/distributed.
- Patch the campaign-mode startup crash without unrelated refactors.

## Changes Made

### 1. Campaign Attempt Tracking Persistence Fix
**What:** Updated `GameCenterManager.savePersistentState()` to convert `attemptsByLevel` keys from `Int` to `String` before saving into `UserDefaults`.
**Why:** Campaign auto-start calls `recordAttempt(mode:levelId:)`. Build 37 saved a nested `[Int: Int]` dictionary under `gcAchievementTracking`, which is not property-list-safe because `UserDefaults` dictionaries require string keys. This matches the reported behavior: app opens, campaign planet is selected, then the app closes when campaign gameplay starts.
**Files:**
- `RocketLander/Models/GameCenterManager.swift`

### 2. Regression Tests
**What:** Added tests that campaign attempt tracking persists string-keyed data and reloads from string-keyed `UserDefaults` payloads.
**Why:** Prevents reintroducing the crash-prone persistence shape.
**Files:**
- `RocketLanderTests/GameStateTests.swift`

### 3. Full-Mode Sweep Fixes
**What:** Swept Classic, Campaign, and Daily Challenge entry/reset paths plus trap patterns. Fixed stale reset state on fresh scene setup, removed lingering Mercury heat particle action on reset, and allowed Mercury/Io effects to run in Daily Challenge via `usesLevelDefinition`.
**Why:** Before uploading a replacement build, the hotfix needed to cover adjacent release bugs, not only the crash line.
**Files:**
- `RocketLander/GameScene.swift`
- `RocketLander/GameScene+Effects.swift`

### 4. Documentation Updates
**What:** Updated project status, changelog, release notes, and project log for the live Build 37 crash/hotfix state.
**Why:** Build 37 is now live, but a replacement build is needed.
**Files:**
- `STATUS.md`
- `PROJECT_LOG.md`
- `CHANGELOG.md`
- `RELEASE_NOTES.md`
- `DECISIONS.md`
- `Docs/chats/2026-05-03_session67_live_campaign_crash_hotfix.md`

### 5. No-Local-Xcode Build Path
**What:** Added a GitHub Actions workflow and reusable CI script for cloud macOS build/test verification.
**Why:** Xcode was removed from this machine for disk space, so replacement-build verification needs to run on a cloud/remote Mac.
**Files:**
- `.github/workflows/ios-ci.yml`
- `Scripts/ci_xcodebuild.sh`
- `Docs/CLOUD_BUILD_RUNBOOK.md`

## Technical Notes
- Current machine has only Command Line Tools selected (`/Library/Developer/CommandLineTools`), so `xcodebuild` and `simctl` are unavailable here.
- `git diff --check` passed.
- A local Swift/Foundation smoke check confirmed the corrected string-keyed payload can be saved/read through `UserDefaults`.
- `python3 -m py_compile` passed for release helper scripts.
- `Info.plist` and entitlements passed `plutil -lint`; asset catalog JSON passed `python3 -m json.tool`.
- `bash -n Scripts/ci_xcodebuild.sh` passed.
- No credential files were found in the app repo sweep; only `starship-dashboard/.env.example` appeared, which is an example file in the companion dashboard folder.

## Decisions
1. Keep the fix narrowly scoped to the crash path: no version bump, no gameplay changes, no refactor.
2. Treat Build 37 as live but broken for campaign startup until a replacement build is verified and uploaded.
3. Daily Challenge should run level hazards wherever the code says `usesLevelDefinition`, not only when `currentMode == .campaign`.

## Definition of Done
- [x] Likely crash root cause identified
- [x] Persistence fix implemented
- [x] Other mode entry/reset paths swept
- [x] Daily Challenge hazard parity fixed
- [x] GitHub Actions cloud CI path added
- [x] Regression tests added
- [x] Docs updated
- [ ] Full Xcode build/test verification (blocked on this machine)
- [ ] Simulator/device campaign smoke verification (blocked on this machine)

## Commits
- None yet.

## Repo Housekeeping
- [ ] Working tree clean (pre-existing uncommitted Build 37/release files remain)
- [x] No secrets or credentials added
- [x] No destructive git operations

## Next Actions
- [ ] Commit/push the hotfix branch and run `gh workflow run "iOS CI" --ref <branch-name>`.
- [ ] Run `xcodebuild test -project RocketLander.xcodeproj -scheme RocketLander -destination 'platform=iOS Simulator,name=iPhone 16 Pro'` or equivalent on a Mac with Xcode selected if using a remote Mac instead of GitHub Actions.
- [ ] Smoke test campaign startup on Earth, Venus, and one early unlocked level.
- [ ] Prepare a replacement App Store build after explicit build/version approval.
