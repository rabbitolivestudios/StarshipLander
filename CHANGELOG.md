# Changelog

All notable changes to the Starship Lander project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
| 1.0.0   | 2026-01-08 | Starship design, sounds, improved scoring     |
| 0.1.0   | 2026-01-07 | Initial development, core gameplay            |
