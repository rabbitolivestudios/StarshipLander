# Starship Lander

A physics-based rocket landing game for iOS, inspired by SpaceX Starship landings.

**Version:** 2.0.2
**Platform:** iOS 15.0+
**Language:** Swift 5.0
**Frameworks:** SwiftUI, SpriteKit, CoreMotion
**Developer:** Rabbit Olive Studios

## Game Overview

Guide your Starship through a controlled descent and land safely on one of three landing platforms. Master thrust control, manage your fuel efficiently, and achieve the perfect landing! Play Classic Mode for free-form practice or tackle Campaign Mode across 10 solar system destinations.

### Features

- **Realistic Physics**: SpriteKit-powered physics simulation
- **Starship Design**: Authentic SpaceX Starship-inspired rocket with flaps and landing legs
- **Three Landing Platforms**: Training Zone (1x), Precision Target (2x), Elite Landing (5x)
- **Campaign Mode**: 10 levels across the solar system with unique gravity and mechanics
- **Dual Control Modes**: Touch buttons or accelerometer (tilt to rotate)
- **Haptic Feedback**: Tactile responses for thrust, rotation, landing, and crashes
- **16-Bit Sound Effects**: Retro chiptune audio for all actions
- **Star Rating System**: Earn 1-3 stars per landing based on platform difficulty
- **Landing Messages**: Contextual feedback with teaching nudges on crashes
- **Skill-Based Scoring**: Up to 20,000 points with platform and fuel multipliers
- **High Score Leaderboard**: Track your top 3 landings
- **AdMob Integration**: Banner ads with App Tracking Transparency support

### Controls

| Control | Action |
|---------|--------|
| **THRUST** (center) | Fire main engines |
| **L** (left) | Rotate counter-clockwise |
| **R** (right) | Rotate clockwise |
| **Tilt** (accelerometer mode) | Tilt phone left/right to rotate |

Toggle between button and accelerometer controls in the main menu.

### Scoring System

**Continuous scoring with dual multipliers (Max ~20,000 points)**

| Component | Max Points | Description |
|-----------|------------|-------------|
| Base | 100 | Successful landing |
| Soft Landing | 500 | Lower vertical speed = more points |
| Horizontal Precision | 400 | Less drift = more points |
| Platform Center | 600 | Closer to center = more points |
| Rotation | 250 | More upright = more points |
| Approach Control | 150 | Controlled descent = more points |
| **Subtotal** | **2000** | Before multipliers |
| **Fuel Multiplier** | **1.0x - 2.0x** | More fuel = higher multiplier |
| **Platform Multiplier** | **1x / 2x / 5x** | Harder platform = higher multiplier |
| **Maximum** | **~20,000** | Perfect landing + 100% fuel + Platform C |

**Formula:** `subtotal × fuelMultiplier × platformMultiplier`

### Landing Platforms

| Platform | Position | Width | Multiplier | Stars | Color |
|----------|----------|-------|------------|-------|-------|
| A — Training Zone | Left (18%) | 130pt | 1x | 1 | Green |
| B — Precision Target | Center (50%) | 110pt | 2x | 2 | Yellow |
| C — Elite Landing | Right (82%) | 80pt | 5x | 3 | Red |

### Campaign Levels

| # | Name | Gravity | Thrust | Special Mechanic |
|---|------|---------|--------|------------------|
| 1 | Moon | 1.6 | 8.0 | None (tutorial) |
| 2 | Mars | 2.0 | 9.5 | Light dust wind |
| 3 | Titan | 2.2 | 10.0 | Dense atmosphere |
| 4 | Europa | 2.5 | 11.0 | Ice surface |
| 5 | Earth | 2.8 | 12.0 | Moving platforms |
| 6 | Venus | 3.2 | 13.0 | Vertical updrafts |
| 7 | Mercury | 3.5 | 14.0 | Heat interference |
| 8 | Ganymede | 3.8 | 15.0 | Deep craters |
| 9 | Io | 4.2 | 16.5 | Deadly volcanic debris |
| 10 | Jupiter | 4.8 | 18.5 | Sudden wind gusts |

*Gravity and thrust increase progressively by level. Each planet has a unique thrust feel — higher gravity levels have more powerful but tighter-margin engines. Values are game-balanced for playability, not real-world accurate.*

## Project Structure

```
StarshipLander/
├── RocketLander/
│   ├── RocketLanderApp.swift        # App entry point, ATT & AdMob init
│   ├── ContentView.swift            # ContentView + MenuView (navigation root)
│   ├── GameScene.swift              # Core update loop, physics, collision
│   ├── GameScene+Setup.swift        # Starfield, terrain, platforms, rocket creation
│   ├── GameScene+Effects.swift      # Explosions, flames, visual effects
│   ├── GameScene+Sound.swift        # All sound methods
│   ├── GameScene+Scoring.swift      # Score calculation, platform detection
│   ├── BannerAdView.swift           # AdMob banner integration
│   ├── Info.plist                   # App configuration
│   ├── Models/
│   │   ├── GameState.swift          # ObservableObject game state
│   │   ├── HighScoreManager.swift   # High score persistence
│   │   ├── LandingPlatform.swift    # Platform A/B/C definitions
│   │   ├── LandingMessages.swift    # Success/crash/rare messages
│   │   ├── LevelDefinition.swift    # 10 campaign level definitions
│   │   └── CampaignState.swift      # Campaign progress persistence
│   ├── Views/
│   │   ├── GameContainerView.swift  # Game container + SpriteKit bridge
│   │   ├── GameOverView.swift       # Game over screen with stars
│   │   ├── HUDViews.swift           # Top HUD + velocity display
│   │   ├── ControlViews.swift       # Bottom controls + buttons
│   │   ├── ShapeViews.swift         # Rocket illustration shapes
│   │   ├── LeaderboardView.swift     # Dedicated leaderboard screen
│   │   └── LevelSelectView.swift    # Campaign level grid
│   ├── Haptics/
│   │   └── HapticManager.swift      # Haptic feedback manager
│   ├── Assets.xcassets/             # App icons and colors
│   └── Sounds/                      # Audio files
│       ├── thrust.wav               # Engine loop
│       ├── rotate.wav               # Rotation blip
│       ├── land_success.wav         # Victory fanfare
│       └── explosion.wav            # Crash sound
├── Docs/
│   └── chats/                       # Session summaries (context restoration)
├── Screenshots/
│   └── v2.0.0/                      # App Store screenshots (1284x2778)
├── Scripts/
│   ├── generate_sounds.py           # Sound effect generator
│   ├── generate_icon.py             # App icon generator
│   ├── generate_screenshots.py      # Screenshot generator
│   └── export_chat_transcripts.py   # Claude Code transcript exporter
├── .github/
│   └── pull_request_template.md     # PR checklist template
├── RocketLander.xcodeproj           # Xcode project
├── CLAUDE.md                        # Claude Code session guidelines
├── STATUS.md                        # Authoritative project snapshot
├── CHANGELOG.md                     # Version history
├── PROJECT_LOG.md                   # Development session logs
├── RELEASE_NOTES.md                 # App Store release notes
├── DECISIONS.md                     # Architectural/design decision records
└── README.md                        # This file
```

## Development

### Prerequisites

- macOS with Xcode 15.0+
- iOS Simulator or physical device
- Apple Developer Account (for device testing & App Store)
- Python 3 (optional, for sound/icon generation)

### Dependencies

Managed via **Swift Package Manager**:
- Google Mobile Ads SDK (v12.14.0)
- Google User Messaging Platform

### Building

```bash
# Open project
open RocketLander.xcodeproj

# Build for simulator
xcodebuild -scheme RocketLander \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  build

# Archive for App Store
xcodebuild -scheme RocketLander \
  -destination 'generic/platform=iOS' \
  -archivePath ./build/RocketLander.xcarchive \
  archive
```

### Regenerating Sound Effects

```bash
python3 Scripts/generate_sounds.py
```

## Technical Specifications

### Game Physics (Classic Mode)
- Gravity: 2.0 units/frame²
- Thrust power: 12.0 velocity/frame
- Rotation power: 0.04 angular velocity/frame (buttons)
- Angular damping: 0.7
- Thrust vectoring: proportional lateral force when tilted while thrusting (0.15 factor)
- Accelerometer sensitivity: 0.06 with 0.1 dead zone

### Landing Thresholds
- Max vertical speed: 40 units/frame
- Max horizontal speed: 25 units/frame
- Max rotation: 0.05 radians (~3°)
- Max approach speed: 80 units/frame

### Fuel Consumption
- Thrust: 0.3% per frame
- Rotation (buttons): 0.08% per frame
- Rotation (accelerometer): scales with tilt intensity

## App Store

**Available on the App Store**: [Starship Lander](https://apps.apple.com/app/starship-lander/id6740857083)

**Developer Website**: https://rabbitolivestudios.github.io

## License

Proprietary - All rights reserved.
© 2026 Rabbit Olive Studios

## Version History

See [CHANGELOG.md](CHANGELOG.md) for detailed version history.

| Version | Date | Description |
|---------|------|-------------|
| 2.0.2 | 2026-01-31 | Campaign polish: scoring, thrust vectoring, planet differentiation |
| 2.0.1 | 2026-01-31 | Dedicated leaderboard screen, version label fix |
| 2.0.0 | 2026-01-30 | Campaign mode, per-planet physics, visual effects |
| 1.1.5 | 2026-01-16 | New scoring system, HUD fixes, version display |
| 1.1.4 | 2026-01-15 | Complete fix for high score input bug, new icon |
| 1.1.3 | 2026-01-14 | Developer website URLs |
| 1.1.2 | 2026-01-12 | Accelerometer controls, reduced rotation sensitivity |
| 1.1.0 | 2026-01-10 | AdMob integration, App Tracking Transparency |
| 1.0.0 | 2026-01-08 | Initial App Store release |
