# Changelog

All notable changes to the Starship Lander project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.3] — Build 30 PUBLISHED (approved 2026-02-06)

### Changed
- **Scoring Rebalance (Session 48)**: Comprehensive scoring improvements to address low score feedback:
  - Soft Landing: 500→550 pts, Horizontal Precision: 400→450 pts (subtotal max 2000→2100)
  - Velocity scoring denominator changed from safe to hard threshold — smooth curve with HARD landing partial credit (no more zero-out cliff)
  - Fuel multiplier range: 1.0-2.0x → 1.0-2.2x
  - Fuel consumption reduced: thrust 0.30→0.27%/frame, rotation 0.08→0.07%/frame, accelerometer 0.04→0.035×tilt
  - **Tilt bands**: Tilt now uses SAFE/HARD/FAIL bands like speed (≤2.9° safe, ≤5.7° hard with partial credit, >5.7° crash). Doubles survivable tilt range. Rotation scoring uses hard tilt as denominator.
  - New theoretical max: 23,100 (was 20,000). Typical scores +15-30% across all scenarios.
- **Europa Cryogeysers (Session 47)**: Replaced ice slide crash mechanic (H.Speed > 20 = instant death) with cryogeyser eruptions — intermittent force-based ice/water plumes that push the rocket upward. 3 fixed geyser positions with staggered active/calm cycling (2-3s active, 3-5s calm), blue/white/cyan particle columns, subtle vent markers on surface. Ice shimmer and low platform friction preserved. Disruptive but survivable.
- **Speed Thresholds Tightened (Session 46)**: Made landings harder across all platforms:
  - Platform A: safe V 80→70, hard V 120→100, safe H 60→50, hard H 100→80 (~15% tighter)
  - Platform B: safe V 55→50, hard V 85→75, safe H 45→40, hard H 75→60 (~15% tighter)
  - Platform C: safe V 35→33, hard V 55→52, safe H 30→28, hard H 50→48 (~5% tighter)
- **Jupiter Difficulty Increase (Session 46)**: Wind now pushes left→right exclusively with stronger force (base 20.0), ambient wind during calm periods, gravity increased from -4.8 to -5.2
- **Titan Thrust Reduction (Session 46)**: Dense atmosphere now reduces thrust to 75% efficiency instead of applying drag damping (makes it harder, not easier)
- **Mercury Heat Shimmer Enhanced (Session 46)**: Increased thrust perturbation wobble, added rising heat distortion particle effect
- **All Celestial Bodies Fixed (Session 46)**: Astronomically-correct bodies visible from each landing location:
  - Moon → Earth, Mars → sunSmall, Titan → Saturn (with rings), Europa → Jupiter (with bands)
  - Earth → Moon (with craters), Venus → sunMedium, Mercury → sunLarge (with glow/corona)
  - Ganymede → Jupiter, Io → Jupiter, Jupiter → europaSmall
- **Earth Platform Movement (Session 46)**: Zone-based collision avoidance — Platform B stays in 5%-50% zone, Platform C stays in 55%-95% zone, eliminating startup collision
- **CENTER Badge Removed (Session 46)**: Flight Data panel CENTER row now shows value only without OK/HARD/FAIL badge

### Fixed
- **Menu Button Truncation (Session 46)**: "Menu" button on landing report no longer truncated on smaller screens
- ~~**Europa Ice Now Affects Gameplay (Session 46)**~~: Superseded by cryogeysers (Session 47)
- **Partial Platform Landing Detection (Session 46)**: Both rocket legs (47pt span) must be within platform bounds to land successfully — one leg hanging off now causes crash ("Missed the platform!")

### Changed
- **Flight Data Panel Redesign (Session 45)**: Complete rewrite of `FinalStatsView` with HUD-style design language:
  - SF Symbol icons per metric (rotate.right, arrow.down, arrow.left.arrow.right, fuelpump.fill, scope)
  - OK/HARD/FAIL colored badge pills (green/yellow/red) per metric based on thresholds
  - 3-color value system matching badges
  - Gray divider lines between rows
  - Centered header with sparkle decorations
  - "HARD LANDING" yellow badge / "RAPID UNSCHEDULED DISASSEMBLY" red badge at bottom
  - Band logic: tilt (safe/fail), V/H speed (uses LandingThresholds), fuel (>20%/>0%/0%), center (<20pt/<30pt/≥30pt)
- **Randomized Crash Headlines (Session 45)**: Static "CRASH!" replaced with pool of 20 randomized messages. SpaceX references ("RAPID UNSCHEDULED DISASSEMBLY", "LITHOBRAKING DETECTED"), space mission quotes ("HOUSTON, WE HAVE A PROBLEM"), Kerbal vibes ("GRAVITY: 1 — PILOT: 0"), dry humor ("TASK FAILED SUCCESSFULLY"). Different message each crash.
- **Game-Over Overlay Restructure (Session 45)**: `GameOverView` moved from HUD VStack to ZStack root in `GameContainerView` for proper full-screen layering. Previously, the overlay was constrained within the HUD VStack causing buttons to be cut off and requiring scroll. See `Screenshots/v2.0.3-bugs/bug14_gameover_overlay_cutoff_buttons_hidden.jpeg` and `bug15_gameover_overlay_scrolled_buttons_visible.jpeg`.

### Fixed
- **High Score Sheet Not Appearing (Session 45)**: Race condition where `onAppear` fired before `gameState` properties propagated. Added `onChange` listeners for `gameState.score` and `gameState.landed` as fallback triggers. Previously the high score input was inline within the overlay, also requiring scroll — see `Screenshots/v2.0.3-bugs/bug16_highscore_inline_requires_scroll.jpeg`. Now presented as a modal sheet.

### Changed
- **Build Hygiene Improvements (Session 42)**:
  - `.gitignore` updated: added `*.p8`, `*.key`, `*.pem`, `*.secret`, `.env`, `.env.*`, `.apple_id`, `*.ipa`, `*.dSYM`, `*.dSYM.zip` patterns
  - All `print()` statements wrapped in `#if DEBUG` guards (5 occurrences in `RocketLanderApp.swift` and `BannerAdView.swift`)
  - ATT request optimized: only calls `requestTrackingAuthorization` when status is `.notDetermined`
  - Player name TextField capped at 20 characters
  - Legacy `Podfile` deleted (project uses SPM)

### Fixed
- **GameOverView Text Truncation**: Landing success messages and crash diagnostic messages were truncated on device. Added `.multilineTextAlignment(.center)` + `.fixedSize(horizontal: false, vertical: true)` to landing message, crash primary diagnostic, and crash secondary diagnostic. Wrapped GameOverView body in ScrollView for vertical overflow protection on tall content (landing + new high score scenario).
- **Menu Ad Banner Clipping (Improved)**: Previous fix (16pt bottom padding) was insufficient — banner was still clipped by home indicator. Restructured MenuView: moved `BannerAdContainer()` outside ScrollView into a `VStack(spacing: 0)` wrapper, pinning the ad at the bottom where SwiftUI's safe area layout naturally keeps it above the home indicator. Verified on iPhone 16 Pro simulator.
- **Menu Layout Overflow**: Menu content (~700pt) overflowed on most iPhones, with the banner ad covering the bottom section. Replaced the inline "HOW TO PLAY" section with a "How to Play >" text button that opens a rich info sheet (`HowToPlayView`). Added 60pt bottom padding to ScrollView content to clear the banner ad. Saves ~79pt of vertical space — menu now fits without scrolling on iPhone 12 mini and larger.

### Added
- **How to Play Info Sheet** (`HowToPlayView.swift`): A scrollable sheet accessible from the menu with 5 sections: Controls (adapts to button/accelerometer setting), Landing Platforms (table with pad/name/width/multiplier/stars), Speed Bands (SAFE/HARD/FAIL explanation + per-platform threshold table), Scoring (all 6 components, fuel/platform multipliers, max 20,000), Campaign (all 10 levels with gravity and special mechanic). Dark theme matching the app, orange accent headers.

### Changed
- **Code Housekeeping (Session 37)**: Removed dead code, fixed imports, deleted stale file. No behavior changes. 9 files changed, 284 deletions.
  - Removed: `leftFlame`/`rightFlame` (GameScene), `crashMessage()`/`crashMessages`/`crashNudges` (LandingMessages), `crashNudge` (GameState), `getTopScore()` (HighScoreManager), `Triangle` shape (ShapeViews), unused `CrashCause` enum cases (`terrainCollision`, `outOfBounds`)
  - Fixed imports: `import SwiftUI` → `import Foundation` + `import Combine` in model files; removed unused `import SpriteKit` from ContentView
  - Deleted stale `SETUP.txt`
  - Updated tests to match removals (90 → 89 tests)

### Added
- **Unit Tests**: 89 XCTest cases across 10 test files covering core game logic
  - ScoringTests: formula verification, HARD penalty, constraint tests, realistic scenarios (16 tests)
  - HighScoreManagerTests: persistence, sorting, backward-compat decoding (9 tests)
  - CampaignStateTests: level unlock, stars, score tracking, persistence (10 tests)
  - LevelDefinitionTests: level data integrity, gravity/thrust progression (8 tests)
  - LandingMessagesTests: message selection logic, pool verification (4 tests)
  - GameStateTests: initial values, reset, accelerometer persistence (3 tests)
  - LandingPlatformTests: multipliers, stars, widths, positions (5 tests)
  - CrashDiagnosticTests: crash classification, precedence, determinism (14 tests)
  - LandingEvaluationTests: per-platform speed band classification, boundaries, composites (20 tests)
  - ScoringHelper: test-only scoring formula replica
- **Per-Platform Speed Bands + Threshold Enforcement**: `LandingThresholds.swift` — single source of truth for SAFE/HARD/FAIL speed thresholds per platform. Platform A (V≤80/H≤60 safe), B (V≤55/H≤45), C (V≤35/H≤30). `checkLanding()` rewritten to use `LandingThresholds.evaluate()` with post-thrust tracked velocities — speed now affects landing success for the first time (exceeding FAIL threshold = crash). HUD updated to show Platform C safe values (V<35, H<30). Old hardcoded V<40/H<25 constants removed.
- **Perfect Landing Score Analysis**: `Scripts/calculate_perfect_scores.py` — frame-by-frame physics simulation computing maximum achievable scores for all 33 level/platform combinations. Models exact SpriteKit physics (gravity, thrust, fuel, screen wrapping, campaign reentry state). Best: Classic C = 14,504 via left screen wrap.

### Changed
- **Removed explicit HARD landing penalty**: The 0.4× subtotal multiplier for HARD landings has been removed. Superseded by smooth curve scoring in Session 48 — velocity components now use hard threshold as denominator, giving HARD landings partial credit.
- **Scoring uses per-platform denominators**: Velocity scoring components use platform-specific hard thresholds as denominators, meaning harder platforms have tighter scoring curves. HARD landings get meaningful partial credit instead of zeroing out.

---

## [2.0.3] - 2026-02-01 (Phase: Campaign Engagement)

### Added
- **Fixed Reentry Start State (Campaign Only)**: Campaign ships spawn with a deterministic 6.9° left tilt and 15 pts/s rightward drift, preventing trivial "hold thrust" strategy. Classic mode unchanged.
- **HUD Tilt Angle Display**: Real-time tilt indicator in degrees with directional color coding (cyan=left, orange=right, green=safe). Includes direction letter (L/R) when tilted beyond safe threshold.
- **Final Stats Panel**: Flight data (tilt, vertical speed, horizontal speed, fuel, center distance) frozen at moment of landing/crash and displayed on game over screen in both modes.
- **Deterministic Crash Messages**: Cause-based crash feedback tied to actual failure values, replacing random crash messages. Priority order: tilt > vertical speed > horizontal speed > approach speed. Same crash always produces the same message.
- **CrashDiagnostic Unit Tests**: 14 new tests verifying crash classification, precedence ordering, secondary hints, determinism (100x repeat), and edge cases.

### Changed
- **Perfect Score Simulation**: Updated `Scripts/calculate_perfect_scores.py` to model campaign reentry state (initial tilt + drift). Campaign scores drop <1% due to tilt correction fuel cost (~0.24%). Best unchanged: Classic C = 12,132.

### Fixed
- **HUD Tilt Truncation**: Tilt value was truncated with ellipsis ("12...L" instead of "12.8° L") due to `minimumScaleFactor` shrinking text. Fixed with `fixedSize()` and widened HUD from 150pt to 170pt.
- **Post-Collision Zeroed Velocities**: Final stats showed V.Speed=0 on crash because SpriteKit zeroes velocities during collision resolution. Fixed with pre-contact velocity tracking in the update loop (`lastTrackedVerticalSpeed`, `lastTrackedHorizontalSpeed`, `lastTrackedTilt`).
- **HUD vs Flight Data Mismatch**: HUD showed live values while Flight Data showed frozen snapshot, causing inconsistent displays on game-over screen. HUD now reads from `final*` values when `gameOver` is true.
- **Visual Start State Mismatch**: Campaign ships appeared upright at spawn despite having a reentry tilt. Fixed by applying `rocket.zRotation` in `setupScene()` after rocket creation.
- **Fuel Display Rounding**: HUD fuel used `Int()` (truncation) while Flight Data used `"%.0f"` (rounding), causing 99% vs 100% discrepancy for the same value. Both now use `"%.0f"` rounding.
- **Signed Tilt Preservation**: `finalTiltAngle` changed from absolute to signed value to preserve L/R direction for HUD display on game-over. `abs()` applied where needed (Flight Data, crash diagnostics).
- **Landing Threshold Using Post-Collision Velocity**: `checkLanding()` read velocity from physics body after SpriteKit collision resolution absorbed impact energy, allowing landings at V.Speed=71 to pass the V<50 threshold. Now uses pre-contact tracked values for threshold checks — same source as HUD, Flight Data, and crash diagnostics.

### Known Issues (Build 19)
- **⚠️ CRITICAL: Impossible to land on device.** Pre-contact tracked values are captured before thrust application in `update()`, making them systematically higher than actual post-thrust velocity. Landing threshold check rejects valid landings.
- **⚠️ CRITICAL: Velocity thresholds were dead code since initial commit.** SpriteKit zeros velocities during collision resolution before `didBegin(contact:)`. The V<40 and H<25 checks always saw V≈0 — speed never affected landing success in any build through Build 18. Build 19 is the first build to enforce speed. See `Docs/DIAGNOSTIC_velocity_thresholds.md`.
- **HUD threshold mismatch since creation.** HUD shows V<50 H<30 but actual GameScene thresholds are V<40 H<25. Created wrong in commit `fede844`, never caught because both display and threshold check were "wrong" in compatible ways.
- **Scoring was inflated.** All prior scores used near-zero post-collision velocities for speed components, producing near-maximum speed scores. Enforcement would lower achievable scores.

---

## [2.0.2] - 2026-01-31 (Phase: Campaign Polish) — SUBMITTED FOR REVIEW 2026-02-01

### Changed
- **Scoring Rebalance**: Redistributed score components to reward center precision more
  - Soft Landing: 700 → 500 points
  - Platform Center: 350 → 600 points
  - Approach Control: 200 → 150 points
  - Fuel multiplier cap: 2.5x → 2.0x
  - New max theoretical score: 20,000 (was 25,000)
- **Proportional Thrust Vectoring**: Replaced binary RCS lateral assist with smooth proportional correction
  - Lateral force scales with tilt angle via sin(rotation) × 0.15 factor
  - Only active while thrusting (no free lateral assist)
- **Venus (Level 6)**: Vertical updrafts replace horizontal turbulence
  - Wind particles now move vertically instead of horizontally
  - Description: "Vertical updrafts disrupt your descent."
  - Mechanic display name: "Vertical Updrafts"
- **Jupiter (Level 10)**: Sudden gusts with calm windows replace smooth sine-wave wind
  - 2-4 second calm periods with light residual wind
  - Followed by 1.5-2.5 second sharp directional gusts
  - Description: "Sudden gusts between calm windows."
- **Mercury (Level 7)**: Heat shimmer now disrupts thrust control
  - Random velocity perturbation applied when thrusting
  - Description: "Heat shimmer disrupts thrust control."
- **Io (Level 9)**: Volcanic eruption particles are now deadly
  - Eruption particles have physics bodies (groundCategory) — contact crashes the rocket
  - Physics bodies removed before fade-out so fading particles are safe
  - Description: "Volcanic debris is deadly — time it."

### Added
- **Leaderboard Star Metadata**: High score entries now store star rating
  - HighScoreEntry gains backward-compatible `stars` field (defaults to 0 for old data)
  - Small star icons displayed between name and score in leaderboard rows
  - Stars passed through from both CampaignState.completedLevel and classic mode saveScore

### Fixed
- **Classic mode star rating not saved**: Classic mode high scores now correctly store the star rating (platform A=1, B=2, C=3) — previously always saved as 0
- **Classic mode star rating not displayed**: Classic section in leaderboard view and menu TOP PILOTS now pass stars to scoreRow — previously only campaign rows showed stars

---

## [2.2.0] - Unreleased (Phase: Monetization)

### Added
- **Remove Ads IAP**: One-time non-consumable purchase ("Support Development")
  - StoreKit 2 with async/await
  - Hides all banner ads when purchased
  - Restore Purchases support
  - Local StoreKit Configuration for testing

### Changed
- **Xcode capabilities**: Added In-App Purchase entitlement

---

## [2.1.0] - Unreleased (Phase: Community) — CODE COMPLETE

### Added
- **Game Center Leaderboards**: 12 leaderboards (1 classic + 10 campaign + 1 galaxy_rank aggregate)
  - `GameCenterManager.swift`: ObservableObject + singleton pattern
  - Automatic authentication on launch with graceful fallback (GC features hidden when not signed in)
  - Fire-and-forget score submission after each successful landing via `GKLeaderboard.submitScore()`
  - Galaxy Rank = sum of best scores across all 10 campaign levels, submitted to aggregate leaderboard
  - Galaxy Rank displayed on menu (badge), campaign screen (explanation), and leaderboard screen (header)
  - GKAccessPoint on menu for native Game Center dashboard access
  - "View Global Rankings" button in LeaderboardView opens `GKGameCenterViewController`
- **Game Center Achievements**: 10 achievements tracking player progression and skill
  - Eagle Has Landed (any SAFE landing), Precision Landing (SAFE on B), Elite Landing (SAFE on C)
  - Fuel Master (≥65% fuel), Precision Pilot (SAFE C with ≤2°tilt, campaign), Triple Elite (SAFE C on 3+ campaign levels)
  - Planet Conquered (3 stars on a campaign level), First Try Perfection (SAFE C first attempt, campaign)
  - Solar System Elite (30 total stars), Master Lander (SAFE C on all 10 campaign levels)
  - Persistent tracking: `safePlatformCLevels` (Set<Int>) and `attemptsByLevel` ([Int:Int]) saved to UserDefaults
  - Idempotent unlocking — safe to report multiple times, `showsCompletionBanner = true`
- **Share Score Card**: Generate and share landing results as an image
  - `ShareScoreCardView.swift`: 320pt dark gradient card with game logo, mode/level, stars, score, platform+band badge, flight data
  - `ShareHelper.renderScoreCard()`: ImageRenderer (iOS 16+) with UIHostingController snapshot fallback (iOS 15)
  - `ShareHelper.shareImage()`: Native share sheet via UIActivityViewController
  - Share button on game-over screen (only visible on successful landings)

### Changed
- **Xcode capabilities**: Added Game Center entitlement (`RocketLander.entitlements`)
- **GameScene**: Added `campaignState` parameter, `recordAttempt()` call in `startGame()`, GC score submission + achievement check in `successfulLanding()`
- **GameContainerView**: Passes `campaignState` and `gameCenterManager` through to GameScene
- **ContentView/MenuView**: Galaxy Rank badge, GKAccessPoint management, `fetchGalaxyRank()` on appear
- **LeaderboardView**: Galaxy Rank header, "View Global Rankings" button, `GKDismissHandler`
- **LevelSelectView**: Galaxy Rank explanation section after level grid
- **App Privacy**: Added "Gameplay Content" declaration for Game Center

---

## [2.0.1] - 2026-01-31

### Added
- **Dedicated Leaderboard Screen**: Tap "TOP PILOTS" on main menu to view all high scores
  - Classic Mode top-3 scores section
  - Campaign per-level top-3 scores for all 10 levels
  - Locked levels shown grayed out with lock icon
  - Gold/silver/bronze rank colors for top-3 positions
  - Scrollable layout with back navigation

### Fixed
- **Accelerometer toggle not affecting gameplay**: MenuView used a separate `@AppStorage` binding that didn't sync with `GameState`. Toggle now binds directly to `gameState.useAccelerometer` so controls and game scene react immediately.

### Changed
- **Version number relocated**: Moved from bottom of scroll content to fixed top-right overlay on menu screen, ensuring it's always visible regardless of scroll position
- **TOP PILOTS section is now tappable**: Acts as entry point to the full leaderboard with "View All >" hint text

---

## [2.0.0] - 2026-01-30

### Added
- **Three Landing Platforms (A/B/C)**: Each with different sizes, positions, and score multipliers
  - Platform A (left, 18%): 130pt wide, 1x multiplier, green lights — "Training Zone"
  - Platform B (center, 50%): 110pt wide, 2x multiplier, yellow lights — "Precision Target"
  - Platform C (right, 82%): 80pt wide, 5x multiplier, red lights — "Elite Landing"
  - Platform labels and multiplier text displayed below each platform
  - Terrain generates valleys around each platform position

- **Campaign Mode**: 10 solar system levels with unique physics and visuals
  - Moon (1.6g), Mars (2.0g), Titan (2.2g), Europa (2.5g), Earth (2.8g)
  - Venus (3.2g), Mercury (3.5g), Ganymede (3.8g), Io (4.2g), Jupiter (4.8g)
  - Gravity increases monotonically by level for progressive difficulty
  - Special mechanics per level: wind, dense atmosphere, cryogeysers, moving platform, turbulence, heat shimmer, deep craters, volcanic eruptions, extreme wind
  - Campaign state persistence via UserDefaults (unlocked levels, stars, scores)
  - Level select grid UI with lock/unlock, star count, best scores

- **Per-Level Thrust Scaling**: Each planet has a unique engine thrust feel
  - Thrust ranges from 8.0 (Moon, floaty) to 18.5 (Jupiter, powerful but tight margin)
  - Thrust-to-gravity ratio decreases progressively: 5.0x (Moon) → 3.8x (Jupiter)
  - Classic mode unchanged at 12.0

- **Visual Effects for All Mechanics**:
  - Wind streak particles (Mars light dust, Venus heavy haze, Jupiter extreme streaks)
  - Atmosphere haze with drifting clouds (Titan)
  - Ice shimmer sparkles near platforms (Europa)
  - Heat shimmer rocket jitter (Mercury)
  - Volcanic eruption particles from terrain (Io)

- **Landing Result Messages**: Contextual feedback on landing/crash outcomes
  - Success messages rotate: "Landing confirmed.", "Precision achieved.", etc.
  - Elite messages for 3-star landings: "Elite landing.", "Near-perfect execution."
  - Crash messages with teaching nudges: "Try a slower approach.", etc.
  - Rare message (1 in 50 chance, score > 4500): "This was exceptional."

- **Haptic Feedback**: Tactile responses for all key actions
  - Thrust: light continuous pulse every 100ms
  - Rotation: medium impact on rotation start
  - Landing: success notification haptic
  - Crash: heavy double-tap impact

- **Star Rating System**: 1-3 stars based on landing platform (A=1, B=2, C=3)

- **Lateral Assist (RCS Thrusters)**: When tilted >5°, small horizontal nudge in tilt direction

- **Per-Level High Scores (Campaign)**: Campaign mode tracks top-3 scores per level/planet separately from classic mode's global leaderboard

- **Level Name HUD**: Planet/level name displayed at top center during campaign gameplay

- **Level Details on Menu**: Level select cards show gravity (m/s²) and special mechanic for unlocked levels

- **Ganymede Deep Craters**: Rock pillar obstacles and raised terrain edges create crater hazards
  - Three jagged rock pillars with physics bodies (left edge, between B-C, right edge)
  - Terrain walls ramp up to 350px at screen edges for crater bowl effect
  - Terrain edge-chain physics body — hitting terrain or rocks crashes the rocket
  - Makes Ganymede visually and mechanically distinct from other levels

- **Astronaut Easter Egg High Scores**: Default leaderboard entries on first launch
  - Classic mode: "Elon" at 1000 points (SpaceX reference)
  - Campaign: astronaut/scientist names relevant to each planet (Armstrong, Aldrin, Huygens, etc.)
  - Seeded only when no scores exist — won't overwrite player scores

### Fixed
- **Dynamic Island Cutoff**: Game title "STARSHIP" no longer hidden behind Dynamic Island on iPhone 16+
  - Menu wrapped in ScrollView to respect safe area insets
  - Reduced spacing, rocket illustration size (70×100 → 60×85), and button height for compact layout
- **Menu Content Cutoff**: "HOW TO PLAY" section and banner ad now fully visible on all screen sizes
- **Campaign Gravity Rebalanced**: All 10 levels now have progressively increasing gravity (1.6 → 4.8) for smooth difficulty curve
- **Earth Platform Overlap**: Moving platforms no longer overlap during movement
  - Platform A: vertical bob only (no horizontal movement)
  - Platform B: horizontal sway reduced from ±50px to ±30px
  - Platform C: horizontal movement reduced from ±30px to ±20px
  - Added edge clamping to enforce minimum 10pt gaps between platforms

### Changed
- **Scoring System**: Platform multiplier stacks with fuel multiplier
  - Formula: `subtotal × fuelMultiplier × platformMultiplier`
  - Max theoretical: 2000 × 2.5 × 5 = 25,000 points
- **Lateral Control**: Increased `rotationPower` from 0.025 to 0.04
- **Angular Damping**: Reduced from 1.0 to 0.7 for more responsive rotation
- **Rocket Start Position**: Now starts upper-left (x=15%, near top)
- **Menu Screen**: Two launch buttons — "Classic Mode" (orange) and "Campaign" (blue/purple)
- **Game Over Screen**: Shows star rating, platform info, "Next Level" button in campaign

### Architecture
- **File splitting**: Split 2 monolithic files (~900 lines each) into 21 organized files
  - `Models/`: GameState, HighScoreManager, LandingPlatform, LandingMessages, LevelDefinition, CampaignState
  - `Views/`: GameContainerView, GameOverView, HUDViews, ControlViews, ShapeViews, LevelSelectView
  - `Haptics/`: HapticManager
  - `GameScene+Setup.swift`, `GameScene+Effects.swift`, `GameScene+Sound.swift`, `GameScene+Scoring.swift`
- ContentView.swift trimmed to ContentView + MenuView only
- GameScene.swift trimmed to core update loop, physics, collision handling

---

## [1.1.5] - 2026-01-16

### Added
- **Version Number Display**: Shows current app version at bottom of menu screen in small gray text
  - Dynamically reads from app bundle (`CFBundleShortVersionString`)
  - Always displays the running version (no manual updates needed)

### Changed
- **New Scoring System**: Completely redesigned for better score differentiation (max ~5000 points)
  - **Continuous scoring**: Every improvement matters (no more tier-based jumps)
  - **Fuel multiplier**: Remaining fuel multiplies total score (1.0x to 2.5x)
  - Components: Soft Landing (700), Horizontal Precision (400), Platform Center (350), Rotation (250), Approach Control (200)
  - Examples: Perfect landing + 100% fuel = 5000, Good landing + 50% fuel = ~3500

### Fixed
- **HUD Text Wrapping**: Fixed velocity numbers and OK/HIGH indicators wrapping to multiple lines when values exceed 3 digits
  - Added line limits and minimum scale factor to velocity text
  - Added fixed size to status indicators
  - Increased HUD width from 130px to 150px for better readability

### App Store
- **New Screenshots**: Replaced v1.0 screenshots with actual v1.1.5 screenshots
  - Menu screen with leaderboard and version number
  - In-game gameplay shot
  - Crash/game over screen
  - All screenshots captured from iPhone 17 Pro Max simulator (1260x2736)

---

## [1.1.4] - 2026-01-15

### Added
- **New Starship App Icon**: Redesigned icon featuring authentic SpaceX Starship design
  - Cylindrical silver body with dome nose cone
  - Forward and aft flaps (dark gray)
  - Three engine nozzles with landing legs
  - Earth visible in background
  - Landing platform at bottom

### Fixed
- **High Score Input Bug (Complete Fix)**: Resolved root cause where keyboard appearance triggered scene resize, which called `setupScene()` and reset the game
  - Added `gameState.gameOver` check in `didChangeSize()` to prevent scene reset during game over
  - This properly allows the TextField to receive keyboard input without restarting

---

## [1.1.3] - 2026-01-14

### Fixed
- **High Score Input Bug (Partial)**: Attempted fix by disabling game scene touch handling when game over

### Changed
- **Developer Website**: Added rabbitolivestudios.github.io for AdMob app-ads.txt verification

---

## [1.1.2] - 2026-01-12

### Added
- **Accelerometer Controls**: New option to control rocket rotation by tilting your phone
  - Toggle between button controls and accelerometer in the menu
  - Dead zone to prevent drift when holding phone level
  - Smooth tilt response with adjustable sensitivity

### Changed
- **Reduced Rotation Sensitivity**: Button rotation is now gentler (0.025 vs 0.05) for finer control
- **Simplified Controls**: When using accelerometer, only thrust button is shown on screen
- **Dynamic Instructions**: "How to Play" section updates based on selected control type

### Technical Details
- CoreMotion framework integration for accelerometer input
- UserDefaults persistence for control preference
- Fuel consumption scales with tilt intensity in accelerometer mode

---

## [1.1.1] - 2026-01-12

### Fixed
- **High Score Input Bug**: Fixed issue where tapping the name input field would restart the game instead of allowing text entry
- **Ad Loading**: Improved ad loading reliability with proper delegate handling

### Technical Details
- Hide game controls when game over screen is displayed
- Added BannerViewDelegate for ad loading diagnostics
- Moved ad loading to main thread with proper timing

---

## [1.1.0] - 2026-01-10

### Added
- **AdMob Integration**: Real Google Mobile Ads support for ad revenue
  - Banner ads on menu screen
  - Banner ads during gameplay
  - Google Mobile Ads SDK via Swift Package Manager
  - SKAdNetwork configuration for ad attribution

- **App Tracking Transparency**: Privacy-compliant ad tracking
  - ATT permission prompt on first launch
  - User can allow or deny tracking
  - Ads work either way (personalized if allowed)

### Technical Details
- GADMobileAds SDK initialized at app launch
- UIViewRepresentable wrapper for GADBannerView integration with SwiftUI
- Test ad unit IDs for development, configurable for production
- ATTrackingManager for iOS 14+ tracking permission

---

## [1.0.0] - 2026-01-08

### Added
- **Starship Visual Design**: Complete redesign of rocket to resemble SpaceX Starship
  - Tall cylindrical silver body with dome nose cone
  - 2 forward flaps and 2 aft flaps (dark gray)
  - 3 engine nozzles with landing legs
  - Updated menu illustration to match

- **16-Bit Sound Effects**: Retro chiptune-style audio
  - `thrust.wav` - Engine rumble loop while thrusting
  - `rotate.wav` - Quick blip on rotation input
  - `land_success.wav` - Victory fanfare on successful landing
  - `explosion.wav` - Crash sound effect
  - Python script (`Scripts/generate_sounds.py`) to regenerate sounds

- **Improved Scoring System**: Complete revamp for better differentiation
  - Base score: 100 points for successful landing
  - Fuel efficiency: 0-500 points (exponential scaling - main differentiator)
  - Soft landing bonus: 0-300 points based on vertical speed
  - Horizontal precision: 0-200 points for drift control
  - Platform center bonus: 0-150 points for landing accuracy
  - Rotation precision: 0-100 points for landing upright
  - Approach control: 0-100 points for controlled descent
  - Maximum possible score: ~1450 points

- **Streamlined High Score Flow**: Name input appears immediately when score qualifies

### Changed
- Flame position adjusted for new Starship engine location
- Sound files integrated into Xcode project build resources
- Removed ad placeholders for clean initial release (ads planned for v1.1)

### Technical Details
- Sound generation uses pure Python with `wave` module (no external dependencies)
- SKAudioNode used for looping thrust sound with proper start/stop handling
- SKAction.playSoundFileNamed used for one-shot sound effects

---

## [0.1.0] - 2026-01-07 (Initial Development)

### Added
- Core gameplay with SpriteKit physics engine
- Thrust and rotation controls
- Fuel management system
- Landing detection with speed/rotation thresholds
- Procedurally generated terrain and starfield
- Platform with randomized positioning
- High score leaderboard (top 3 scores)
- AdMob integration placeholder
- Privacy policy template
- App Store submission automation scripts

### Game Mechanics
- Gravity: 2.0 units
- Thrust power: 12.0 velocity change per frame
- Rotation power: 0.05 angular velocity per input
- Fuel consumption: 0.3% per frame (thrust), 0.08% per frame (rotation)
- Safe landing thresholds:
  - Vertical speed: ≤ 40 units
  - Horizontal speed: ≤ 25 units
  - Rotation: ≤ 0.05 radians (~3 degrees)
  - Approach speed: ≤ 80 units

---

## Version History Summary

| Version | Date       | Highlights                                    |
|---------|------------|-----------------------------------------------|
| 2.0.3   | 2026-02-01 | Campaign engagement: reentry state, tilt HUD, flight stats, crash diagnostics |
| 2.0.2   | 2026-01-31 | Campaign polish: scoring, thrust vectoring, planet differentiation |
| 2.0.1   | 2026-01-31 | Dedicated leaderboard screen, version label fix |
| 2.0.0   | 2026-01-30 | Campaign mode, per-planet physics, visual effects |
| 1.1.5   | 2026-01-16 | New scoring system, HUD fixes, version display|
| 1.1.4   | 2026-01-15 | New Starship icon, high score bug fix         |
| 1.1.3   | 2026-01-14 | Developer website, partial bug fix            |
| 1.1.2   | 2026-01-12 | Accelerometer controls, reduced sensitivity   |
| 1.1.1   | 2026-01-12 | Bug fixes (high score input, ads)             |
| 1.1.0   | 2026-01-10 | AdMob integration for ad revenue              |
| 1.0.0   | 2026-01-08 | Starship design, sounds, improved scoring     |
| 0.1.0   | 2026-01-07 | Initial development, core gameplay            |
