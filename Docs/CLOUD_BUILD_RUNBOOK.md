# Cloud Build Runbook

Use this when the local machine does not have Xcode installed.

## What This Solves

- Build and test the iOS app without installing Xcode locally.
- Verify hotfixes on a GitHub-hosted macOS runner before creating a replacement App Store build.
- Keep Apple credentials out of the repository.

## GitHub Actions CI

Workflow:

- `.github/workflows/ios-ci.yml`
- Script: `Scripts/ci_xcodebuild.sh`

It runs on GitHub-hosted `macos-latest`, selects an available iPhone simulator, and runs:

```bash
xcodebuild test -project RocketLander.xcodeproj -scheme RocketLander -destination "id=<simulator-id>"
```

The workflow uploads `build/ci/TestResults.xcresult` as an artifact if available.

## Manual Run

After committing and pushing a branch:

```bash
gh workflow run "iOS CI" --ref <branch-name>
gh run list --workflow "iOS CI" --limit 5
gh run watch <run-id>
```

## Local Mac With Xcode

If a different Mac has Xcode installed, the same script can be run locally:

```bash
Scripts/ci_xcodebuild.sh
```

## Replacement App Store Build

CI build/test is credential-free. Uploading a replacement App Store build still needs one of these:

1. **Xcode Cloud** in App Store Connect, using Apple-managed signing.
2. **GitHub Actions release workflow** with GitHub Secrets for the distribution certificate, provisioning profile, and App Store Connect API key.
3. **Temporary remote Mac** with Xcode installed, using the existing manual archive/export process.

For the current emergency hotfix, use GitHub Actions CI first to prove the build/tests pass, then choose Xcode Cloud or a temporary remote Mac for the signed archive/upload.
