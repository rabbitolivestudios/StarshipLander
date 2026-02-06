#!/usr/bin/env python3
"""
Create Game Center leaderboards and achievements via App Store Connect API.

Usage:
    ASC_ISSUER_ID=<issuer-id> python3 Scripts/setup_game_center.py

Reads API key from ~/.appstoreconnect/private_keys/AuthKey_*.p8
"""

import os
import sys
import glob
import time
import json
import jwt
import requests

# ── Configuration ─────────────────────────────────────────────────────────

BUNDLE_ID = "com.tboliveira.StarshipLander"
BASE_URL = "https://api.appstoreconnect.apple.com"

LEADERBOARDS = [
    {"ref": "classic", "name": "Classic Mode"},
    {"ref": "campaign_1", "name": "Moon"},
    {"ref": "campaign_2", "name": "Mars"},
    {"ref": "campaign_3", "name": "Titan"},
    {"ref": "campaign_4", "name": "Europa"},
    {"ref": "campaign_5", "name": "Earth"},
    {"ref": "campaign_6", "name": "Venus"},
    {"ref": "campaign_7", "name": "Mercury"},
    {"ref": "campaign_8", "name": "Ganymede"},
    {"ref": "campaign_9", "name": "Io"},
    {"ref": "campaign_10", "name": "Jupiter"},
    {"ref": "galaxy_rank", "name": "Galaxy Rank"},
]

ACHIEVEMENTS = [
    {
        "ref": "eagle_has_landed",
        "name": "The Eagle Has Landed",
        "desc": "Complete a SAFE landing on any platform.",
        "points": 10,
    },
    {
        "ref": "precision_landing",
        "name": "Precision Landing",
        "desc": "Complete a SAFE landing on Platform B (Precision Target).",
        "points": 10,
    },
    {
        "ref": "elite_landing",
        "name": "Elite Landing",
        "desc": "Complete a SAFE landing on Platform C (Elite Landing).",
        "points": 15,
    },
    {
        "ref": "fuel_master",
        "name": "Fuel Master",
        "desc": "Land with 65% or more fuel remaining.",
        "points": 10,
    },
    {
        "ref": "precision_pilot",
        "name": "Precision Pilot",
        "desc": "SAFE landing on Platform C with tilt under 2 degrees in Campaign mode.",
        "points": 20,
    },
    {
        "ref": "triple_elite",
        "name": "Triple Elite",
        "desc": "SAFE landing on Platform C on 3 different campaign planets.",
        "points": 20,
    },
    {
        "ref": "planet_conquered",
        "name": "Planet Conquered",
        "desc": "Earn 3 stars on any campaign level.",
        "points": 15,
    },
    {
        "ref": "first_try_perfection",
        "name": "First Try Perfection",
        "desc": "SAFE Platform C landing on your very first attempt at a campaign level.",
        "points": 25,
    },
    {
        "ref": "solar_system_elite",
        "name": "Solar System Elite",
        "desc": "Earn all 30 campaign stars across every planet.",
        "points": 25,
    },
    {
        "ref": "master_lander",
        "name": "Master Lander",
        "desc": "SAFE Platform C landing on all 10 campaign planets.",
        "points": 50,
    },
]

# ── Auth helpers ──────────────────────────────────────────────────────────

def find_api_key():
    """Find API key from env vars or ~/.appstoreconnect/private_keys/"""
    # Prefer env vars (e.g., from Vercel)
    key_id = os.environ.get("ASC_KEY_ID")
    private_key = os.environ.get("ASC_PRIVATE_KEY")
    if key_id and private_key:
        # Restore newlines if escaped
        if "\\n" in private_key and "\n" not in private_key:
            private_key = private_key.replace("\\n", "\n")
        return key_id, private_key

    # Fall back to .p8 file on disk
    pattern = os.path.expanduser("~/.appstoreconnect/private_keys/AuthKey_*.p8")
    keys = sorted(glob.glob(pattern))
    if not keys:
        print("ERROR: No API key found. Set ASC_KEY_ID + ASC_PRIVATE_KEY env vars,")
        print("       or place a .p8 key in ~/.appstoreconnect/private_keys/")
        sys.exit(1)
    path = keys[0]
    key_id = os.path.basename(path).replace("AuthKey_", "").replace(".p8", "")
    with open(path, "r") as f:
        private_key = f.read()
    return key_id, private_key


def generate_token(issuer_id, key_id, private_key):
    """Generate a JWT for App Store Connect API."""
    now = int(time.time())
    payload = {
        "iss": issuer_id,
        "iat": now,
        "exp": now + 1200,  # 20 min
        "aud": "appstoreconnect-v1",
    }
    return jwt.encode(payload, private_key, algorithm="ES256", headers={"kid": key_id})


def make_headers(token):
    return {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json",
    }


# ── API calls ─────────────────────────────────────────────────────────────

def get_app_id(headers):
    """Find the app's ASC ID from the bundle ID."""
    r = requests.get(
        f"{BASE_URL}/v1/apps",
        headers=headers,
        params={"filter[bundleId]": BUNDLE_ID, "fields[apps]": "bundleId,name"},
    )
    r.raise_for_status()
    data = r.json()["data"]
    if not data:
        print(f"ERROR: No app found with bundle ID {BUNDLE_ID}")
        sys.exit(1)
    app_id = data[0]["id"]
    app_name = data[0]["attributes"]["name"]
    print(f"Found app: {app_name} (ID: {app_id})")
    return app_id


def get_or_create_gc_detail(headers, app_id):
    """Get or create the Game Center detail for the app."""
    # Check if it exists
    r = requests.get(
        f"{BASE_URL}/v1/apps/{app_id}/gameCenterDetail",
        headers=headers,
    )
    if r.status_code == 200:
        data = r.json().get("data")
        if data:
            print(f"Game Center detail exists (ID: {data['id']})")
            return data["id"]

    # Create it
    body = {
        "data": {
            "type": "gameCenterDetails",
            "relationships": {
                "app": {"data": {"type": "apps", "id": app_id}}
            },
        }
    }
    r = requests.post(f"{BASE_URL}/v1/gameCenterDetails", headers=headers, json=body)
    if r.status_code == 409:
        # Already exists — try fetching again
        r2 = requests.get(f"{BASE_URL}/v1/apps/{app_id}/gameCenterDetail", headers=headers)
        r2.raise_for_status()
        data = r2.json()["data"]
        print(f"Game Center detail already existed (ID: {data['id']})")
        return data["id"]
    r.raise_for_status()
    gc_id = r.json()["data"]["id"]
    print(f"Created Game Center detail (ID: {gc_id})")
    return gc_id


def get_existing_leaderboards(headers, gc_detail_id):
    """Get existing leaderboard reference names."""
    existing = set()
    url = f"{BASE_URL}/v1/gameCenterDetails/{gc_detail_id}/gameCenterLeaderboards"
    params = {"fields[gameCenterLeaderboards]": "referenceName,vendorIdentifier", "limit": 50}
    r = requests.get(url, headers=headers, params=params)
    r.raise_for_status()
    for item in r.json().get("data", []):
        vid = item["attributes"].get("vendorIdentifier", "")
        if vid:
            existing.add(vid)
    return existing


def create_leaderboard(headers, gc_detail_id, ref_name, display_name):
    """Create a single leaderboard with English localization."""
    body = {
        "data": {
            "type": "gameCenterLeaderboards",
            "attributes": {
                "referenceName": display_name,
                "vendorIdentifier": ref_name,
                "defaultFormatter": "INTEGER",
                "submissionType": "BEST_SCORE",
                "scoreSortType": "DESC",
                "scoreRangeStart": "0",
                "scoreRangeEnd": "100000",
            },
            "relationships": {
                "gameCenterDetail": {
                    "data": {"type": "gameCenterDetails", "id": gc_detail_id}
                }
            },
        }
    }
    r = requests.post(f"{BASE_URL}/v1/gameCenterLeaderboards", headers=headers, json=body)
    if r.status_code == 409:
        # 409 can mean "already exists" OR "entity error" — print details
        print(f"  Leaderboard '{ref_name}' got 409:")
        print(f"  {r.text[:500]}")
        return None
    if r.status_code >= 400:
        print(f"  ERROR creating leaderboard '{ref_name}': {r.status_code}")
        print(f"  {r.text[:500]}")
        return None
    lb_id = r.json()["data"]["id"]
    print(f"  Created leaderboard '{ref_name}' ({display_name}) — ID: {lb_id}")

    # Add English localization
    loc_body = {
        "data": {
            "type": "gameCenterLeaderboardLocalizations",
            "attributes": {
                "locale": "en-US",
                "name": display_name,
                "formatterOverride": "INTEGER",
                "formatterSuffix": " pts",
                "formatterSuffixSingular": " pt",
            },
            "relationships": {
                "gameCenterLeaderboard": {
                    "data": {"type": "gameCenterLeaderboards", "id": lb_id}
                }
            },
        }
    }
    r2 = requests.post(
        f"{BASE_URL}/v1/gameCenterLeaderboardLocalizations",
        headers=headers,
        json=loc_body,
    )
    if r2.status_code < 400:
        print(f"    + en-US localization added")
    else:
        print(f"    ! Localization warning: {r2.status_code} — {r2.text[:200]}")

    return lb_id


def get_existing_achievements(headers, gc_detail_id):
    """Get existing achievement reference names."""
    existing = set()
    url = f"{BASE_URL}/v1/gameCenterDetails/{gc_detail_id}/gameCenterAchievements"
    params = {"fields[gameCenterAchievements]": "referenceName,vendorIdentifier", "limit": 50}
    r = requests.get(url, headers=headers, params=params)
    r.raise_for_status()
    for item in r.json().get("data", []):
        vid = item["attributes"].get("vendorIdentifier", "")
        if vid:
            existing.add(vid)
    return existing


def create_achievement(headers, gc_detail_id, ref_name, display_name, description, points):
    """Create a single achievement with English localization."""
    body = {
        "data": {
            "type": "gameCenterAchievements",
            "attributes": {
                "referenceName": display_name,
                "vendorIdentifier": ref_name,
                "points": points,
                "repeatable": False,
                "showBeforeEarned": True,
            },
            "relationships": {
                "gameCenterDetail": {
                    "data": {"type": "gameCenterDetails", "id": gc_detail_id}
                }
            },
        }
    }
    r = requests.post(f"{BASE_URL}/v1/gameCenterAchievements", headers=headers, json=body)
    if r.status_code == 409:
        print(f"  Achievement '{ref_name}' already exists — skipping")
        return None
    if r.status_code >= 400:
        print(f"  ERROR creating achievement '{ref_name}': {r.status_code}")
        print(f"  {r.text[:500]}")
        return None
    ach_id = r.json()["data"]["id"]
    print(f"  Created achievement '{ref_name}' ({display_name}, {points}pts) — ID: {ach_id}")

    # Add English localization
    loc_body = {
        "data": {
            "type": "gameCenterAchievementLocalizations",
            "attributes": {
                "locale": "en-US",
                "name": display_name,
                "beforeEarnedDescription": description,
                "afterEarnedDescription": description,
            },
            "relationships": {
                "gameCenterAchievement": {
                    "data": {"type": "gameCenterAchievements", "id": ach_id}
                }
            },
        }
    }
    r2 = requests.post(
        f"{BASE_URL}/v1/gameCenterAchievementLocalizations",
        headers=headers,
        json=loc_body,
    )
    if r2.status_code < 400:
        print(f"    + en-US localization added")
    else:
        print(f"    ! Localization warning: {r2.status_code} — {r2.text[:200]}")

    return ach_id


# ── Main ──────────────────────────────────────────────────────────────────

def main():
    issuer_id = os.environ.get("ASC_ISSUER_ID")
    if not issuer_id:
        print("ERROR: Set ASC_ISSUER_ID environment variable")
        print("  Find it at: https://appstoreconnect.apple.com/access/integrations/api")
        print("  Usage: ASC_ISSUER_ID=<id> python3 Scripts/setup_game_center.py")
        sys.exit(1)

    key_id, private_key = find_api_key()
    print(f"Using API key: {key_id}")

    token = generate_token(issuer_id, key_id, private_key)
    headers = make_headers(token)

    # 1. Find app
    app_id = get_app_id(headers)

    # 2. Get/create Game Center detail
    gc_detail_id = get_or_create_gc_detail(headers, app_id)

    # 3. Create leaderboards
    existing_lbs = get_existing_leaderboards(headers, gc_detail_id)
    print(f"\n── Creating {len(LEADERBOARDS)} leaderboards ──")
    created_lbs = 0
    for lb in LEADERBOARDS:
        if lb["ref"] in existing_lbs:
            print(f"  Leaderboard '{lb['ref']}' already exists — skipping")
            continue
        result = create_leaderboard(headers, gc_detail_id, lb["ref"], lb["name"])
        if result:
            created_lbs += 1
    print(f"Leaderboards: {created_lbs} created, {len(existing_lbs)} already existed")

    # 4. Create achievements
    existing_achs = get_existing_achievements(headers, gc_detail_id)
    print(f"\n── Creating {len(ACHIEVEMENTS)} achievements ──")
    created_achs = 0
    for ach in ACHIEVEMENTS:
        if ach["ref"] in existing_achs:
            print(f"  Achievement '{ach['ref']}' already exists — skipping")
            continue
        result = create_achievement(
            headers, gc_detail_id, ach["ref"], ach["name"], ach["desc"], ach["points"]
        )
        if result:
            created_achs += 1
    print(f"Achievements: {created_achs} created, {len(existing_achs)} already existed")

    print(f"\n{'='*50}")
    print(f"DONE — {created_lbs} leaderboards + {created_achs} achievements created")
    print(f"Total: {len(LEADERBOARDS)} leaderboards, {len(ACHIEVEMENTS)} achievements")
    print(f"Verify at: https://appstoreconnect.apple.com")


if __name__ == "__main__":
    main()
