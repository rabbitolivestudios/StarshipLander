#!/usr/bin/env python3
"""
Generate 1024x1024 achievement icons for Game Center.

Each icon is a circular badge/emblem with:
- Outer metallic ring border
- Colored gradient background
- Central geometric symbol
- Achievement name on bottom banner

Usage:
    python3 Scripts/generate_achievement_icons.py
"""

import math
from PIL import Image, ImageDraw, ImageFont

SIZE = 1024
CENTER = SIZE // 2
OUTPUT_DIR = "Screenshots/achievements"


def create_base_badge(bg_color_top, bg_color_bottom, ring_color, ring_highlight):
    """Create a badge with circular gradient background and metallic ring."""
    img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Outer ring (metallic look via multiple concentric circles)
    ring_outer = 500
    ring_inner = 440
    ring_mid = (ring_outer + ring_inner) // 2

    # Dark outline
    draw.ellipse(
        [CENTER - ring_outer - 4, CENTER - ring_outer - 4,
         CENTER + ring_outer + 4, CENTER + ring_outer + 4],
        fill=(20, 20, 25, 255)
    )

    # Ring body
    draw.ellipse(
        [CENTER - ring_outer, CENTER - ring_outer,
         CENTER + ring_outer, CENTER + ring_outer],
        fill=ring_color
    )

    # Ring highlight (top half lighter)
    for i in range(ring_outer - ring_inner):
        r = ring_outer - i
        alpha = int(80 * (1 - i / (ring_outer - ring_inner)))
        y_offset = -10
        draw.ellipse(
            [CENTER - r, CENTER - r + y_offset, CENTER + r, CENTER + r + y_offset],
            outline=(*ring_highlight, alpha)
        )

    # Inner background with radial gradient approximation
    for r in range(ring_inner, 0, -1):
        t = r / ring_inner
        color = tuple(int(bg_color_top[i] * t + bg_color_bottom[i] * (1 - t)) for i in range(3))
        draw.ellipse(
            [CENTER - r, CENTER - r, CENTER + r, CENTER + r],
            fill=(*color, 255)
        )

    # Inner shadow ring
    draw.ellipse(
        [CENTER - ring_inner, CENTER - ring_inner,
         CENTER + ring_inner, CENTER + ring_inner],
        outline=(0, 0, 0, 80), width=4
    )

    return img, draw


def add_banner(draw, text, banner_color, text_color=(255, 255, 255)):
    """Add a name banner at the bottom of the badge."""
    # Banner ribbon
    banner_y = 750
    banner_h = 100
    banner_w = 600

    # Banner shape (rectangle with angled ends)
    points = [
        (CENTER - banner_w // 2 - 30, banner_y),
        (CENTER + banner_w // 2 + 30, banner_y),
        (CENTER + banner_w // 2, banner_y + banner_h),
        (CENTER - banner_w // 2, banner_y + banner_h),
    ]
    draw.polygon(points, fill=(*banner_color, 230))

    # Banner border
    draw.line(
        [(CENTER - banner_w // 2 - 30, banner_y),
         (CENTER + banner_w // 2 + 30, banner_y)],
        fill=(255, 255, 255, 100), width=3
    )
    draw.line(
        [(CENTER - banner_w // 2, banner_y + banner_h),
         (CENTER + banner_w // 2, banner_y + banner_h)],
        fill=(0, 0, 0, 100), width=3
    )

    # Text
    try:
        font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 48)
    except (OSError, IOError):
        font = ImageFont.load_default()

    bbox = draw.textbbox((0, 0), text, font=font)
    tw = bbox[2] - bbox[0]
    th = bbox[3] - bbox[1]
    draw.text(
        (CENTER - tw // 2, banner_y + (banner_h - th) // 2 - 5),
        text, fill=(*text_color, 255), font=font
    )


def add_glow(draw, cx, cy, radius, color, intensity=40):
    """Add a soft glow effect."""
    for r in range(radius, 0, -3):
        alpha = int(intensity * (r / radius) ** 2)
        draw.ellipse(
            [cx - r, cy - r, cx + r, cy + r],
            fill=(*color, alpha)
        )


def draw_star(draw, cx, cy, outer_r, inner_r, color, points=5, rotation=-90):
    """Draw a 5-pointed star."""
    coords = []
    for i in range(points * 2):
        angle = math.radians(rotation + i * 360 / (points * 2))
        r = outer_r if i % 2 == 0 else inner_r
        coords.append((cx + r * math.cos(angle), cy + r * math.sin(angle)))
    draw.polygon(coords, fill=color)


def draw_rocket(draw, cx, cy, scale=1.0, color=(220, 220, 230)):
    """Draw a simple rocket silhouette."""
    s = scale
    # Body
    body_points = [
        (cx, cy - 120 * s),          # Nose tip
        (cx - 35 * s, cy - 40 * s),  # Left shoulder
        (cx - 35 * s, cy + 80 * s),  # Left bottom
        (cx + 35 * s, cy + 80 * s),  # Right bottom
        (cx + 35 * s, cy - 40 * s),  # Right shoulder
    ]
    draw.polygon(body_points, fill=color)

    # Nose cone
    draw.pieslice(
        [cx - 35 * s, cy - 80 * s, cx + 35 * s, cy - 10 * s],
        180, 360, fill=(*color[:2], min(color[2] + 30, 255))
    )

    # Fins
    fin_color = (color[0] // 2, color[1] // 2, color[2] // 2)
    # Left fin
    left_fin = [
        (cx - 35 * s, cy + 40 * s),
        (cx - 70 * s, cy + 100 * s),
        (cx - 35 * s, cy + 80 * s),
    ]
    draw.polygon(left_fin, fill=fin_color)
    # Right fin
    right_fin = [
        (cx + 35 * s, cy + 40 * s),
        (cx + 70 * s, cy + 100 * s),
        (cx + 35 * s, cy + 80 * s),
    ]
    draw.polygon(right_fin, fill=fin_color)

    # Engine nozzle
    draw.rectangle(
        [cx - 15 * s, cy + 80 * s, cx + 15 * s, cy + 95 * s],
        fill=(100, 100, 110)
    )

    # Window
    draw.ellipse(
        [cx - 12 * s, cy - 35 * s, cx + 12 * s, cy - 10 * s],
        fill=(100, 180, 255)
    )


def draw_flame(draw, cx, cy, scale=1.0, color=(255, 150, 30)):
    """Draw engine flame below rocket."""
    s = scale
    # Outer flame
    flame_points = [
        (cx - 18 * s, cy),
        (cx, cy + 70 * s),
        (cx + 18 * s, cy),
    ]
    draw.polygon(flame_points, fill=color)
    # Inner flame (brighter)
    inner_points = [
        (cx - 10 * s, cy),
        (cx, cy + 45 * s),
        (cx + 10 * s, cy),
    ]
    draw.polygon(inner_points, fill=(255, 255, 100))


def draw_checkmark(draw, cx, cy, size, color=(255, 255, 255), width=20):
    """Draw a checkmark."""
    draw.line(
        [(cx - size * 0.5, cy), (cx - size * 0.1, cy + size * 0.4)],
        fill=color, width=width
    )
    draw.line(
        [(cx - size * 0.1, cy + size * 0.4), (cx + size * 0.5, cy - size * 0.35)],
        fill=color, width=width
    )


def draw_crosshair(draw, cx, cy, radius, color=(255, 255, 255), width=8):
    """Draw a crosshair/target."""
    # Outer circle
    draw.ellipse(
        [cx - radius, cy - radius, cx + radius, cy + radius],
        outline=color, width=width
    )
    # Inner circle
    draw.ellipse(
        [cx - radius * 0.5, cy - radius * 0.5, cx + radius * 0.5, cy + radius * 0.5],
        outline=color, width=width - 2
    )
    # Center dot
    draw.ellipse(
        [cx - 10, cy - 10, cx + 10, cy + 10],
        fill=color
    )
    # Cross lines (with gaps for inner circle)
    gap = int(radius * 0.55)
    draw.line([(cx - radius - 20, cy), (cx - gap, cy)], fill=color, width=width - 2)
    draw.line([(cx + gap, cy), (cx + radius + 20, cy)], fill=color, width=width - 2)
    draw.line([(cx, cy - radius - 20), (cx, cy - gap)], fill=color, width=width - 2)
    draw.line([(cx, cy + gap), (cx, cy + radius + 20)], fill=color, width=width - 2)


def draw_droplet(draw, cx, cy, scale=1.0, color=(100, 200, 255)):
    """Draw a fuel droplet."""
    s = scale
    # Droplet body (circle + triangle top)
    r = 70 * s
    draw.ellipse([cx - r, cy - r * 0.3, cx + r, cy + r * 1.3], fill=color)
    # Pointy top
    draw.polygon([
        (cx, cy - r * 1.5),
        (cx - r * 0.6, cy),
        (cx + r * 0.6, cy),
    ], fill=color)
    # Highlight
    hr = r * 0.4
    draw.ellipse(
        [cx - hr - 15 * s, cy - hr + 10 * s, cx - hr + 15 * s, cy + hr - 20 * s],
        fill=(min(color[0] + 80, 255), min(color[1] + 80, 255), min(color[2] + 80, 255))
    )


def draw_crown(draw, cx, cy, scale=1.0, color=(255, 215, 0)):
    """Draw a crown."""
    s = scale
    w = 140 * s
    h = 100 * s
    # Base
    draw.rectangle(
        [cx - w, cy + h * 0.2, cx + w, cy + h * 0.6],
        fill=color
    )
    # Points
    points = [
        (cx - w, cy + h * 0.2),
        (cx - w, cy - h * 0.4),           # Left peak
        (cx - w * 0.5, cy),               # Left valley
        (cx, cy - h * 0.7),               # Center peak
        (cx + w * 0.5, cy),               # Right valley
        (cx + w, cy - h * 0.4),           # Right peak
        (cx + w, cy + h * 0.2),
    ]
    draw.polygon(points, fill=color)
    # Darker outline
    darker = (color[0] - 50, color[1] - 50, 0)
    draw.line(points + [points[0]], fill=darker, width=6)
    # Jewels
    jewel_r = 14 * s
    draw.ellipse([cx - jewel_r, cy - h * 0.25 - jewel_r, cx + jewel_r, cy - h * 0.25 + jewel_r], fill=(255, 50, 50))
    draw.ellipse([cx - w * 0.65 - jewel_r, cy - jewel_r, cx - w * 0.65 + jewel_r, cy + jewel_r], fill=(50, 150, 255))
    draw.ellipse([cx + w * 0.65 - jewel_r, cy - jewel_r, cx + w * 0.65 + jewel_r, cy + jewel_r], fill=(50, 255, 50))


def draw_planet(draw, cx, cy, radius, color, ring=False, ring_color=None):
    """Draw a simple planet."""
    draw.ellipse(
        [cx - radius, cy - radius, cx + radius, cy + radius],
        fill=color
    )
    # Slight highlight
    hr = radius * 0.7
    draw.ellipse(
        [cx - hr - radius * 0.2, cy - hr - radius * 0.2,
         cx - hr + radius * 0.5, cy - hr + radius * 0.5],
        fill=(min(color[0] + 40, 255), min(color[1] + 40, 255), min(color[2] + 40, 255), 100)
    )
    if ring and ring_color:
        # Draw a ring (ellipse around planet)
        draw.ellipse(
            [cx - radius * 1.8, cy - radius * 0.3,
             cx + radius * 1.8, cy + radius * 0.3],
            outline=ring_color, width=8
        )


# ── Achievement Generators ──────────────────────────────────────────────

def gen_eagle_has_landed():
    """#1 - The Eagle Has Landed (any SAFE landing) - Green"""
    img, draw = create_base_badge((40, 160, 60), (10, 60, 20), (60, 140, 70), (120, 220, 130))
    draw_rocket(draw, CENTER, CENTER - 60, scale=1.6, color=(220, 225, 235))
    draw_flame(draw, CENTER, CENTER + 68, scale=1.6, color=(255, 180, 50))
    draw_checkmark(draw, CENTER + 140, CENTER + 110, 90, color=(255, 255, 255), width=26)
    add_banner(draw, "EAGLE HAS LANDED", (30, 100, 40))
    return img


def gen_precision_landing():
    """#2 - Precision Landing (SAFE on B) - Yellow/Gold"""
    img, draw = create_base_badge((200, 170, 30), (100, 75, 5), (200, 180, 50), (255, 240, 100))
    draw_crosshair(draw, CENTER, CENTER - 30, 160, color=(255, 255, 255), width=12)
    # "B" label
    try:
        font_big = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 100)
    except (OSError, IOError):
        font_big = ImageFont.load_default()
    bbox = draw.textbbox((0, 0), "B", font=font_big)
    tw = bbox[2] - bbox[0]
    draw.text((CENTER - tw // 2, CENTER + 120), "B", fill=(255, 255, 255, 255), font=font_big)
    add_banner(draw, "PRECISION LANDING", (140, 110, 10))
    return img


def gen_elite_landing():
    """#3 - Elite Landing (SAFE on C) - Red/Crimson"""
    img, draw = create_base_badge((180, 30, 30), (70, 5, 10), (170, 40, 40), (240, 100, 100))
    # Big star
    draw_star(draw, CENTER, CENTER - 50, 150, 65, (255, 255, 255))
    # "C" in the star
    try:
        font_big = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 100)
    except (OSError, IOError):
        font_big = ImageFont.load_default()
    bbox = draw.textbbox((0, 0), "C", font=font_big)
    tw, th = bbox[2] - bbox[0], bbox[3] - bbox[1]
    draw.text((CENTER - tw // 2, CENTER - 50 - th // 2 - 10), "C", fill=(160, 15, 15, 255), font=font_big)
    add_banner(draw, "ELITE LANDING", (120, 20, 20))
    return img


def gen_fuel_master():
    """#4 - Fuel Master (≥65% fuel) - Blue/Cyan"""
    img, draw = create_base_badge((30, 100, 200), (10, 30, 80), (40, 120, 200), (100, 180, 255))
    draw_droplet(draw, CENTER, CENTER - 30, scale=2.0, color=(100, 210, 255))
    # "65%" text
    try:
        font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 65)
    except (OSError, IOError):
        font = ImageFont.load_default()
    text = "65%"
    bbox = draw.textbbox((0, 0), text, font=font)
    tw = bbox[2] - bbox[0]
    draw.text((CENTER - tw // 2, CENTER + 130), text, fill=(255, 255, 255, 255), font=font)
    add_banner(draw, "FUEL MASTER", (20, 60, 130))
    return img


def gen_precision_pilot():
    """#5 - Precision Pilot (SAFE C + ≤2° tilt, campaign) - Purple"""
    img, draw = create_base_badge((130, 40, 180), (45, 10, 80), (140, 50, 180), (200, 120, 255))
    # Perfectly straight rocket (emphasizing zero tilt)
    draw_rocket(draw, CENTER, CENTER - 50, scale=1.6, color=(230, 220, 245))
    draw_flame(draw, CENTER, CENTER + 78, scale=1.6, color=(200, 100, 255))
    # Level line showing 0° tilt
    draw.line([(CENTER - 200, CENTER + 170), (CENTER + 200, CENTER + 170)],
              fill=(255, 255, 255), width=6)
    # Small ticks on level line
    for tx in range(-200, 201, 50):
        draw.line([(CENTER + tx, CENTER + 165), (CENTER + tx, CENTER + 175)],
                  fill=(255, 255, 255, 180), width=3)
    # Angle indicator "≤2°"
    try:
        font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 55)
    except (OSError, IOError):
        font = ImageFont.load_default()
    draw.text((CENTER + 100, CENTER + 95), "≤2°", fill=(255, 255, 255, 255), font=font)
    add_banner(draw, "PRECISION PILOT", (80, 25, 120))
    return img


def gen_triple_elite():
    """#6 - Triple Elite (SAFE C on 3+ planets) - Orange/Amber"""
    img, draw = create_base_badge((220, 130, 20), (110, 50, 0), (210, 140, 30), (255, 200, 80))
    # Three large stars in a row
    star_y = CENTER - 50
    draw_star(draw, CENTER - 160, star_y + 10, 90, 38, (255, 255, 255))
    draw_star(draw, CENTER, star_y - 30, 110, 47, (255, 255, 255))
    draw_star(draw, CENTER + 160, star_y + 10, 90, 38, (255, 255, 255))
    # "3×" text
    try:
        font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 80)
    except (OSError, IOError):
        font = ImageFont.load_default()
    bbox = draw.textbbox((0, 0), "3×", font=font)
    tw = bbox[2] - bbox[0]
    draw.text((CENTER - tw // 2, CENTER + 100), "3×", fill=(255, 255, 255, 255), font=font)
    add_banner(draw, "TRIPLE ELITE", (160, 80, 10))
    return img


def gen_planet_conquered():
    """#7 - Planet Conquered (3 stars on any level) - Teal"""
    img, draw = create_base_badge((20, 150, 150), (10, 70, 80), (30, 160, 150), (80, 220, 210))
    add_glow(draw, CENTER, CENTER + 20, 180, (40, 200, 200), 25)
    # Planet
    draw_planet(draw, CENTER, CENTER + 10, 100, (60, 180, 170))
    # Three stars above
    star_y = CENTER - 140
    draw_star(draw, CENTER - 110, star_y + 20, 50, 22, (255, 255, 200))
    draw_star(draw, CENTER, star_y - 10, 60, 26, (255, 255, 220))
    draw_star(draw, CENTER + 110, star_y + 20, 50, 22, (255, 255, 200))
    add_banner(draw, "PLANET CONQUERED", (15, 100, 100))
    return img


def gen_first_try_perfection():
    """#8 - First Try Perfection (SAFE C first attempt) - Silver/White"""
    img, draw = create_base_badge((120, 125, 140), (50, 55, 65), (160, 165, 175), (220, 225, 235))
    # Large "1st" in white with dark shadow for contrast
    try:
        font_big = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 200)
        font_sm = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 90)
    except (OSError, IOError):
        font_big = ImageFont.load_default()
        font_sm = font_big
    # "1" centered — dark shadow first, then white
    bbox = draw.textbbox((0, 0), "1", font=font_big)
    tw, th = bbox[2] - bbox[0], bbox[3] - bbox[1]
    x1 = CENTER - tw // 2 - 25
    y1 = CENTER - th // 2 - 60
    # Shadow
    draw.text((x1 + 4, y1 + 4), "1", fill=(30, 30, 40, 150), font=font_big)
    draw.text((x1, y1), "1", fill=(255, 255, 255, 255), font=font_big)
    # "st" superscript
    draw.text((CENTER + tw // 2 - 20 + 4, CENTER - 120 + 4), "st", fill=(30, 30, 40, 150), font=font_sm)
    draw.text((CENTER + tw // 2 - 20, CENTER - 120), "st", fill=(255, 255, 255, 255), font=font_sm)
    # Sparkles around
    sparkle_positions = [(CENTER - 200, CENTER - 140), (CENTER + 200, CENTER - 80),
                         (CENTER - 160, CENTER + 120), (CENTER + 180, CENTER + 140)]
    for sx, sy in sparkle_positions:
        draw_star(draw, sx, sy, 30, 12, (255, 255, 255))
    add_banner(draw, "FIRST TRY PERFECTION", (80, 82, 90))
    return img


def gen_solar_system_elite():
    """#9 - Solar System Elite (30 total stars) - Deep Blue/Indigo"""
    img, draw = create_base_badge((30, 30, 140), (10, 10, 60), (40, 40, 160), (100, 100, 230))
    # 10 planets in orbit ring
    orbit_r = 210
    orbit_cy = CENTER - 20
    planet_colors = [
        (180, 180, 190),  # Moon
        (200, 100, 60),   # Mars
        (220, 180, 100),  # Titan
        (160, 200, 220),  # Europa
        (60, 130, 200),   # Earth
        (230, 180, 100),  # Venus
        (170, 130, 110),  # Mercury
        (140, 140, 160),  # Ganymede
        (230, 200, 80),   # Io
        (210, 160, 120),  # Jupiter
    ]
    # Orbit path
    draw.ellipse(
        [CENTER - orbit_r, orbit_cy - orbit_r, CENTER + orbit_r, orbit_cy + orbit_r],
        outline=(120, 120, 220, 100), width=3
    )
    for i, color in enumerate(planet_colors):
        angle = math.radians(i * 36 - 90)
        px = CENTER + orbit_r * math.cos(angle)
        py = orbit_cy + orbit_r * math.sin(angle)
        pr = 24
        draw.ellipse([px - pr, py - pr, px + pr, py + pr], fill=color)
    # 3 stars in the center of the ring
    star_y = orbit_cy - 30
    draw_star(draw, CENTER - 80, star_y + 10, 45, 19, (255, 255, 200))
    draw_star(draw, CENTER, star_y - 15, 55, 23, (255, 255, 220))
    draw_star(draw, CENTER + 80, star_y + 10, 45, 19, (255, 255, 200))
    # "30" text below stars, still inside the ring
    try:
        font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 70)
    except (OSError, IOError):
        font = ImageFont.load_default()
    text = "30"
    bbox = draw.textbbox((0, 0), text, font=font)
    tw = bbox[2] - bbox[0]
    draw.text((CENTER - tw // 2, orbit_cy + 30), text, fill=(255, 255, 220, 255), font=font)
    add_banner(draw, "SOLAR SYSTEM ELITE", (20, 20, 100))
    return img


def gen_master_lander():
    """#10 - Master Lander (SAFE C on all 10) - Gold"""
    img, draw = create_base_badge((200, 170, 40), (120, 90, 10), (210, 180, 50), (255, 240, 120))
    add_glow(draw, CENTER, CENTER - 40, 220, (255, 215, 0), 30)
    # Crown
    draw_crown(draw, CENTER, CENTER - 60, scale=1.4, color=(255, 220, 50))
    # "10/10" text below crown
    try:
        font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 70)
    except (OSError, IOError):
        font = ImageFont.load_default()
    text = "10/10"
    bbox = draw.textbbox((0, 0), text, font=font)
    tw = bbox[2] - bbox[0]
    draw.text((CENTER - tw // 2, CENTER + 80), text, fill=(255, 240, 200, 255), font=font)
    add_banner(draw, "MASTER LANDER", (140, 110, 10))
    return img


# ── Main ─────────────────────────────────────────────────────────────────

ACHIEVEMENTS = [
    ("eagle_has_landed", gen_eagle_has_landed),
    ("precision_landing", gen_precision_landing),
    ("elite_landing", gen_elite_landing),
    ("fuel_master", gen_fuel_master),
    ("precision_pilot", gen_precision_pilot),
    ("triple_elite", gen_triple_elite),
    ("planet_conquered", gen_planet_conquered),
    ("first_try_perfection", gen_first_try_perfection),
    ("solar_system_elite", gen_solar_system_elite),
    ("master_lander", gen_master_lander),
]


def main():
    import os
    os.makedirs(OUTPUT_DIR, exist_ok=True)

    for ref, generator in ACHIEVEMENTS:
        print(f"Generating {ref}...", end=" ")
        img = generator()
        path = os.path.join(OUTPUT_DIR, f"{ref}.png")
        img.save(path, "PNG")
        print(f"saved to {path}")

    print(f"\nDone — {len(ACHIEVEMENTS)} achievement icons generated in {OUTPUT_DIR}/")


if __name__ == "__main__":
    main()
