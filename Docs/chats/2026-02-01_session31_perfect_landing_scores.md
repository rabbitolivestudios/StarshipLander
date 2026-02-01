# 2026-02-01 — Session 31: Perfect Landing Score Analysis

## Goals
- Calculate the theoretical "perfect landing" score for each platform on each level
- Build a frame-by-frame physics simulation matching SpriteKit's actual behavior
- Use results for future achievement planning, difficulty tuning, and Game Center targets

## Changes Made

### 1. Perfect Landing Score Calculator Script
**What:** Created `Scripts/calculate_perfect_scores.py` — a frame-by-frame physics simulation that models the exact game physics (gravity, thrust, fuel, approach speed gate, screen wrapping) and uses a reactive controller to find the maximum achievable score for all 11 levels x 3 platforms = 33 combinations.
**Why:** Understanding the scoring ceiling for each level/platform combination is critical for setting achievement thresholds, Game Center leaderboard expectations, and difficulty balance analysis.
**Files:** `Scripts/calculate_perfect_scores.py` (new)
**App code changed:** None

## Research / Ideas Discussed

### SpriteKit Physics Model (verified against GameScene.swift)
- **Unit conversion**: 1 SpriteKit meter = 150 points. Velocity in pts/s.
- **Gravity per frame**: `|g| × 150 / 60 = |g| × 2.5 pts/s`
- **Thrust mechanics** (GameScene.swift lines 259-271):
  - `angle = zRotation + π/2`
  - Vertical: `cos(zRotation) × T`
  - Horizontal: `-sin(zRotation) × T + sin(zRotation) × T × 0.15` = net `sin(θ) × T × 0.85`
- **Fuel**: 0.3%/thrust frame, 0.08%/rotation frame
- **Binary thrust**: on/off only, no partial thrust. Controlled descent requires PWM-style pulse thrusting.

### Approach Speed is a CRASH GATE (critical discovery)
- `approachSpeed = avg(last 30 velocity samples)` (GameScene.swift line 479)
- If > 80 pts/s, it's a **crash**, NOT just a scoring penalty (line 490)
- This makes pure suicide burns unviable — must maintain controlled descent for 30+ frames
- Hover duty cycle: fraction of frames needing thrust = g_frame/T (Classic: 41.7%, Jupiter: 64.9%)

### Screen Wrapping for Platform C
- Game wraps at x < -20 → x = screenW+20 (GameScene.swift lines 338-343)
- Platform C (x=322.3) is **shorter going LEFT via wrap** than going right:
  - Right: 263.3 pts
  - Left wrap: 169.7 pts (36% shorter!)
- All 11 Platform C optimal trajectories use the left wrap

### Score Optimization: Center vs Fuel Trade-off
- The optimizer searched landing positions from -0.8 to +0.8 across platform width
- **Center landing ALWAYS wins** (0/33 off-center optimal), even though off-center saves fuel
- Reason: the 600 center bonus × platform multiplier (especially 5x for C) outweighs fuel savings
- Example: Platform C center = 600×5=3,000 bonus; fuel savings from edge landing ≈ 5-10% → only 500-1,000 pts from multiplier

### Simulation Controller Strategy
The reactive controller uses:
1. **Freefall**: When well above braking zone, no thrust (save fuel)
2. **Horizontal thrust during freefall**: For distant platforms (B, C), thrust at high tilt angle during excess altitude to build horizontal velocity
3. **Tilted braking**: When entering brake zone, thrust with tilt toward target (simultaneous vertical braking + horizontal acceleration)
4. **Adjusted hover**: PWM hover with tilt-corrected duty cycle (`gv / (cos(θ)*T)` instead of `gv/T`)
5. **Landing**: Cancel horizontal velocity near platform, touch down

### Key Physics Findings
- **Per-frame physics ratios**: Classic 2.40×, Moon 2.00×, Jupiter 1.54× (T / g_frame)
- **Hover duty cycle**: Classic 41.7%, Moon 50.0%, Jupiter 64.9%
- **Fall height**: 528 pts (START_Y 752 - PLATFORM_Y 224)
- **Start position**: x=58.95 (15% of screen width)

## Results — Perfect Landing Scores

### Score Table (all 33/33 successful)

| Level | g | T | Platform A | Fuel% | Platform B | Fuel% | Platform C (←wrap) | Fuel% |
|-------|---|---|----------:|------:|----------:|------:|-------------------:|------:|
| Classic | 2.0 | 12.0 | 2,980 | 60% | 5,067 | 39% | **12,132** | 30% |
| Moon | 1.6 | 8.0 | 2,684 | 48% | 4,299 | 18% | 10,461 | 17% |
| Mars | 2.0 | 9.5 | 2,712 | 44% | 4,627 | 23% | 10,955 | 16% |
| Titan | 2.2 | 10.0 | 2,732 | 46% | 4,512 | 19% | 10,628 | 20% |
| Europa | 2.5 | 11.0 | 2,776 | 48% | 4,509 | 24% | 10,787 | 20% |
| Earth | 2.8 | 12.0 | 2,809 | 48% | 4,662 | 23% | 11,144 | 23% |
| Venus | 3.2 | 13.0 | 2,710 | 50% | 4,574 | 24% | 11,010 | 20% |
| Mercury | 3.5 | 14.0 | 2,763 | 44% | 4,627 | 28% | 11,391 | 22% |
| Ganymede | 3.8 | 15.0 | 2,800 | 51% | 4,662 | 24% | 11,452 | 25% |
| Io | 4.2 | 16.5 | 2,881 | 54% | 4,812 | 28% | 11,579 | 29% |
| Jupiter | 4.8 | 18.5 | 2,853 | 54% | 4,967 | 33% | 12,076 | 33% |

### Key Findings
- **Best possible: Classic C = 12,132** (30% fuel, via left wrap)
- **Worst possible: Moon A = 2,684** (48% fuel)
- **Theoretical max: 20,000** (impossible — requires 0 speed, 100% fuel, dead center)
- **Best achievable is 60.7% of theoretical max** (12,132 / 20,000)
- **Fuel range: 16%–60%** across all combinations
- **Validation: Classic A simulation = 2,980 vs user's real score = 2,965** (0.5% difference)

### Achievement Planning Reference (% of ceiling)
- Expert (70%): Classic C ≈ 8,492
- Good (45%): Classic C ≈ 5,459
- Average (25%): Classic C ≈ 3,033

## Technical Notes
- Simulation iteratively debugged over multiple rewrites. Key challenges:
  1. SpriteKit velocity is in pts/s (150 pts/m conversion), not m/s
  2. Approach speed is a crash gate, not just a scoring penalty
  3. Hover duty cycle must account for tilt angle
  4. Horizontal movement must happen during ALL thrust frames (braking + hover + freefall-zone horizontal)
  5. Screen wrapping reduces Platform C horizontal distance by 36%
- The optimizer searches a 4D space: target descent speed × max tilt × direction (L/R) × landing position offset
- Fine-tuning pass around the coarse optimum for higher precision
- Controller successfully handles all thrust-to-gravity ratios from Moon (2.0×) to Classic (2.4×)

## Decisions
1. **"Perfect landing" = maximum score, not just center landing**: Optimizer searches landing positions across platform width. Center always wins due to multiplier amplification.
2. **Screen wrapping is the optimal Platform C strategy**: Going left (170 pts) beats going right (263 pts) for all levels.

## Definition of Done
- [x] Physics simulation matches SpriteKit behavior
- [x] All 33 level/platform combinations computed
- [x] Screen wrapping implemented
- [x] Landing position optimization implemented
- [x] Results validated against real gameplay (Classic A: 2,980 sim vs 2,965 real)
- [x] Script saved to Scripts/calculate_perfect_scores.py
- [x] No app code changes
- [x] Session summary created
- [x] STATUS.md updated
- [x] PROJECT_LOG.md updated

## Commits
- `a49dc8b` — Add perfect landing score analysis: 33 level/platform combinations
- `ab43822` — Update session 31 summary with commit hash
- `9ed8272` — Update CHANGELOG.md and DECISIONS.md for session 31

## Repo Housekeeping
- [x] Working tree clean (no stale untracked files)
- [x] .gitignore up to date
- [x] README.md project structure matches actual files (calculate_perfect_scores.py already listed)
- [x] No secrets or credentials in tracked files

## Next Actions
- [ ] Wait for App Store review response for v2.0.2
- [ ] Use perfect landing scores to set Game Center achievement thresholds (v2.1.0)
- [ ] Consider adding the score ceiling data to the game itself (e.g., "Your score: X / Best possible: Y")
- [ ] Further validate scores with actual gameplay on more levels
- [ ] Plan v2.1.0 (Game Center + achievements)
