#!/usr/bin/env python3
"""Generate app icons for CrownSpin watchOS app."""

from PIL import Image, ImageDraw
import math
import os

# Icon sizes needed for watchOS
ICON_SIZES = [48, 55, 58, 87, 80, 88, 92, 100, 102, 108, 172, 196, 216, 234, 258, 1024]

# Colors
BACKGROUND_COLOR = (20, 20, 30)   # Near black
CROWN_COLOR = (255, 140, 50)      # Bright orange
CROWN_HIGHLIGHT = (255, 180, 100) # Light orange highlight
CROWN_SHADOW = (200, 100, 30)     # Darker orange shadow


def draw_crown(draw, size, center_x, center_y, crown_size):
    """Draw a Digital Crown with rotation motion indicators."""
    # Larger crown dimensions
    width = crown_size * 0.45
    height = crown_size * 0.70

    left = center_x - width / 2
    right = center_x + width / 2
    top = center_y - height / 2
    bottom = center_y + height / 2

    # Draw rotation motion arcs (behind the crown)
    arc_radius = height * 0.55
    arc_width = max(3, int(size * 0.025))

    # Top arc - clockwise motion
    arc_bbox_top = [
        center_x - arc_radius, top - arc_radius * 0.3,
        center_x + arc_radius, top + arc_radius * 1.2
    ]
    draw.arc(arc_bbox_top, start=200, end=340, fill=CROWN_HIGHLIGHT, width=arc_width)

    # Bottom arc - clockwise motion
    arc_bbox_bottom = [
        center_x - arc_radius, bottom - arc_radius * 1.2,
        center_x + arc_radius, bottom + arc_radius * 0.3
    ]
    draw.arc(arc_bbox_bottom, start=20, end=160, fill=CROWN_SHADOW, width=arc_width)

    # Draw main crown body (rounded rectangle)
    corner_radius = width * 0.25

    draw.rounded_rectangle(
        [left, top, right, bottom],
        radius=corner_radius,
        fill=CROWN_COLOR
    )

    # Draw ridges/grooves on the crown
    num_ridges = 9
    ridge_spacing = height / (num_ridges + 1)
    ridge_width = max(2, int(size * 0.018))

    for i in range(1, num_ridges + 1):
        y = top + i * ridge_spacing
        # Alternate colors for ridge effect
        color = CROWN_HIGHLIGHT if i % 2 == 0 else CROWN_SHADOW
        draw.line(
            [(left + corner_radius * 0.3, y), (right - corner_radius * 0.3, y)],
            fill=color,
            width=ridge_width
        )


def generate_icon(size, output_path):
    """Generate a single icon at the specified size."""
    # Create image with slight padding for anti-aliasing
    img = Image.new('RGB', (size, size), BACKGROUND_COLOR)
    draw = ImageDraw.Draw(img)

    center = size // 2
    crown_size = size * 0.8

    draw_crown(draw, size, center, center, crown_size)

    img.save(output_path, 'PNG')
    print(f"Generated: {output_path}")


def main():
    # Output directory
    output_dir = os.path.join(
        os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
        'CrownSpin/CrownSpin Watch App/Assets.xcassets/AppIcon.appiconset'
    )

    os.makedirs(output_dir, exist_ok=True)

    # Generate all icon sizes
    for size in ICON_SIZES:
        output_path = os.path.join(output_dir, f'icon-{size}.png')
        generate_icon(size, output_path)

    print(f"\nGenerated {len(ICON_SIZES)} icons in {output_dir}")


if __name__ == '__main__':
    main()
