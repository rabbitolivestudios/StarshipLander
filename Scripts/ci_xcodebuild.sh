#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

PROJECT="RocketLander.xcodeproj"
SCHEME="RocketLander"
RESULT_DIR="build/ci"
RESULT_BUNDLE="$RESULT_DIR/TestResults.xcresult"

if ! command -v xcodebuild >/dev/null 2>&1; then
  echo "error: xcodebuild not found. Run this on a Mac with Xcode installed or in GitHub Actions." >&2
  exit 1
fi

if ! xcodebuild -version >/dev/null 2>&1; then
  echo "error: xcodebuild exists but the active developer directory is not full Xcode." >&2
  echo "Current developer directory: $(xcode-select -p 2>/dev/null || echo unknown)" >&2
  echo "Use: sudo xcode-select -s /Applications/Xcode.app/Contents/Developer" >&2
  exit 1
fi

mkdir -p "$RESULT_DIR"
rm -rf "$RESULT_BUNDLE"

echo "== Xcode =="
xcodebuild -version
xcode-select -p

echo "== Resolve packages =="
xcodebuild -resolvePackageDependencies -project "$PROJECT" -scheme "$SCHEME"

echo "== Select simulator =="
SIM_ID="$(
  python3 - <<'PY'
import json
import subprocess
import sys

preferred_names = [
    "iPhone 17 Pro",
    "iPhone 16 Pro",
    "iPhone 16",
    "iPhone 15 Pro",
    "iPhone 15",
]

raw = subprocess.check_output(["xcrun", "simctl", "list", "devices", "available", "-j"], text=True)
devices_by_runtime = json.loads(raw).get("devices", {})
devices = [
    device
    for runtime_devices in devices_by_runtime.values()
    for device in runtime_devices
    if device.get("isAvailable", True)
]

for name in preferred_names:
    for device in devices:
        if device.get("name") == name:
            print(device["udid"])
            sys.exit(0)

for device in devices:
    if device.get("name", "").startswith("iPhone"):
        print(device["udid"])
        sys.exit(0)

print("No available iPhone simulator found", file=sys.stderr)
sys.exit(1)
PY
)"
echo "Using simulator id: $SIM_ID"

xcrun simctl boot "$SIM_ID" >/dev/null 2>&1 || true

echo "== Test =="
xcodebuild test \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -destination "id=$SIM_ID" \
  -resultBundlePath "$RESULT_BUNDLE"

echo "CI xcodebuild test succeeded."
