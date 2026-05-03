# Session 66 — v2.2.0 ASO Screenshots and App Store Submission

Date: 2026-05-01

## Goal

Prepare the v2.2.0 App Store listing with stronger ASO screenshots/copy, attach Build 37, and submit for review.

## Completed

- Generated a new App Store screenshot pack in `Screenshots/appstore-v2.2.0/`.
- Reworked screenshot style after competitor review:
  - Full-screen real gameplay/menu/campaign captures
  - Orbitron/sci-fi headline typography
  - Larger arcade-style callouts
  - No phone mockups
  - Opaque lower treatment to hide simulator test ads
- Added reproducible generator: `Scripts/generate_appstore_screenshots_v220.py`.
- Added App Store Connect updater: `Scripts/update_app_store_v220.py`.
- Created v2.2.0 App Store version in App Store Connect.
- Updated ASO localization copy:
  - Promotional text
  - Description
  - Keywords
  - What’s New
  - Support/marketing URLs
- Updated review notes.
- Attached Build 37 to v2.2.0.
- Uploaded five 1284x2778 screenshots to `APP_IPHONE_65`.
- Verified screenshot asset delivery state is `COMPLETE` for all five images.
- Submitted v2.2.0 for App Store review using the `reviewSubmissions` API flow.

## Final App Store Connect State

- Version: v2.2.0
- Build: 37
- Build processing state: VALID
- Screenshot set: `APP_IPHONE_65`
- Screenshot count: 5
- Review submission state: `WAITING_FOR_REVIEW`
- Submitted timestamp: 2026-05-01T19:24:48.031Z

## Notes

- The deprecated `appStoreVersionSubmissions` create endpoint returned 403; the newer `reviewSubmissions` + `reviewSubmissionItems` flow succeeded.
- Apple object storage produced one transient SSL error during screenshot upload; retry/backoff succeeded.
- No credentials were written to the repository. The updater reads the local ASC API key from `~/.appstoreconnect/private_keys/` and requires `ASC_ISSUER_ID` from the environment.

## Next

- Monitor App Store review.
- If approved, verify the live App Store build and first-run behavior.
- If rejected, address Apple feedback only.
