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
| 1.1.5 | 11 | Submitted for review - New scoring system + HUD fixes |
| 1.2 | - | **IN DEVELOPMENT** - 3 platforms, campaign mode, haptics, file split |

**NEXT STEPS:**
1. Wait for v1.1.5 approval
2. Test v1.2 on device (haptics, all 10 campaign levels)
3. Update Info.plist version to 1.2
4. Submit v1.2 to App Store

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

2. **v1.2 Testing Needed:**
   - Test all 3 platforms on physical device
   - Test haptics on physical device
   - Test all 10 campaign levels
   - Verify campaign persistence across app restarts
   - Test level unlock progression

3. **Phase 3 Planned (v1.4):**
   - Game Center leaderboards (1 classic + 10 level)
   - "Support Development" IAP (remove ads)
   - Share Score card
   - Achievements ("Fuel Master", "Zero Drift", "Elite Pilot")

4. **Phase 4 Planned (v1.5):**
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

## Contact / Accounts

- **Apple Developer Account:** Thiago Borges de Oliveira
- **AdMob Account:** Associated with Google account
- **App Store Connect:** https://appstoreconnect.apple.com

---

*Last updated: 2026-01-30 (Session 11)*
