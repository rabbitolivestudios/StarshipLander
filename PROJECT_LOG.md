# Starship Lander - Project Log

This file documents the development history and decisions for the Starship Lander project. Use this to continue work in future sessions.

---

## Project Overview

- **App Name:** Starship Lander
- **Bundle ID:** com.tboliveira.StarshipLander
- **Platform:** iOS (iPhone)
- **Framework:** SwiftUI + SpriteKit
- **Developer:** Thiago Borges de Oliveira
- **Team ID:** 6XK6BNVURL

---

## Current Status (2026-02-01)

| Version | Build | Status |
|---------|-------|--------|
| 1.0 | 2 | Rejected (Guideline 5.1.2 - tracking without ATT) |
| 1.1.0 | 4 | Published on App Store |
| 1.1.1 | 5 | Bug fixes (not uploaded - superseded) |
| 1.1.2 | 6 | Published - Accelerometer controls |
| 1.1.3 | 7 | Published - Partial bug fix + URL update |
| 1.1.4 | 10 | Published - Bug fix + new icon |
| 1.1.5 | 11 | Published on App Store - New scoring system + HUD fixes |
| 2.0.0 | 12 | ~~SUBMITTED FOR REVIEW~~ — replaced by v2.0.2 (never reviewed after 2 days) |
| 2.0.1 | 13 | Dedicated leaderboard screen, version label fix |
| 2.0.2 | 16 | **SUBMITTED FOR REVIEW** (2026-02-01) — replaces v2.0.0, campaign polish + star fixes |
| 2.0.3 | 22 | Per-platform speed bands + velocity threshold enforcement + removed HARD penalty + scoring overhaul + menu ad clipping fix. Uploaded to TestFlight. Supersedes Build 21. |

**NEXT STEPS:**
1. Device test Build 22 on TestFlight (scoring feel, HARD landing scores, threshold enforcement behavior, menu ad fix)
2. Wait for App Store review response for v2.0.2 (submitted 2026-02-01)
3. If approved, decide whether to submit v2.0.3 (Build 22) or wait for v2.1.0

**v2.1.0 PLANNED — Phase: Community (scope locked):**
- [planned] 11 Game Center leaderboards (1 classic + 10 campaign)
- [planned] 10 Game Center achievements
- [planned] Share Score Card (SwiftUI render + native share sheet)

**v2.2.0 PLANNED — Phase: Monetization (scope locked):**
- [planned] "Support Development" IAP (remove ads, StoreKit 2)

**BACKLOG (v2.3+):**
- ~~Campaign per-level high scores display~~ — **DONE in v2.0.1**
- iPad support
- Localization
- ~~Automated tests (XCTest)~~ — **Unit tests DONE (Session 30)**; UI tests (XCUITest) still planned

---

## AdMob Configuration

| Setting | Value |
|---------|-------|
| Publisher ID | pub-3801339388353505 |
| App ID | ca-app-pub-3801339388353505~8476936917 |
| Banner Ad Unit ID | ca-app-pub-3801339388353505/4009394081 |

**Implementation:**
- Test ads shown in DEBUG builds
- Production ads in RELEASE builds
- Banner ads on menu screen and during gameplay
- SDK: Google Mobile Ads via Swift Package Manager (v12.14.0)

---

## Development History

### Session 1 (2026-01-07) - Initial Development
- Created core game with SpriteKit physics
- Implemented thrust and rotation controls
- Added fuel management system
- Created landing detection logic
- Built procedurally generated terrain
- Added high score leaderboard (top 3)
- Created placeholder for AdMob ads

### Session 2 (2026-01-08) - v1.0 Enhancements
- **Starship Redesign:** Changed rocket visual to resemble SpaceX Starship
  - Cylindrical silver body with dome nose
  - 2 forward flaps, 2 aft flaps (dark gray)
  - 3 engine nozzles with landing legs
  - Updated menu illustration to match

- **Sound Effects:** Added 16-bit retro sounds
  - `thrust.wav` - Engine loop while thrusting
  - `rotate.wav` - Blip on rotation input
  - `land_success.wav` - Victory fanfare
  - `explosion.wav` - Crash sound
  - Generated via Python script (`Scripts/generate_sounds.py`)

- **Scoring System Revamp:**
  - Base: 100 points
  - Fuel efficiency: 0-500 points (exponential, main differentiator)
  - Soft landing: 0-300 points
  - Horizontal precision: 0-200 points
  - Platform center: 0-150 points
  - Rotation precision: 0-100 points
  - Approach control: 0-100 points
  - Max possible: ~1450 points

- **High Score Flow:** Simplified - name input appears directly when score qualifies

- **Bug Fix:** Thrust sound not playing - fixed with URL-based SKAudioNode initializer

### Session 3 (2026-01-08) - v1.0 Submission
- Removed ad placeholders for clean initial release
- Updated bundle ID to com.tboliveira.StarshipLander
- Configured Xcode signing with Apple Developer account
- Registered test device (iPhone 16 TBO)
- Successfully archived and uploaded v1.0 (build 2) to App Store Connect
- Submitted for Apple review

### Session 4 (2026-01-08) - v1.1 AdMob Integration
- User added Google Mobile Ads SDK via Swift Package Manager
- Updated `BannerAdView.swift` with real GADBannerView implementation
- Updated `RocketLanderApp.swift` to initialize Mobile Ads SDK
- Added banner ads to menu and game screens in `ContentView.swift`
- Configured Info.plist with AdMob App ID
- Updated API calls for latest SDK (BannerView, Request, AdSizeBanner)
- Updated version to 1.1 (build 3)
- Successfully archived and uploaded to App Store Connect
- **Waiting for v1.0 approval before submitting v1.1**

### Session 5 (2026-01-08) - v1.2 Planning
- Discussed v1.2 feature options
- Selected: **Haptic Feedback** + **Campaign Mode**
- Refined campaign concept to **Solar System Theme**
- Each level = a celestial body with unique physics and visuals
- Created detailed implementation plan

### Session 6 (2026-01-10) - App Store Rejection Fix
- v1.0 rejected for Guideline 5.1.2 (tracking without ATT permission)
- Root cause: App Privacy indicated Device ID tracking, but no ATT prompt
- Solution: Implement App Tracking Transparency for v1.1
- Added `AppTrackingTransparency` framework
- ATT permission prompt on app launch
- Added `NSUserTrackingUsageDescription` to Info.plist
- Updated build to 4
- Uploaded v1.1 (build 4) to App Store Connect
- **v1.1 (build 4) SUBMITTED FOR REVIEW**

### Session 7 (2026-01-12) - v1.1 Published + Bug Fixes + Accelerometer

**v1.1 APPROVED AND PUBLISHED!**

**Bugs Found After Release:**
1. High score name TextField restarts game when tapped
2. Ads not showing (expected - AdMob takes 24-48h for new apps)

**v1.1.1 Bug Fixes (Build 5):**
- Fixed TextField restart by hiding `BottomControlsView` when `gameOver` is true
- Added `BannerViewDelegate` for ad loading diagnostics
- Did not upload - superseded by v1.1.2

**v1.1.2 Control Improvements (Build 6):**
- User reported rotation controls too sensitive
- Implemented BOTH fixes:
  1. Reduced button rotation power (0.05 -> 0.025)
  2. Added accelerometer controls option

**Accelerometer Implementation:**
- CoreMotion framework for device tilt detection
- Dead zone (0.1) prevents drift when holding phone level
- Sensitivity (0.06) for smooth rotation response
- Fuel consumption scales with tilt intensity
- Settings toggle in MenuView with UserDefaults persistence
- Dynamic UI: rotation buttons hidden in accelerometer mode

### Session 8 (2026-01-14) - v1.1.3 Bug Fix + Developer Website

**v1.1.2 APPROVED AND PUBLISHED!**

- High score TextField still not working (game restarts on tap)
- GitHub Pages Setup: rabbitolivestudios.github.io
- v1.1.3 Bug Fix (Build 7): Added `.allowsHitTesting(!gameState.gameOver)`
- App Store Connect URLs Updated

**v1.1.3 PUBLISHED** (2026-01-14)

### Session 9 (2026-01-15) - v1.1.4 Complete TextField Bug Fix

- Root cause: `didChangeSize()` calling `setupScene()` when keyboard appeared
- Fix: Added `!gameState.gameOver` check in `didChangeSize()`
- New Starship App Icon
- v1.1.4 (build 10) uploaded
- **PUBLISHED** (2026-01-15)

### Session 10 (2026-01-16) - v1.1.5 Scoring System + Screenshots

- Redesigned scoring from tier-based to continuous with fuel multiplier
- Max ~5000 points (subtotal 2000 x 2.5 fuel multiplier)
- HUD text wrapping fixes
- Version number display on menu
- New App Store screenshots
- v1.1.5 (build 11) **SUBMITTED FOR REVIEW**

### Session 11 (2026-01-30) - v1.2 Major Implementation

**Massive codebase restructure and feature implementation.**

#### Phase 0: File Splitting
Split 2 monolithic files (~900 lines each) into 21 organized files across 4 directories:

**New Directory Structure:**
```
RocketLander/
├── Models/              (6 files)
│   ├── GameState.swift          — ObservableObject with new platform/campaign properties
│   ├── HighScoreManager.swift   — High score persistence
│   ├── LandingPlatform.swift    — Platform A/B/C enum (widths, multipliers, colors)
│   ├── LandingMessages.swift    — Success/crash messages with teaching nudges
│   ├── LevelDefinition.swift    — 10 campaign levels (gravity, visuals, mechanics)
│   └── CampaignState.swift      — Campaign persistence (unlocked levels, stars, scores)
├── Views/               (6 files)
│   ├── ShapeViews.swift         — RocketIllustration, StarshipBody, Parallelogram, Triangle
│   ├── HUDViews.swift           — TopHUDView, VelocityHUDView
│   ├── ControlViews.swift       — BottomControlsView, ControlButton, ThrustButton
│   ├── GameContainerView.swift  — GameContainerView + GameSceneView UIViewRepresentable
│   ├── GameOverView.swift       — Game over with stars, platform info, campaign buttons
│   └── LevelSelectView.swift    — Campaign level grid (lock/unlock, stars, best scores)
├── Haptics/             (1 file)
│   └── HapticManager.swift      — Thrust, rotation, landing, crash haptics
├── GameScene.swift              — Core update loop, physics, collision, campaign mechanics
├── GameScene+Setup.swift        — Scene setup: starfield, terrain, platforms, rocket
├── GameScene+Effects.swift      — Flames, explosions, success particles, shimmer, volcanic
├── GameScene+Sound.swift        — All sound methods
├── GameScene+Scoring.swift      — Scoring with platform multiplier
├── ContentView.swift            — ContentView + MenuView (Classic/Campaign buttons)
├── BannerAdView.swift           — AdMob (unchanged)
├── RocketLanderApp.swift        — App entry (unchanged)
└── Info.plist
```

#### Phase 1: Core Gameplay Improvements (v1.2)

**1.1 Lateral Control Fix:**
- `rotationPower`: 0.025 -> 0.04 (60% increase)
- `angularDamping`: 1.0 -> 0.7 (30% reduction)
- Lateral assist: when rocket tilted >5deg, small horizontal nudge (~2.0 units) applied in tilt direction (simulates RCS thrusters)

**1.2 Three Landing Platforms:**
| Platform | Position | Width | Multiplier | Lights | Stars |
|----------|----------|-------|------------|--------|-------|
| A "Training Zone" | x=18% | 130pt | 1x | Green | 1 |
| B "Precision Target" | x=50% | 110pt | 2x | Yellow | 2 |
| C "Elite Landing" | x=82% | 80pt | 5x | Red | 3 |

- Rocket starts from upper-left (x=15%, y=height-100)
- Terrain generates valleys around each platform position
- Each platform has label + multiplier text below it
- On collision, determines which platform was contacted
- **Scoring:** `finalScore = subtotal * fuelMultiplier * platformMultiplier`
- Max theoretical: 2000 * 2.5 * 5 = 25,000 points

**1.3 Landing Messages:**
- Success messages rotate: "Landing confirmed.", "Precision achieved.", etc.
- Elite (platform C): "Elite landing.", "Near-perfect execution."
- Rare message (1/50 chance, score > 4500): "This was exceptional."
- Crash messages: "Descent unstable." + teaching nudge ("Try a slower approach.")
- Star display: 1-3 stars based on platform landed on

**1.4 Haptic Feedback:**
- Thrust: light continuous pulse every 100ms while thrusting
- Rotation: medium impact on rotation start
- Landing: success notification haptic
- Crash: heavy double-tap impact

#### Phase 2: Campaign Mode (v1.3 features, implemented early)

**10 Campaign Levels:**
| # | Name | Gravity | Special Mechanic |
|---|------|---------|------------------|
| 1 | Moon | -1.6 | None (tutorial) |
| 2 | Mars | -3.7 | Light dust wind (constant force) |
| 3 | Titan | -1.4 | Dense atmosphere (high linear damping) |
| 4 | Europa | -1.3 | Ice surface (low friction platforms) |
| 5 | Earth | -9.8 | Moving barge (platform B oscillates) |
| 6 | Venus | -8.9 | Heavy turbulence (sine-wave variable wind) |
| 7 | Mercury | -3.7 | Heat shimmer (visual distortion effect) |
| 8 | Ganymede | -1.4 | Deep craters (elevated terrain between platforms) |
| 9 | Io | -1.8 | Volcanic eruptions (particle emissions from terrain) |
| 10 | Jupiter | -24.8 | Extreme wind gusts (strong oscillating force) |

**Campaign System:**
- `CampaignState` persisted to UserDefaults via Codable
- Level 1 always unlocked; completing a level unlocks the next
- Stars: best per level (platform A=1, B=2, C=3)
- Per-level high scores (top 3)
- Total stars displayed on menu (/30 max)

**UI Changes:**
- Menu: "CLASSIC" button (orange) + "CAMPAIGN" button (blue/purple)
- Level select grid: 2-column layout, lock/unlock states, stars, best scores, descriptions
- Game over: stars display, platform name + multiplier, "Next Level" button in campaign mode

**GameScene Campaign Integration:**
- Gravity set from `LevelDefinition` for each level
- Unique sky/terrain/celestial body visuals per level
- Special mechanics applied per-frame in update loop:
  - Wind forces (constant, sine-wave, extreme)
  - Moving platform (platform B oscillation with bounds)
  - Dense atmosphere (increased linear damping)
  - Ice surface (low friction physics bodies)
  - Heat shimmer (visual distortion action)
  - Volcanic eruptions (periodic particle emissions)
  - Deep craters (elevated terrain generation)

**Files Created:** 17 new files
**Files Modified:** ContentView.swift, GameScene.swift, project.pbxproj
**Build Status:** Compiles with 0 errors, 0 warnings

**Chat Transcript Export:**
- Created `Scripts/export_chat_transcripts.py` to convert JSONL transcripts to readable Markdown
- Exports user messages and assistant text responses
- Saves to `Docs/ChatTranscripts/` directory

---

## Key Files

| File | Purpose |
|------|---------|
| `RocketLander/ContentView.swift` | ContentView + MenuView (Classic/Campaign navigation) |
| `RocketLander/GameScene.swift` | Core update loop, physics, collision, campaign mechanics |
| `RocketLander/GameScene+Setup.swift` | Scene setup: starfield, terrain, 3 platforms, rocket |
| `RocketLander/GameScene+Effects.swift` | Flames, explosions, success particles, level effects |
| `RocketLander/GameScene+Sound.swift` | All sound methods |
| `RocketLander/GameScene+Scoring.swift` | Scoring with platform multiplier |
| `RocketLander/Models/GameState.swift` | Game state ObservableObject |
| `RocketLander/Models/HighScoreManager.swift` | High score persistence |
| `RocketLander/Models/LandingPlatform.swift` | Platform A/B/C definitions |
| `RocketLander/Models/LandingMessages.swift` | Landing/crash messages |
| `RocketLander/Models/LevelDefinition.swift` | 10 campaign level definitions |
| `RocketLander/Models/CampaignState.swift` | Campaign persistence |
| `RocketLander/Views/ShapeViews.swift` | Rocket illustration + shapes |
| `RocketLander/Views/HUDViews.swift` | Top HUD + velocity display |
| `RocketLander/Views/ControlViews.swift` | Bottom controls + buttons |
| `RocketLander/Views/GameContainerView.swift` | Game container + SpriteKit bridge |
| `RocketLander/Views/GameOverView.swift` | Game over screen with stars/campaign |
| `RocketLander/Views/LevelSelectView.swift` | Campaign level select grid |
| `RocketLander/Haptics/HapticManager.swift` | Haptic feedback manager |
| `RocketLander/BannerAdView.swift` | AdMob banner integration |
| `RocketLander/RocketLanderApp.swift` | App entry point, SDK init |
| `RocketLander/Info.plist` | App configuration |
| `Scripts/export_chat_transcripts.py` | Chat transcript exporter |

---

## Git Information

- **Repository:** Local git repo
- **Current Branch:** main
- **Latest Tag:** v1.1.0

---

## Known Issues / Future Work

1. **dSYM Warnings:** Upload shows warnings for GoogleMobileAds.framework - harmless

2. **v2.0.0 Testing Needed:**
   - Test all 3 platforms on physical device
   - Test haptics on physical device
   - Test all 10 campaign levels with per-level thrust
   - Verify campaign persistence across app restarts
   - Test level unlock progression
   - Verify visual effects on device (wind, haze, ice, eruptions)

3. **Campaign Gravity + Thrust:** **RESOLVED (Sessions 17-18)**
   - Gravity: monotonically increasing -1.6 → -4.8
   - Thrust: per-level scaling 8.0 → 18.5 (ratio 5.0x → 3.8x)
   - All levels landable with distinct feel per planet

4. **Phase 3 Planned (v2.1):**
   - Game Center leaderboards (1 classic + 10 level)
   - "Support Development" IAP (remove ads)
   - Share Score card
   - Achievements ("Fuel Master", "Zero Drift", "Elite Pilot")

5. **Phase 4 Planned (v2.2):**
   - Weekly Challenge (deterministic from week number, no server)
   - Social link in settings
   - Easter eggs (land with 0% fuel, score 1969, perfect rotation on C)

---

## Troubleshooting Notes

### Thrust Sound Not Playing
- **Problem:** SKAudioNode with `fileNamed:` initializer didn't work
- **Solution:** Use URL-based initializer and explicit `SKAction.play()`

### CocoaPods Installation Failed
- **Problem:** System Ruby 2.6 too old for latest CocoaPods
- **Solution:** Used Swift Package Manager instead for Google Mobile Ads

### Xcode Signing "Communication with Apple failed"
- **Problem:** No registered devices
- **Solution:** Connect iPhone, trust computer, register device UDID

### Google Mobile Ads API Changes
- **Problem:** `GADBannerView` renamed to `BannerView`
- **Solution:** Update class names: `BannerView`, `Request`, `AdSizeBanner`, `MobileAds.shared`

---

### Session 12 (2026-01-30) - Campaign UX Improvements

**Per-level high scores, level name HUD, and level details on menu.**

#### Changes Made:
1. **Per-level high scores in campaign mode**: High scores are now separate per level/planet in campaign mode. Classic mode retains its own global leaderboard. `CampaignState.isHighScore()` checks against per-level top-3 scores. `GameOverView.saveScore()` routes to the correct storage based on game mode.

2. **Level name on HUD during campaign**: When playing in campaign mode, the planet/level name (e.g., "MOON", "MARS") is displayed at top center of the screen in `TopHUDView`.

3. **Gravity and mechanics on level select**: Each level card in `LevelSelectView` now shows gravity value (e.g., "1.6 m/s²") and special mechanic name (e.g., "Light Wind") for unlocked levels. Added `displayName` computed property to `SpecialMechanic` enum.

4. **Button wrapping fix**: Fixed game over action buttons (Menu/Next/Retry) wrapping text in campaign mode by reducing padding and adding `lineLimit(1)`.

#### Files Modified:
- `RocketLander/Models/LevelDefinition.swift` — Added `SpecialMechanic.displayName`
- `RocketLander/Models/CampaignState.swift` — Added `isHighScore(for:score:)`
- `RocketLander/Views/HUDViews.swift` — Added level name display in campaign
- `RocketLander/Views/LevelSelectView.swift` — Added gravity + mechanic to level cards
- `RocketLander/Views/GameOverView.swift` — Per-mode high score check and save, button fix

### Session 13 (2026-01-30) - Visual Polish

**Planet name centering, celestial body detail, and Starship redesign.**

#### Changes Made:
1. **Planet name truly centered**: Switched TopHUDView from HStack with Spacers to ZStack overlay so the level name is always screen-centered regardless of back button/fuel gauge widths.

2. **Detailed celestial bodies**: All background planets now have surface features:
   - **Earth**: Green continents (5 blobs), white polar ice caps, cloud wisps
   - **Mars**: Dark maria regions, polar cap, Olympus Mons hint
   - **Jupiter**: Horizontal cloud bands (5 layers), Great Red Spot
   - **Venus**: Thick cloud bands
   - **Saturn**: Subtle bands, multi-layer rings (back + front + inner)
   - **Europa**: Ice crack lines (8 random fractures)
   - **Io**: Volcanic spots (yellow/orange/red)
   - **All planets**: Terminator shadow (dark crescent for 3D), atmospheric glow for planets with atmosphere, improved crater depth with inner shadows

3. **Improved Starship design** (SpriteKit + SwiftUI menu):
   - Wider body (24→26pt), taller (65→70pt)
   - Darker metallic color palette with visible body highlight strip
   - Panel seam lines (3 horizontal + 1 vertical) for industrial look
   - Larger forward flaps (14→16pt outer) and aft flaps (16→18pt outer)
   - Hinge detail lines at flap attachment points
   - Wider engine skirt with tapered nozzles (bell shape)
   - Inner nozzle glow details
   - Sturdier landing legs with foot pads
   - Menu illustration updated to match with Trapezoid shape

#### Files Modified:
- `RocketLander/Views/HUDViews.swift` — ZStack centering for level name
- `RocketLander/GameScene+Setup.swift` — Celestial body features, improved rocket
- `RocketLander/Views/ShapeViews.swift` — Updated menu rocket, added Trapezoid shape

### Session 14 (2026-01-30) - Gameplay Balance & Platform Movement

**Fixed unplayable Earth gravity and added per-platform movement.**

#### Changes Made:
1. **Scaled thrust to gravity**: Campaign levels now scale thrust power to `abs(gravity) × 4.5`. This ensures consistent difficulty feel across all levels (classic mode keeps thrust=12.0 with gravity=-2.0, giving 6x ratio; campaign gives 4.5x ratio — harder but playable). Earth at -9.8 now has thrust=44.1 instead of 12.0.

2. **Per-platform movement on Earth**: All three platforms now move on the Earth (moving platform) level:
   - **Platform A** (Training Zone): Slow vertical bob, ±20px at 15px/s
   - **Platform B** (Precision Target): Horizontal sway, ±80px at 40px/s (main barge)
   - **Platform C** (Elite Landing): Horizontal ±50px at 55px/s + sine-wave vertical bob — hardest to land on

#### Revision (same session):
Reverted thrust scaling (not needed). Instead rebalanced all gravity values to game-friendly range:
- Moon: -1.6, Mars: -3.7, Titan: -1.4, Europa: -1.3
- **Earth: -9.8 → -4.5 → -3.5** (Session 15), **Venus: -8.9 → -4.2**, Mercury: -3.7
- Ganymede: -1.4, Io: -1.8, **Jupiter: -24.8 → -6.0**

Fixed platform movement bounds — each platform now stays within its own zone (left/center/right) with smaller, controlled displacements (±15-50px) instead of wandering across the screen.

#### Files Modified:
- `RocketLander/GameScene.swift` — Reverted thrust scaling, per-platform movement with zone bounds
- `RocketLander/Models/LevelDefinition.swift` — Rebalanced gravity values for Earth, Venus, Jupiter

### Session 15 (2026-01-30) - Dynamic Island Fix, Menu Layout, Platform Overlap & Gravity Tuning

**Bug fixes and UI improvements from simulator testing on iPhone 16 Pro.**

#### Issues Reported:
1. Game title "STARSHIP" cut off by Dynamic Island on iPhone 16+
2. Earth level gravity too strong — continuous thrust could not decelerate the lander
3. Earth level moving platforms overlapping each other
4. "HOW TO PLAY" section cut off at bottom of main menu

#### Changes Made:

**1. Dynamic Island / Menu Layout Fix (`ContentView.swift`):**
- Wrapped `MenuView` body in a `ScrollView` so content respects the safe area and scrolls below the Dynamic Island
- Removed flexible `Spacer()` elements (incompatible with ScrollView) and reduced VStack spacing from 20 to 16
- Reduced rocket illustration from 70×100pt to 60×85pt
- Reduced Classic button height from 55pt to 50pt
- Removed extra padding on banner ad and version text
- Result: All content (title, leaderboard, buttons, controls, HOW TO PLAY, banner ad, version) now visible on one screen without clipping

**2. Earth Level Gravity (`LevelDefinition.swift`):**
- Reduced Earth gravity from -4.5 to -3.5 (was -9.8 before Session 14, then -4.5, now -3.5)
- With thrust power at 12.0, this gives a 3.4x thrust-to-gravity ratio — challenging but landable
- **Outstanding issue:** Jupiter at -6.0 is still reported as impossible even at full thrust. Needs further balancing — either reduce gravity further or implement per-level thrust scaling

**3. Platform Overlap Fix (`GameScene.swift`):**
- Reduced horizontal movement ranges from `[15, 50, 30]` to `[0, 30, 20]`:
  - Platform A (Training Zone): Now vertical bob only, no horizontal movement
  - Platform B (Precision Target): Horizontal sway reduced from ±50px to ±30px
  - Platform C (Elite Landing): Horizontal movement reduced from ±30px to ±20px
- Reduced platform speeds from `[12, 30, 40]` to `[12, 25, 30]`
- Added clamping logic to prevent overlap:
  - Platform B clamped between A's right edge and C's left edge (10pt gap minimum)
  - Platform C clamped to stay right of B's right edge (10pt gap minimum)
- Platforms now stay strictly within their own zones (left/center/right)

**4. HOW TO PLAY Visibility:**
- Fixed by the ScrollView + spacing reduction changes above — no longer cut off

#### Files Modified:
- `RocketLander/ContentView.swift` — ScrollView wrapper, spacing/size reductions
- `RocketLander/Models/LevelDefinition.swift` — Earth gravity -4.5 → -3.5
- `RocketLander/GameScene.swift` — Platform movement ranges + clamping logic

#### Simulator Testing (iPhone 16 Pro, iOS 26.2):
- Main menu: Title fully visible below Dynamic Island ✓
- Main menu: HOW TO PLAY section fully visible ✓
- Main menu: All content fits on screen ✓
- Earth level: Platforms visually separated ✓ (verified in screenshot)
- Earth level: Gravity still needs further testing for landability
- **Jupiter level: Reported as impossible — needs balancing (TODO)**

#### Outstanding Work:
- Balance gravity across ALL campaign levels so difficulty increases progressively
- Current gravity values: Moon -1.6, Mars -3.7, Titan -1.4, Europa -1.3, Earth -3.5, Venus -4.2, Mercury -3.7, Ganymede -1.4, Io -1.8, Jupiter -6.0
- Thrust power is fixed at 12.0 for all levels — higher gravity levels may need thrust scaling or gravity caps
- Test all levels end-to-end on device

#### Chat Transcript Summary:
- User reported 3 bugs from testing on real iPhone 16
- Fixed Dynamic Island cutoff by wrapping menu in ScrollView
- Fixed Earth gravity from -4.5 to -3.5
- Fixed platform overlap with reduced ranges and edge clamping
- Attempted automated simulator testing via AppleScript/CGEvent but Simulator doesn't respond to macOS click events as touch input
- Installed and launched on iPhone 16 Pro simulator for manual testing
- Screenshots confirmed title and HOW TO PLAY fixes
- User reported Jupiter still impossible — deferred to next session for full gravity balancing pass

### Session 16 (2026-01-30) - Ganymede Deep Craters Terrain Overhaul

**Made Ganymede "deep craters" mechanic visible and functional.**

#### Problem:
User played Ganymede level and saw no craters. The previous implementation added random +30-60px height bumps at 25% of terrain segments, which were smoothed away by the averaging pass. No visual or gameplay distinction from other levels.

#### Changes Made:

**1. Terrain Ridge Generation (`GameScene+Setup.swift`):**
- Replaced random bumps with deliberate elevated ridges between platform zones
- Ridge height: up to +200px above base terrain (~380px total vs platforms at 220px)
- Ridges ramp up smoothly over 60px from platform edge, creating visible valleys
- Platforms sit in clear valleys with tall ridges on all sides
- Left and right screen edges also elevated (no safe terrain outside platform zones)
- Small random variation (±10px) on ridges for natural look

**2. Terrain Physics for Ganymede (`GameScene+Setup.swift`):**
- Added `addTerrainPhysics()` method — creates edge-chain physics body along terrain surface
- Uses `groundCategory` so rocket crashes on contact with ridges
- Only active on Ganymede (level 8); other levels keep terrain as visual-only
- Ridges are now actual obstacles, not just visual decoration

#### Files Modified:
- `RocketLander/GameScene+Setup.swift` — Ridge terrain generation + terrain physics body

#### Definition of Done:
- [x] Ganymede terrain has visible elevated ridges between platforms
- [x] Ridges have physics (crash on contact via groundCategory)
- [x] Platforms remain in valleys, accessible from above
- [x] Build succeeds (0 errors)
- [x] Docs updated

### Session 17 (2026-01-30) - Campaign Gravity Rebalance (Progressive Difficulty)

**Rebalanced all 10 campaign level gravity values for smooth progressive difficulty.**

#### Problem:
Gravity values did not increase with level number. Low-gravity levels (Titan -1.4, Europa -1.3, Ganymede -1.4, Io -1.8) appeared late in the campaign but were easier than early levels (Mars -3.7, Earth -3.5). Jupiter at -6.0 was impossible.

#### Design Principle:
Gravity increases monotonically with level number. Thrust is fixed at 12.0. Target thrust-to-gravity ratio: 7.5x (level 1) down to 2.5x (level 10). Special mechanics layer additional difficulty on top of gravity.

#### New Gravity Curve:

| Level | Name | Old Gravity | New Gravity | Thrust Ratio | Mechanic |
|-------|------|------------|------------|-------------|----------|
| 1 | Moon | -1.6 | -1.6 | 7.5x | None |
| 2 | Mars | -3.7 | -2.0 | 6.0x | Light wind |
| 3 | Titan | -1.4 | -2.2 | 5.5x | Dense atmosphere |
| 4 | Europa | -1.3 | -2.5 | 4.8x | Ice surface |
| 5 | Earth | -3.5 | -2.8 | 4.3x | Moving platforms |
| 6 | Venus | -4.2 | -3.2 | 3.8x | Heavy turbulence |
| 7 | Mercury | -3.7 | -3.5 | 3.4x | Heat shimmer |
| 8 | Ganymede | -1.4 | -3.8 | 3.2x | Deep craters |
| 9 | Io | -1.8 | -4.2 | 2.9x | Volcanic eruptions |
| 10 | Jupiter | -6.0 | -4.8 | 2.5x | Extreme wind |

#### Files Modified:
- `RocketLander/Models/LevelDefinition.swift` — All 10 gravity values updated

#### Definition of Done:
- [x] Gravity increases with each level
- [x] All thrust ratios ≥ 2.5x (landable with skill)
- [x] Build succeeds
- [x] Docs updated

### Session 18 (2026-01-30) - Per-Level Thrust, Visual Effects, Ganymede Fix, Easter Eggs, v2.0.0

**Major session: completed campaign gameplay polish and bumped to v2.0.0.**

#### Per-Level Thrust Scaling:
- Added `thrustPower` property to `LevelDefinition`
- Each planet has unique thrust: 8.0 (Moon, floaty) → 18.5 (Jupiter, powerful but tight)
- Thrust-to-gravity ratio decreases: 5.0x → 3.8x for progressive difficulty
- Classic mode unchanged at 12.0
- **Files:** `LevelDefinition.swift`, `GameScene.swift`

#### Visual Effects for All Mechanics:
- Wind streak particles at 3 intensities (Mars/Venus/Jupiter)
- Atmosphere haze with drifting clouds (Titan)
- Ice shimmer sparkles near platforms (Europa)
- Europa ice surface friction (0.01)
- **Files:** `GameScene+Effects.swift`, `GameScene.swift`

#### Ganymede Deep Craters (3rd Attempt — Success):
- Prior terrain ridge approaches failed: platforms cover 320 of 393pt (81% screen width), no room for terrain ridges between them
- New approach: standalone rock pillar obstacles (`SKShapeNode` with polygon physics bodies)
  - 3 pillars: left edge (height 200), between B-C (height 180), right edge (height 190)
  - Raised terrain at screen edges (up to 350px) for crater bowl effect
  - All have `groundCategory` — hitting them = crash
- **Files:** `GameScene+Setup.swift`

#### Astronaut Easter Egg High Scores:
- Prepopulated leaderboards with 1000-point entries using space figure names
- Classic: "Elon" | Moon: "Armstrong" | Mars: "Aldrin" | Titan: "Huygens"
- Europa: "Galileo" | Earth: "Gagarin" | Venus: "Shepard" | Mercury: "Glenn"
- Ganymede: "Marius" | Io: "Collins" | Jupiter: "Shoemaker"
- Seeded on first launch only (won't overwrite player scores)
- **Files:** `HighScoreManager.swift`, `CampaignState.swift`

#### Version Bump to v2.0.0:
- Campaign mode fundamentally changes the product — merits major version bump
- Updated: `Info.plist` (2.0.0, build 12), `README.md`, `CHANGELOG.md`, `RELEASE_NOTES.md`, `PROJECT_LOG.md`

#### Definition of Done:
- [x] Per-level thrust implemented and tested
- [x] All visual effects visible in simulator
- [x] Ganymede rock pillars visible and deadly
- [x] Easter egg scores seeded on fresh install
- [x] Version 2.0.0 across all files
- [x] All 10 levels playtested on simulator
- [x] All docs updated (DECISIONS.md, CHANGELOG.md, session summary, PROJECT_LOG.md)

### Session 19 (2026-01-30) - App Store Screenshots, Submission, Project Guidelines

**Phase: Release + Project Management. Screenshots, App Store submission, and CLAUDE.md guidelines.**

#### App Store Screenshots:
- Captured 10 screenshots from iPhone 16 Pro simulator using `xcrun simctl io screenshot`
- Clean status bar override (9:41, full battery/signal)
- Covers: main menu, classic gameplay, campaign level select, 5 campaign levels (Titan, Ganymede, Venus crash, Earth, Jupiter, Io), and successful landing with high score entry
- Initially captured at 1206×2622 (iPhone 16 Pro native) — rejected by App Store Connect
- Resized to 1284×2778 (iPhone 6.7" Pro Max) using `sips -z 2778 1284`
- **Location:** `Screenshots/v2.0.0/`

#### Detailed Release Notes:
- Expanded RELEASE_NOTES.md v2.0.0 from ~30 lines to ~170 lines
- Added comprehensive sections: campaign table, platform table, visual effects, scoring formula, astronaut easter eggs table, architecture
- Updated status from "IN DEVELOPMENT" to "SUBMITTED TO APP STORE CONNECT"

#### App Store Copy:
- Promotional text (166 chars) for anytime updates
- Description (897 chars) — structured with Campaign Mode, Three Platforms, Features sections
- "What's New" text with bullet points for all new features

#### App Store Submission:
- v2.0.0 (Build 12) submitted for App Store review
- Screenshots uploaded at correct 1284×2778 dimensions
- All text fields populated (promotional, description, what's new)

#### Technical Issues Resolved:
- Git HTTP/2 broken pipe on large pushes — fixed with `git config http.version HTTP/1.1`
- AppleScript clicks don't translate to SpriteKit UITouch hold events — used manual navigation + timed capture
- App Store Connect rejected 1206×2622 screenshots — requires exactly 1284×2778 for iPhone 6.7"

#### Project Management Guidelines:
- Created `CLAUDE.md` — persistent instructions for Claude Code session continuity
  - Start of session checklist, phase discipline, definition of done
  - Mandatory documentation updates, code standards, testing expectations
  - Privacy guardrails, change summary format, hard "do not" list
- Created `.github/pull_request_template.md` — PR checklist (scope, build, regression, docs, privacy, testing, risk)
- Added dedicated "Chat Session Logging (mandatory)" section to CLAUDE.md with 7 enforcement rules
- Inspired by jessfraz/dotfiles AGENTS.md, adapted for iOS project and session continuity
- **Files:** `CLAUDE.md`, `.github/pull_request_template.md`, `DECISIONS.md`

#### Research / Ideas Logged:
- Campaign per-level high scores display — top-3 stored but only #1 visible on level cards. Options: expand cards, tap-to-expand, or dedicated screen. Added to backlog.

#### Definition of Done:
- [x] 10 screenshots captured and resized
- [x] Screenshots uploaded to App Store Connect
- [x] Release notes expanded with full feature documentation
- [x] App Store description and "What's New" drafted
- [x] v2.0.0 submitted for review
- [x] CLAUDE.md created with full project guidelines
- [x] PR template created
- [x] Chat session logging enforced in CLAUDE.md
- [x] Campaign high scores display idea logged in backlog
- [x] Session summary finalized and committed

---

### Session 20 (2026-01-31) — STATUS.md Reconciliation

**Goal:** Create `STATUS.md` as the authoritative project snapshot and update `CLAUDE.md` to reference it as the single source of truth.

**Context:** User requested a compressed, reconciled project snapshot that takes precedence over chat logs and other documentation. This ensures new sessions can quickly understand the project state without reading all historical chat summaries.

**Sources consulted for reconciliation:**
- `CLAUDE.md` — project guidelines, file structure, build commands
- `PROJECT_LOG.md` — version history table, session entries, backlog
- `DECISIONS.md` — all 12 architectural/design decisions
- `CHANGELOG.md` — version-level change tracking
- `RELEASE_NOTES.md` — v2.0.0 feature list, App Store copy
- `README.md` — high-level project description
- `Info.plist` — current version/build numbers
- `Docs/chats/` — 5 session summaries (sessions 15-19)
- `.github/pull_request_template.md` — PR checklist

**Discrepancies found:** None — all documentation was consistent regarding v2.0.0 Build 12 submitted for review, feature set, and current status.

**Assumptions documented in STATUS.md:**
- v1.1.5 (Build 11) status is unclear — PROJECT_LOG says "Submitted for review" but no confirmation of publication. May have been superseded by v2.0.0.
- v2.0.0 not yet approved — Apple may reject for ad compliance, screenshot accuracy, or privacy declarations.
- No device testing performed for v2.0.0 — haptics, accelerometer, and ads are simulator-only verified.

**Files changed:**
- `STATUS.md` (new) — authoritative project snapshot with 9 sections: Project Snapshot, What Is Done, What Is NOT Done, Current Phase, Immediate Next Tasks, Non-Negotiable Principles, How to Resume Work, Known Risks, Ownership
- `CLAUDE.md` (updated) — added STATUS.md as authoritative truth in intro, session checklist (step 2), session continuity table (first entry with precedence rule), and documentation requirements (section G)

### Session 26 (2026-01-31) - TestFlight Setup + Device Testing + Accelerometer Fix

**Set up TestFlight for device testing. Found and fixed accelerometer toggle bug.**

#### Changes Made:

1. **TestFlight setup**:
   - Archived and uploaded v2.0.1 (Build 13) to App Store Connect
   - Created internal testing group "Developer Testing"
   - Added personal Apple ID as team member (Developer role) for TestFlight access
   - Successfully installed and tested on physical iPhone

2. **Device testing results**:
   - Haptics: all 4 types working (thrust, rotation, landing, crash)
   - Ads: banner ads loading correctly, ATT prompt appearing
   - Sound effects: working
   - Layout: no issues, version number visible top-right
   - Accelerometer: **BUG FOUND** — toggle had no effect on gameplay
   - Campaign: testing in progress (deferred to next session)

3. **Accelerometer bug fix (`ContentView.swift`)**:
   - Root cause: MenuView used `@AppStorage("useAccelerometer")` which updated UserDefaults but not `GameState.useAccelerometer` (read once at init)
   - Fix: removed `@AppStorage`, bound toggle directly to `gameState.useAccelerometer`
   - Fix committed locally, needs new TestFlight build to verify on device

4. **Environment setup**:
   - Installed Homebrew and `gh` CLI (session 25)
   - Fixed `xcode-select` path after Homebrew install switched it to Command Line Tools

#### Files Modified:
- `RocketLander/ContentView.swift` — removed `@AppStorage`, bound to `gameState.useAccelerometer`

#### Pending:
- Campaign mode device testing (user testing async)
- New TestFlight build with accelerometer fix
- Accelerometer verification on device

---

### Session 25 (2026-01-31) - v2.1.0 Planning Session

**Planned v2.1.0 scope: Game Center, Achievements, Remove Ads IAP, Share Score Card.**

#### Research Completed:

1. **GameKit / Game Center (iOS 15+)**:
   - Authentication: `GKLocalPlayer.local.authenticateHandler` — automatic, graceful fallback
   - Score submission: `GKLeaderboard.submitScore()` — built-in offline queue, best-score-only
   - Achievements: `GKAchievement.report()` — idempotent, percentComplete 0-100
   - Access Point: `GKAccessPoint.shared` — 3 lines for native dashboard overlay
   - Leaderboard IDs: reverse-domain, must register in App Store Connect first
   - Privacy: No ATT needed; add "Gameplay Content" to App Privacy declarations
   - Entitlement: "Game Center" capability in Xcode

2. **StoreKit 2 (iOS 15+)**:
   - Purchase: `Product.purchase()` async/await with JWS on-device verification
   - Restore: `AppStore.sync()` + `Transaction.currentEntitlements`
   - Persistence: `currentEntitlements` as truth, UserDefaults as fast cache
   - Testing: Local StoreKit Configuration file (no App Store Connect needed)
   - Privacy: No additional declarations
   - Entitlement: "In-App Purchase" capability in Xcode

3. **Achievement hook points identified**:
   - `saveScore()` in GameOverView for landing-based achievements
   - `CampaignState.completedLevel()` for progression achievements
   - `GameState` properties for condition checks (fuel, rotation, stars, platform)

4. **Ad removal integration point**:
   - `BannerAdContainer` in ContentView + GameContainerView — conditionally hide based on UserDefaults flag

#### Decisions Made:
- Game Center auth: automatic with graceful fallback (no forced popups)
- 10 achievements, all binary (0% or 100%), no grind-based
- StoreKit 2 with on-device JWS verification, no server needed
- Privacy: "Gameplay Content" declaration for Game Center, no other changes

#### v2.1.0 Scope — Community (locked):
- 11 Game Center leaderboards (classic + 10 campaign)
- 10 achievements
- Share Score Card with native share sheet
- No gameplay, physics, or campaign balance changes

#### v2.2.0 Scope — Monetization (locked):
- 1 non-consumable IAP ("Support Development" — remove ads)
- No gameplay, physics, or campaign balance changes

#### Files Changed:
- `CHANGELOG.md` — added v2.1.0 Unreleased section
- `DECISIONS.md` — 4 new decision entries (Game Center, achievements, IAP, privacy)
- `STATUS.md` — updated phase, next tasks, not-done status
- `PROJECT_LOG.md` — this entry
- `Docs/chats/2026-01-31_session25_v21_planning.md` — session summary

---

### Session 24 (2026-01-31) - Dedicated Leaderboard Screen (v2.0.1)

**Added a dedicated leaderboard screen and fixed version label visibility.**

#### Changes Made:

1. **Dedicated Leaderboard Screen (`LeaderboardView.swift` — new file)**:
   - Accessible by tapping "TOP PILOTS" section on main menu
   - Classic Mode section with top-3 scores
   - Campaign section with all 10 levels, each showing per-level top-3 scores
   - Locked levels shown grayed out with lock icon, no scores
   - Gold/silver/bronze rank colors for positions 1-3
   - Header with back navigation and trophy icon
   - Scrollable layout matching existing app design patterns

2. **Menu "TOP PILOTS" made tappable (`ContentView.swift`)**:
   - Wrapped existing leaderboard VStack in a Button with `.buttonStyle(.plain)`
   - Added "View All >" hint text at bottom of section
   - Added `showingLeaderboard` state for navigation

3. **Version label relocated (`ContentView.swift`)**:
   - Moved from bottom of ScrollView content to fixed `.overlay(alignment: .topTrailing)`
   - Always visible regardless of scroll position

4. **Version bump to 2.0.1 (Build 13)**:
   - Updated `Info.plist` CFBundleShortVersionString and CFBundleVersion

#### Files Created:
- `RocketLander/Views/LeaderboardView.swift`

#### Files Modified:
- `RocketLander/ContentView.swift` — navigation state, conditional branch, tappable TOP PILOTS, version label overlay
- `RocketLander.xcodeproj/project.pbxproj` — added LeaderboardView.swift to project
- `RocketLander/Info.plist` — version 2.0.1, build 13

#### Definition of Done:
- [x] Leaderboard screen opens from menu TOP PILOTS tap
- [x] Classic top-3 and campaign per-level top-3 displayed
- [x] Locked levels grayed out with lock icon
- [x] Back button returns to menu
- [x] Version label visible on menu at all times
- [x] Build succeeds
- [x] Docs updated

---

### Session 27 (2026-01-31) - Campaign Mode Device Testing Feedback

**Goal:** Receive and document campaign mode device testing feedback from TestFlight playtesting.

**Apple Review:** v2.0.0 still pending review (submitted 2026-01-30).

**Campaign Feedback (aspirational direction, no code changes):**
- Campaign feels balanced but homogeneous — planets differ by scalar tuning, not distinct mechanics
- Platform difficulty ladder (A=easy, B=hard, C=elite) is correct and should be preserved
- Core issue is recoverability, not difficulty — small lateral mistakes are unrecoverable
- Recommended hybrid model: Classic stays strict, Campaign becomes "accessible mastery"
- Planets should each teach one clear mechanic that changes how you fly
- Scoring expressiveness gap — center-of-platform precision needs to matter more
- Leaderboard should show star rating metadata for score context

**Key decision:** No implementation yet. Design discussion must precede any campaign changes.

#### Files Modified:
- None (feedback-only session)

---

### Session 28 (2026-01-31) - v2.0.2 Campaign Polish Patch

**Goal:** Implement campaign gameplay tuning based on device testing feedback: scoring rebalance, proportional thrust vectoring, differentiated planet mechanics, leaderboard star metadata.

#### Changes Made:

1. **Scoring Rebalance (`GameScene+Scoring.swift`)**:
   - Soft Landing: 700 → 500, Center: 350 → 600, Approach: 200 → 150 (subtotal stays 2000)
   - Fuel multiplier cap: 2.5x → 2.0x. New max: 20,000 (was 25,000)
   - Center precision now the highest-weighted component

2. **Proportional Thrust Vectoring (`GameScene.swift`)**:
   - Removed binary RCS lateral assist (2.0 units when tilted >5°)
   - Added proportional: `sin(rotation) × thrustPower × 0.15` — only while thrusting
   - Smooth, physics-based correction that scales with tilt angle

3. **Venus — Vertical Updrafts (`GameScene.swift`, `GameScene+Effects.swift`)**:
   - Wind force now vertical (dy) instead of horizontal (dx)
   - Wind particles move bottom-to-top instead of right-to-left
   - Description: "Vertical updrafts disrupt your descent."

4. **Jupiter — Sudden Gusts (`GameScene.swift`)**:
   - Replaced smooth sine-wave wind with calm/gust cycle
   - 2.5-4s calm → 1.5-2.5s sharp gust with random direction
   - Description: "Sudden gusts between calm windows."

5. **Mercury — Heat Interference (`GameScene.swift`)**:
   - Random velocity perturbation when thrusting (±1.5 dx, ±0.8 dy)
   - Visual shimmer effect unchanged
   - Description: "Heat shimmer disrupts thrust control."

6. **Io — Deadly Volcanic Debris (`GameScene+Effects.swift`)**:
   - Eruption particles get physics bodies (groundCategory → crash on contact)
   - Physics removed before fade-out (safe to touch fading particles)
   - Description: "Volcanic debris is deadly — time it."

7. **Leaderboard Star Metadata (`HighScoreManager.swift`, `CampaignState.swift`, `LeaderboardView.swift`)**:
   - HighScoreEntry gains `stars` field with backward-compatible Codable
   - Stars passed through from CampaignState.completedLevel
   - Small star icons shown in campaign leaderboard rows

8. **Level Description Updates (`LevelDefinition.swift`)**:
   - Venus, Mercury, Io, Jupiter descriptions updated to match new mechanics
   - `.heavyTurbulence` display name: "Vertical Updrafts"

#### Files Modified:
- `RocketLander/GameScene+Scoring.swift`
- `RocketLander/GameScene.swift`
- `RocketLander/GameScene+Effects.swift`
- `RocketLander/Models/HighScoreManager.swift`
- `RocketLander/Models/CampaignState.swift`
- `RocketLander/Views/LeaderboardView.swift`
- `RocketLander/Models/LevelDefinition.swift`

#### Definition of Done:
- [x] Scoring rebalance: center 600pts, fuel cap 2.0x, max 20,000
- [x] Thrust vectoring: proportional, thrust-only
- [x] Venus: vertical updrafts + vertical particles
- [x] Jupiter: calm/gust cycle
- [x] Mercury: thrust perturbation
- [x] Io: deadly volcanic particles
- [x] Leaderboard star metadata: backward-compatible, displayed
- [x] Level descriptions updated
- [x] Build succeeds
- [x] All docs updated (CHANGELOG, DECISIONS, STATUS, PROJECT_LOG, README)
- [x] Version bumped to 2.0.2 (Build 14→15)
- [x] Archived and uploaded to App Store Connect / TestFlight
- [x] Fixed classic mode star rating not saved in high scores
- [x] Fixed classic mode star rating not displayed in leaderboard and menu

#### Commits:
- `35de6a9` — Campaign polish: scoring rebalance, thrust vectoring, planet differentiation
- `1c754f8` — Bump version to 2.0.2 (Build 14), upload to TestFlight
- `4216f7e` — Update session 28 summary: commits, version bump, TestFlight upload
- `cf1afd8` — End session 28: update PROJECT_LOG with commits and status
- `e3ccdce` — Fix classic mode star rating not saved in high scores (Build 15)
- `2a4ecb8` — Fix classic mode star display in leaderboard and menu (Build 16)

---

### Session 29 (2026-02-01) - Replace v2.0.0 Submission with v2.0.2

**Goal:** v2.0.0 (Build 12) had been "Waiting for Review" for 2 days with no response. Decision: replace with v2.0.2 (Build 16) to avoid shipping outdated gameplay. Update all App Store copy and submit.

#### Changes Made:

1. **Decision: Replace v2.0.0 with v2.0.2**
   - v2.0.0 had binary RCS, 25k max score, cosmetic-only planet mechanics, no star metadata
   - v2.0.2 has proportional thrust vectoring, 20k max, differentiated mechanics, star display
   - Better to reset review clock than ship inferior version

2. **App Store Copy Updated**
   - Description: 25,000 → 20,000 points (only change needed)
   - What's New: removed "V2.0.0", 25k→20k, "RCS thruster assist" → "Proportional thrust vectoring"
   - Review Notes: explains v2.0.2 replaces v2.0.0, lists all campaign mechanics
   - Promotional Text: new — "A skill-based landing game where precision beats luck..."
   - Keywords: lander, physics, precision, skill, thrust, flight, descent, control, challenge, hardcore, starship, simulator

3. **RELEASE_NOTES.md Overhauled**
   - v2.0.0 section replaced with v2.0.2
   - All outdated references fixed (RCS, 25k score, planet mechanics descriptions)
   - Added App Store copy blocks (Description, What's New, Review Notes)
   - Added v2.0.2 bug fixes section

4. **Documentation Updated**
   - STATUS.md: submission status, phase, next tasks, risks
   - PROJECT_LOG.md: current status table, next steps
   - DECISIONS.md: new entry documenting the replacement decision
   - RELEASE_NOTES.md: full v2.0.2 overhaul

#### Submission Details:
- Version: 2.0.2 (Build 16)
- Submitted: 2026-02-01 at 07:52
- Submission ID: 7ff9c921-0349-49c2-98b9-bfe9d1ca092f
- Status: Waiting for Review
- Build already uploaded from session 28 — no new archive needed

#### Definition of Done:
- [x] Decision made: replace v2.0.0 with v2.0.2
- [x] App Store description updated (20k score)
- [x] What's New updated (thrust vectoring, 20k)
- [x] Review Team Notes updated (explains replacement, lists mechanics)
- [x] Promotional text set
- [x] Keywords set
- [x] RELEASE_NOTES.md overhauled for v2.0.2
- [x] STATUS.md updated
- [x] PROJECT_LOG.md updated
- [x] DECISIONS.md entry added
- [x] v2.0.2 (Build 16) submitted for App Store review
- [x] Session summary created
- [x] All docs committed and pushed

#### Commits:
- `4fe3a43` — Replace v2.0.0 submission with v2.0.2: update App Store copy and docs
- `f7cf43a` — Update session 29 summary with commit hash and housekeeping
- `85689f9` — Add submission status to CHANGELOG v2.0.2 header
- `7ce6bc4` — Update README project structure: add caption_screenshots.py and metadata
- `786d081` — Fix stale references in docs: submission status, device testing, decisions

---

### Session 30 (2026-02-01) - Automated Unit Tests (XCTest)

**Goal:** Add unit tests for core game logic to provide regression protection.

#### Changes Made:

1. **Extracted scoring to static method (`GameScene+Scoring.swift`)**:
   - Added `GameScene.calculateScore()` static function with all inputs as parameters
   - Instance method becomes a thin wrapper — zero behavior change

2. **Created test target**:
   - Added `RocketLanderTests` directory with 7 test files (51 tests total)
   - Updated `project.pbxproj` with test target, build phases, configurations
   - Updated scheme to include test target in TestAction

3. **Test coverage**:
   - ScoringTests (11): formula verification + realistic scenarios
   - HighScoreManagerTests (9): persistence, sorting, backward-compat
   - CampaignStateTests (10): unlock, stars, scores, persistence
   - LevelDefinitionTests (8): data integrity, progression
   - LandingMessagesTests (5): message selection logic
   - GameStateTests (3): initial values, reset, settings persistence
   - LandingPlatformTests (5): multipliers, stars, widths, positions

#### Files Created:
- `RocketLanderTests/ScoringTests.swift`
- `RocketLanderTests/HighScoreManagerTests.swift`
- `RocketLanderTests/CampaignStateTests.swift`
- `RocketLanderTests/LevelDefinitionTests.swift`
- `RocketLanderTests/LandingMessagesTests.swift`
- `RocketLanderTests/GameStateTests.swift`
- `RocketLanderTests/LandingPlatformTests.swift`

#### Files Modified:
- `RocketLander/GameScene+Scoring.swift` — static scoring method
- `RocketLander.xcodeproj/project.pbxproj` — test target
- `RocketLander.xcodeproj/xcshareddata/xcschemes/RocketLander.xcscheme` — test action

#### Definition of Done:
- [x] 51 tests pass, main app builds
- [x] No behavior changes
- [x] All docs updated

### Session 31 (2026-02-01) - Perfect Landing Score Analysis

**Goal:** Calculate maximum achievable scores for all 33 level/platform combinations using frame-by-frame physics simulation.

#### Changes Made:

1. **Created `Scripts/calculate_perfect_scores.py`**: Frame-by-frame physics simulation matching SpriteKit behavior (gravity×150 pts/m conversion, binary thrust, approach speed crash gate, screen wrapping). Reactive controller optimizes over descent speed, tilt angle, direction, and landing position.

2. **Key discoveries**:
   - Approach speed (avg of last 30 velocity samples) is a CRASH GATE, not just a scoring penalty
   - Screen wrapping makes going left the optimal strategy for Platform C (170 pts vs 263 pts)
   - Center landing always maximizes score — the 600 center bonus × multiplier always outweighs fuel savings from off-center landing
   - Best possible: Classic C = 12,132 (30% fuel, via left wrap). Worst: Moon A = 2,684 (48% fuel).

#### Files Created:
- `Scripts/calculate_perfect_scores.py`

#### No app code modified.

#### Interpretation & Intent
- These results reinforce the current design goals: the scoring system rewards skill (precision, fuel management, platform choice) over luck. No action or balance changes are required.
- The data exists to inform future achievement thresholds, sanity-check scoring changes, and guard against regressions that would erode skill expression.
- Platform C screen wrapping is considered emergent mastery, not an exploit. Center precision dominance is intentional and desirable.

#### Definition of Done:
- [x] All 33/33 landings computed
- [x] Validated against real gameplay (sim 2,980 vs real 2,965 for Classic A)
- [x] All docs updated

---

### Session 32 (2026-02-01) - Campaign Mode Engagement Upgrade (v2.0.3)

**Goal:** Implement four coordinated changes to improve Campaign mode engagement and gameplay feedback.

#### Changes Made:

1. **Fixed Reentry Start State (Campaign Only) (`GameScene.swift`)**:
   - `CampaignReentryState` struct: 0.12 rad (~6.9°) left tilt + 15 pts/s rightward drift
   - Applied via `applyCampaignReentryState()` when rocket becomes dynamic
   - Prevents trivial "hold thrust" strategy for Platform A
   - Classic mode unchanged (upright start)

2. **HUD Tilt Angle Display (`HUDViews.swift`)**:
   - New tilt row in VelocityHUDView with real-time degree readout
   - Directional color: cyan (left), orange (right), green (safe)
   - Direction letter (L/R) shown when tilt exceeds safe threshold
   - Safe threshold added to bottom line: "V<50 H<30 T<3°"

3. **Final Stats Panel (`GameOverView.swift`, `GameScene.swift`, `GameState.swift`)**:
   - `snapshotFinalStats()` freezes flight data at moment of landing/crash
   - `FinalStatsView` component displays tilt, speeds, fuel, center distance
   - Shown on both landing and crash game-over screens
   - Color-coded: green (safe) / red (exceeded threshold)

4. **Deterministic Crash Messages (`LandingMessages.swift`, `GameScene.swift`)**:
   - `CrashCause` enum with precedence ordering
   - `diagnosticCrashMessage()` produces cause-based feedback with actual values
   - Priority: tilt > vertical > horizontal > approach > terrain > out-of-bounds
   - Secondary hint for multiple failures
   - Same inputs always produce same output (no randomness)

5. **GameState Properties (`GameState.swift`)**:
   - Added: `tiltAngle` (signed), `finalTiltAngle`, `finalVerticalSpeed`, `finalHorizontalSpeed`, `finalFuel`, `finalDistanceFromCenter`, `crashDiagnosticPrimary`, `crashDiagnosticSecondary`
   - All cleared in `reset()`

6. **Unit Tests (`CrashDiagnosticTests.swift`)**:
   - 14 new tests: single-cause, precedence, secondary hints, determinism (100x), edge cases, value display
   - Total test count: 65 across 8 files

7. **Version Bump**: 2.0.3 (Build 17)

8. **TestFlight Upload**: Archived and uploaded Build 17 to App Store Connect for device testing.

9. **Perfect Score Simulation Update (`Scripts/calculate_perfect_scores.py`)**:
   - Updated to model campaign reentry state (initial tilt + drift)
   - Adds tilt correction phase: 3 rotation frames costing ~0.24% fuel
   - Initial rightward drift of 15 pts/s affects trajectory optimization
   - Impact: <1% score change on all 30 campaign level/platform combinations
   - Classic mode unchanged. Best: Classic C = 12,132. All 33/33 landings computed.
   - Center landing still always optimal (0/33 off-center)

#### Files Created:
- `RocketLanderTests/CrashDiagnosticTests.swift`

#### Files Modified:
- `RocketLander/GameScene.swift` — CampaignReentryState, applyCampaignReentryState(), snapshotFinalStats(), crash diagnostic wiring, tiltAngle tracking
- `RocketLander/Models/GameState.swift` — tiltAngle, final* properties, crashDiagnostic* properties, reset
- `RocketLander/Models/LandingMessages.swift` — CrashCause, CrashDiagnostic, diagnosticCrashMessage()
- `RocketLander/Views/HUDViews.swift` — tilt angle row, tilt color/direction properties
- `RocketLander/Views/GameOverView.swift` — FinalStatsView, crash diagnostic display
- `RocketLander/Info.plist` — version 2.0.3, build 17
- `Scripts/calculate_perfect_scores.py` — campaign reentry state modeling

#### Commits:
- `fede844` — Campaign engagement upgrade v2.0.3
- `8aa9c00` — Update session 32 summary with commit hash
- `31b8070` — Repo housekeeping: update README structure
- `afc6883` — Add housekeeping commit to session 32 summary
- `9cb1ffe` — Update perfect score simulation for campaign reentry state
- `fbdccbf` — Update session 32 summary with simulation commit

#### Definition of Done:
- [x] Campaign ships spawn with tilt + drift
- [x] Classic mode unchanged (upright start)
- [x] HUD shows real-time tilt in degrees with direction
- [x] Final stats frozen and displayed on game-over
- [x] Crash messages are deterministic and cause-based
- [x] 14 crash diagnostic tests pass
- [x] All 65 tests pass
- [x] Build succeeds
- [x] Version bumped to 2.0.3 (Build 17)
- [x] Build 17 uploaded to TestFlight
- [x] Perfect score simulation updated for campaign reentry (33/33, <1% impact)
- [x] All docs updated
- [x] Repo housekeeping complete

---

## Contact / Accounts

- **Apple Developer Account:** Thiago Borges de Oliveira
- **AdMob Account:** Associated with Google account
- **App Store Connect:** https://appstoreconnect.apple.com

---

### Session 33 (2026-02-01) - v2.0.3 Device Testing Bug Fixes (Build 18)

**Goal:** Fix 4 bugs found during on-device testing of v2.0.3 Build 17 on TestFlight, then upload Build 18 for continued testing.

#### Bugs Found (from device screenshots):
1. **HUD Tilt Truncation**: Tilt value showed "12...L" instead of "12.8° L" due to `minimumScaleFactor` shrinking text
2. **Post-Collision Zeroed Velocities**: Crash diagnostics showed "approach too high (87)" but V.Speed=0 — SpriteKit zeroes velocities in collision resolution
3. **HUD vs Flight Data Mismatch**: HUD showed live values, Flight Data showed frozen snapshot — different numbers for same metric on game-over screen
4. **Visual Start State**: Campaign ships appeared upright at spawn despite having reentry tilt applied on first input

#### Changes Made:

1. **Pre-Contact Velocity Tracking (`GameScene.swift`)**:
   - Added `lastTrackedVerticalSpeed`, `lastTrackedHorizontalSpeed`, `lastTrackedTilt` — updated synchronously in update loop
   - `snapshotFinalStats()` uses tracked values instead of reading physics body at collision time
   - Ensures accurate touchdown speeds and tilt in all end-of-run displays

2. **HUD Display Consistency (`HUDViews.swift`)**:
   - Added `displayVertical`, `displayHorizontal`, `displayTiltAngle` computed properties
   - Switch between live values (gameplay) and `final*` values (game-over)
   - Fixed tilt truncation: replaced `minimumScaleFactor(0.7)` with `fixedSize()`, widened HUD 150→170pt
   - Fixed fuel rounding: `Int()` → `"%.0f"` for consistency with Flight Data

3. **Visual Start State (`GameScene.swift` — `setupScene()`)**:
   - Applied `rocket.zRotation = CampaignReentryState.initialTilt` after `createRocket()` for campaign mode
   - Ship now visually tilted at spawn, matching the physics state applied on first input

4. **Signed Tilt Preservation (`GameOverView.swift`)**:
   - `finalTiltAngle` changed from absolute to signed (preserves L/R direction for HUD)
   - Added `abs()` where needed for FinalStatsView display

5. **Bug Evidence Screenshots**: Saved to `Screenshots/v2.0.3-bugs/` with descriptive names

6. **Landing Threshold Consistency (`GameScene.swift`)**:
   - Device testing of Build 18 revealed successful landings at V.Speed=71 (threshold is 50)
   - Root cause: `checkLanding()` read velocity from physics body after collision resolution absorbed impact
   - Fix: `checkLanding()` now uses `lastTrackedVerticalSpeed`/`lastTrackedHorizontalSpeed`/`lastTrackedTilt` (pre-contact values) for threshold checks
   - Same fix applies to both Classic and Campaign modes (no mode-specific branching)

7. **Build Bumps**: Build 17 → 18 → 19 for TestFlight uploads

#### Files Modified:
- `RocketLander/GameScene.swift` — pre-contact tracking, visual start state, signed tilt, landing threshold fix
- `RocketLander/Views/HUDViews.swift` — display properties, fixedSize, fuel rounding, widened HUD
- `RocketLander/Views/GameOverView.swift` — abs() on finalTiltAngle for FinalStatsView
- `RocketLander/Info.plist` — build 17 → 19

#### Commits:
- `e6db4b5` — Fix v2.0.3 telemetry bugs: HUD truncation, snapshot timing, visual start state
- `d6befb5` — Bump to Build 18 + update all docs for v2.0.3 bug fixes
- `a177219` — End session 33: finalize docs with commit hashes and TestFlight status
- `361bf4f` — Fix landing threshold using post-collision velocity instead of pre-contact

#### Definition of Done:
- [x] All 4 original bugs fixed
- [x] Landing threshold consistency bug fixed (Build 19)
- [x] 65/65 tests pass
- [x] Build succeeds
- [x] Bug evidence screenshots saved (5 total)
- [x] User confirmed Build 17 fixes work on device
- [x] Build number bumped to 19
- [x] All docs updated (CHANGELOG, STATUS, PROJECT_LOG, DECISIONS, session summary)
- [x] Build 19 archived and uploaded to TestFlight

---

### Session 34 (2026-02-01) - CRITICAL: Velocity Thresholds Never Enforced

**Goal:** Investigate and document Build 19 device testing failure — impossible to land on TestFlight.

#### Critical Discoveries:

1. **Velocity thresholds were dead code since initial commit (`e8e9656`)**:
   - `checkLanding()` reads from `rocket.physicsBody?.velocity` in `didBegin(contact:)`
   - SpriteKit zeros velocities during collision resolution before callback fires
   - V<40 and H<25 checks always saw V≈0 → always passed → speed never mattered
   - The only functional landing constraint was rotation (< 0.05 rad)

2. **Build 19 was first-ever speed enforcement, but too strict**:
   - Changed `checkLanding()` to use `lastTrackedVerticalSpeed` (pre-contact tracked)
   - But tracking happens at line 272 of `update()`, BEFORE thrust at line 286
   - Pre-thrust values are ~10-15 units higher than post-thrust when player is decelerating
   - Result: impossible to land even with careful approach

3. **HUD threshold mismatch since creation (commit `fede844`)**:
   - HUD uses V<50, H<30; actual GameScene thresholds are V<40, H<25
   - Never caught because both display and threshold were wrong in compatible ways

4. **Scoring was inflated in all prior builds**:
   - Scoring formula received near-zero post-collision velocities → max speed scores
   - All existing high scores achieved under "speed doesn't matter" regime

5. **Tests didn't catch it because**:
   - 65 unit tests all test isolated pure functions
   - No integration test simulates a physics collision and verifies pass/fail
   - Scoring simulation assumes thresholds work; has no knowledge of SpriteKit collision behavior
   - Device testing never tested boundary velocities specifically

#### Actions Taken:
- Reverted unauthorized Build 20 commit (`git revert 4a676cc` → `f500a2b`)
- Created comprehensive diagnostic: `Docs/DIAGNOSTIC_velocity_thresholds.md`
- Updated all project management docs (STATUS, DECISIONS, CHANGELOG, PROJECT_LOG)
- **No code fix implemented** — requires game design decision first

#### Files Created:
- `Docs/DIAGNOSTIC_velocity_thresholds.md` — full diagnostic report for developer review

#### Files Modified:
- `STATUS.md` — updated with critical bug status
- `DECISIONS.md` — added pending threshold design decision entry
- `CHANGELOG.md` — added known issues section for Build 19
- `PROJECT_LOG.md` — this entry

#### Pending Decision:
Should speed affect landing success? Options:
- (A) Revert to pre-Build 19 behavior (speed thresholds remain dead code)
- (B) Post-thrust tracking + current thresholds V<40/H<25 (new, harder game)
- (C) Post-thrust tracking + raised thresholds (new enforcement, generous)
- (D) Split sources (display vs enforcement different)

See `Docs/DIAGNOSTIC_velocity_thresholds.md` for full analysis.

#### Definition of Done:
- [x] Root cause fully analyzed (3 iterations of deepening analysis)
- [x] Unauthorized Build 20 reverted
- [x] Diagnostic document created
- [x] All project management docs updated
- [ ] Bug evidence screenshots saved (waiting for user to re-share)
- [ ] Session summary created
- [ ] Design decision made
- [ ] Fix implemented and tested

---

### Session 35 (2026-02-01) - Scoring Overhaul: Per-Platform Speed Bands + HARD Penalty Removal

**Goal:** Remove the overly harsh 0.4× HARD landing penalty, commit per-platform speed bands system, upload Build 21 to TestFlight, and run updated perfect score simulation.

#### Changes Made:

1. **Per-Platform Speed Bands (`LandingThresholds.swift` — new file)**:
   - `SpeedBand` enum: `.safe`, `.hard`, `.fail` with Comparable conformance
   - `PlatformBands` struct: per-platform safe/hard thresholds for V and H speeds
   - Platform A: V≤80/H≤60 (safe), V≤120/H≤100 (hard), above = fail
   - Platform B: V≤55/H≤45 (safe), V≤85/H≤75 (hard), above = fail
   - Platform C: V≤35/H≤30 (safe), V≤55/H≤50 (hard), above = fail
   - Pure `evaluate()` function for landing classification
   - `LandingEvaluationTests.swift`: 20 tests covering all platforms, boundaries, composites

2. **Removed explicit HARD landing penalty (`GameScene+Scoring.swift`, `ScoringHelper.swift`)**:
   - Removed `if speedBand == .hard { subtotal *= 0.4 }` from both production and test scoring
   - HARD landings are now penalized naturally: velocity components (500 soft + 400 horizontal = 900 pts) score zero because speeds exceed the safe threshold (the scoring denominator)
   - Consistent ~55% reduction (HARD gets ~1100/2000 subtotal vs SAFE's 2000/2000)
   - No scoring discontinuity at the SAFE/HARD boundary
   - Satisfies constraint: HARD-C > SAFE-B > SAFE-A at all fuel levels

3. **Updated scoring tests (`ScoringTests.swift`)**:
   - Renamed `testHardLandingPenalty` → `testHardLandingNaturalPenalty`
   - Added `testHardCBeatsSafeB`: verifies constraint at multiple fuel levels
   - Added `testHardCBeatsSafeA`: verifies constraint
   - Added `testNoPenaltyDiscontinuity`: V=34 (SAFE-C) ≈ V=36 (HARD-C) within 100 pts
   - Added `testApproachSpeedImpact`: approach component contributes ~150 pts
   - Total: 16 scoring tests (was 11)

4. **Updated Python scoring script (`Scripts/calculate_perfect_scores.py`)**:
   - Removed 0.4× HARD penalty from `calc_score()` and `score_detail()`
   - All 33/33 optimal landings are in SAFE band (no HARD landings in optimal play)
   - Best: Classic C = 12,077 (via left screen wrap, 30% fuel)
   - Worst: Europa A = 2,663 (43% fuel)
   - Score range: 2,663 – 12,077

5. **Build 21 uploaded to TestFlight**:
   - Bumped build from 19 → 21 (skipping 20 which was reverted)
   - Archive + export succeeded. dSYM warnings for GoogleMobileAds are harmless.

6. **Documented in DECISIONS.md**: Full entry for the removal decision with context, options, and consequences.

#### Perfect Score Simulation Results (Build 21):

| Level | Platform A | Platform B | Platform C | C Direction |
|-------|-----------|-----------|-----------|-------------|
| Classic | 3,023 (60% fuel) | 5,135 (39%) | 12,077 (30%) | ← wrap |
| Moon | 2,776 (53%) | 4,423 (25%) | 10,110 (16%) | ← wrap |
| Mars | 2,766 (55%) | 4,311 (23%) | 10,494 (16%) | ← wrap |
| Titan | 2,687 (50%) | 4,489 (22%) | 10,126 (14%) | ← wrap |
| Europa | 2,663 (43%) | 4,340 (24%) | 9,975 (12%) | ← wrap |
| Earth | 2,750 (48%) | 4,504 (31%) | 10,574 (17%) | ← wrap |
| Venus | 2,757 (50%) | 4,658 (29%) | 10,610 (18%) | ← wrap |
| Mercury | 2,738 (51%) | 4,700 (32%) | 11,047 (23%) | ← wrap |
| Ganymede | 2,781 (53%) | 4,738 (30%) | 10,977 (16%) | ← wrap |
| Io | 2,794 (51%) | 4,454 (21%) | 11,289 (22%) | ← wrap |
| Jupiter | 2,715 (57%) | 4,856 (32%) | 11,244 (25%) | ← wrap |

**Achievement planning (% of ceiling)**: Expert=70%, Good=45%, Average=25%

Key findings:
- All 33/33 landings in SAFE band — optimal play never enters HARD
- 11/33 use left screen wrap (all Platform C)
- 0/33 off-center — center landing always optimal
- Fuel range: 12%–60% remaining

#### Files Created:
- `RocketLander/Models/LandingThresholds.swift`
- `RocketLanderTests/LandingEvaluationTests.swift`

#### Files Modified:
- `RocketLander/GameScene+Scoring.swift` — removed HARD penalty
- `RocketLanderTests/ScoringHelper.swift` — removed HARD penalty
- `RocketLanderTests/ScoringTests.swift` — updated + 5 new tests
- `Scripts/calculate_perfect_scores.py` — removed HARD penalty
- `DECISIONS.md` — new entry for HARD penalty removal
- `RocketLander/Info.plist` — build 19 → 21
- `RocketLander.xcodeproj/project.pbxproj` — added new files to project

#### Definition of Done:
- [x] HARD penalty removed from all 3 scoring implementations (app, test helper, Python)
- [x] Per-platform speed bands committed (LandingThresholds.swift)
- [x] 90/90 tests pass (25 new tests: 20 landing evaluation + 5 scoring)
- [x] Build succeeds
- [x] Build 21 archived and uploaded to TestFlight
- [x] Perfect score simulation updated (33/33 computed, all SAFE band)
- [x] DECISIONS.md entry added
- [x] All docs updated (CHANGELOG, STATUS, PROJECT_LOG, README)
- [x] Session summary created

---

### Session 36 (2026-02-01) - Fix Menu Ad Banner Clipping + Build 22 Upload

**Goal:** Fix the banner ad on the menu screen being clipped by the home indicator safe area. Correct stale documentation. Upload Build 22 to TestFlight with all v2.0.3 changes including menu ad fix.

**What Changed:**
- Added `.padding(.bottom, 16)` to `BannerAdContainer()` in `MenuView` (`ContentView.swift` line 260)
- The ad was the last item in the ScrollView's VStack with no bottom padding, causing it to be clipped by the home indicator on iPhones without a home button
- `GameContainerView.swift` already had `.padding(.bottom, 5)` on its banner ad; menu needed more clearance due to ScrollView behavior
- Corrected stale documentation that incorrectly described velocity threshold enforcement as "pending" (it was implemented in Build 21, commit `1698220`)
- Bumped build number 21 → 22 in Info.plist
- Archived, exported, and uploaded Build 22 to TestFlight (includes menu ad fix + all Build 21 changes)

**Files Modified:**
- `RocketLander/ContentView.swift` — added bottom padding to BannerAdContainer
- `RocketLander/Info.plist` — build number 21 → 22
- `DECISIONS.md` — changed velocity threshold entry from PENDING to RESOLVED
- `STATUS.md`, `PROJECT_LOG.md`, `CHANGELOG.md` — corrected stale references, updated build info

**Key Decisions:**
- Used 16pt padding (vs 5pt in gameplay) because the menu ScrollView needs more clearance when scrolled to the bottom

#### Definition of Done:
- [x] Banner ad fully visible when scrolled to bottom on iPhone 16 Pro
- [x] Build succeeds
- [x] 90/90 tests pass
- [x] Build 22 archived, exported, and uploaded to TestFlight
- [x] All stale "pending" references corrected
- [x] All docs updated with accurate build info
- [x] Session summary created

---

*Last updated: 2026-02-01 (Session 36, Build 22)*
