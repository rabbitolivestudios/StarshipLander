# 2026-02-06 — Session 55: Share Score Card Redesign

## Goals
- Redesign Share Score Card: add crash card variant, compact stats, App Store link
- Enable sharing on crash game-over screens
- Discuss GIF replay feasibility (deferred)

## Changes Made

### 1. shortCrashCause() Added to LandingMessages
**What:** New static function returning compact cause strings for crash share cards.
**Why:** Crash cards need a single short diagnostic line, not the verbose two-line format used in the game-over screen.
**Files:** `RocketLander/Models/LandingMessages.swift`
**Details:** Returns "Tilt (18.4°)", "V.Speed (547 m/s)", "H.Speed (89 m/s)", "Missed Platform", or "Ship Lost". Same priority logic as `diagnosticCrashMessage()`.

### 2. ShareScoreCardView Redesigned
**What:** Complete redesign with landing and crash variants in a single view.
**Why:** Growth plan requires crash sharing and a poster-like card, not a telemetry dump.
**Files:** `RocketLander/Views/ShareScoreCardView.swift`
**Details:**
- Landing: score hero → stars → mode/level → platform+band badge → compact colored stats (V/H/Fuel) → App Store footer
- Crash: headline hero (red) → mode/level → CRASH badge → "Cause: ..." → App Store footer
- Stats values colored green/yellow/red by band (V/H use platform-specific thresholds, fuel uses 20%/0% breakpoints)
- Crash card border red instead of orange
- `ShareHelper.shareImage()` now includes text payload with App Store URL
- Footer: "Starship Lander on the App Store" (semibold, 0.7 opacity)

### 3. GameOverView Updated for Crash Sharing
**What:** Removed `if gameState.landed` gate on share button. Rewrote `shareScoreCard()` for both variants.
**Why:** Crash headlines are viral — "RAPID UNSCHEDULED DISASSEMBLY" is more shareable than a score.
**Files:** `RocketLander/Views/GameOverView.swift`
**Details:**
- Share button always visible (landing + crash)
- Crash card passes `crashMessage` @State as headline, calls `shortCrashCause()` for diagnostic
- Share text: "I scored X in Starship Lander! <URL>" or "<CRASH HEADLINE> <URL>"
- `hitTerrain` inferred from `crashDiagnosticPrimary.contains("Missed")`

## Research / Ideas Discussed

### GIF Replay (Deferred)
- Ring buffer in `GameScene.update()` capturing frames via `SKView.texture(from:)`
- Keep last ~90-150 frames (3-5s at 30fps), encode to GIF via `CGImageDestination` (ImageIO, native)
- Memory concern: ~45MB ring buffer, needs tuning for older devices
- Verdict: valuable for virality (especially crash GIFs), target v2.2.0 or later
- No new SDK needed

### Share Card Design Discussion
- Agreed on "poster not telemetry" philosophy
- Compact stats: V, H, Fuel only (3 metrics max) — no tilt, no center
- Crash cards get their own layout with headline hero
- Auto-suggest triggers deferred to follow-up v2.1.x

## Technical Notes
- `isLanded` conditional in single view chosen over two separate views (70% shared layout)
- `hitTerrain` inference from diagnostic text is pragmatic — only matters for edge case where no thresholds violated
- Band coloring uses `LandingThresholds.verticalBand()` / `horizontalBand()` — same source of truth as HUD
- App Store URL confirmed: https://apps.apple.com/us/app/starship-lander/id6757563869

## Decisions
1. Single view with conditional branching (not two separate card views)
2. Compact stats: V, H, Fuel with band-aware coloring
3. Crash diagnostic includes units (m/s) for clarity
4. GIF replay deferred to v2.2.0+
5. Auto-suggest share triggers deferred to follow-up iteration

## Definition of Done
- [x] Crash share card with headline hero + cause diagnostic
- [x] Landing card with compact colored stats (V/H/Fuel)
- [x] Share button on both landing and crash
- [x] App Store link on card + URL in share text
- [x] Crash values include units
- [x] Stats colored by band
- [x] Footer legibility improved
- [x] Build succeeds, 91/91 tests pass
- [x] Simulator tested
- [x] All docs updated

## Commits
- `00cce8d` — Redesign Share Score Card: crash sharing, compact stats, App Store link

## Repo Housekeeping
- [x] Working tree clean (only expected changes)
- [x] .gitignore up to date
- [x] README.md project structure matches actual files
- [x] No secrets or credentials in tracked files

## Next Actions
- [ ] Wait for v2.1.0 App Store review approval
- [ ] Device test share card on TestFlight (both landing and crash)
- [ ] Implement auto-suggest share triggers (high score, 3-star C, rare crash) in follow-up
- [ ] Plan GIF replay for v2.2.0+
- [ ] Create 5 high-converting App Store screenshots per growth plan
- [ ] Plan v2.2.0 (Monetization): approach TBD
