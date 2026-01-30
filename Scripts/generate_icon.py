#!/usr/bin/env python3
"""
App Icon Generator for Starship Lander
Generates a 1024x1024 app icon featuring a SpaceX Starship design
"""

import sys
import math
import random

try:
    from PIL import Image, ImageDraw
except ImportError:
    print("Installing Pillow...")
    import subprocess
    subprocess.check_call([sys.executable, "-m", "pip", "install", "Pillow", "-q"])
    from PIL import Image, ImageDraw


def draw_rounded_rect(draw, coords, radius, fill, outline=None, width=1):
    """Draw a rounded rectangle"""
    x1, y1, x2, y2 = coords
    draw.rounded_rectangle(coords, radius=radius, fill=fill, outline=outline, width=width)


def create_starship_icon(size=1024):
    """Create a Starship Lander app icon"""

    img = Image.new('RGB', (size, size), (0, 0, 0))
    draw = ImageDraw.Draw(img)

    # === BACKGROUND: Space gradient ===
    for y in range(size):
        ratio = y / size
        r = int(5 + 15 * ratio)
        g = int(5 + 15 * ratio)
        b = int(20 + 40 * ratio)
        draw.line([(0, y), (size, y)], fill=(r, g, b))

    # === STARS ===
    random.seed(42)
    for _ in range(80):
        x = random.randint(0, size)
        y = random.randint(0, int(size * 0.7))
        brightness = random.randint(150, 255)
        star_size = random.randint(1, 3)
        draw.ellipse([x-star_size, y-star_size, x+star_size, y+star_size],
                     fill=(brightness, brightness, brightness))

    # === EARTH in background (top right) ===
    earth_radius = int(size * 0.12)
    earth_x = int(size * 0.82)
    earth_y = int(size * 0.15)
    # Earth base (blue)
    draw.ellipse([earth_x - earth_radius, earth_y - earth_radius,
                  earth_x + earth_radius, earth_y + earth_radius],
                 fill=(50, 100, 180))
    # Add some green landmass hints
    draw.ellipse([earth_x - earth_radius//2, earth_y - earth_radius//3,
                  earth_x + earth_radius//4, earth_y + earth_radius//3],
                 fill=(60, 140, 80))

    # === LANDING PLATFORM ===
    platform_width = int(size * 0.35)
    platform_height = int(size * 0.025)
    platform_x = (size - platform_width) // 2
    platform_y = int(size * 0.88)

    # Platform base
    draw.rectangle([platform_x, platform_y, platform_x + platform_width, platform_y + platform_height],
                   fill=(60, 60, 65), outline=(80, 80, 85), width=2)

    # Landing markings (X pattern)
    marking_color = (255, 180, 0)
    center_x = size // 2
    mark_size = int(platform_width * 0.15)
    draw.line([center_x - mark_size, platform_y + platform_height//2,
               center_x + mark_size, platform_y + platform_height//2], fill=marking_color, width=3)

    # Platform legs/supports
    support_width = int(size * 0.02)
    support_height = int(size * 0.03)
    for offset in [-0.35, 0.35]:
        sx = int(center_x + offset * platform_width)
        draw.rectangle([sx - support_width//2, platform_y + platform_height,
                       sx + support_width//2, platform_y + platform_height + support_height],
                      fill=(50, 50, 55))

    # === STARSHIP ===
    ship_center_x = size // 2
    ship_center_y = int(size * 0.48)
    scale = size / 1024

    # Ship dimensions
    body_width = int(100 * scale)
    body_height = int(280 * scale)
    dome_height = int(50 * scale)

    # Ship colors
    body_color = (225, 225, 230)  # Silver
    body_highlight = (240, 240, 245)
    body_shadow = (180, 180, 185)
    flap_color = (55, 55, 60)  # Dark gray
    engine_color = (40, 40, 45)

    # === FLAME (behind ship) ===
    flame_width = int(70 * scale)
    flame_height = int(120 * scale)
    flame_top_y = ship_center_y + body_height // 2 + int(10 * scale)

    # Outer flame (orange-red)
    for i in range(3):
        offset = i * int(8 * scale)
        alpha = 1.0 - (i * 0.25)
        flame_points = [
            (ship_center_x - flame_width//2 - offset, flame_top_y),
            (ship_center_x, flame_top_y + flame_height + offset),
            (ship_center_x + flame_width//2 + offset, flame_top_y),
        ]
        color = (int(255 * alpha), int(100 * alpha), int(20 * alpha))
        draw.polygon(flame_points, fill=color)

    # Inner flame (yellow-white)
    inner_flame_points = [
        (ship_center_x - flame_width//4, flame_top_y),
        (ship_center_x, flame_top_y + flame_height * 0.6),
        (ship_center_x + flame_width//4, flame_top_y),
    ]
    draw.polygon(inner_flame_points, fill=(255, 240, 150))

    # Core flame (white)
    core_flame_points = [
        (ship_center_x - flame_width//8, flame_top_y),
        (ship_center_x, flame_top_y + flame_height * 0.35),
        (ship_center_x + flame_width//8, flame_top_y),
    ]
    draw.polygon(core_flame_points, fill=(255, 255, 220))

    # === LANDING LEGS ===
    leg_width = int(12 * scale)
    leg_length = int(80 * scale)
    leg_angle = 25
    leg_start_y = ship_center_y + body_height // 2 - int(20 * scale)

    for side in [-1, 1]:
        leg_start_x = ship_center_x + side * (body_width // 2 - int(5 * scale))
        leg_end_x = leg_start_x + side * int(leg_length * math.sin(math.radians(leg_angle)))
        leg_end_y = leg_start_y + int(leg_length * math.cos(math.radians(leg_angle)))

        # Leg
        draw.line([leg_start_x, leg_start_y, leg_end_x, leg_end_y],
                  fill=(90, 90, 95), width=leg_width)

        # Foot pad
        foot_size = int(15 * scale)
        draw.ellipse([leg_end_x - foot_size, leg_end_y - foot_size//2,
                     leg_end_x + foot_size, leg_end_y + foot_size//2],
                    fill=(70, 70, 75))

    # === AFT FLAPS (behind body, lower) ===
    aft_flap_width = int(55 * scale)
    aft_flap_height = int(70 * scale)
    aft_flap_y = ship_center_y + body_height // 2 - aft_flap_height - int(10 * scale)

    for side in [-1, 1]:
        flap_x = ship_center_x + side * (body_width // 2 + int(5 * scale))

        # Aft flap shape (angled parallelogram)
        if side == -1:
            points = [
                (flap_x, aft_flap_y),
                (flap_x - aft_flap_width, aft_flap_y + int(15 * scale)),
                (flap_x - aft_flap_width, aft_flap_y + aft_flap_height),
                (flap_x, aft_flap_y + aft_flap_height - int(10 * scale)),
            ]
        else:
            points = [
                (flap_x, aft_flap_y),
                (flap_x + aft_flap_width, aft_flap_y + int(15 * scale)),
                (flap_x + aft_flap_width, aft_flap_y + aft_flap_height),
                (flap_x, aft_flap_y + aft_flap_height - int(10 * scale)),
            ]
        draw.polygon(points, fill=flap_color, outline=(70, 70, 75))

    # === MAIN BODY (cylindrical with dome) ===
    body_top = ship_center_y - body_height // 2
    body_bottom = ship_center_y + body_height // 2
    body_left = ship_center_x - body_width // 2
    body_right = ship_center_x + body_width // 2

    # Main cylindrical body
    draw.rectangle([body_left, body_top + dome_height, body_right, body_bottom],
                   fill=body_color)

    # Body highlight (left side gradient effect)
    highlight_width = body_width // 4
    draw.rectangle([body_left, body_top + dome_height, body_left + highlight_width, body_bottom],
                   fill=body_highlight)

    # Body shadow (right side)
    draw.rectangle([body_right - highlight_width, body_top + dome_height, body_right, body_bottom],
                   fill=body_shadow)

    # Dome nose cone
    draw.ellipse([body_left, body_top, body_right, body_top + dome_height * 2],
                 fill=body_color)
    draw.ellipse([body_left, body_top, body_left + highlight_width * 2, body_top + dome_height * 2],
                 fill=body_highlight)

    # === FORWARD FLAPS (on body, upper) ===
    fwd_flap_width = int(45 * scale)
    fwd_flap_height = int(50 * scale)
    fwd_flap_y = body_top + dome_height + int(40 * scale)

    for side in [-1, 1]:
        flap_x = ship_center_x + side * (body_width // 2)

        if side == -1:
            points = [
                (flap_x, fwd_flap_y),
                (flap_x - fwd_flap_width, fwd_flap_y + int(10 * scale)),
                (flap_x - fwd_flap_width, fwd_flap_y + fwd_flap_height),
                (flap_x, fwd_flap_y + fwd_flap_height - int(5 * scale)),
            ]
        else:
            points = [
                (flap_x, fwd_flap_y),
                (flap_x + fwd_flap_width, fwd_flap_y + int(10 * scale)),
                (flap_x + fwd_flap_width, fwd_flap_y + fwd_flap_height),
                (flap_x, fwd_flap_y + fwd_flap_height - int(5 * scale)),
            ]
        draw.polygon(points, fill=flap_color, outline=(70, 70, 75))

    # === ENGINE SECTION ===
    engine_height = int(25 * scale)
    engine_y = body_bottom - engine_height
    draw.rectangle([body_left - int(5 * scale), engine_y,
                   body_right + int(5 * scale), body_bottom + int(5 * scale)],
                  fill=engine_color)

    # Engine nozzles (3)
    nozzle_width = int(18 * scale)
    nozzle_height = int(15 * scale)
    nozzle_y = body_bottom

    for offset in [-1, 0, 1]:
        nx = ship_center_x + offset * int(25 * scale)
        # Nozzle bell shape
        draw.polygon([
            (nx - nozzle_width//2, nozzle_y),
            (nx - nozzle_width//2 - int(5*scale), nozzle_y + nozzle_height),
            (nx + nozzle_width//2 + int(5*scale), nozzle_y + nozzle_height),
            (nx + nozzle_width//2, nozzle_y),
        ], fill=(30, 30, 35), outline=(50, 50, 55))

    # === BODY DETAILS ===
    # Grid fin hints / panel lines
    line_color = (200, 200, 205)
    for i in range(1, 4):
        y = body_top + dome_height + i * (body_height - dome_height) // 4
        draw.line([body_left + int(10*scale), y, body_right - int(10*scale), y],
                  fill=line_color, width=1)

    # SpaceX-style black band near top
    band_y = body_top + dome_height + int(20 * scale)
    band_height = int(15 * scale)
    draw.rectangle([body_left, band_y, body_right, band_y + band_height],
                   fill=(30, 30, 35))

    return img


def main():
    output_path = "../RocketLander/Assets.xcassets/AppIcon.appiconset/icon-1024.png"

    print("Generating Starship Lander app icon...")
    icon = create_starship_icon(1024)
    icon.save(output_path, "PNG")
    print(f"Icon saved to: {output_path}")
    print("Done!")


if __name__ == "__main__":
    main()
