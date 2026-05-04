# App Store ASO — v2.2.1 Hotfix

Status: v2.2.1 Build 38 hotfix copy applied in App Store Connect. Build 38 is attached and submitted for App Store review.

## Screenshot Pack

Directory: `Screenshots/appstore-v2.2.0/`

All screenshots are 1284x2778 PNGs for the iPhone 6.5/6.7 screenshot set.

1. `01_land_or_crash.png` — LAND / OR CRASH
2. `02_daily_challenge.png` — NEW DAILY / MISSIONS
3. `03_rankings_blue_stars.png` — CLIMB THE / GALAXY RANK
4. `04_precision_physics.png` — MASTER THE / DESCENT
5. `05_ten_world_campaign.png` — 10 WORLDS / ONE SHIP

## Promotional Text

Hotfix: fixes the Campaign startup crash in v2.2.0, with Daily Challenge, Blue Stars, and global ranks still included.

## Keywords

rocket,lander,space,landing,physics,flight,moon,mars,daily,challenge,leaderboard,arcade

## What’s New

HOTFIX IN v2.2.1

• Fixes a crash that could close the app when starting Campaign mode after selecting a planet
• Improves fresh-run reset handling so a new run cannot immediately reset on first input
• Restores Mercury heat shimmer and Io volcanic effects in Daily Challenge

Also includes the v2.2 Daily Challenge update: 75 rotating challenges, Blue Star rewards, global rank display, refreshed Starship artwork, and improved campaign/daily scoring persistence.

## Review Notes

Starship Lander is a skill-based rocket landing game.

No login is required. Game Center is optional and used for leaderboards and achievements. If the reviewer is not signed into Game Center, the game remains playable and leaderboard UI may show local/fallback states.

Daily Challenge is available from the main menu. Blue Stars are earned in-game through Daily Challenge completions and campaign milestones; there is no in-app purchase in this build.

This v2.2.1 hotfix resolves a live v2.2.0 Campaign startup crash. Repro in the affected build: open Campaign, select a planet such as Earth or Venus, then start gameplay. The fix makes campaign Game Center attempt tracking persist with property-list-safe keys and also clears stale fresh-run reset state.

Ads are shown with conservative pacing on retry/next-level flows. The ATT prompt may appear on first launch. Button controls are enabled by default; tilt controls can be selected from the settings menu.
