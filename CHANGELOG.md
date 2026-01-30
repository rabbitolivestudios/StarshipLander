# Changelog

All notable changes to the Starship Lander project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.0] - 2026-01-30

### Added
- **Three Landing Platforms (A/B/C)**: Each with different sizes, positions, and score multipliers
  - Platform A (left, 18%): 130pt wide, 1x multiplier, green lights — "Training Zone"
  - Platform B (center, 50%): 110pt wide, 2x multiplier, yellow lights — "Precision Target"
  - Platform C (right, 82%): 80pt wide, 5x multiplier, red lights — "Elite Landing"
  - Platform labels and multiplier text displayed below each platform
  - Terrain generates valleys around each platform position

- **Campaign Mode**: 10 solar system levels with unique physics and visuals
  - Moon (1.6g), Mars (3.7g), Titan (1.4g), Europa (1.3g), Earth (9.8g)
  - Venus (8.9g), Mercury (3.7g), Ganymede (1.4g), Io (1.8g), Jupiter (24.8g)
  - Special mechanics per level: wind, dense atmosphere, ice surface, moving platform, turbulence, heat shimmer, deep craters, volcanic eruptions, extreme wind
  - Campaign state persistence via UserDefaults (unlocked levels, stars, scores)
  - Level select grid UI with lock/unlock, star count, best scores

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
| 1.2.0   | 2026-01-30 | 3 platforms, campaign mode, haptics, messages |
| 1.1.5   | 2026-01-16 | New scoring system, HUD fixes, version display|
| 1.1.4   | 2026-01-15 | New Starship icon, high score bug fix         |
| 1.1.3   | 2026-01-14 | Developer website, partial bug fix            |
| 1.1.2   | 2026-01-12 | Accelerometer controls, reduced sensitivity   |
| 1.1.1   | 2026-01-12 | Bug fixes (high score input, ads)             |
| 1.1.0   | 2026-01-10 | AdMob integration for ad revenue              |
| 1.0.0   | 2026-01-08 | Starship design, sounds, improved scoring     |
| 0.1.0   | 2026-01-07 | Initial development, core gameplay            |
