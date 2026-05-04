#!/usr/bin/env python3
"""
Prepare the App Store Connect v2.2.1 hotfix listing.

This script uses the same credential flow as setup_game_center.py:
  ASC_ISSUER_ID=<issuer-id> python3 Scripts/update_app_store_v220.py --apply
  ASC_ISSUER_ID=<issuer-id> python3 Scripts/update_app_store_v220.py --apply --submit

It does not store credentials. It reads the .p8 key from
~/.appstoreconnect/private_keys/AuthKey_*.p8 or ASC_KEY_ID/ASC_PRIVATE_KEY.
"""

import argparse
import glob
import os
import sys
import time
from pathlib import Path

import requests

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "Scripts"))

from setup_game_center import BASE_URL, generate_token, get_app_id, make_headers  # noqa: E402

VERSION = "2.2.1"
BUILD_NUMBER = "38"
LOCALE = "en-US"
SCREENSHOT_DISPLAY_TYPE = "APP_IPHONE_65"
SCREENSHOT_DIR = ROOT / "Screenshots" / "appstore-v2.2.0"

PROMOTIONAL_TEXT = (
    "Hotfix: fixes the Campaign startup crash in v2.2.0, with Daily Challenge, Blue Stars, and global ranks still included."
)

DESCRIPTION = """Master rocket landings under real pressure.

Starship Lander is a precision space-flight game about thrust, gravity, fuel, and timing. Guide your rocket toward the platform, manage descent speed, keep your tilt under control, and touch down cleanly before the mission slips away.

NEW: DAILY CHALLENGE
Take on a fresh landing mission every day. Each challenge changes the objective, planet, difficulty, and scoring pressure. Complete daily missions to earn Blue Stars and build consistency.

SKILL-BASED ROCKET PHYSICS
Every landing is earned. Control vertical speed, horizontal drift, tilt, fuel, and timing while aiming for one of three landing zones.

10-WORLD CAMPAIGN
Fly through a full campaign across Moon, Mars, Titan, Europa, Earth, Venus, Mercury, Ganymede, Io, and Jupiter. Each world changes gravity, hazards, and the way your rocket handles.

GLOBAL COMPETITION
Compete through Game Center leaderboards for Classic, Campaign, Galaxy Rank, and Daily Challenge scores.

FEATURES
• Daily Challenge mode with rotating objectives
• Blue Star rewards for daily completions and milestones
• 10 campaign worlds with unique hazards
• Skill-based physics and scoring
• Button and tilt controls
• Global leaderboards and achievements
• Fast retries for “one more landing” gameplay

Landing is easy. Landing well is not."""

WHATS_NEW = """HOTFIX IN v2.2.1

• Fixes a crash that could close the app when starting Campaign mode after selecting a planet
• Improves fresh-run reset handling so a new run cannot immediately reset on first input
• Restores Mercury heat shimmer and Io volcanic effects in Daily Challenge

Also includes the v2.2 Daily Challenge update: 75 rotating challenges, Blue Star rewards, global rank display, refreshed Starship artwork, and improved campaign/daily scoring persistence."""

KEYWORDS = "rocket,lander,space,landing,physics,flight,moon,mars,daily,challenge,leaderboard,arcade"
SUPPORT_URL = "https://rabbitolivestudios.github.io"
MARKETING_URL = "https://rabbitolivestudios.github.io"
REVIEW_NOTES = """Starship Lander is a skill-based rocket landing game.

No login is required. Game Center is optional and used for leaderboards and achievements. If the reviewer is not signed into Game Center, the game remains playable and leaderboard UI may show local/fallback states.

This v2.2.1 hotfix resolves a live v2.2.0 Campaign startup crash. Repro in the affected build: open Campaign, select a planet such as Earth or Venus, then start gameplay. The fix makes campaign Game Center attempt tracking persist with property-list-safe keys and also clears stale fresh-run reset state.

Daily Challenge is available from the main menu. Blue Stars are earned in-game through Daily Challenge completions and campaign milestones; there is no in-app purchase in this build.

Ads are shown with conservative pacing on retry/next-level flows. The ATT prompt may appear on first launch. Button controls are enabled by default; tilt controls can be selected from the settings menu."""


def find_api_key():
    key_id = os.environ.get("ASC_KEY_ID")
    private_key = os.environ.get("ASC_PRIVATE_KEY")
    if key_id and private_key:
        if "\\n" in private_key and "\n" not in private_key:
            private_key = private_key.replace("\\n", "\n")
        return key_id, private_key

    pattern = os.path.expanduser("~/.appstoreconnect/private_keys/AuthKey_*.p8")
    keys = sorted(glob.glob(pattern), key=lambda p: os.path.getmtime(p), reverse=True)
    if not keys:
        raise SystemExit("No ASC API key found in ~/.appstoreconnect/private_keys/")

    path = keys[0]
    key_id = os.path.basename(path).replace("AuthKey_", "").replace(".p8", "")
    with open(path, "r") as handle:
        private_key = handle.read()
    return key_id, private_key


def request_json(headers, method, path, *, expected=(200, 201, 204), **kwargs):
    url = f"{BASE_URL}{path}"
    response = requests.request(method, url, headers=headers, timeout=60, **kwargs)
    if response.status_code not in expected:
        raise RuntimeError(f"{method} {path} failed: {response.status_code}\n{response.text[:1200]}")
    if response.status_code == 204 or not response.content:
        return None
    return response.json()


def list_versions(headers, app_id):
    data = request_json(
        headers,
        "GET",
        f"/v1/apps/{app_id}/appStoreVersions",
        params={
            "filter[platform]": "IOS",
            "fields[appStoreVersions]": "versionString,appStoreState,platform",
            "limit": 20,
        },
    )
    return data.get("data", [])


def get_or_create_version(headers, app_id, apply):
    for version in list_versions(headers, app_id):
        attrs = version["attributes"]
        if attrs.get("versionString") == VERSION:
            print(f"Using existing App Store version {VERSION} ({attrs.get('appStoreState')}) id={version['id']}")
            return version["id"]

    print(f"App Store version {VERSION} does not exist.")
    if not apply:
        return None

    body = {
        "data": {
            "type": "appStoreVersions",
            "attributes": {"platform": "IOS", "versionString": VERSION},
            "relationships": {"app": {"data": {"type": "apps", "id": app_id}}},
        }
    }
    data = request_json(headers, "POST", "/v1/appStoreVersions", json=body)
    version_id = data["data"]["id"]
    print(f"Created App Store version {VERSION} id={version_id}")
    return version_id


def patch_version(headers, version_id, apply):
    body = {
        "data": {
            "type": "appStoreVersions",
            "id": version_id,
            "attributes": {
                "copyright": "2026 Rabbit & Olive Studios",
                "releaseType": "AFTER_APPROVAL",
            },
        }
    }
    print("Updating version-level copyright/releaseType")
    if apply:
        request_json(headers, "PATCH", f"/v1/appStoreVersions/{version_id}", json=body)


def get_or_create_localization(headers, version_id, apply):
    data = request_json(
        headers,
        "GET",
        f"/v1/appStoreVersions/{version_id}/appStoreVersionLocalizations",
        params={"fields[appStoreVersionLocalizations]": "locale", "limit": 50},
    )
    for loc in data.get("data", []):
        if loc["attributes"].get("locale") == LOCALE:
            print(f"Using localization {LOCALE} id={loc['id']}")
            return loc["id"]

    print(f"Localization {LOCALE} does not exist.")
    if not apply:
        return None

    body = {
        "data": {
            "type": "appStoreVersionLocalizations",
            "attributes": {"locale": LOCALE},
            "relationships": {
                "appStoreVersion": {"data": {"type": "appStoreVersions", "id": version_id}}
            },
        }
    }
    data = request_json(headers, "POST", "/v1/appStoreVersionLocalizations", json=body)
    loc_id = data["data"]["id"]
    print(f"Created localization {LOCALE} id={loc_id}")
    return loc_id


def patch_localization(headers, loc_id, apply):
    body = {
        "data": {
            "type": "appStoreVersionLocalizations",
            "id": loc_id,
            "attributes": {
                "description": DESCRIPTION,
                "keywords": KEYWORDS,
                "marketingUrl": MARKETING_URL,
                "promotionalText": PROMOTIONAL_TEXT,
                "supportUrl": SUPPORT_URL,
                "whatsNew": WHATS_NEW,
            },
        }
    }
    print("Updating ASO localization copy")
    if apply:
        request_json(headers, "PATCH", f"/v1/appStoreVersionLocalizations/{loc_id}", json=body)


def patch_review_notes(headers, version_id, apply):
    data = request_json(
        headers,
        "GET",
        f"/v1/appStoreVersions/{version_id}/appStoreReviewDetail",
        params={"fields[appStoreReviewDetails]": "notes"},
    )
    detail = data["data"]
    body = {
        "data": {
            "type": "appStoreReviewDetails",
            "id": detail["id"],
            "attributes": {"notes": REVIEW_NOTES},
        }
    }
    print("Updating review notes")
    if apply:
        request_json(headers, "PATCH", f"/v1/appStoreReviewDetails/{detail['id']}", json=body)


def find_build(headers, app_id):
    data = request_json(
        headers,
        "GET",
        "/v1/builds",
        params={
            "filter[app]": app_id,
            "filter[version]": BUILD_NUMBER,
            "fields[builds]": "version,processingState,uploadedDate,expired",
            "sort": "-uploadedDate",
            "limit": 10,
        },
    )
    builds = data.get("data", [])
    if not builds:
        raise RuntimeError(f"Build {BUILD_NUMBER} not found in App Store Connect")
    build = builds[0]
    attrs = build["attributes"]
    print(
        f"Using Build {attrs.get('version')} id={build['id']} "
        f"state={attrs.get('processingState')} uploaded={attrs.get('uploadedDate')} expired={attrs.get('expired')}"
    )
    return build["id"]


def attach_build(headers, version_id, build_id, apply):
    body = {"data": {"type": "builds", "id": build_id}}
    print(f"Attaching Build {BUILD_NUMBER} to App Store version {VERSION}")
    if apply:
        request_json(
            headers,
            "PATCH",
            f"/v1/appStoreVersions/{version_id}/relationships/build",
            json=body,
        )


def screenshot_paths():
    paths = sorted(SCREENSHOT_DIR.glob("0*.png"))
    if len(paths) != 5:
        raise RuntimeError(f"Expected 5 screenshots in {SCREENSHOT_DIR}, found {len(paths)}")
    return paths


def get_or_create_screenshot_set(headers, loc_id, apply):
    data = request_json(
        headers,
        "GET",
        f"/v1/appStoreVersionLocalizations/{loc_id}/appScreenshotSets",
        params={
            "fields[appScreenshotSets]": "screenshotDisplayType",
            "limit": 50,
        },
    )
    for item in data.get("data", []):
        if item["attributes"].get("screenshotDisplayType") == SCREENSHOT_DISPLAY_TYPE:
            print(f"Using screenshot set {SCREENSHOT_DISPLAY_TYPE} id={item['id']}")
            return item["id"]

    print(f"Screenshot set {SCREENSHOT_DISPLAY_TYPE} does not exist.")
    if not apply:
        return None

    body = {
        "data": {
            "type": "appScreenshotSets",
            "attributes": {"screenshotDisplayType": SCREENSHOT_DISPLAY_TYPE},
            "relationships": {
                "appStoreVersionLocalization": {
                    "data": {"type": "appStoreVersionLocalizations", "id": loc_id}
                }
            },
        }
    }
    data = request_json(headers, "POST", "/v1/appScreenshotSets", json=body)
    set_id = data["data"]["id"]
    print(f"Created screenshot set {SCREENSHOT_DISPLAY_TYPE} id={set_id}")
    return set_id


def delete_existing_screenshots(headers, set_id, apply):
    data = request_json(
        headers,
        "GET",
        f"/v1/appScreenshotSets/{set_id}/appScreenshots",
        params={"fields[appScreenshots]": "fileName", "limit": 50},
    )
    screenshots = data.get("data", [])
    if not screenshots:
        print("No existing screenshots to delete")
        return
    print(f"Deleting {len(screenshots)} existing screenshots in set")
    if not apply:
        return
    for screenshot in screenshots:
        request_json(headers, "DELETE", f"/v1/appScreenshots/{screenshot['id']}", expected=(204,))


def reserve_upload(headers, set_id, path):
    file_size = path.stat().st_size
    body = {
        "data": {
            "type": "appScreenshots",
            "attributes": {
                "fileName": path.name,
                "fileSize": file_size,
            },
            "relationships": {
                "appScreenshotSet": {"data": {"type": "appScreenshotSets", "id": set_id}}
            },
        }
    }
    data = request_json(headers, "POST", "/v1/appScreenshots", json=body)
    return data["data"]


def upload_screenshot(headers, set_id, path, apply):
    print(f"Uploading {path.name} ({path.stat().st_size} bytes)")
    if not apply:
        return
    screenshot = reserve_upload(headers, set_id, path)
    screenshot_id = screenshot["id"]
    upload_ops = screenshot["attributes"].get("uploadOperations", [])
    if not upload_ops:
        raise RuntimeError(f"No upload operations returned for {path.name}")

    data = path.read_bytes()
    for op in upload_ops:
        method = op["method"]
        url = op["url"]
        op_headers = {h["name"]: h["value"] for h in op.get("requestHeaders", [])}
        offset = op.get("offset", 0)
        length = op.get("length", len(data))
        chunk = data[offset : offset + length]
        last_error = None
        for attempt in range(1, 7):
            try:
                response = requests.request(method, url, headers=op_headers, data=chunk, timeout=120)
                if response.status_code < 400:
                    last_error = None
                    break
                last_error = RuntimeError(
                    f"Binary upload failed for {path.name}: {response.status_code}\n{response.text[:500]}"
                )
            except requests.RequestException as exc:
                last_error = exc

            wait = min(5 * attempt, 20)
            print(f"  Upload attempt {attempt}/6 failed for {path.name}; retrying in {wait}s")
            time.sleep(wait)
        if last_error:
            raise RuntimeError(f"Binary upload failed for {path.name} after retries: {last_error}")

    body = {
        "data": {
            "type": "appScreenshots",
            "id": screenshot_id,
            "attributes": {"uploaded": True},
        }
    }
    request_json(headers, "PATCH", f"/v1/appScreenshots/{screenshot_id}", json=body)


def upload_screenshots(headers, loc_id, apply):
    paths = screenshot_paths()
    set_id = get_or_create_screenshot_set(headers, loc_id, apply)
    if not set_id:
        print("Skipping screenshot upload in dry run")
        return
    delete_existing_screenshots(headers, set_id, apply)
    for path in paths:
        upload_screenshot(headers, set_id, path, apply)


def submit_for_review(headers, app_id, version_id, apply):
    print("Preparing App Store review submission")
    submissions = request_json(
        headers,
        "GET",
        f"/v1/apps/{app_id}/reviewSubmissions",
        params={
            "filter[platform]": "IOS",
            "fields[reviewSubmissions]": "platform,state,submittedDate",
            "limit": 20,
        },
    ).get("data", [])

    submission = next(
        (item for item in submissions if item["attributes"].get("state") == "READY_FOR_REVIEW"),
        None,
    )
    if submission:
        submission_id = submission["id"]
        print(f"Using existing review submission id={submission_id}")
    else:
        if not apply:
            print("Would create review submission")
            return
        body = {
            "data": {
                "type": "reviewSubmissions",
                "attributes": {"platform": "IOS"},
                "relationships": {"app": {"data": {"type": "apps", "id": app_id}}},
            }
        }
        submission = request_json(headers, "POST", "/v1/reviewSubmissions", expected=(201,), json=body)["data"]
        submission_id = submission["id"]
        print(f"Created review submission id={submission_id}")

    if apply:
        body = {
            "data": {
                "type": "reviewSubmissionItems",
                "relationships": {
                    "reviewSubmission": {"data": {"type": "reviewSubmissions", "id": submission_id}},
                    "appStoreVersion": {"data": {"type": "appStoreVersions", "id": version_id}},
                },
            }
        }
        try:
            item = request_json(headers, "POST", "/v1/reviewSubmissionItems", expected=(201,), json=body)["data"]
            print(f"Created review submission item id={item['id']}")
        except RuntimeError as exc:
            text = str(exc)
            if "409" in text:
                print("Review submission item already exists")
            else:
                raise

        body = {
            "data": {
                "type": "reviewSubmissions",
                "id": submission_id,
                "attributes": {"submitted": True},
            }
        }
        submission = request_json(
            headers,
            "PATCH",
            f"/v1/reviewSubmissions/{submission_id}",
            expected=(200,),
            json=body,
        )["data"]
        attrs = submission["attributes"]
        print(f"Review submission state={attrs.get('state')} submittedDate={attrs.get('submittedDate')}")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--apply", action="store_true", help="Make changes in App Store Connect")
    parser.add_argument("--skip-screenshots", action="store_true")
    parser.add_argument("--submit", action="store_true", help="Submit the prepared version for App Store review")
    args = parser.parse_args()

    issuer_id = os.environ.get("ASC_ISSUER_ID")
    if not issuer_id:
        raise SystemExit("Set ASC_ISSUER_ID in the environment")

    key_id, private_key = find_api_key()
    token = generate_token(issuer_id, key_id, private_key)
    headers = make_headers(token)
    app_id = get_app_id(headers)

    print("Mode:", "APPLY" if args.apply else "DRY RUN")
    version_id = get_or_create_version(headers, app_id, args.apply)
    if not version_id:
        print("Dry run complete before version creation")
        return
    patch_version(headers, version_id, args.apply)
    loc_id = get_or_create_localization(headers, version_id, args.apply)
    if not loc_id:
        print("Dry run complete before localization creation")
        return
    patch_localization(headers, loc_id, args.apply)
    patch_review_notes(headers, version_id, args.apply)
    build_id = find_build(headers, app_id)
    attach_build(headers, version_id, build_id, args.apply)
    if not args.skip_screenshots:
        upload_screenshots(headers, loc_id, args.apply)
    if args.submit:
        submit_for_review(headers, app_id, version_id, args.apply)
    print("Done")


if __name__ == "__main__":
    main()
