# 2026-01-30 — Session 15: Dynamic Island, Gravity & Platform Fixes

## Goals
- Fix game title clipped by Dynamic Island on iPhone 16+
- Fix Earth level gravity (thrust can't overcome descent)
- Fix Earth level platform overlap during movement
- Fix "HOW TO PLAY" section cut off at bottom of menu
- Document all changes

## Decisions
1. **Menu → ScrollView**: Wrapped menu in ScrollView rather than just adding padding. Solves both Dynamic Island (top) and content cutoff (bottom) issues simultaneously.
2. **Earth gravity -4.5 → -3.5**: Conservative reduction. Still challenging (3.4x thrust ratio) but landable with skill.
3. **Platform clamping**: Added runtime edge-clamping in addition to reducing movement ranges. Belt-and-suspenders approach prevents any future overlap even if ranges change.
4. **Adopted new documentation standards**: Project management instructions formalized for all future sessions (DECISIONS.md, chat summaries, definition of done, change summaries).

## Open Questions
1. **Jupiter gravity balance**: At -6.0 (2.0x thrust ratio), Jupiter is reported as impossible. Need to either reduce gravity or implement per-level thrust scaling. Full balancing pass needed.
2. **Progressive difficulty curve**: Current level order by gravity doesn't match level order. E.g., Mars (level 2) is harder gravity-wise than Earth (level 5). Should difficulty be strictly increasing by level number?
3. **v1.1.5 status**: Still "submitted for review" — need to check App Store Connect.

## Next Actions
- [ ] Full campaign gravity balancing pass — ensure all 10 levels are landable with increasing difficulty
- [ ] Test all levels on physical device (haptics, platform movement, wind effects)
- [ ] Decide: per-level thrust scaling vs. capped gravity values
- [ ] Version bump to 1.2.0 once balanced and tested
- [ ] Submit v1.2 to App Store
