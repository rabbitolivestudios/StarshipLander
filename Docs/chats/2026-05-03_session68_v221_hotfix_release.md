# Session 68 - v2.2.1 Build 38 Hotfix Release

Date: 2026-05-03

## Goal

Ship an emergency replacement for the live v2.2.0 Build 37 Campaign startup crash, using the newly restored SSD Xcode install.

## What Changed

- Bumped `RocketLander/Info.plist` to version `2.2.1`, build `38`.
- Prepared App Store Connect hotfix text in `Scripts/update_app_store_v220.py` and `Docs/APP_STORE_ASO_V220.md`.
- Updated release documentation across `README.md`, `CHANGELOG.md`, `RELEASE_NOTES.md`, `STATUS.md`, and `PROJECT_LOG.md`.

## Verification

- GitHub Actions iOS CI passed on the hotfix branch: 96 tests, 0 failures.
- Local SSD Xcode 26.4.1 `Scripts/ci_xcodebuild.sh` passed: 96 tests, 0 failures.
- `RocketLander/Info.plist` and `RocketLander/RocketLander.entitlements` passed `plutil -lint`.
- App Store metadata scripts passed syntax checks.
- Release archive succeeded at `build/RocketLander-Build38.xcarchive`.

## App Store Connect

- Xcode Organizer uploaded v2.2.1 Build 38 successfully.
- Upload completed with non-blocking third-party dSYM warnings for Google Mobile Ads and UserMessagingPlatform.
- App Store Connect processed Build 38 as `VALID`.
- Created the v2.2.1 App Store version page.
- Updated promotional text, What's New, review notes, and related English metadata.
- Attached Build 38.
- Submitted for App Store review.
- Final review submission state: `WAITING_FOR_REVIEW`.
- Submitted date: `2026-05-04T01:20:53Z`.

## Next Steps

- Monitor App Store review for v2.2.1 Build 38.
- After approval/distribution, verify Campaign startup on Earth, Venus, and an early unlocked planet.
- Resume v2.3/growth work only after the live Campaign crash is resolved.
