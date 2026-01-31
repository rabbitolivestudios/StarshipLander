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

## Current Status (2026-01-30)

| Version | Build | Status |
|---------|-------|--------|
| 1.0 | 2 | Rejected (Guideline 5.1.2 - tracking without ATT) |
| 1.1.0 | 4 | Published on App Store |
| 1.1.1 | 5 | Bug fixes (not uploaded - superseded) |
| 1.1.2 | 6 | Published - Accelerometer controls |
| 1.1.3 | 7 | Published - Partial bug fix + URL update |
| 1.1.4 | 10 | Published - Bug fix + new icon |
| 1.1.5 | 11 | Published on App Store - New scoring system + HUD fixes |
| 2.0.0 | 12 | **SUBMITTED FOR REVIEW** - Campaign mode, per-planet physics, visual effects |
| 2.0.1 | 13 | Dedicated leaderboard screen, version label fix |

**NEXT STEPS:**
1. Wait for App Store review response
2. If rejected, address feedback and resubmit
3. If approved, verify live listing screenshots and description

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
- Automated tests (XCTest)

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

## Contact / Accounts

- **Apple Developer Account:** Thiago Borges de Oliveira
- **AdMob Account:** Associated with Google account
- **App Store Connect:** https://appstoreconnect.apple.com

---

*Last updated: 2026-01-31 (Session 25)*
