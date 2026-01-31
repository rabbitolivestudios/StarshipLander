#!/usr/bin/env python3
"""
Bake marketing captions onto App Store screenshots.

Usage:
    python3 Scripts/caption_screenshots.py

Reads from Screenshots/v2.0.0/, writes captioned versions to the same directory.
Requires: Pillow (pip install Pillow)
"""

import os
from PIL import Image, ImageDraw, ImageFont

# --- Configuration ---

SCREENSHOTS_DIR = os.path.join(os.path.dirname(__file__), '..', 'Screenshots', 'v2.0.0')

# Font: SF Compact Black (macOS system font)
# Fallback chain for other systems
FONT_CANDIDATES = [
    '/System/Library/Fonts/SFCompact.ttf',       # macOS - SF Compact Black
    '/System/Library/Fonts/SFNSRounded.ttf',      # macOS - SF NS Rounded
    '/System/Library/Fonts/Helvetica.ttc',        # macOS fallback
    '/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf',  # Linux
]

FONT_SIZE = 100
LINE_SPACING = 12  # pixels between lines

# Background pill styling (default)
PILL_COLOR = (20, 20, 30, 190)    # dark blue-black at ~75% opacity
PILL_PADDING_H = 50               # horizontal padding inside pill
PILL_PADDING_V = 14               # vertical padding inside pill
PILL_RADIUS = 24                   # corner radius

# Caption definitions: (filename, line1, line2, y_top, pill_color_override)
# y_top: top edge of pill, tuned per screenshot to sit as header with gap before HUD
# pill_color_override: None = use default, or (r,g,b,a) tuple for this screenshot
CAPTIONS = [
    # 1. Gameplay — HUD box starts ~260px. Pill at 140 ends ~320, gap before HUD at ~370
    ('02_classic_gameplay.png',       'PRECISION PILOTING.',    'NO MARGIN FOR ERROR.',   140, None),
    # 2. Main menu — "LANDER" title at ~360. Reduced opacity to prevent visual overload
    ('01_main_menu.png',             'CONTROL THRUST.',        'MASTER THE DESCENT.',    140, (20, 20, 30, 155)),
    # 3. Crash — HUD starts ~260. Similar to gameplay
    ('06_campaign_venus_crash.png',   'Crash. Learn.',          'Try again.',             140, None),
    # 4. Landing success — HUD starts ~260
    ('10_landing_success.png',        'PRECISION',              'IS SCORED.',             140, None),
    # 5. Campaign select — "CAMPAIGN" header at ~266, cards at ~350
    ('03_campaign_level_select.png',  'A 10-WORLD',            'SKILL CAMPAIGN',         140, None),
]


def find_font(size):
    """Load the first available font from candidates."""
    for path in FONT_CANDIDATES:
        if os.path.exists(path):
            try:
                return ImageFont.truetype(path, size)
            except Exception:
                continue
    raise RuntimeError(f"No suitable font found. Tried: {FONT_CANDIDATES}")


def measure_text(font, text):
    """Return (width, height, y_offset) of text using font bounding box."""
    bbox = font.getbbox(text)
    return bbox[2] - bbox[0], bbox[3] - bbox[1], bbox[1]


def add_caption(input_path, output_path, line1, line2, y_top, pill_color=None):
    """Open a screenshot, draw a 2-line caption with background pill, save."""
    img = Image.open(input_path).convert('RGBA')
    width, height = img.size

    # Create overlay for translucent drawing
    overlay = Image.new('RGBA', (width, height), (0, 0, 0, 0))
    draw = ImageDraw.Draw(overlay)

    font = find_font(FONT_SIZE)
    color = pill_color or PILL_COLOR

    # Measure both lines
    w1, h1, yoff1 = measure_text(font, line1)
    w2, h2, yoff2 = measure_text(font, line2)

    # Use fixed line height based on cap height for consistent pill sizing
    # across ALL CAPS and mixed-case text (descenders extend below)
    cap_height = font.getbbox('ABCDEFG')[3] - font.getbbox('ABCDEFG')[1]
    line_height = cap_height
    text_block_h = line_height * 2 + LINE_SPACING
    text_block_w = max(w1, w2)

    # Pill dimensions (centered, clamped to image bounds)
    pill_w = text_block_w + PILL_PADDING_H * 2
    pill_h = text_block_h + PILL_PADDING_V * 2
    pill_x0 = max(0, (width - pill_w) // 2)
    pill_y0 = y_top
    pill_x1 = min(width, pill_x0 + pill_w)
    pill_y1 = pill_y0 + pill_h

    # Draw background pill
    draw.rounded_rectangle(
        (pill_x0, pill_y0, pill_x1, pill_y1),
        radius=PILL_RADIUS,
        fill=color
    )

    # Text positioning: centered in pill
    text_area_y0 = pill_y0 + PILL_PADDING_V

    # Line 1
    x1 = (width - w1) // 2
    y1_draw = text_area_y0 - yoff1

    # Line 2
    x2 = (width - w2) // 2
    y2_draw = text_area_y0 + line_height + LINE_SPACING - yoff2

    draw.text((x1, y1_draw), line1, fill=(255, 255, 255, 255), font=font)
    draw.text((x2, y2_draw), line2, fill=(255, 255, 255, 255), font=font)

    # Composite overlay onto original
    result = Image.alpha_composite(img, overlay)

    # Save as PNG (lossless)
    result.save(output_path, 'PNG', optimize=False)

    opacity_pct = round(color[3] / 255 * 100)
    print(f"  Pill: ({pill_x0},{pill_y0}) to ({pill_x1},{pill_y1}), h={pill_h}px, opacity={opacity_pct}%")
    return result.size


def main():
    screenshots_dir = os.path.abspath(SCREENSHOTS_DIR)
    print(f"Screenshots directory: {screenshots_dir}")
    print(f"Font size: {FONT_SIZE}px, Default pill: {PILL_COLOR}")
    print()

    for entry in CAPTIONS:
        filename, line1, line2, y_top, pill_override = entry
        input_path = os.path.join(screenshots_dir, filename)
        base, ext = os.path.splitext(filename)
        output_name = f"{base}_captioned{ext}"
        output_path = os.path.join(screenshots_dir, output_name)

        if not os.path.exists(input_path):
            print(f"SKIP: {filename} not found")
            continue

        size = add_caption(input_path, output_path, line1, line2, y_top, pill_override)
        print(f"OK: {output_name} ({size[0]}x{size[1]})")

    print("\nDone.")


if __name__ == '__main__':
    main()
