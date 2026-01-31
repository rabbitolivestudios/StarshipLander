# 2026-01-31 — Session 21: App Store Captioned Screenshots

## Goals
- Bake marketing captions directly onto 5 existing App Store screenshots
- Create a reproducible script for generating captioned screenshots
- Ensure output dimensions remain 1284x2778 PNG

## Changes Made

### 1. Caption Screenshots Script
**What:** Created `Scripts/caption_screenshots.py` — a Python/Pillow script that composites marketing text onto existing screenshots with a dark translucent pill background.
**Why:** Apple does not support visible caption metadata on screenshots. Text must be baked into the image files for App Store marketing.
**Files:** `Scripts/caption_screenshots.py` (new)

Technical details:
- Font: SF Compact Black (`/System/Library/Fonts/SFCompact.ttf`) at 100px — bold sans-serif, "App Store headline" style
- Text color: white (#FFFFFF)
- Background: dark translucent rounded rectangle (rgba 20,20,30 at ~75% opacity, 32px corner radius)
- Position: pill top edge at y=130px (below status bar, within safe area)
- Pill clamped to image bounds to prevent overflow on wide captions
- Fallback font chain for non-macOS systems (SF NS Rounded, Helvetica, DejaVu)

### 2. Captioned Screenshots (5 files)
**What:** Generated 5 captioned PNGs from existing v2.0.0 screenshots.
**Why:** Marketing captions for App Store listing to communicate game features at a glance.
**Files:** `Screenshots/v2.0.0/*_captioned.png` (5 new files)

| # | File | Line 1 | Line 2 | Size |
|---|------|--------|--------|------|
| 1 | `01_main_menu_captioned.png` | PRECISION PILOTING. | NO MARGIN FOR ERROR. | 1296KB |
| 2 | `02_classic_gameplay_captioned.png` | CONTROL THRUST. | MASTER THE DESCENT. | 925KB |
| 3 | `10_landing_success_captioned.png` | PRECISION | IS SCORED. | 813KB |
| 4 | `03_campaign_level_select_captioned.png` | A 10-WORLD | SKILL CAMPAIGN | 1398KB |
| 5 | `06_campaign_venus_crash_captioned.png` | FAILURE | TEACHES CONTROL. | 862KB |

All outputs verified at 1284x2778px, RGBA PNG, lossless.

## Technical Notes
- ImageMagick was not installed; used Python Pillow instead
- macOS system font `SFCompact.ttf` loads as "SF Compact Black" weight — ideal for bold headlines without needing a separate bold font file
- Pillow's `getbbox()` returns (x_offset, y_offset, x_end, y_end); the x_offset and y_offset must be accounted for when positioning text to avoid misalignment
- The pill for screenshot 01 ("NO MARGIN FOR ERROR." at 100px) exceeds image width by 3px per side; clamped with `max(0, ...)` / `min(width, ...)`
- Dark game backgrounds (space theme) make the translucent pill subtle but the white text remains highly readable
- Caption position y=130 places text between the iOS status bar (~y0-120) and game HUD elements (~y260+), partially overlapping game titles/labels which is standard for App Store marketing screenshots

## Decisions
1. **Pillow over ImageMagick** — ImageMagick not installed on this machine. Pillow was available and provides precise pixel-level control for text rendering and alpha compositing.
2. **SF Compact Black over SF NS** — SFCompact.ttf loads as "Black" weight, which is ideal for marketing headlines. SFNS.ttf loads as "Regular" which would look too thin.
3. **Translucent pill over text shadow** — Dark rounded rectangle provides consistent readability across all backgrounds. Text shadow alone would be less visible on the already-dark space backgrounds.
4. **y=130 pill top** — Places caption just below status bar content (which ends ~y120). Overlaps some game UI elements (titles, labels) but this is standard practice for App Store marketing screenshots where the caption is the primary visual element.

## Definition of Done
- [x] 5 captioned PNGs generated at correct dimensions (1284x2778)
- [x] Captions match exact text specified (ALL CAPS, correct punctuation)
- [x] Dark translucent pill background for readability
- [x] Bold sans-serif font (SF Compact Black)
- [x] Positioned at top center within safe area
- [x] Game UI remains visible below captions
- [x] Reproducible script committed
- [x] All outputs committed and pushed

## Commits
- `f3adeb3` — Add captioned App Store screenshots with generation script

## Repo Housekeeping
- [x] Working tree clean (no stale untracked files)
- [x] .gitignore up to date
- [x] README.md project structure matches actual files
- [x] No secrets or credentials in tracked files

## Next Actions
- [ ] Upload captioned screenshots to App Store Connect
- [ ] Wait for App Store review response for v2.0.0
- [ ] Device playtesting: haptics, accelerometer, ads on physical iPhone
- [ ] Plan v2.0.1: campaign per-level high scores display
