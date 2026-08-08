"""Dev-only: generate placeholder meal photos for tools/preview_pdf.py.

Real plans pull recipe photos from Supabase storage; previews just need
something with the right aspect ratio and enough color to judge how a card
reads with an image in it.
"""

from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw

OUT_DIR = Path("/tmp/nutriflow-previews/photos")

PALETTES = {
    "breakfast": ((252, 231, 190), (233, 175, 106), (120, 84, 45)),
    "lunch": ((226, 240, 214), (150, 190, 120), (74, 106, 58)),
    "dinner": ((246, 216, 200), (219, 132, 96), (128, 62, 42)),
}

W, H = 640, 420


def make(name: str, colors: tuple) -> None:
    bg, mid, dark = colors
    img = Image.new("RGB", (W, H), bg)
    draw = ImageDraw.Draw(img, "RGBA")

    # Plate.
    draw.ellipse((W * 0.14, H * 0.10, W * 0.86, H * 0.98), fill=(255, 255, 255, 255))
    draw.ellipse((W * 0.20, H * 0.18, W * 0.80, H * 0.90), fill=mid + (255,))

    # A few "portions" on the plate.
    for i, (cx, cy, r) in enumerate(
        [(0.40, 0.42, 0.10), (0.60, 0.50, 0.13), (0.47, 0.68, 0.08)]
    ):
        fill = dark if i % 2 else tuple(min(255, c + 40) for c in dark)
        draw.ellipse(
            (W * (cx - r), H * (cy - r * 1.5), W * (cx + r), H * (cy + r * 1.5)),
            fill=fill + (235,),
        )

    img.save(OUT_DIR / f"{name}.png")


if __name__ == "__main__":
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    for name, colors in PALETTES.items():
        make(name, colors)
    print(f"wrote {len(PALETTES)} photos to {OUT_DIR}")
