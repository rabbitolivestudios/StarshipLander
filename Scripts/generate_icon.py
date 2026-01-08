#!/usr/bin/env python3
"""
App Icon Generator for Rocket Lander
Generates a 1024x1024 app icon using PIL/Pillow
"""

import sys
import math

try:
    from PIL import Image, ImageDraw
except ImportError:
    print("Installing Pillow...")
    import subprocess
    subprocess.check_call([sys.executable, "-m", "pip", "install", "Pillow", "-q"])
    from PIL import Image, ImageDraw

def create_rocket_icon(size=1024):
    """Create a rocket lander app icon"""

    # Create image with gradient background
    img = Image.new('RGB', (size, size), (0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Draw gradient background (space)
    for y in range(size):
        ratio = y / size
        r = int(10 * (1 - ratio) + 30 * ratio)
        g = int(10 * (1 - ratio) + 30 * ratio)
        b = int(40 * (1 - ratio) + 80 * ratio)
        draw.line([(0, y), (size, y)], fill=(r, g, b))

    # Add stars
    import random
    random.seed(42)  # Consistent stars
    for _ in range(100):
        x = random.randint(0, size)
        y = random.randint(0, size)
        brightness = random.randint(150, 255)
        star_size = random.randint(1, 3)
        draw.ellipse([x-star_size, y-star_size, x+star_size, y+star_size],
                     fill=(brightness, brightness, brightness))

    # Draw platform at bottom
    platform_width = size * 0.3
    platform_height = size * 0.04
    platform_x = (size - platform_width) / 2
    platform_y = size * 0.85

    draw.rectangle([platform_x, platform_y, platform_x + platform_width, platform_y + platform_height],
                   fill=(255, 140, 0), outline=(255, 200, 0), width=3)

    # Draw landing lights on platform
    light_radius = size * 0.015
    for offset in [-1, 1]:
        light_x = size/2 + offset * (platform_width/2 - light_radius * 2)
        light_y = platform_y - light_radius
        draw.ellipse([light_x - light_radius, light_y - light_radius,
                      light_x + light_radius, light_y + light_radius],
                     fill=(0, 255, 100))

    # Draw rocket
    rocket_center_x = size / 2
    rocket_center_y = size * 0.45
    rocket_scale = size / 1024

    # Rocket body (white triangle)
    body_width = 80 * rocket_scale
    body_height = 200 * rocket_scale

    body_points = [
        (rocket_center_x, rocket_center_y - body_height/2),  # Top
        (rocket_center_x - body_width/2, rocket_center_y + body_height/2),  # Bottom left
        (rocket_center_x + body_width/2, rocket_center_y + body_height/2),  # Bottom right
    ]
    draw.polygon(body_points, fill=(240, 240, 240), outline=(180, 180, 180))

    # Nose cone (red)
    nose_height = 60 * rocket_scale
    nose_points = [
        (rocket_center_x, rocket_center_y - body_height/2 - nose_height/2),  # Top
        (rocket_center_x - body_width/3, rocket_center_y - body_height/2 + 10),  # Bottom left
        (rocket_center_x + body_width/3, rocket_center_y - body_height/2 + 10),  # Bottom right
    ]
    draw.polygon(nose_points, fill=(220, 50, 50), outline=(180, 40, 40))

    # Landing legs
    leg_width = 8 * rocket_scale
    leg_extend = 50 * rocket_scale
    leg_bottom_y = rocket_center_y + body_height/2 + 40 * rocket_scale

    # Left leg
    left_leg_points = [
        (rocket_center_x - body_width/3, rocket_center_y + body_height/3),
        (rocket_center_x - body_width/2 - leg_extend, leg_bottom_y),
        (rocket_center_x - body_width/2 - leg_extend + leg_width*2, leg_bottom_y),
        (rocket_center_x - body_width/3 + leg_width, rocket_center_y + body_height/3),
    ]
    draw.polygon(left_leg_points, fill=(100, 100, 100), outline=(80, 80, 80))

    # Right leg
    right_leg_points = [
        (rocket_center_x + body_width/3, rocket_center_y + body_height/3),
        (rocket_center_x + body_width/2 + leg_extend, leg_bottom_y),
        (rocket_center_x + body_width/2 + leg_extend - leg_width*2, leg_bottom_y),
        (rocket_center_x + body_width/3 - leg_width, rocket_center_y + body_height/3),
    ]
    draw.polygon(right_leg_points, fill=(100, 100, 100), outline=(80, 80, 80))

    # Engine flame
    flame_width = 40 * rocket_scale
    flame_height = 80 * rocket_scale
    flame_top_y = rocket_center_y + body_height/2

    # Outer flame (orange)
    outer_flame_points = [
        (rocket_center_x - flame_width/2, flame_top_y),
        (rocket_center_x, flame_top_y + flame_height),
        (rocket_center_x + flame_width/2, flame_top_y),
    ]
    draw.polygon(outer_flame_points, fill=(255, 140, 0))

    # Inner flame (yellow)
    inner_flame_points = [
        (rocket_center_x - flame_width/4, flame_top_y),
        (rocket_center_x, flame_top_y + flame_height * 0.7),
        (rocket_center_x + flame_width/4, flame_top_y),
    ]
    draw.polygon(inner_flame_points, fill=(255, 220, 100))

    # Add rounded corners for iOS
    # Create a mask with rounded corners
    mask = Image.new('L', (size, size), 0)
    mask_draw = ImageDraw.Draw(mask)
    corner_radius = int(size * 0.22)  # iOS standard corner radius ratio
    mask_draw.rounded_rectangle([0, 0, size, size], radius=corner_radius, fill=255)

    # Create output with rounded corners
    output = Image.new('RGB', (size, size), (0, 0, 0))
    output.paste(img, mask=mask)

    return img  # Return without mask for App Store (Apple applies its own mask)

def main():
    output_path = "../RocketLander/Assets.xcassets/AppIcon.appiconset/icon-1024.png"

    print("Generating Rocket Lander app icon...")
    icon = create_rocket_icon(1024)
    icon.save(output_path, "PNG")
    print(f"Icon saved to: {output_path}")
    print("Done!")

if __name__ == "__main__":
    main()
