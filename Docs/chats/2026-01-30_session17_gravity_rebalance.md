# 2026-01-30 — Session 17: Campaign Gravity Rebalance

## Goals
- Fix Jupiter (and all levels) so gravity increases progressively with level number
- Ensure all levels are landable (minimum thrust ratio 2.5x)

## Decisions
1. **Monotonically increasing gravity**: Every level has higher gravity than the previous one. Special mechanics add difficulty on top.
2. **Gravity range 1.6 → 4.8**: With fixed thrust of 12.0, this gives ratios from 7.5x (easy tutorial) to 2.5x (very hard but possible).
3. **No per-level thrust scaling**: Kept thrust fixed at 12.0 for all levels. Simpler, players don't need to relearn thrust feel.

## Open Questions
1. Is 2.5x ratio (Jupiter) actually playable with extreme wind on top? Needs playtesting.
2. Should level descriptions mention gravity values? Currently only the level select UI shows them.

## Next Actions
- [ ] Playtest all 10 levels on simulator
- [ ] Playtest on physical device (haptics, wind feel)
- [ ] Fine-tune individual values if any level feels wrong
