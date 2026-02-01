#!/usr/bin/env python3
"""
Calculate optimal 'perfect landing' scores for Starship Lander.

Physics model (matching GameScene.swift + SpriteKit internals):

  SpriteKit: 150 points per meter. Velocity in pts/s.
  Gravity per frame: |g| × 150 / 60 = |g| × 2.5 pts/s
  Thrust: binary on/off, T pts/s per frame when upright.
  Tilt θ: vy += cos(θ)*T, vx += sin(θ)*T*0.85 (net after vectoring)
  Fuel: 0.3%/thrust frame, 0.08%/rotation frame

  Landing gates (ALL must pass, or crash):
    - verticalSpeed <= 40 pts/s
    - horizontalSpeed <= 25 pts/s
    - rotation <= 0.05 rad
    - approachSpeed <= 80 pts/s  (average of last 30 velocity samples)

  Screen wrapping: x < -20 → x = screenW + 20; x > screenW + 20 → x = -20
  Velocity preserved through wrap. Going left from start can be shorter to
  reach platform C than going right.

  Optimization: search over target descent speed, max tilt, direction
  (left/right considering wrap), and landing offset on the platform.
  "Perfect landing" = maximum possible score, not just dead-center landing.
"""

import math

# =============================================================================
# Constants
# =============================================================================

SCREEN_W = 393.0
SCREEN_H = 852.0
PTS_PER_M = 150.0
FPS = 60
DT = 1.0 / FPS

START_X = 0.15 * SCREEN_W          # 58.95
START_Y = SCREEN_H - 100           # 752
PLATFORM_Y = 224.0
FALL_HEIGHT = START_Y - PLATFORM_Y  # 528

WRAP_WIDTH = SCREEN_W + 40         # 433 (from -20 to screenW+20)

FUEL_THRUST = 0.3
FUEL_ROTATE = 0.08

# Campaign reentry state (applied to all non-Classic levels)
CAMPAIGN_INITIAL_TILT = 0.12       # ~6.9° left tilt (radians)
CAMPAIGN_INITIAL_HSPEED = 15.0     # rightward drift (pts/s)

MAX_SAFE_VERT = 40.0
MAX_SAFE_HORIZ = 25.0
MAX_SAFE_ROT = 0.05
MAX_SAFE_APPROACH = 80.0
APPROACH_WINDOW = 30


# =============================================================================
# Data
# =============================================================================

PLATFORMS = [
    {"name": "A", "xf": 0.18, "w": 130.0, "mult": 1.0},
    {"name": "B", "xf": 0.50, "w": 110.0, "mult": 2.0},
    {"name": "C", "xf": 0.82, "w": 80.0,  "mult": 5.0},
]
for p in PLATFORMS:
    p["x"] = p["xf"] * SCREEN_W

LEVELS = [
    {"name": "Classic",  "g": 2.0, "T": 12.0},
    {"name": "Moon",     "g": 1.6, "T": 8.0},
    {"name": "Mars",     "g": 2.0, "T": 9.5},
    {"name": "Titan",    "g": 2.2, "T": 10.0},
    {"name": "Europa",   "g": 2.5, "T": 11.0},
    {"name": "Earth",    "g": 2.8, "T": 12.0},
    {"name": "Venus",    "g": 3.2, "T": 13.0},
    {"name": "Mercury",  "g": 3.5, "T": 14.0},
    {"name": "Ganymede", "g": 3.8, "T": 15.0},
    {"name": "Io",       "g": 4.2, "T": 16.5},
    {"name": "Jupiter",  "g": 4.8, "T": 18.5},
]


def g_frame(g_val):
    return abs(g_val) * PTS_PER_M * DT


# =============================================================================
# Scoring
# =============================================================================

def calc_score(v, h, rot, appr, fuel, rx, plat):
    sub = 100.0
    sub += 500.0 * (1.0 - min(1.0, v / MAX_SAFE_VERT)) ** 2
    sub += 400.0 * (1.0 - min(1.0, h / MAX_SAFE_HORIZ)) ** 2
    cr = min(1.0, abs(rx - plat["x"]) / (plat["w"] / 2.0))
    sub += 600.0 * (1.0 - cr) ** 2
    sub += 250.0 * (1.0 - min(1.0, rot / MAX_SAFE_ROT)) ** 2
    sub += 150.0 * (1.0 - min(1.0, appr / MAX_SAFE_APPROACH)) ** 2
    fm = 1.0 + fuel / 100.0
    return int(sub * fm * plat["mult"]), sub, fm


def score_detail(v, h, rot, appr, fuel, rx, plat):
    base = 100.0
    soft = 500.0 * (1.0 - min(1.0, v / MAX_SAFE_VERT)) ** 2
    hz = 400.0 * (1.0 - min(1.0, h / MAX_SAFE_HORIZ)) ** 2
    cr = min(1.0, abs(rx - plat["x"]) / (plat["w"] / 2.0))
    ctr = 600.0 * (1.0 - cr) ** 2
    rt = 250.0 * (1.0 - min(1.0, rot / MAX_SAFE_ROT)) ** 2
    ap = 150.0 * (1.0 - min(1.0, appr / MAX_SAFE_APPROACH)) ** 2
    sub = base + soft + hz + ctr + rt + ap
    fm = 1.0 + fuel / 100.0
    return {"base": base, "soft": soft, "horiz": hz, "center": ctr,
            "rot": rt, "approach": ap, "sub": sub, "fm": fm,
            "pm": plat["mult"], "total": int(sub * fm * plat["mult"])}


# =============================================================================
# Simulation — Reactive Controller with Wrapping + Position Optimization
# =============================================================================

def compute_dx_rem(x, tx, go_left, plat_w):
    """Compute signed remaining horizontal distance considering direction and wrapping."""
    dx_direct = tx - x

    # If close to target (within platform width), use direct distance
    # This handles overshoot correction naturally
    if abs(dx_direct) < plat_w:
        return dx_direct

    if go_left:
        # Want negative dx_rem (going left)
        if dx_direct <= 0:
            return dx_direct
        else:
            return dx_direct - WRAP_WIDTH
    else:
        # Want positive dx_rem (going right)
        if dx_direct >= 0:
            return dx_direct
        else:
            return dx_direct + WRAP_WIDTH


def simulate(level, plat, target_desc=35.0, max_tilt=0.40,
             go_left=False, x_offset=0.0, is_campaign=False, debug=False):
    """
    Frame-by-frame simulation with reactive controller.

    Parameters:
      target_desc: desired descent speed during controlled approach
      max_tilt: maximum tilt angle in radians
      go_left: if True, go left (and potentially wrap) to reach platform
      x_offset: landing offset from center (-1.0 to 1.0, fraction of half-width)
      is_campaign: if True, apply campaign reentry state (initial tilt + drift)

    Optimization: "perfect landing" = maximum score, which is a trade-off
    between center precision (up to 600 subtotal pts), fuel remaining
    (1.0-2.0x multiplier on entire subtotal), and other landing quality metrics.
    Landing off-center but saving fuel can sometimes score higher.
    """
    gv = g_frame(level["g"])
    T = level["T"]
    net_upright = T - gv

    # Clamp max_tilt so we can always brake: cos(max_tilt)*T > gv
    max_possible_tilt = math.acos(min(0.99, gv / T * 1.1))
    max_tilt = min(max_tilt, max_possible_tilt)

    # Target landing position (offset from center)
    tx = plat["x"] + x_offset * (plat["w"] / 2.0)
    tx = max(plat["x"] - plat["w"] / 2, min(plat["x"] + plat["w"] / 2, tx))

    x, y, vx, vy = START_X, START_Y, 0.0, 0.0
    fuel = 100.0
    ship_tilt = 0.0  # current ship tilt (radians, positive = left)

    # Apply campaign reentry state
    if is_campaign:
        vx = CAMPAIGN_INITIAL_HSPEED
        ship_tilt = CAMPAIGN_INITIAL_TILT
    vel_ring = []
    hover_acc = 0.0

    # Campaign tilt correction phase: the ship starts tilted and must rotate
    # to upright before effective thrust is possible. Each rotation frame costs
    # FUEL_ROTATE and corrects ~rotationPower (0.04 rad) of tilt.
    # During correction, thrust is less effective (cos(ship_tilt) vertical component).
    rotation_power = 0.04  # rad per frame (matching GameScene rotationPower)
    if is_campaign and ship_tilt != 0:
        while abs(ship_tilt) > 0.005 and fuel > 1.0:
            # Rotate toward upright
            correction = min(abs(ship_tilt), rotation_power)
            ship_tilt -= math.copysign(correction, ship_tilt)
            fuel -= FUEL_ROTATE

            # Gravity still applies during correction (freefall)
            vy -= gv
            x += vx / FPS
            y += vy / FPS

            # Screen wrapping
            if x < -20:
                x = SCREEN_W + 20
            elif x > SCREEN_W + 20:
                x = -20

            vel_ring.append(max(0.0, -vy))
            if len(vel_ring) > APPROACH_WINDOW:
                vel_ring.pop(0)

    for frame in range(8000):
        height = y - PLATFORM_Y
        desc = max(0.0, -vy)

        # Compute dx_rem considering wrapping direction
        dx_rem = compute_dx_rem(x, tx, go_left, plat["w"])

        vel_ring.append(desc)
        if len(vel_ring) > APPROACH_WINDOW:
            vel_ring.pop(0)

        if height <= 0.5 and desc <= MAX_SAFE_VERT:
            break
        if height < -10 or fuel <= 0.5:
            return None

        # ===== 1. COMPUTE DESIRED HORIZONTAL TILT =====
        tilt = 0.0
        h_decel_rate = math.sin(max_tilt) * T * 0.85
        moving_toward = (vx > 0 and dx_rem > 0) or (vx < 0 and dx_rem < 0)

        if h_decel_rate > 0.01:
            frames_to_stop = abs(vx) / h_decel_rate
            stop_dist = abs(vx) * frames_to_stop / (2 * FPS)
        else:
            stop_dist = 0

        if abs(dx_rem) < 2.0 and abs(vx) < 3.0:
            tilt = 0.0
        elif moving_toward and stop_dist >= abs(dx_rem) * 0.8:
            # Decelerate — tilt opposite to velocity
            decel_sin = min(math.sin(max_tilt), abs(vx) / (T * 0.85 * 2))
            tilt_mag = math.asin(min(1.0, decel_sin))
            tilt = tilt_mag if vx < 0 else -tilt_mag
        elif abs(dx_rem) > 2.0:
            # Accelerate toward target
            accel_sin = min(math.sin(max_tilt), abs(dx_rem) / 150.0)
            if abs(vx) > 80 and moving_toward:
                accel_sin *= 0.2
            elif abs(vx) > 50 and moving_toward:
                accel_sin *= 0.5
            tilt_mag = math.asin(min(1.0, max(0.001, accel_sin)))
            tilt = tilt_mag if dx_rem > 0 else -tilt_mag

        # Near landing, prioritize vertical
        if height < 15:
            tilt *= 0.2
        elif height < 30:
            tilt *= 0.5

        abs_tilt = abs(tilt)
        need_horizontal = abs_tilt > 0.01

        # ===== 2. COMPUTE VERTICAL BRAKING BUDGET =====
        eff_net = (math.cos(abs_tilt) * T - gv) if need_horizontal else net_upright
        if eff_net <= 0:
            eff_net = net_upright

        if desc > target_desc:
            brake_f = (desc - target_desc) / eff_net
            brake_h = (desc + target_desc) / 2 * brake_f / FPS
        else:
            brake_h = 0

        hover_h = target_desc * APPROACH_WINDOW / FPS
        total_needed = brake_h + hover_h + 5

        # ===== 3. THRUST DECISION =====
        in_freefall_zone = height > total_needed * 1.2
        do_thrust = False

        if in_freefall_zone:
            if need_horizontal and fuel > 20:
                # Use excess altitude for horizontal movement
                do_thrust = True
            else:
                do_thrust = False
        elif desc > target_desc:
            do_thrust = True  # brake
        else:
            # PWM hover — adjust duty cycle for tilt
            if need_horizontal:
                cos_t = math.cos(abs_tilt)
                hover_frac = gv / (cos_t * T) if cos_t * T > gv else 0.95
            else:
                hover_frac = gv / T
            hover_frac = min(hover_frac, 0.95)
            hover_acc += hover_frac
            if hover_acc >= 1.0:
                hover_acc -= 1.0
                do_thrust = True
            if desc > target_desc * 1.2:
                do_thrust = True
                hover_acc = 0.0
            elif desc < target_desc * 0.5 and height > 8:
                do_thrust = False

        # In freefall zone with horizontal thrust, use high tilt to minimize
        # vertical slowdown (keep falling while moving sideways)
        if in_freefall_zone and do_thrust and need_horizontal:
            hover_tilt = math.acos(min(1.0, gv / T))
            if abs_tilt < hover_tilt * 0.8:
                abs_tilt = hover_tilt * 0.8
                tilt = abs_tilt if tilt > 0 else -abs_tilt

        # ===== 4. APPLY PHYSICS =====
        if do_thrust:
            abs_tilt = abs(tilt)
            vy += math.cos(abs_tilt) * T
            if abs_tilt > 0.005:
                sign = 1 if tilt > 0 else -1
                vx += sign * math.sin(abs_tilt) * T * 0.85
                fuel -= FUEL_THRUST + FUEL_ROTATE
            else:
                fuel -= FUEL_THRUST

        vy -= gv
        x += vx / FPS
        y += vy / FPS

        # Screen wrapping (matching GameScene.swift lines 338-343)
        if x < -20:
            x = SCREEN_W + 20
        elif x > SCREEN_W + 20:
            x = -20

        if debug and frame < 30:
            print(f"  f{frame:3d}: h={height:6.1f} desc={desc:5.1f} "
                  f"vx={vx:6.1f} x={x:6.1f} dx={dx_rem:6.1f} "
                  f"thr={'Y' if do_thrust else 'N'} tilt={tilt:+.3f} "
                  f"fuel={fuel:.1f} {'FF' if in_freefall_zone else ''}")

    # --- Evaluate landing ---
    height = y - PLATFORM_Y
    if height > 5 or fuel <= 0:
        return None

    lv = max(0.0, -vy)
    lh = abs(vx)
    rot = 0.005

    fuel -= 0.5  # rotation overhead
    fuel = max(0.0, fuel)

    appr = sum(vel_ring) / len(vel_ring) if vel_ring else lv

    if lv > MAX_SAFE_VERT or lh > MAX_SAFE_HORIZ or appr > MAX_SAFE_APPROACH:
        return None

    score, sub, fm = calc_score(lv, lh, rot, appr, fuel, x, plat)

    return {
        "score": score, "sub": round(sub, 1), "fm": round(fm, 3),
        "fuel": round(fuel, 1),
        "v": round(lv, 1), "h": round(lh, 1),
        "appr": round(appr, 1),
        "frames": frame + 1, "x": round(x, 1),
        "go_left": go_left, "x_offset": round(x_offset, 2),
    }


def find_best(level, plat, is_campaign=False):
    """Search over all parameters for maximum score."""
    best = None

    # Compute distances in both directions
    # For campaign, initial rightward drift shifts effective start position
    eff_start_x = START_X
    dx_right = plat["x"] - eff_start_x
    dx_left = eff_start_x + 20 + (SCREEN_W + 20 - plat["x"])
    directions = [False]  # always try right
    if dx_left < dx_right * 0.95:  # try left if it's notably shorter
        directions.append(True)

    for go_left in directions:
        for td_10 in range(100, 395, 10):  # 10.0 to 39.0, step 1.0
            td = td_10 / 10.0
            for mt_100 in range(5, 55, 5):  # 0.05 to 0.50 rad
                mt = mt_100 / 100.0
                for xo_10 in range(-8, 9, 2):  # -0.8 to 0.8, step 0.2
                    xo = xo_10 / 10.0
                    r = simulate(level, plat, target_desc=td,
                                 max_tilt=mt, go_left=go_left, x_offset=xo,
                                 is_campaign=is_campaign)
                    if r and (best is None or r["score"] > best["score"]):
                        best = r
                        best["td"] = td
                        best["mt"] = mt

    # Fine-tune around best parameters
    if best:
        td0 = best["td"]
        mt0 = best["mt"]
        xo0 = best["x_offset"]
        gl0 = best["go_left"]
        for td_10 in range(max(100, int(td0 * 10) - 15),
                           min(395, int(td0 * 10) + 16), 3):
            td = td_10 / 10.0
            for mt_100 in range(max(5, int(mt0 * 100) - 8),
                                min(55, int(mt0 * 100) + 9), 2):
                mt = mt_100 / 100.0
                for xo_10 in range(max(-10, int(xo0 * 10) - 3),
                                   min(11, int(xo0 * 10) + 4)):
                    xo = xo_10 / 10.0
                    r = simulate(level, plat, target_desc=td,
                                 max_tilt=mt, go_left=gl0, x_offset=xo,
                                 is_campaign=is_campaign)
                    if r and r["score"] > best["score"]:
                        best = r
                        best["td"] = td
                        best["mt"] = mt

    return best


# =============================================================================
# Output
# =============================================================================

def main():
    W = 95
    print("=" * W)
    print("STARSHIP LANDER — Perfect Landing Score Analysis")
    print("=" * W)
    print()

    print("PHYSICS MODEL")
    print(f"  Screen: {SCREEN_W:.0f}×{SCREEN_H:.0f} | Start: ({START_X:.1f}, {START_Y:.0f}) | Platform Y: {PLATFORM_Y:.0f} | Fall: {FALL_HEIGHT:.0f} pts")
    print(f"  Gravity/frame: |g|×2.5 | Thrust/frame: T | Hover duty: g_frame/T")
    print(f"  Approach gate: avg(last {APPROACH_WINDOW} speeds) <= {MAX_SAFE_APPROACH}")
    print(f"  Screen wrap: x<-20 → {SCREEN_W:.0f}+20 | x>{SCREEN_W:.0f}+20 → -20")
    print()

    print(f"  {'Level':<10} {'|g|':>4} {'T':>5} | {'g/f':>5} {'Net':>5} {'Ratio':>6} {'Hover':>6}")
    print(f"  {'-'*10} {'-'*4} {'-'*5} | {'-'*5} {'-'*5} {'-'*6} {'-'*6}")
    for lv in LEVELS:
        g = g_frame(lv["g"])
        n = lv["T"] - g
        r = lv["T"] / g
        hv = g / lv["T"] * 100
        print(f"  {lv['name']:<10} {lv['g']:>4.1f} {lv['T']:>5.1f} | {g:>5.1f} {n:>+5.1f} {r:>5.2f}× {hv:>5.1f}%")
    print()

    print("CAMPAIGN REENTRY STATE")
    tilt_deg = CAMPAIGN_INITIAL_TILT * 180 / math.pi
    print(f"  Initial tilt: {CAMPAIGN_INITIAL_TILT:.2f} rad ({tilt_deg:.1f}°) left")
    print(f"  Initial H.speed: {CAMPAIGN_INITIAL_HSPEED:.1f} pts/s rightward")
    print(f"  Correction cost: ~{math.ceil(CAMPAIGN_INITIAL_TILT / 0.04)} rotation frames × {FUEL_ROTATE}% = ~{math.ceil(CAMPAIGN_INITIAL_TILT / 0.04) * FUEL_ROTATE:.2f}% fuel")
    print(f"  Applies to: all campaign levels (not Classic)")
    print()

    print("PLATFORM LAYOUT (distances from start)")
    for p in PLATFORMS:
        d_right = p["x"] - START_X
        d_left = START_X + 20 + (SCREEN_W + 20 - p["x"])
        shorter = "right" if d_right <= d_left else f"LEFT WRAP ({d_left:.0f} vs {d_right:.0f})"
        print(f"  {p['name']}: x={p['x']:.1f} (right={d_right:.1f}, left-wrap={d_left:.1f}) — {shorter}")
    print()

    print("THEORETICAL MAX (impossible: zero everything, 100% fuel, dead center)")
    for p in PLATFORMS:
        s, _, _ = calc_score(0, 0, 0, 0, 100, p["x"], p)
        print(f"  {p['name']} ({p['mult']:.0f}x): {s:,}")
    print()

    # --- Compute all optimal scores ---
    print("OPTIMAL PLAY SCORES (maximum achievable points)")
    print("Optimized over: descent speed, tilt angle, direction (L/R), landing position")
    print()
    hdr = f"  {'Level':<10} {'g':>4} {'T':>5} | {'A':>7} {'f%':>4} | {'B':>7} {'f%':>4} | {'C':>7} {'f%':>4} {'dir':>4}"
    print(hdr)
    print("  " + "-" * 72)

    all_r = {}
    for lv in LEVELS:
        is_campaign = lv["name"] != "Classic"
        row = f"  {lv['name']:<10} {lv['g']:>4.1f} {lv['T']:>5.1f} |"
        lr = {}
        for p in PLATFORMS:
            r = find_best(lv, p, is_campaign=is_campaign)
            if r:
                d = "←" if r.get("go_left") else "→"
                row += f" {r['score']:>7,} {r['fuel']:>3.0f}% |"
                if p["name"] == "C":
                    row += f"  {d}"
                lr[p["name"]] = r
            else:
                row += f" {'FAIL':>7} {'':>4} |"
                lr[p["name"]] = None
        print(row)
        all_r[lv["name"]] = lr
    print()

    # Landing details
    print("LANDING DETAILS")
    print(f"  {'Level':<10} | {'A v':>4} {'Ah':>4} {'Aap':>4} {'Axo':>4} | {'B v':>4} {'Bh':>4} {'Bap':>4} {'Bxo':>4} | {'C v':>4} {'Ch':>4} {'Cap':>4} {'Cxo':>4}")
    print("  " + "-" * 75)
    for lv in LEVELS:
        lr = all_r[lv["name"]]
        row = f"  {lv['name']:<10} |"
        for pn in ["A", "B", "C"]:
            r = lr.get(pn)
            if r:
                xo = r.get("x_offset", 0)
                row += f" {r['v']:>4.0f} {r['h']:>4.1f} {r['appr']:>4.0f} {xo:>+4.1f} |"
            else:
                row += f" {'—':>4} {'—':>4} {'—':>4} {'—':>4} |"
        print(row)
    print()

    # Breakdowns
    print("SCORE BREAKDOWNS")
    print()
    for lname, pname, desc in [
        ("Moon", "A", "Easiest level"),
        ("Classic", "A", "Classic easy"),
        ("Classic", "B", "Classic mid"),
        ("Classic", "C", "Classic best (highest possible score)"),
        ("Jupiter", "A", "Hardest level"),
        ("Jupiter", "C", "Hardest combo"),
    ]:
        r = all_r.get(lname, {}).get(pname)
        if not r:
            print(f"  {lname} {pname} — {desc}: FAILED")
            print()
            continue
        p = next(pp for pp in PLATFORMS if pp["name"] == pname)
        bd = score_detail(r["v"], r["h"], 0.005, r["appr"], r["fuel"], r["x"], p)
        d = "←wrap" if r.get("go_left") else "→"
        xo = r.get("x_offset", 0)
        print(f"  {lname} {pname} — {desc}")
        print(f"    Dir: {d} | Fuel: {r['fuel']:.0f}% | x={r['x']:.0f} (offset {xo:+.1f}) | {r['frames']}f")
        print(f"    B:{bd['base']:.0f} S:{bd['soft']:.0f} H:{bd['horiz']:.0f} "
              f"C:{bd['center']:.0f} R:{bd['rot']:.0f} A:{bd['approach']:.0f} "
              f"= {bd['sub']:.0f} × {bd['fm']:.2f} × {bd['pm']:.0f}x = {bd['total']:,}")
        print()

    # Achievement reference
    print("=" * W)
    print("ACHIEVEMENT PLANNING REFERENCE")
    print("=" * W)
    print()
    print(f"  {'Scenario':<22} {'Ceiling':>8} {'Expert':>8} {'Good':>8} {'Average':>8}")
    print(f"  {'-'*22} {'-'*8} {'-'*8} {'-'*8} {'-'*8}")
    for lv in LEVELS:
        lr = all_r[lv["name"]]
        for pn in ["A", "B", "C"]:
            r = lr.get(pn)
            c = r["score"] if r else 0
            print(f"  {lv['name']+' '+pn:<22} {c:>8,} {int(c*0.7):>8,} {int(c*0.45):>8,} {int(c*0.25):>8,}")
        if lv["name"] in ("Classic", "Moon", "Jupiter"):
            print()

    # Key findings
    print()
    print("=" * W)
    print("KEY FINDINGS")
    print("=" * W)
    scores = [(ln, pn, r) for ln, lr in all_r.items() for pn, r in lr.items() if r]
    if scores:
        hi = max(scores, key=lambda x: x[2]["score"])
        lo = min(scores, key=lambda x: x[2]["score"])
        fuels = [r["fuel"] for _, _, r in scores]
        wraps = sum(1 for _, _, r in scores if r.get("go_left"))
        offcenter = sum(1 for _, _, r in scores if abs(r.get("x_offset", 0)) > 0.1)
        print(f"  Best:  {hi[0]} {hi[1]} = {hi[2]['score']:,} (fuel {hi[2]['fuel']:.0f}%)")
        print(f"  Worst: {lo[0]} {lo[1]} = {lo[2]['score']:,} (fuel {lo[2]['fuel']:.0f}%)")
        print(f"  Fuel range: {min(fuels):.0f}%–{max(fuels):.0f}%")
        print(f"  Landings using left wrap: {wraps}/33")
        print(f"  Landings off-center: {offcenter}/33")
        print(f"  Landings computed: {len(scores)}/33")
    else:
        print("  ERROR: No landings succeeded. Physics model needs review.")


if __name__ == "__main__":
    main()
