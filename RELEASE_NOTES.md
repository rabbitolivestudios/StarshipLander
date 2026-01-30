# Release Notes

## Version 2.0.0 (Build 12)
**Status:** SUBMITTED TO APP STORE CONNECT (2026-01-30)

### Overview
Version 2.0.0 is a major update that transforms Starship Lander from a single-mode arcade game into a full campaign experience across the solar system. Land on 10 different worlds, each with unique gravity, engine thrust, and environmental hazards. Choose between three landing platforms per level with increasing difficulty and score multipliers.

---

### Campaign Mode
A brand new 10-level campaign spanning the solar system. Levels unlock progressively — complete one to unlock the next. Each level features a unique celestial body with its own physics, visuals, and environmental challenges.

| # | Planet | Gravity | Thrust | Special Mechanic |
|---|--------|---------|--------|------------------|
| 1 | Moon | 1.6 m/s² | 8.0 | None — training level |
| 2 | Mars | 2.0 m/s² | 9.5 | Light wind (dust storms) |
| 3 | Titan | 2.2 m/s² | 10.0 | Dense atmosphere (drag + haze) |
| 4 | Europa | 2.5 m/s² | 11.0 | Ice surface (low friction landing) |
| 5 | Earth | 2.8 m/s² | 12.0 | Moving platforms |
| 6 | Venus | 3.2 m/s² | 13.0 | Heavy turbulence (wind gusts) |
| 7 | Mercury | 3.5 m/s² | 14.0 | Heat shimmer (visual distortion) |
| 8 | Ganymede | 3.8 m/s² | 15.0 | Deep craters (rock pillars + terrain walls) |
| 9 | Io | 4.2 m/s² | 16.5 | Volcanic eruptions (terrain particles) |
| 10 | Jupiter | 4.8 m/s² | 18.5 | Extreme wind (powerful gusts) |

- Gravity increases monotonically from 1.6 (Moon) to 4.8 (Jupiter) for a smooth difficulty curve
- Thrust-to-gravity ratio decreases from 5.0x (Moon, floaty and forgiving) to 3.8x (Jupiter, powerful but tight margin)
- Classic mode remains unchanged at gravity 2.0 / thrust 12.0

### Per-Planet Physics
Each planet has a unique engine thrust value, not just different gravity. This means every world has a distinct "engine feel" — Moon feels floaty and forgiving, while Jupiter gives you raw power but almost no margin for error. Players must adapt their piloting style to each destination.

### Three Landing Platforms
Every level now features three landing platforms with different sizes and score multipliers:

| Platform | Position | Width | Multiplier | Color |
|----------|----------|-------|------------|-------|
| Training Zone (A) | Left (18%) | 130pt | 1x | Green |
| Precision Target (B) | Center (50%) | 110pt | 2x | Yellow |
| Elite Landing (C) | Right (82%) | 80pt | 5x | Red |

- Platform labels and multiplier text displayed below each platform
- Terrain automatically generates valleys around each platform position
- Choose your risk/reward — easy landing or high score attempt

### Visual Effects
Each environmental mechanic now has a corresponding visual effect:

- **Wind streaks** (Mars, Venus, Jupiter): Horizontal particle streaks at 3 intensity levels — light dust (Mars), heavy haze (Venus), extreme streaks (Jupiter)
- **Atmosphere haze** (Titan): Semi-transparent overlay with drifting cloud particles simulating Titan's thick nitrogen atmosphere
- **Ice shimmer** (Europa): Twinkling sparkle particles near the platform surface, plus low-friction physics on landing
- **Heat shimmer** (Mercury): Subtle rocket position jitter simulating heat distortion from the scorching surface
- **Volcanic eruptions** (Io): Particle bursts erupting from the terrain, referencing Io's extreme volcanic activity
- **Planetary bodies**: Each level displays its parent planet/moon in the sky (Earth shows the Moon, Titan shows Saturn, etc.)

### Star Rating System
Earn 1 to 3 stars per landing based on which platform you land on:
- Platform A (Training Zone) = 1 star
- Platform B (Precision Target) = 2 stars
- Platform C (Elite Landing) = 3 stars

Total: 30 stars possible across all 10 campaign levels. Star count displayed on the main menu and level select screen.

### Scoring System
Platform multiplier stacks with the existing fuel multiplier:
- Formula: `base subtotal × fuel multiplier × platform multiplier`
- Max theoretical score: 2,000 × 2.5 × 5 = **25,000 points**
- Score components: Soft landing (700), Horizontal precision (400), Platform center (350), Rotation (250), Approach control (200)

### Per-Level High Scores
Campaign mode tracks top-3 scores **per level** separately from classic mode's global leaderboard. Each planet has its own leaderboard with its own high score entries.

### Landing Messages
Contextual feedback on every landing and crash:
- **Success messages** rotate: "Landing confirmed.", "Precision achieved.", "Controlled descent.", etc.
- **Elite messages** for 3-star landings: "Elite landing.", "Near-perfect execution."
- **Crash messages** with teaching tips: "Try a slower approach.", "Keep the rocket upright on final approach.", etc.
- **Rare easter egg** (1 in 50 chance, score > 4,500): "This was exceptional."

### Haptic Feedback
Tactile feedback for all key game actions (iPhone only):
- **Thrust**: Light continuous pulse every 100ms while engine is firing
- **Rotation**: Medium impact haptic on rotation start
- **Successful landing**: Success notification haptic
- **Crash**: Heavy double-tap impact

### Improved Controls
- **Lateral assist (RCS thrusters)**: When the rocket is tilted >5°, a small horizontal nudge is applied in the tilt direction for more responsive lateral movement
- **Increased rotation power**: `rotationPower` increased from 0.025 to 0.04
- **Reduced angular damping**: From 1.0 to 0.7 for snappier rotation response

### Astronaut Easter Eggs
High score leaderboards come pre-populated with 1,000-point default entries featuring names of astronauts and scientists relevant to each celestial body:

| Level | Default Name | Reference |
|-------|-------------|-----------|
| Classic | Elon | Elon Musk, SpaceX founder |
| Moon | Armstrong | Neil Armstrong, first moonwalker |
| Mars | Aldrin | Buzz Aldrin, Mars mission advocate |
| Titan | Huygens | Christiaan Huygens, discovered Titan |
| Europa | Galileo | Galileo Galilei, discovered Europa |
| Earth | Gagarin | Yuri Gagarin, first human in space |
| Venus | Shepard | Alan Shepard, first American in space |
| Mercury | Glenn | John Glenn, Project Mercury astronaut |
| Ganymede | Marius | Simon Marius, named the Galilean moons |
| Io | Collins | Michael Collins, Apollo 11 command module pilot |
| Jupiter | Shoemaker | Eugene Shoemaker, Shoemaker-Levy 9 comet |

Default scores are seeded only on first launch — they will never overwrite player scores.

### Level Select Screen
- 2-column grid showing all 10 levels
- Each card displays: level number, planet name, star count, best score
- Unlocked levels show gravity (m/s²) and special mechanic
- Locked levels appear dimmed with a lock icon
- Total star count displayed at top right

### Ganymede Deep Craters
Ganymede features a unique hazard: deep crater terrain with rock pillar obstacles.
- Three jagged rock pillars with collision physics (left edge, between platforms B-C, right edge)
- Terrain walls ramp up to 350px at screen edges, creating a crater bowl effect
- Hitting terrain or rock pillars is fatal — adds a navigation challenge unique to this level

### Menu Redesign
- Two launch buttons: "Classic" (orange) and "Campaign" (blue/purple gradient)
- TOP PILOTS leaderboard displayed on main menu
- Total campaign star count shown between the buttons
- Menu wrapped in ScrollView for Dynamic Island safe area support
- "HOW TO PLAY" and controls section fully visible on all screen sizes

### Game Over Screen
- Shows star rating for the landing
- Displays platform name and multiplier
- "Next Level" button in campaign mode to advance without returning to menu
- "Retry" button to immediately replay the same level
- High score entry appears inline when score qualifies

---

### Bug Fixes
- **Fixed**: Game title "STARSHIP" no longer hidden behind Dynamic Island on iPhone 16 and later — menu wrapped in ScrollView to respect safe area insets
- **Fixed**: "HOW TO PLAY" section and banner ad no longer cut off at bottom of menu on any screen size
- **Fixed**: Earth level moving platforms no longer overlap during movement — Platform A now bobs vertically only, Platform B/C horizontal sway reduced, edge clamping enforces minimum 10pt gaps
- **Fixed**: Campaign gravity fully rebalanced — all 10 levels use progressively increasing gravity (1.6 → 4.8) with per-level thrust scaling for a smooth difficulty curve
- **Fixed**: Ganymede terrain now features rock pillar obstacles and raised crater walls instead of failed terrain ridge approach

### Architecture
- Codebase split from 2 monolithic files (~900 lines each) into 21 organized files:
  - `Models/`: GameState, HighScoreManager, LandingPlatform, LandingMessages, LevelDefinition, CampaignState
  - `Views/`: GameContainerView, GameOverView, HUDViews, ControlViews, ShapeViews, LevelSelectView
  - `Haptics/`: HapticManager
  - `GameScene+Setup.swift`, `GameScene+Effects.swift`, `GameScene+Sound.swift`, `GameScene+Scoring.swift`
- ContentView.swift trimmed to ContentView + MenuView only
- GameScene.swift trimmed to core update loop, physics, and collision handling

---

### App Store Release Notes (Copy this)
```
MAJOR UPDATE — Campaign Mode is here!

Explore the solar system in an all-new 10-level campaign! Land on the Moon, Mars, Titan, Europa, Earth, Venus, Mercury, Ganymede, Io, and Jupiter — each with unique gravity, engine thrust, and environmental hazards.

NEW FEATURES:
• Campaign Mode — 10 levels with progressive difficulty
• Per-planet physics — adapt to each world's unique gravity and engine feel
• Three landing platforms per level — Training Zone (1x), Precision Target (2x), Elite Landing (5x)
• Visual effects — wind streaks, atmospheric haze, ice shimmer, heat distortion, volcanic eruptions
• Star rating system — earn up to 3 stars per landing (30 total)
• Haptic feedback — feel the thrust, landings, and crashes
• Contextual landing messages with crash tips
• Per-level high score leaderboards
• Astronaut easter egg high scores — can you beat Armstrong on the Moon?
• Score up to 25,000 points with platform and fuel multipliers!

IMPROVEMENTS:
• More responsive controls with RCS thruster assist
• Fixed layout for iPhone 16 Dynamic Island
• Redesigned menu with Classic and Campaign modes
```

---

## Version 1.1.5 (Build 11)
**Status:** SUBMITTED FOR REVIEW (2026-01-16)

### What's New
- New scoring system with better differentiation (max ~5000 points)
- Continuous scoring - every improvement counts
- Fuel efficiency now multiplies your score (save fuel for higher scores!)
- Fixed HUD text wrapping on high velocities
- Version number now displayed on menu screen

### App Store Release Notes (Copy this)
```
- New and improved scoring system (max ~5000 points)
- Save fuel to multiply your score!
- Bug fixes and improvements
```

---

## Version 1.1.4 (Build 10)
**Status:** PUBLISHED (2026-01-15)

### What's New
- Complete fix for high score name input bug
- New Starship-style app icon (cylindrical body, flaps, landing legs)

### App Store Release Notes (Copy this)
```
- New Starship-style app icon
- Fixed high score name input issue
- Bug fixes and improvements
```

---

## Version 1.1.3 (Build 7)
**Status:** PUBLISHED (2026-01-14)

### What's New
- Fixed high score name input not responding to taps
- Updated developer website URLs

### App Store Release Notes (Copy this)
```
- Fixed issue where high score name input wasn't responding
- Bug fixes and improvements
```

---

## Version 1.1.2 (Build 6)
**Status:** PUBLISHED (2026-01-12)

### What's New
- New accelerometer controls - tilt your phone to rotate the rocket
- Toggle between button and tilt controls in the menu
- Improved button sensitivity for finer rotation control

### App Store Release Notes (Copy this)
```
- New accelerometer controls! Tilt your phone to rotate the rocket
- Toggle between button and tilt controls in the menu
- Improved button sensitivity for finer rotation control
- Smoother gameplay experience
```

---

## Version 1.1.0 (Build 4)
**Status:** PUBLISHED (2026-01-12)

### What's New
- Added support for advertisements to help keep the game free

### App Store Release Notes
```
Bug fixes and performance improvements.
Added support for in-app advertisements.
```

---

## Version 1.0 (Build 2)
**Status:** REJECTED (Guideline 5.1.2 - Superseded by v1.1)

### What's New
- Initial release of Starship Lander
- Land the Starship safely on the platform
- Retro 16-bit sound effects
- High score leaderboard

### App Store Release Notes
```
Land the Starship on the landing platform!

Features:
• Realistic physics-based gameplay
• Intuitive touch controls for thrust and rotation
• Retro 16-bit sound effects
• High score leaderboard - compete for the top spot!
• Fuel management adds strategic depth

Can you master the perfect landing?
```
