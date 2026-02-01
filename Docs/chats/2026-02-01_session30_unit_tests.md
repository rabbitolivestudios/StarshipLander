# 2026-02-01 — Session 30: Automated Unit Tests (XCTest)

## Goals
- Add unit tests for core game logic: scoring formula, high score persistence, campaign state management, level definitions, landing messages, game state, and platform data
- Test scoring formula without modifying submitted app code
- Create XCTest target in the Xcode project

## Changes Made

### 1. Test-Only Scoring Helper
**What:** Created `ScoringHelper.calculateScore()` in `RocketLanderTests/ScoringHelper.swift` — a pure function that replicates the exact scoring formula from `GameScene+Scoring.swift` with hardcoded constants matching the app's values. Lives entirely in the test target.
**Why:** The scoring formula is tightly coupled to GameScene instance properties (`gameState.fuel`, `rocket.position.x`, `size.width`), making it impossible to test without a SpriteKit scene. Initially extracted as a static method on GameScene (modifying app code), but reverted because v2.0.2 Build 16 is submitted for review and app source must remain untouched.
**Files:** `RocketLanderTests/ScoringHelper.swift`
**App code changed:** None — `RocketLander/` directory has zero diff against Build 16.

### 2. Created Test Target
**What:** Added `RocketLanderTests` target to the Xcode project with 7 test files (51 tests total). Updated `project.pbxproj` with all required sections (file references, build files, groups, native target, build configurations, sources/frameworks/resources build phases, target dependency, container item proxy). Updated the shared scheme to include the test target in its TestAction.
**Why:** The project had no automated tests. Unit tests provide regression protection and document expected behavior of core game logic.
**Files:** `RocketLander.xcodeproj/project.pbxproj`, `RocketLander.xcodeproj/xcshareddata/xcschemes/RocketLander.xcscheme`

### 3. ScoringTests (11 tests)
**What:** Formula verification tests (theoretical max, base score, fuel multiplier range, platform multipliers, individual components, subtotal max) and realistic best-achievable scenario tests (classic mode, per-level with fuel estimates, fuel impact, platform ordering).
**Files:** `RocketLanderTests/ScoringTests.swift`

### 4. HighScoreManagerTests (9 tests)
**What:** Default seed, add score, top-3 limit, sort order, isHighScore logic, stars preservation, backward-compatible JSON decoding (missing stars field), persistence across instances.
**Files:** `RocketLanderTests/HighScoreManagerTests.swift`

### 5. CampaignStateTests (10 tests)
**What:** Initial state, default astronaut scores seeded, level unlock progression, last level completion safety, stars keep-best/upgrade, total stars, score top-3, isHighScore, persistence.
**Files:** `RocketLanderTests/CampaignStateTests.swift`

### 6. LevelDefinitionTests (8 tests)
**What:** Level count (10), sequential IDs, monotonically increasing gravity, monotonically increasing thrust, thrust-to-gravity ratio > 3.0 (landable), level lookup, invalid lookup returns nil, expected mechanic per level.
**Files:** `RocketLanderTests/LevelDefinitionTests.swift`

### 7. LandingMessagesTests (5 tests)
**What:** Platform C returns elite messages, platform A returns standard messages, crash message structure (non-empty tuple), rare message requires score > 4500, all message arrays non-empty.
**Files:** `RocketLanderTests/LandingMessagesTests.swift`

### 8. GameStateTests (3 tests)
**What:** Initial values (fuel 100, score 0, not game over), reset restores all defaults, accelerometer setting persists to UserDefaults.
**Files:** `RocketLanderTests/GameStateTests.swift`

### 9. LandingPlatformTests (5 tests)
**What:** Multipliers (1.0/2.0/5.0), stars (1/2/3), widths (130/110/80), positions (0.18/0.50/0.82), allCases count (3).
**Files:** `RocketLanderTests/LandingPlatformTests.swift`

## Research / Ideas Discussed
- UI tests (XCUITest) deferred — requires accessibility identifiers across many view files, separate task
- Integration tests (full SpriteKit scene testing) considered too complex and low ROI for now

## Technical Notes
- Tests clean UserDefaults keys in setUp/tearDown to avoid test pollution
- Scoring tests use a helper method with sensible defaults to reduce boilerplate
- The scheme had no `<Testables>` section — had to add it manually to enable `xcodebuild test`
- One test initially failed: `testBaseScoreOnly` expected 100 but got 700 because dead-center positioning still earned 600 center precision points. Fixed by positioning rocket at platform edge.

## Decisions
1. **Test-only scoring helper (not app code modification)**: Initially extracted scoring as a static method on GameScene, but this modified app code while Build 16 is under App Store review. Reverted to option 3: test-only helper that replicates the formula. Documented in DECISIONS.md.
2. **UserDefaults cleanup in tests**: Each test class that touches UserDefaults cleans its keys in setUp/tearDown to prevent cross-test pollution

## Definition of Done
- [x] Scoring formula testable via test-only helper (no app code changes)
- [x] Test target created in Xcode project
- [x] 7 test files written (51 tests total)
- [x] All 51 tests pass
- [x] Main app still builds
- [x] No behavior changes to existing code
- [x] STATUS.md updated
- [x] CHANGELOG.md updated
- [x] README.md updated (project structure + test command)
- [x] PROJECT_LOG.md updated
- [x] Session summary created

## Commits
- `261d618` — Add unit tests: 51 XCTest cases across 7 test files
- `aca62fd` — Fix session gaps: DECISIONS.md entry, commit hash, housekeeping
- `03739e0` — Move scoring helper to test target, restore app code to Build 16

## Repo Housekeeping
- [x] Working tree clean (no stale untracked files)
- [x] .gitignore up to date
- [x] README.md project structure matches actual files
- [x] No secrets or credentials in tracked files

## Next Actions
- [ ] Add UI tests (XCUITest) — requires accessibility identifiers
- [ ] Wait for App Store review response for v2.0.2
- [ ] Plan v2.1.0 (Game Center + achievements)
