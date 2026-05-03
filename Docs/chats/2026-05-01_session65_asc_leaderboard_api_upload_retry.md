# Session 65 — App Store Connect API Recovery, Daily Challenge Release, and Upload Network Blocker

**Date:** 2026-05-01
**Goal:** Use browser-harness and App Store Connect to clear the remaining v2.2.0 release blockers, create/release the Daily Challenge Game Center leaderboard, and retry Build 37 upload.

---

## What Changed

### Browser-harness and ASC access
- Cloned and installed `browser-harness` under `/private/tmp/browser-harness`.
- Enabled Chrome remote debugging and attached to the existing App Store Connect browser session.
- Verified App Store Connect agreements are active:
  - Free Apps Agreement: active
  - Paid Apps Agreement: active
  - Effective through January 7, 2027

### App Store Connect API credentials
- Recovered the App Store Connect issuer ID from the Integrations/API page.
- Created a new Team API key with Admin access.
- Downloaded the `.p8` key and copied it to `~/.appstoreconnect/private_keys/`.
- Set key permissions to `600`.
- No credentials were written into the repo.

### Game Center resources
- Ran `Scripts/setup_game_center.py --create-releases` with the new API credentials.
- Found app `Starship Lander` / app ID `6757563869`.
- Existing Game Center detail found.
- Created the new `daily_challenge` leaderboard and en-US localization.
- Leaderboard releases completed: 13/13.
- Achievement releases completed: 10/10.

### Build 37 upload attempts
- Retried upload through Xcode's `xcodebuild -exportArchive` upload path after agreements were active.
- Retried upload through `xcrun altool` using the new App Store Connect API key.
- Both paths now pass authentication/contracts and reach Apple upload transport.
- Both paths repeatedly fail on the Apple analysis ZIP upload:
  - `Checksums do not match`
  - `NSURLErrorDomain Code=-1005 "The network connection was lost."`
  - Host: `northamerica-1.object-storage.apple.com`
- A Tailscale-off Xcode retry produced the same failure, then Tailscale was restored.

---

## Current Release State

- Build 37 archive is ready: `build/RocketLander-Build37.xcarchive`.
- Local App Store IPA is ready: `build/export-build37-local/RocketLander.ipa`.
- `daily_challenge` is created/released in App Store Connect.
- App Store Connect agreements are active.
- Build 37 is not uploaded to TestFlight yet.

---

## Blocker

Build 37 upload is blocked by this Mac/network's connection to Apple object storage, not by contracts, credentials, or Game Center configuration. Disabling Tailscale did not clear the failure, so the next useful test is a different upstream connection such as a phone hotspot or different Wi-Fi.

Recommended retry command:

```sh
xcodebuild -exportArchive \
  -archivePath build/RocketLander-Build37.xcarchive \
  -exportPath build/export-build37-xcode-final \
  -exportOptionsPlist build/ExportOptions.plist \
  -allowProvisioningUpdates
```

---

## Verification

- Prior simulator test suite passed: 94 tests, 0 failures.
- Prior release smoke screenshots captured under `Screenshots/simulator-2026-04-29-release-smoke/`.
- App Store Connect API query after the failed upload attempts did not show Build 37 as uploaded/processing.

---

## Next Steps

1. Switch to a hotspot/different Wi-Fi.
2. Retry Xcode upload for Build 37.
3. Verify Build 37 enters TestFlight processing.
4. Run TestFlight/device smoke.
5. Submit v2.2.0 for App Store review.
