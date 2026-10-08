#!/usr/bin/env python3
"""Draw the settings dashboard's Welcome showcase art and news story images.

The Welcome page leads with a hero image, and a featured news story carries a
smaller one. Both are the same abstract "horizon": seven thin arcs in the
module accent colours (Docs/Branding/ColourSchema.md) fanning in from beyond
the right edge, a low glow rising behind them and a sparse star field, all on
the dashboard's dark panel colour. The left 40% stays dark and calm because the
Lua side fades the art's left edge into the panel there.

Everything is drawn at 4x and scaled down with LANCZOS for smooth arcs. Output
is deterministic: each image seeds random.Random with zlib.crc32 of its output
name, so a rerun produces byte-identical PNGs.

Usage:
    python3 tools/make_welcome_art.py hero
        -> media/dashboard/welcome/hero.png (1024x512)
    python3 tools/make_welcome_art.py story axis-settings-refresh
        -> media/news/axis-settings-refresh.png (512x256)
    python3 tools/make_welcome_art.py tiles ~/shots [--out DIR]
        -> DIR/<module>.png (512x256), DIR defaults to media/dashboard/welcome/tiles

tiles reads screenshots named <module>.png or <module>.jpg for
focus presence vista insight echo augment essence integrations, centre-crops
each to 2:1 and resizes it to 512x256.
"""

import argparse
import math
import os
import random
import sys
import zlib

try:
    from PIL import Image, ImageChops, ImageDraw, ImageFilter
except ImportError:
    sys.exit("Pillow is required: python3 -m pip install Pillow")

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
HERO_OUT = os.path.join(REPO, "media", "dashboard", "welcome", "hero.png")
STORY_DIR = os.path.join(REPO, "media", "news")
TILES_OUT = os.path.join(REPO, "media", "dashboard", "welcome", "tiles")

BG = (0x16, 0x16, 0x1C)
# Module accents, outermost arc first: Focus, Presence, Vista, Insight, Echo,
# Augment, Essence. Keep in step with Docs/Branding/ColourSchema.md.
ACCENTS = ["FFD133", "33FFDF", "B366FF", "FF66B3", "8FA3E8", "33CC66", "DC143C"]
GLOW = (0x8F, 0x7A, 0xE8)  # cool violet between the Vista and Echo accents
TILE_MODULES = ["focus", "presence", "vista", "insight", "echo", "augment",
                "essence", "integrations"]
SS = 4  # supersampling factor


def hex_rgb(value):
    return tuple(int(value[i:i + 2], 16) for i in (0, 2, 4))


def calm_mask(w, h, start=0.30, full=0.62):
    """Horizontal ramp: 0 left of `start`, 1 right of `full`, smoothstep between."""
    row = []
    for x in range(w):
        t = min(1.0, max(0.0, (x / w - start) / (full - start)))
        row.append(int(255 * t * t * (3 - 2 * t)))
    strip = Image.new("L", (w, 1))
    strip.putdata(row)
    return strip.resize((w, h))


def scale_alpha(layer, mask):
    """Multiply an RGBA layer's alpha by an L mask."""
    r, g, b, a = layer.split()
    return Image.merge("RGBA", (r, g, b, ImageChops.multiply(a, mask)))


def draw_horizon(width, height, name):
    rng = random.Random(zlib.crc32(name.encode("utf-8")))
    W, H = width * SS, height * SS
    u = W / 1024.0  # one hero pixel at supersampled scale, per output width

    img = Image.new("RGBA", (W, H), BG + (255,))
    calm = calm_mask(W, H)

    # Soft wash: a barely-lighter sky toward the lower right.
    wash = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    wd = ImageDraw.Draw(wash)
    wd.ellipse((W * 0.45, H * 0.15, W * 1.45, H * 1.55), fill=(0x2A, 0x26, 0x3A, 90))
    wash = wash.filter(ImageFilter.GaussianBlur(160 * u))
    img = Image.alpha_composite(img, scale_alpha(wash, calm))

    # Low wide glow near the bottom right: concentric ellipses, alpha 60 -> 0.
    glow = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    gd = ImageDraw.Draw(glow)
    cx, cy = W * 0.80, H * 0.98
    rx, ry = W * 0.42, H * 0.30
    steps = 24
    for i in range(steps):
        t = i / (steps - 1)
        alpha = round(60 * (1 - t))
        k = 1 - 0.85 * t
        gd.ellipse((cx - rx * k, cy - ry * k, cx + rx * k, cy + ry * k),
                   fill=GLOW + (alpha,))
    glow = glow.filter(ImageFilter.GaussianBlur(40 * u))
    img = Image.alpha_composite(img, scale_alpha(glow, calm))

    # Seven arcs fanning from a point off the right edge. Every circle passes
    # through P; its centre sits below-left of P, so the arcs share an origin
    # and spread apart as they sweep left, like layered horizons.
    px, py = W * 1.06, H * 0.64
    arcs = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    halo = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    ad, hd = ImageDraw.Draw(arcs), ImageDraw.Draw(halo)
    for i, hexcol in enumerate(ACCENTS):
        col = hex_rgb(hexcol)
        radius = W * (1.10 + 0.15 * i + rng.uniform(-0.02, 0.02))
        theta = math.radians(97 + 2.0 * i + rng.uniform(-0.4, 0.4))
        ox = px + radius * math.cos(theta)
        oy = py + radius * math.sin(theta)
        box = (ox - radius, oy - radius, ox + radius, oy + radius)
        line_w = (3 if i in (0, 3) else 2) * SS  # 2-3px once scaled down
        ad.ellipse(box, outline=col + (int(205 - 10 * i),), width=line_w)
        hd.ellipse(box, outline=col + (150,), width=line_w * 5)
    halo = halo.filter(ImageFilter.GaussianBlur(14 * u))
    # Arcs brighten toward the right and fall away into the calm left.
    arc_mask = calm_mask(W, H, start=0.22, full=0.78)
    halo_mask = arc_mask.point(lambda v: v * 120 // 255)
    img = Image.alpha_composite(img, scale_alpha(halo, halo_mask))
    img = Image.alpha_composite(img, scale_alpha(arcs, arc_mask))

    # Horizon bloom where the arcs gather, just inside the right edge.
    bloom = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    bd = ImageDraw.Draw(bloom)
    bx, by, br = W * 0.97, H * 0.66, W * 0.10
    bd.ellipse((bx - br, by - br * 0.6, bx + br, by + br * 0.6), fill=(0xFF, 0xE8, 0xC8, 105))
    bloom = bloom.filter(ImageFilter.GaussianBlur(60 * u))
    img = Image.alpha_composite(img, bloom)

    # Sparse star field: 60 dots at alpha 30-90, thinner and dimmer on the left.
    stars = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    sd = ImageDraw.Draw(stars)
    for _ in range(60):
        x = W * (1 - rng.random() ** 1.6)  # skewed toward the right
        y = H * rng.random() ** 1.3 * 0.85  # mostly in the upper sky
        alpha = rng.randint(30, 90)
        r = rng.choice((0.6, 0.8, 0.8, 1.0, 1.3)) * u
        tint = rng.choice(((255, 255, 255), (220, 228, 255), (255, 240, 220)))
        sd.ellipse((x - r, y - r, x + r, y + r), fill=tint + (alpha,))
    star_mask = calm_mask(W, H, start=0.0, full=0.55)
    star_mask = star_mask.point(lambda v: 90 + v * 165 // 255)
    img = Image.alpha_composite(img, scale_alpha(stars, star_mask))

    return img.resize((width, height), Image.LANCZOS)


def save(img, path):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    img.save(path, optimize=True)
    print(f"wrote {os.path.relpath(path)} ({img.width}x{img.height})")


def cmd_hero(args):
    save(draw_horizon(1024, 512, "hero"), args.out or HERO_OUT)


def cmd_story(args):
    out = args.out or os.path.join(STORY_DIR, f"{args.name}.png")
    save(draw_horizon(512, 256, args.name), out)


def cmd_tiles(args):
    written = 0
    for module in TILE_MODULES:
        src = next((os.path.join(args.src_dir, module + ext)
                    for ext in (".png", ".jpg", ".jpeg")
                    if os.path.isfile(os.path.join(args.src_dir, module + ext))), None)
        if not src:
            print(f"skip {module}: no {module}.png or {module}.jpg")
            continue
        shot = Image.open(src).convert("RGBA")
        w, h = shot.size
        if w >= 2 * h:
            cw, ch = 2 * h, h
        else:
            cw, ch = w, w // 2
        left, top = (w - cw) // 2, (h - ch) // 2
        tile = shot.crop((left, top, left + cw, top + ch)).resize((512, 256), Image.LANCZOS)
        save(tile, os.path.join(args.out, f"{module}.png"))
        written += 1
    if not written:
        sys.exit(f"no screenshots found in {args.src_dir}")


def main():
    parser = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    sub = parser.add_subparsers(dest="command", required=True)

    p = sub.add_parser("hero", help="draw the Welcome hero (1024x512)")
    p.add_argument("--out", help=f"output path (default {os.path.relpath(HERO_OUT, REPO)})")
    p.set_defaults(func=cmd_hero)

    p = sub.add_parser("story", help="draw a news story image (512x256)")
    p.add_argument("name", help="story id; also the seed and the file name")
    p.add_argument("--out", help="output path (default media/news/<name>.png)")
    p.set_defaults(func=cmd_story)

    p = sub.add_parser("tiles", help="crop module screenshots into 512x256 tiles")
    p.add_argument("src_dir", help="folder of <module>.png|jpg screenshots")
    p.add_argument("--out", default=TILES_OUT,
                   help="output folder (default media/dashboard/welcome/tiles)")
    p.set_defaults(func=cmd_tiles)

    args = parser.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
