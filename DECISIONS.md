# Starship Lander — Decisions

This file records key technical and design decisions, including context, alternatives, and consequences.

---

## [2026-01-07] Game Engine Choice
**Context:** Needed a 2D physics engine for iOS rocket landing game.
**Options considered:** (1) SpriteKit + SwiftUI, (2) Unity, (3) pure SwiftUI with custom physics.
**Decision:** SpriteKit for physics/rendering, SwiftUI for menus/HUD.
**Why:** Native iOS, no third-party dependency, excellent physics integration, small binary size.
**Consequences:** Locked to Apple platforms. SpriteKit<>SwiftUI bridging requires UIViewRepresentable wrapper.

---

## [2026-01-08] Scoring System — Continuous with Dual Multipliers
**Context:** Original tier-based scoring gave identical scores for different skill levels.
**Options considered:** (1) Tier jumps, (2) Linear continuous, (3) Continuous + multipliers.
**Decision:** Continuous scoring with fuel multiplier (1.0–2.5x) and platform multiplier (1x/2x/5x). Max ~25,000.
**Why:** Every improvement in landing quality produces a visible score change. Fuel incentivizes efficiency. Platform choice adds risk/reward.
**Consequences:** Wide score range (100–25,000) makes leaderboard more meaningful. Harder to compare scores across platforms.

---

## [2026-01-10] AdMob + App Tracking Transparency
**Context:** Apple rejected v1.0 for Guideline 5.1.2 — Device ID tracking without ATT prompt.
**Options considered:** (1) Remove tracking entirely, (2) Add ATT prompt.
**Decision:** Added ATT prompt at launch. Ads work with or without tracking consent.
**Why:** Required for App Store compliance. Non-intrusive — one-time prompt.
**Consequences:** Some users deny tracking → lower ad revenue. Privacy-compliant.

---

## [2026-01-12] Dual Control Modes (Buttons + Accelerometer)
**Context:** User reported button rotation too sensitive.
**Options considered:** (1) Reduce sensitivity only, (2) Add accelerometer option, (3) Both.
**Decision:** Both — reduced button power (0.05→0.025→0.04) and added accelerometer toggle.
**Why:** Different players prefer different inputs. Accelerometer feels more immersive.
**Consequences:** Must maintain two code paths. Accelerometer unavailable on iPad without gyroscope. Settings persisted via UserDefaults.

---

## [2026-01-30] Campaign Gravity — Game-Balanced vs Real-World
**Context:** Original campaign used real-world gravity values (Earth 9.8, Jupiter 24.8). These were unplayable because thrust power (12.0) is fixed.
**Options considered:** (1) Scale thrust per level, (2) Reduce gravity to playable range, (3) Both.
**Decision:** Reduced gravity values to game-friendly range. Thrust stays fixed at 12.0 for all levels.
**Why:** Simpler than per-level thrust scaling. Players shouldn't need to relearn thrust feel per level. Gravity differences still create distinct difficulty.
**Consequences:** Gravity values are NOT real-world accurate (labeled "m/s²" in UI but values are game-tuned). Earth went from -9.8→-4.5→-3.5. Jupiter from -24.8→-6.0 (still possibly too hard — needs testing).

**Session 17 update:** Fully rebalanced to monotonically increasing gravity by level number:

| Level | Name | Game Gravity | Thrust Ratio |
|-------|------|-------------|-------------|
| 1 | Moon | 1.6 | 7.5x |
| 2 | Mars | 2.0 | 6.0x |
| 3 | Titan | 2.2 | 5.5x |
| 4 | Europa | 2.5 | 4.8x |
| 5 | Earth | 2.8 | 4.3x |
| 6 | Venus | 3.2 | 3.8x |
| 7 | Mercury | 3.5 | 3.4x |
| 8 | Ganymede | 3.8 | 3.2x |
| 9 | Io | 4.2 | 2.9x |
| 10 | Jupiter | 4.8 | 2.5x |

---

## [2026-01-30] Earth Moving Platforms — Zone Clamping
**Context:** All three platforms moved on Earth level but overlapped due to unconstrained horizontal ranges.
**Options considered:** (1) Only move one platform, (2) Reduce ranges, (3) Reduce ranges + add clamping.
**Decision:** Option 3 — reduced ranges AND added runtime clamping to enforce 10pt minimum gap.
**Why:** Clamping is a safety net even if ranges are conservative. Prevents physics glitches from platform overlap.
**Consequences:** Platform A no longer moves horizontally (vertical bob only). B and C have smaller, bounded movement. Feels less chaotic but more fair.

---

## [2026-01-30] Menu ScrollView for Dynamic Island
**Context:** iPhone 16+ Dynamic Island clips the game title "STARSHIP" at top of menu.
**Options considered:** (1) Add top padding, (2) Wrap in ScrollView, (3) Reduce title font size.
**Decision:** Wrapped menu in ScrollView + reduced spacing/element sizes to fit all content.
**Why:** ScrollView automatically respects safe area. Also solves "HOW TO PLAY" cutoff at bottom on smaller screens. Content still fits on one screen on iPhone 16 Pro without scrolling.
**Consequences:** Flexible `Spacer()` replaced with fixed spacing. Content is slightly more compact. Works on all screen sizes.

---

## [2026-01-30] Ganymede Craters — Ridge Terrain with Physics
**Context:** Ganymede's "deep craters" special mechanic had no visible effect. Previous implementation added random height bumps that were smoothed away. User couldn't distinguish Ganymede terrain from any other level.
**Options considered:** (1) More aggressive random bumps, (2) Deliberate ridges between platforms, (3) Overlay crater sprites on terrain.
**Decision:** Option 2 — generate tall ridges (+200px) between platform zones with physics bodies.
**Why:** Ridges create clear valleys where platforms sit. This is both visually distinctive and mechanically meaningful — the rocket must descend vertically into a valley rather than approaching from the side. Adding physics bodies makes ridges actually dangerous.
**Consequences:** Ganymede plays fundamentally differently from other levels. Terrain physics body only added for level 8 (edge-chain along terrain surface). Other levels keep visual-only terrain. The ridge height (200px above base ≈380px total) is well above platforms (220px), so the rocket must navigate down into valleys carefully.

---

## [2026-01-30] Per-Level Thrust Scaling
**Context:** Fixed thrust (12.0) across all campaign levels meant higher gravity levels either felt impossible or indistinguishable. User wanted each planet to feel different as a core skill challenge.
**Options considered:** (1) Scale thrust proportionally to gravity (constant ratio), (2) Scale with decreasing ratio (progressive difficulty), (3) Keep fixed thrust and only adjust gravity.
**Decision:** Option 2 — each level gets a custom `thrustPower` that scales with gravity but at a decreasing ratio (6.0x on Moon → 3.8x on Jupiter).
**Why:** Players must adapt to different thrust feels per planet. Early levels feel floaty and forgiving; later levels feel heavy with tighter margins. This creates the skill-based learning curve the game needs.
**Consequences:** Classic mode unchanged (thrust 12.0). Campaign thrust ranges from 8.0 (Moon) to 18.5 (Jupiter). Thrust ratio never drops below 3.8x, ensuring all levels are landable. Players experience distinct "engine feel" per planet.

---

## [2026-01-30] Visual Effects for All Campaign Mechanics
**Context:** Most campaign special mechanics had no visual indicator. Only Mercury (heat shimmer) and Io (volcanic eruptions) had effects. Players couldn't see wind, ice, or atmosphere.
**Options considered:** (1) Add particle effects only, (2) Add particles + gameplay effects, (3) Minimal HUD indicators.
**Decision:** Option 2 — every mechanic gets both a visual indicator and gameplay effect.
**Why:** Visual feedback is essential for players to understand why their rocket behaves differently. Effects must be visible AND felt.
**Consequences:** Added wind streak particles (Mars/Venus/Jupiter at 3 intensities), atmosphere haze clouds (Titan), ice shimmer sparkles (Europa). Each visual matches the mechanic: wind streaks blow horizontally, haze drifts slowly, ice sparkles near platforms.

---

## [2026-01-30] Ganymede Craters — Rock Pillars (3rd Approach)
**Context:** Two prior attempts to create terrain ridges between platforms failed. First attempt: random height bumps smoothed away. Second attempt: per-segment nearest-platform valley logic — platform valleys overlapped (320pt of platform on a 393pt screen, leaving no room for ridges). Third attempt needed.
**Options considered:** (1) Override platform positions for Ganymede, (2) Accept no ridges, (3) Standalone rock pillar obstacles + raised terrain at screen edges.
**Decision:** Option 3 — independent rock pillar nodes with physics bodies, plus raised terrain walls at screen edges.
**Why:** Platforms cover 81% of screen width, making terrain-based ridges between them geometrically impossible. Standalone rock nodes can be placed precisely in the 30pt gap between B and C, plus at screen edges, without conflicting with platform geometry.
**Consequences:** Three jagged rock pillars placed (left edge, between B-C, right edge) at y=150 with heights 180-200px. Each has a polygon physics body with `groundCategory` — hitting them crashes the rocket. Terrain also raised at screen edges (up to 350px) for visual crater bowl effect. Ganymede now has clear visual and mechanical distinction.

---

## [2026-01-30] Prepopulated High Scores — Astronaut Easter Eggs
**Context:** Empty high score boards on first launch feel lifeless. User wanted easter egg default scores to give new players something to beat.
**Options considered:** (1) Random names, (2) Developer names, (3) Astronaut/scientist names relevant to each planet.
**Decision:** Option 3 — each campaign level gets a 1000-point default score under the last name of a space figure connected to that celestial body. Classic mode gets "Elon" (SpaceX reference).
**Why:** Creates a discovery moment when players notice the names. Each name teaches a bit of space history. The 1000-point score is beatable but not trivial.
**Consequences:** Seeded on first launch only (if no scores exist for a level). Names: Armstrong (Moon), Aldrin (Mars), Huygens (Titan), Galileo (Europa), Gagarin (Earth), Shepard (Venus), Glenn (Mercury), Marius (Ganymede), Collins (Io), Shoemaker (Jupiter), Elon (Classic).

---

## [2026-01-31] Phase Split — v2.1 (Community) and v2.2 (Monetization)
**Context:** Original plan bundled Game Center, achievements, share card, and Remove Ads IAP into a single v2.1.0. Per CLAUDE.md phase discipline, unrelated phases should not be mixed in one commit or version.
**Options considered:** (1) Keep everything in v2.1.0 with separate commits, (2) Split into two versions by phase.
**Decision:** Option 2 — v2.1.0 is Community phase (Game Center leaderboards, achievements, share score card). v2.2.0 is Monetization phase (Remove Ads IAP via StoreKit 2).
**Why:** Strict adherence to phase discipline. Each version has a single theme, reducing review risk and keeping App Store submissions focused. If one feature has issues during review, it doesn't block the other.
**Consequences:** Two separate App Store submissions instead of one. v2.2.0 depends on v2.1.0 being shipped first (no hard dependency, but logical ordering). IAP capability added in v2.2.0, not v2.1.0.

---

## [2026-01-31] Game Center Integration Strategy
**Context:** v2.1 adds Game Center leaderboards and achievements. Need to decide authentication approach, leaderboard structure, and achievement philosophy.
**Options considered:** (1) Force Game Center sign-in, (2) Opt-in with manual button, (3) Automatic authentication with graceful fallback.
**Decision:** Option 3 — set `GKLocalPlayer.local.authenticateHandler` at launch. If signed in, enable Game Center features. If not, hide GC UI elements and continue with local-only scores.
**Why:** Non-intrusive. Players who don't use Game Center are unaffected. No forced popups. Score submission is fire-and-forget with GameKit's built-in offline queue.
**Consequences:** Must maintain dual paths (local leaderboard always works; Game Center is additive). LeaderboardView gets a Local/Game Center toggle. Achievements are Game Center-only (no local fallback needed). 11 leaderboards must be configured in App Store Connect before submission.

---

## [2026-01-31] Achievement Design Philosophy
**Context:** Need to define which achievements to include and how they unlock. Risk of too many trivial achievements or too few meaningful ones.
**Options considered:** (1) Many granular achievements (land 10 times, land 50 times, etc.), (2) Milestone-only achievements, (3) Mix of skill-based and progression achievements.
**Decision:** Option 3 — 10 achievements covering first experiences, skill milestones, and mastery goals. No grind-based achievements (no "land 100 times"). All are one-shot (100% complete when triggered), no incremental progress.
**Why:** Keeps achievement list clean and meaningful. Each achievement represents a distinct skill or milestone. Players can see them all in the Game Center dashboard without clutter.
**Consequences:** All achievements are binary (0% or 100%). Hook points: `saveScore()` in GameOverView for landing-based achievements, `CampaignState` for progression achievements. `GKAchievement.report()` is idempotent so safe to call repeatedly.

---

## [2026-01-31] Remove Ads IAP — StoreKit 2 Approach
**Context:** Adding a one-time "Support Development" IAP to remove all banner ads. Need to choose between StoreKit 1 (legacy) and StoreKit 2 (modern).
**Options considered:** (1) StoreKit 1 with receipt validation, (2) StoreKit 2 with on-device JWS verification, (3) Third-party SDK (RevenueCat).
**Decision:** Option 2 — StoreKit 2 with async/await. On-device JWS verification (no server needed). UserDefaults cache for synchronous ad-hiding checks, `Transaction.currentEntitlements` as source of truth on launch.
**Why:** StoreKit 2 is simpler, modern Swift, no receipt parsing. No server infrastructure needed for a single non-consumable. UserDefaults cache ensures `BannerAdContainer` can synchronously decide whether to show ads.
**Consequences:** Requires iOS 15+ (already our minimum). Must add "In-App Purchase" capability in Xcode. Need StoreKit Configuration file for local testing. Must provide "Restore Purchases" button per App Review guidelines. Product ID: `com.tboliveira.StarshipLander.removeAds`.

---

## [2026-01-31] Privacy Impact — Game Center + StoreKit
**Context:** Adding Game Center and StoreKit to v2.1. Must assess privacy declarations per CLAUDE.md guardrails.
**Decision:** Game Center requires adding "Gameplay Content" under "Usage Data" in App Privacy declarations (purpose: App Functionality). StoreKit requires no additional declarations. Neither involves tracking. No ATT changes needed.
**Why:** Game Center sends gameplay data (scores, achievements) to Apple's servers — this is first-party data handled by Apple, not tracking. StoreKit transaction data stays within Apple's infrastructure.
**Consequences:** Update App Store Connect privacy declarations to add "Gameplay Content" when submitting v2.1. No code changes for ATT. Existing AdMob ATT prompt unchanged.

---

## [2026-01-31] CLAUDE.md for Session Continuity and Project Guidelines
**Context:** Claude Code sessions can expire or lose context at any time. Without persistent instructions, each new session starts from scratch with no understanding of project conventions, documentation requirements, or development workflow. Previous sessions sometimes missed documentation updates or introduced inconsistent practices.
**Options considered:** (1) Verbal reminders each session, (2) A README section with guidelines, (3) A dedicated `CLAUDE.md` file (automatically read by Claude Code at session start), (4) `.codex/AGENTS.md` (Codex CLI format, per jessfraz reference).
**Decision:** Option 3 — `CLAUDE.md` in project root. Also added `.github/pull_request_template.md` for PR checks.
**Why:** `CLAUDE.md` is natively supported by Claude Code — it's read automatically at the start of every session without any manual steps. It's the most reliable way to enforce guidelines across sessions. The PR template adds a structured safety net for code changes even as a solo developer.
**Consequences:** Every session now has a mandatory 10-step startup checklist, phase discipline, definition of done, documentation requirements, code standards, testing expectations, privacy guardrails, and a hard "do not" list. Documentation updates are non-negotiable. Change summaries are mandatory output. PRs auto-fill with regression safety, scope, and compliance checks.
