#!/usr/bin/env python3
"""
App Store Screenshot Generator for Starship Lander
Generates 3 screenshots at 1260x2736 pixels (iPhone 6.5")
"""

import sys
import math
import random

try:
    from PIL import Image, ImageDraw, ImageFont
except ImportError:
    print("Installing Pillow...")
    import subprocess
    subprocess.check_call([sys.executable, "-m", "pip", "install", "Pillow", "-q"])
    from PIL import Image, ImageDraw, ImageFont

# Screenshot dimensions (iPhone 6.5")
WIDTH = 1260
HEIGHT = 2736

# Colors
BLACK = (0, 0, 0)
WHITE = (255, 255, 255)
ORANGE = (255, 165, 0)
RED = (255, 70, 70)
GREEN = (100, 255, 100)
YELLOW = (255, 220, 50)
GRAY = (128, 128, 128)
DARK_GRAY = (40, 40, 45)
SILVER = (225, 225, 230)
LIGHT_GRAY = (200, 200, 200)


def draw_space_background(draw, width, height):
    """Draw space gradient background with stars"""
    for y in range(height):
        ratio = y / height
        r = int(5 + 20 * ratio)
        g = int(5 + 20 * ratio)
        b = int(20 + 50 * ratio)
        draw.line([(0, y), (width, y)], fill=(r, g, b))

    # Stars
    random.seed(42)
    for _ in range(150):
        x = random.randint(0, width)
        y = random.randint(0, int(height * 0.85))
        brightness = random.randint(150, 255)
        size = random.randint(2, 5)
        draw.ellipse([x-size, y-size, x+size, y+size], fill=(brightness, brightness, brightness))


def draw_starship(draw, center_x, center_y, scale=1.0, show_flame=True, rotation=0):
    """Draw the Starship rocket"""
    s = scale

    # Dimensions
    body_width = int(80 * s)
    body_height = int(220 * s)
    dome_height = int(40 * s)

    body_color = SILVER
    flap_color = DARK_GRAY

    # Flame (if showing)
    if show_flame:
        flame_width = int(60 * s)
        flame_height = int(120 * s)
        flame_top = center_y + body_height // 2

        # Outer flame
        draw.polygon([
            (center_x - flame_width//2, flame_top),
            (center_x, flame_top + flame_height),
            (center_x + flame_width//2, flame_top),
        ], fill=(255, 100, 20))

        # Inner flame
        draw.polygon([
            (center_x - flame_width//4, flame_top),
            (center_x, flame_top + flame_height * 0.6),
            (center_x + flame_width//4, flame_top),
        ], fill=(255, 220, 100))

    # Landing legs
    leg_length = int(70 * s)
    leg_start_y = center_y + body_height // 2 - int(15 * s)
    for side in [-1, 1]:
        leg_start_x = center_x + side * (body_width // 2 - int(5 * s))
        leg_end_x = leg_start_x + side * int(leg_length * 0.4)
        leg_end_y = leg_start_y + int(leg_length * 0.9)
        draw.line([leg_start_x, leg_start_y, leg_end_x, leg_end_y], fill=(90, 90, 95), width=int(10 * s))
        # Foot
        draw.ellipse([leg_end_x - int(12*s), leg_end_y - int(6*s),
                     leg_end_x + int(12*s), leg_end_y + int(6*s)], fill=(70, 70, 75))

    # Aft flaps
    flap_w = int(45 * s)
    flap_h = int(60 * s)
    flap_y = center_y + body_height // 2 - flap_h - int(8 * s)
    for side in [-1, 1]:
        fx = center_x + side * (body_width // 2 + int(3 * s))
        if side == -1:
            points = [(fx, flap_y), (fx - flap_w, flap_y + int(12*s)),
                     (fx - flap_w, flap_y + flap_h), (fx, flap_y + flap_h - int(8*s))]
        else:
            points = [(fx, flap_y), (fx + flap_w, flap_y + int(12*s)),
                     (fx + flap_w, flap_y + flap_h), (fx, flap_y + flap_h - int(8*s))]
        draw.polygon(points, fill=flap_color)

    # Main body
    body_top = center_y - body_height // 2
    body_bottom = center_y + body_height // 2
    body_left = center_x - body_width // 2
    body_right = center_x + body_width // 2

    draw.rectangle([body_left, body_top + dome_height, body_right, body_bottom], fill=body_color)

    # Dome
    draw.ellipse([body_left, body_top, body_right, body_top + dome_height * 2], fill=body_color)

    # Forward flaps
    fwd_flap_w = int(38 * s)
    fwd_flap_h = int(45 * s)
    fwd_flap_y = body_top + dome_height + int(30 * s)
    for side in [-1, 1]:
        fx = center_x + side * (body_width // 2)
        if side == -1:
            points = [(fx, fwd_flap_y), (fx - fwd_flap_w, fwd_flap_y + int(8*s)),
                     (fx - fwd_flap_w, fwd_flap_y + fwd_flap_h), (fx, fwd_flap_y + fwd_flap_h - int(4*s))]
        else:
            points = [(fx, fwd_flap_y), (fx + fwd_flap_w, fwd_flap_y + int(8*s)),
                     (fx + fwd_flap_w, fwd_flap_y + fwd_flap_h), (fx, fwd_flap_y + fwd_flap_h - int(4*s))]
        draw.polygon(points, fill=flap_color)

    # Engine section
    engine_h = int(20 * s)
    draw.rectangle([body_left - int(4*s), body_bottom - engine_h,
                   body_right + int(4*s), body_bottom + int(4*s)], fill=(40, 40, 45))

    # Engine nozzles
    for offset in [-1, 0, 1]:
        nx = center_x + offset * int(20 * s)
        draw.polygon([
            (nx - int(14*s), body_bottom),
            (nx - int(18*s), body_bottom + int(12*s)),
            (nx + int(18*s), body_bottom + int(12*s)),
            (nx + int(14*s), body_bottom),
        ], fill=(30, 30, 35))

    # Black band
    band_y = body_top + dome_height + int(15 * s)
    draw.rectangle([body_left, band_y, body_right, band_y + int(12*s)], fill=(30, 30, 35))


def draw_terrain(draw, width, height):
    """Draw ground terrain"""
    ground_y = int(height * 0.88)

    # Rough terrain
    random.seed(123)
    points = [(0, height)]
    x = 0
    while x < width:
        y = ground_y + random.randint(-20, 40)
        points.append((x, y))
        x += random.randint(30, 80)
    points.append((width, ground_y + random.randint(-20, 40)))
    points.append((width, height))

    draw.polygon(points, fill=(60, 60, 65))


def draw_platform(draw, center_x, y, width_px=200):
    """Draw landing platform"""
    h = 25
    draw.rectangle([center_x - width_px//2, y, center_x + width_px//2, y + h],
                  fill=(70, 70, 75), outline=(100, 100, 105), width=3)
    # Markings
    draw.line([center_x - 30, y + h//2, center_x + 30, y + h//2], fill=ORANGE, width=4)
    # Supports
    for offset in [-0.35, 0.35]:
        sx = int(center_x + offset * width_px)
        draw.rectangle([sx - 12, y + h, sx + 12, y + h + 40], fill=(50, 50, 55))


def draw_moon(draw, x, y, radius):
    """Draw moon in background"""
    draw.ellipse([x - radius, y - radius, x + radius, y + radius], fill=(220, 220, 210))
    # Craters
    craters = [(0.3, 0.2, 0.15), (-0.2, 0.3, 0.1), (0.1, -0.2, 0.12), (-0.3, -0.1, 0.08)]
    for cx, cy, cr in craters:
        cx = x + int(cx * radius)
        cy = y + int(cy * radius)
        cr = int(cr * radius)
        draw.ellipse([cx - cr, cy - cr, cx + cr, cy + cr], fill=(180, 180, 170))


def draw_hud(draw, x, y, vert_vel, horiz_vel, fuel, scale=1.0):
    """Draw velocity HUD"""
    s = scale
    w = int(150 * s)
    h = int(200 * s)

    # Background
    draw.rounded_rectangle([x, y, x + w, y + h], radius=int(15*s), fill=(0, 0, 0, 200), outline=(80, 80, 80))

    # Vertical velocity
    vert_color = GREEN if vert_vel <= 50 else (YELLOW if vert_vel <= 80 else RED)
    draw.text((x + int(15*s), y + int(15*s)), "VERT", fill=GRAY, font=None)
    draw.text((x + int(15*s), y + int(35*s)), str(int(vert_vel)), fill=vert_color, font=None)

    # Horizontal velocity
    horiz_color = GREEN if horiz_vel <= 30 else (YELLOW if horiz_vel <= 50 else RED)
    draw.text((x + int(15*s), y + int(75*s)), "HORIZ", fill=GRAY, font=None)
    draw.text((x + int(15*s), y + int(95*s)), str(int(horiz_vel)), fill=horiz_color, font=None)

    # Safe thresholds
    draw.text((x + int(15*s), y + int(140*s)), "SAFE:", fill=GRAY, font=None)
    draw.text((x + int(15*s), y + int(160*s)), "V<50 H<30", fill=(100, 200, 100), font=None)


def draw_fuel_gauge(draw, x, y, fuel_pct, scale=1.0):
    """Draw fuel gauge"""
    s = scale
    w = int(120 * s)
    h = int(12 * s)

    fuel_color = GREEN if fuel_pct > 50 else (YELLOW if fuel_pct > 20 else RED)

    draw.text((x, y - int(25*s)), f"{int(fuel_pct)}%", fill=fuel_color, font=None)
    draw.rectangle([x, y, x + w, y + h], fill=(60, 60, 60))
    draw.rectangle([x, y, x + int(w * fuel_pct / 100), y + h], fill=fuel_color)


def draw_button(draw, x, y, w, h, text, color, text_color=WHITE):
    """Draw a control button"""
    draw.rounded_rectangle([x, y, x + w, y + h], radius=15, fill=color, outline=(255, 255, 255, 100))
    # Center text roughly
    draw.text((x + w//2 - len(text)*4, y + h//2 - 8), text, fill=text_color, font=None)


def create_screenshot_1_menu():
    """Screenshot 1: Menu Screen"""
    img = Image.new('RGB', (WIDTH, HEIGHT), BLACK)
    draw = ImageDraw.Draw(img)

    draw_space_background(draw, WIDTH, HEIGHT)

    # Title
    title_y = 400
    # STARSHIP in white
    draw.text((WIDTH//2 - 180, title_y), "STARSHIP", fill=WHITE, font=None)
    # LANDER in orange
    draw.text((WIDTH//2 - 140, title_y + 80), "LANDER", fill=ORANGE, font=None)

    # Draw larger title text manually
    for i, char in enumerate("STARSHIP"):
        cx = WIDTH//2 - 200 + i * 50
        draw.rectangle([cx, title_y, cx + 40, title_y + 60], fill=WHITE)

    for i, char in enumerate("LANDER"):
        cx = WIDTH//2 - 150 + i * 50
        draw.rectangle([cx, title_y + 90, cx + 40, title_y + 150], fill=ORANGE)

    # Starship illustration (larger)
    draw_starship(draw, WIDTH//2, 850, scale=1.8, show_flame=True)

    # Leaderboard box
    lb_x = WIDTH//2 - 200
    lb_y = 1200
    lb_w = 400
    lb_h = 250
    draw.rounded_rectangle([lb_x, lb_y, lb_x + lb_w, lb_y + lb_h], radius=20, fill=(255, 255, 255, 20))
    draw.text((lb_x + 120, lb_y + 20), "TOP PILOTS", fill=YELLOW, font=None)
    draw.text((lb_x + 30, lb_y + 70), "1. ACE       4850", fill=YELLOW, font=None)
    draw.text((lb_x + 30, lb_y + 120), "2. PILOT     3920", fill=WHITE, font=None)
    draw.text((lb_x + 30, lb_y + 170), "3. ROOKIE    2150", fill=WHITE, font=None)

    # Launch button
    btn_x = WIDTH//2 - 160
    btn_y = 1550
    btn_w = 320
    btn_h = 90
    # Gradient-like button
    for i in range(btn_h):
        ratio = i / btn_h
        r = int(255 * (1 - ratio * 0.3))
        g = int(140 * (1 - ratio * 0.5))
        b = int(0)
        draw.line([(btn_x, btn_y + i), (btn_x + btn_w, btn_y + i)], fill=(r, g, b))
    draw.rounded_rectangle([btn_x, btn_y, btn_x + btn_w, btn_y + btn_h], radius=45, outline=ORANGE, width=3)
    draw.text((btn_x + 90, btn_y + 30), "LAUNCH", fill=BLACK, font=None)

    # Controls toggle
    draw.rounded_rectangle([WIDTH//2 - 180, 1720, WIDTH//2 + 180, 1820], radius=15, fill=(255, 255, 255, 15))
    draw.text((WIDTH//2 - 80, 1740), "CONTROLS", fill=ORANGE, font=None)
    draw.text((WIDTH//2 - 100, 1780), "Tilt to Rotate", fill=WHITE, font=None)

    # How to play
    draw.rounded_rectangle([WIDTH//2 - 180, 1880, WIDTH//2 + 180, 2050], radius=15, fill=(255, 255, 255, 15))
    draw.text((WIDTH//2 - 90, 1900), "HOW TO PLAY", fill=ORANGE, font=None)
    draw.text((WIDTH//2 - 150, 1950), "Hold THRUST to fire", fill=GRAY, font=None)
    draw.text((WIDTH//2 - 150, 1990), "Tilt phone to rotate", fill=GRAY, font=None)

    # Version number
    draw.text((WIDTH//2 - 30, 2650), "v1.1.5", fill=(100, 100, 100), font=None)

    return img


def create_screenshot_2_gameplay():
    """Screenshot 2: In-Game"""
    img = Image.new('RGB', (WIDTH, HEIGHT), BLACK)
    draw = ImageDraw.Draw(img)

    draw_space_background(draw, WIDTH, HEIGHT)

    # Moon in background
    draw_moon(draw, WIDTH - 200, 600, 180)

    # Terrain
    draw_terrain(draw, WIDTH, HEIGHT)

    # Platform
    platform_y = int(HEIGHT * 0.85)
    draw_platform(draw, WIDTH//2 + 100, platform_y, 220)

    # Starship (in flight, slightly tilted position)
    draw_starship(draw, WIDTH//2 - 50, 1100, scale=1.3, show_flame=True)

    # Close button
    draw.ellipse([50, 120, 130, 200], fill=(100, 100, 100, 150))
    draw.text((75, 145), "X", fill=WHITE, font=None)

    # Fuel gauge (top right)
    draw.text((WIDTH - 200, 130), "87%", fill=GREEN, font=None)
    draw.rectangle([WIDTH - 200, 170, WIDTH - 80, 185], fill=(60, 60, 60))
    draw.rectangle([WIDTH - 200, 170, WIDTH - 95, 185], fill=GREEN)

    # Velocity HUD (center top area)
    hud_x = WIDTH//2 - 100
    hud_y = 250
    hud_w = 200
    hud_h = 280

    draw.rounded_rectangle([hud_x, hud_y, hud_x + hud_w, hud_y + hud_h],
                          radius=15, fill=(0, 0, 0, 200), outline=(80, 80, 80), width=2)

    # VERT section
    draw.text((hud_x + 60, hud_y + 20), "VERT", fill=GRAY, font=None)
    draw.text((hud_x + 60, hud_y + 50), "45", fill=YELLOW, font=None)
    draw.rounded_rectangle([hud_x + 130, hud_y + 45, hud_x + 180, hud_y + 75],
                          radius=5, fill=(200, 200, 0, 50))
    draw.text((hud_x + 140, hud_y + 50), "OK", fill=YELLOW, font=None)

    # Divider
    draw.line([(hud_x + 20, hud_y + 100), (hud_x + hud_w - 20, hud_y + 100)], fill=(80, 80, 80), width=1)

    # HORIZ section
    draw.text((hud_x + 60, hud_y + 120), "HORIZ", fill=GRAY, font=None)
    draw.text((hud_x + 60, hud_y + 150), "12", fill=GREEN, font=None)
    draw.rounded_rectangle([hud_x + 130, hud_y + 145, hud_x + 180, hud_y + 175],
                          radius=5, fill=(0, 200, 0, 50))
    draw.text((hud_x + 140, hud_y + 150), "OK", fill=GREEN, font=None)

    # Divider
    draw.line([(hud_x + 20, hud_y + 200), (hud_x + hud_w - 20, hud_y + 200)], fill=(80, 80, 80), width=1)

    # SAFE thresholds
    draw.text((hud_x + 30, hud_y + 220), "SAFE:", fill=GRAY, font=None)
    draw.text((hud_x + 90, hud_y + 220), "V<50  H<30", fill=(100, 200, 100), font=None)

    # Control buttons at bottom
    # Thrust button (center, large)
    thrust_x = WIDTH//2 - 150
    thrust_y = HEIGHT - 280
    thrust_w = 300
    thrust_h = 100
    for i in range(thrust_h):
        ratio = i / thrust_h
        r = int(255 * (1 - ratio * 0.3))
        g = int(140 * (1 - ratio * 0.5))
        draw.line([(thrust_x, thrust_y + i), (thrust_x + thrust_w, thrust_y + i)], fill=(r, g, 0))
    draw.rounded_rectangle([thrust_x, thrust_y, thrust_x + thrust_w, thrust_y + thrust_h],
                          radius=20, outline=(255, 255, 255, 100), width=3)
    draw.text((thrust_x + 100, thrust_y + 35), "THRUST", fill=WHITE, font=None)

    return img


def create_screenshot_3_gameover():
    """Screenshot 3: Game Over / Crash"""
    img = Image.new('RGB', (WIDTH, HEIGHT), BLACK)
    draw = ImageDraw.Draw(img)

    draw_space_background(draw, WIDTH, HEIGHT)

    # Moon
    draw_moon(draw, WIDTH - 250, 500, 160)

    # Terrain
    draw_terrain(draw, WIDTH, HEIGHT)

    # Platform
    platform_y = int(HEIGHT * 0.85)
    draw_platform(draw, WIDTH//2, platform_y, 220)

    # Explosion effect (where rocket crashed)
    explosion_x = WIDTH//2 - 100
    explosion_y = platform_y - 50
    for i in range(8):
        angle = i * 45
        length = random.randint(60, 120)
        end_x = explosion_x + int(length * math.cos(math.radians(angle)))
        end_y = explosion_y + int(length * math.sin(math.radians(angle)))
        color = random.choice([ORANGE, RED, YELLOW])
        draw.line([explosion_x, explosion_y, end_x, end_y], fill=color, width=8)

    # Explosion center
    draw.ellipse([explosion_x - 50, explosion_y - 50, explosion_x + 50, explosion_y + 50], fill=ORANGE)
    draw.ellipse([explosion_x - 30, explosion_y - 30, explosion_x + 30, explosion_y + 30], fill=YELLOW)

    # Game Over overlay
    overlay_x = WIDTH//2 - 250
    overlay_y = HEIGHT//2 - 300
    overlay_w = 500
    overlay_h = 450

    draw.rounded_rectangle([overlay_x, overlay_y, overlay_x + overlay_w, overlay_y + overlay_h],
                          radius=30, fill=(0, 0, 0, 230), outline=(255, 70, 70, 150), width=3)

    # X icon (crash)
    icon_x = WIDTH//2
    icon_y = overlay_y + 80
    draw.ellipse([icon_x - 50, icon_y - 50, icon_x + 50, icon_y + 50], fill=RED)
    draw.text((icon_x - 15, icon_y - 25), "X", fill=WHITE, font=None)

    # CRASH! text
    draw.text((WIDTH//2 - 70, overlay_y + 150), "CRASH!", fill=RED, font=None)

    # Buttons
    btn_y = overlay_y + 280

    # Menu button
    menu_x = overlay_x + 50
    menu_w = 180
    menu_h = 70
    draw.rounded_rectangle([menu_x, btn_y, menu_x + menu_w, btn_y + menu_h],
                          radius=15, fill=(100, 100, 100, 150))
    draw.text((menu_x + 55, btn_y + 22), "Menu", fill=WHITE, font=None)

    # Retry button
    retry_x = overlay_x + overlay_w - 230
    retry_w = 180
    retry_h = 70
    for i in range(retry_h):
        ratio = i / retry_h
        r = int(255 * (1 - ratio * 0.3))
        g = int(140 * (1 - ratio * 0.5))
        draw.line([(retry_x, btn_y + i), (retry_x + retry_w, btn_y + i)], fill=(r, g, 0))
    draw.rounded_rectangle([retry_x, btn_y, retry_x + retry_w, btn_y + retry_h],
                          radius=15, outline=ORANGE, width=2)
    draw.text((retry_x + 55, btn_y + 22), "Retry", fill=WHITE, font=None)

    # Fuel gauge (dimmed, top right)
    draw.text((WIDTH - 200, 130), "23%", fill=RED, font=None)
    draw.rectangle([WIDTH - 200, 170, WIDTH - 80, 185], fill=(60, 60, 60))
    draw.rectangle([WIDTH - 200, 170, WIDTH - 172, 185], fill=RED)

    return img


def main():
    output_dir = "../Screenshots"
    import os
    os.makedirs(output_dir, exist_ok=True)

    print("Generating App Store screenshots (1260x2736)...")

    # Screenshot 1: Menu
    print("  Creating screenshot 1 (Menu)...")
    img1 = create_screenshot_1_menu()
    img1.save(f"{output_dir}/screenshot_1_menu.png", "PNG")
    print(f"  Saved: {output_dir}/screenshot_1_menu.png")

    # Screenshot 2: Gameplay
    print("  Creating screenshot 2 (Gameplay)...")
    img2 = create_screenshot_2_gameplay()
    img2.save(f"{output_dir}/screenshot_2_gameplay.png", "PNG")
    print(f"  Saved: {output_dir}/screenshot_2_gameplay.png")

    # Screenshot 3: Game Over
    print("  Creating screenshot 3 (Game Over)...")
    img3 = create_screenshot_3_gameover()
    img3.save(f"{output_dir}/screenshot_3_gameover.png", "PNG")
    print(f"  Saved: {output_dir}/screenshot_3_gameover.png")

    print("\nDone! Screenshots saved to Screenshots/ folder")


if __name__ == "__main__":
    main()
