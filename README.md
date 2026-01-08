# Starship Lander

A physics-based rocket landing game for iOS, inspired by SpaceX Starship landings.

**Version:** 1.0.0
**Platform:** iOS 15.0+
**Language:** Swift 5.0
**Frameworks:** SwiftUI, SpriteKit

## Game Overview

Guide your Starship through a controlled descent and land safely on the platform. Master thrust control, manage your fuel efficiently, and achieve the perfect landing!

### Features

- **Realistic Physics**: SpriteKit-powered physics simulation
- **Starship Design**: Authentic SpaceX Starship-inspired rocket with flaps and landing legs
- **16-Bit Sound Effects**: Retro chiptune audio for thrust, rotation, landing, and crashes
- **Skill-Based Scoring**: Score based on fuel efficiency, landing precision, and approach control
- **High Score Leaderboard**: Track your top 3 landings
- **AdMob Integration**: Monetization-ready with banner ads

### Controls

| Control | Action |
|---------|--------|
| **THRUST** (center) | Fire main engines |
| **L** (left) | Rotate counter-clockwise |
| **R** (right) | Rotate clockwise |

### Scoring System

| Component | Max Points | Criteria |
|-----------|------------|----------|
| Base | 100 | Successful landing |
| Fuel Efficiency | 500 | More remaining fuel = higher score |
| Soft Landing | 300 | Lower vertical speed at touchdown |
| Horizontal Precision | 200 | Minimal horizontal drift |
| Platform Center | 150 | Land closer to platform center |
| Rotation | 100 | Land perfectly upright |
| Approach Control | 100 | Controlled descent speed |
| **Maximum** | **~1450** | Perfect landing |

## Project Structure

```
StarshipLander/
├── RocketLander/
│   ├── RocketLanderApp.swift    # App entry point
│   ├── ContentView.swift        # UI, menus, controls (868 lines)
│   ├── GameScene.swift          # Game logic, physics (830 lines)
│   ├── BannerAdView.swift       # AdMob integration
│   ├── Info.plist               # App configuration
│   ├── Assets.xcassets/         # App icons and colors
│   └── Sounds/                  # Audio files
│       ├── thrust.wav           # Engine loop
│       ├── rotate.wav           # Rotation blip
│       ├── land_success.wav     # Victory fanfare
│       └── explosion.wav        # Crash sound
├── Scripts/
│   ├── generate_sounds.py       # Sound effect generator
│   ├── generate_icon.py         # App icon generator
│   └── app_store_metadata.json  # App Store listing data
├── RocketLander.xcodeproj/      # Xcode project
├── Podfile                      # CocoaPods dependencies
├── CHANGELOG.md                 # Version history
├── SETUP.txt                    # App Store submission guide
├── privacy_policy.html          # Privacy policy
└── setup_and_submit.sh          # Automation script
```

## Development

### Prerequisites

- macOS with Xcode 15.0+
- iOS Simulator or physical device
- CocoaPods (for AdMob SDK)
- Python 3 (for sound/icon generation)

### Building

```bash
# Open project
open RocketLander.xcodeproj

# Or with CocoaPods (for AdMob)
pod install
open RocketLander.xcworkspace
```

### Regenerating Sound Effects

```bash
python3 Scripts/generate_sounds.py
```

### Running Tests

Build and run on iOS Simulator via Xcode or:

```bash
xcodebuild -project RocketLander.xcodeproj \
  -scheme RocketLander \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  build
```

## App Store Submission

See `SETUP.txt` for complete App Store submission instructions.

### Quick Checklist

- [ ] Apple Developer Account ($99/year)
- [ ] AdMob Account (for ad revenue)
- [ ] Run `./setup_and_submit.sh`
- [ ] Create app in App Store Connect
- [ ] Upload screenshots
- [ ] Host privacy policy
- [ ] Submit for review

## Technical Specifications

### Game Physics
- Gravity: 2.0 units/frame²
- Thrust power: 12.0 velocity/frame
- Rotation power: 0.05 angular velocity/frame

### Landing Thresholds
- Max vertical speed: 40 units/frame
- Max horizontal speed: 25 units/frame
- Max rotation: 0.05 radians (~3°)
- Max approach speed: 80 units/frame

### Fuel Consumption
- Thrust: 0.3% per frame
- Rotation: 0.08% per frame

## License

Proprietary - All rights reserved.

## Version History

See [CHANGELOG.md](CHANGELOG.md) for detailed version history.

| Version | Date | Description |
|---------|------|-------------|
| 1.0.0 | 2026-01-08 | Initial App Store release |
