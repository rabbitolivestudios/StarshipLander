# 2026-01-30 — Session 16: Ganymede Deep Craters Overhaul

## Goals
- Make Ganymede "deep craters" mechanic actually visible and functional
- Add terrain obstacles between platforms

## Decisions
1. **Ridge approach over random bumps**: Previous random +30-60px bumps at 25% of segments were invisible after smoothing. Replaced with deliberate +200px ridges in all non-platform zones.
2. **Physics on terrain**: Added edge-chain physics body along terrain surface for Ganymede only. Uses `groundCategory` so contact = crash. Other levels unaffected.
3. **Smooth ramp**: Ridges ramp up over 60px from platform edges, creating natural-looking valleys rather than cliff walls.

## Open Questions
1. Is 200px ridge height balanced? May need tuning after playtesting.
2. Should other levels also have terrain physics? Currently only Ganymede.
3. Jupiter gravity balancing still outstanding from Session 15.

## Next Actions
- [ ] Test Ganymede level on simulator and device — verify ridges visible and physics working
- [ ] Full campaign gravity balancing pass (Jupiter priority)
- [ ] Consider terrain physics for other levels if needed
