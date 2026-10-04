#!/usr/bin/env python3
"""Build the shareable "what changed" card for a merged Horizon Suite change.

Every merged change with something a player can see gets one of these: a single
PNG that shows the option (if there is one) and the tracker, frame or panel
before and after. It goes into the PR's Evidence section and is posted wherever
the change is announced, so players see the update without reading the diff.

The card is the same shape every time: a header in the module's brand colour
(Docs/Branding/ColourSchema.md), an optional option row, then the before and
after side by side. A change with no "before" (a brand new frame) passes only
--after and gets a single "New" panel instead.

Usage:
    python3 tools/make_update_card.py --module Focus \\
        --title "Hide the group finder eye" \\
        --subtitle "New option: Focus > Group Finder Button" \\
        --option option-row.png --before before.png --after after.png \\
        --before-label "Before: eye shown (default)" \\
        --after-label "After: Group Finder Button off" \\
        --version 6.6.0 --out card.png

--option takes a screenshot of the options row. Rows are drawn full panel
width with the label on the left and the control on the right, so the empty
middle is cut out automatically; --no-squeeze keeps the row as captured.
"""

import argparse
import os
import sys

try:
    from PIL import Image, ImageDraw, ImageFont
except ImportError:
    sys.exit("Pillow is required: python3 -m pip install Pillow")

# Docs/Branding/ColourSchema.md. Keep in step with that file.
MODULE_COLOURS = {
    "Augment": "#33CC66", "Axis": "#E0E0E0", "Echo": "#8FA3E8",
    "Essence": "#DC143C", "Flow": "#3399FF", "Focus": "#FFD133",
    "Insight": "#FF66B3", "Presence": "#33FFDF", "Vista": "#B366FF",
    "Core": "#FF8C42",
}
FLAVOUR_COLOURS = {"Retail": "#5B9BD5", "Forever": "#C8A055"}

BG = (24, 22, 28)
PANEL = (34, 31, 40)
TEXT = (236, 236, 240)
MUTED = (160, 158, 172)
BEFORE = (170, 168, 182)
AFTER = (90, 220, 120)

GUTTER = 28
MAX_SHOT_W = 520  # each side of the pair is scaled down to at most this

BOLD_FONTS = [
    "/System/Library/Fonts/Supplemental/Arial Bold.ttf",
    "C:/Windows/Fonts/arialbd.ttf",
    "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf",
]
REGULAR_FONTS = [
    "/System/Library/Fonts/Supplemental/Arial.ttf",
    "C:/Windows/Fonts/arial.ttf",
    "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
]


def font(paths, size):
    for p in paths:
        if os.path.exists(p):
            return ImageFont.truetype(p, size)
    return ImageFont.load_default()


def hex_rgb(h):
    h = h.lstrip("#")
    return tuple(int(h[i:i + 2], 16) for i in (0, 2, 4))


def squeeze_row(img, gap=60, pad=24, threshold=170):
    """Cut the empty middle out of a full-width options row.

    Finds the columns holding bright pixels (label text, the toggle or slider),
    keeps the first and last clusters, and drops what lies between them.
    """
    w, h = img.size
    px = img.convert("L").load()
    cols = [any(px[x, y] > threshold for y in range(h)) for x in range(w)]
    clusters, start, last = [], None, None
    for x, on in enumerate(cols):
        if on:
            if start is None:
                start = x
            elif x - last > gap:
                clusters.append((start, last))
                start = x
            last = x
    if start is not None:
        clusters.append((start, last))
    if len(clusters) < 2:
        return img
    left_end = min(clusters[0][1] + pad, w)
    # The label may span several clusters (word gaps); keep everything up to
    # the last cluster that starts within the left third.
    for a, b in clusters:
        if a < w / 3:
            left_end = min(b + pad, w)
    right_start = max(clusters[-1][0] - pad, left_end)
    if right_start - left_end < 2 * gap:
        return img
    left = img.crop((0, 0, left_end, h))
    right = img.crop((right_start, 0, w, h))
    out = Image.new("RGB", (left.width + gap + right.width, h), img.getpixel((left_end, h // 2)))
    out.paste(left, (0, 0))
    out.paste(right, (left.width + gap, 0))
    return out


def fit(img, max_w):
    if img.width <= max_w:
        return img
    r = max_w / img.width
    return img.resize((max_w, round(img.height * r)), Image.LANCZOS)


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--module", required=True, choices=sorted(MODULE_COLOURS))
    ap.add_argument("--title", required=True, help="what changed, in a player's words")
    ap.add_argument("--subtitle", help="where to find it, e.g. 'New option: Focus > Group Finder Button'")
    ap.add_argument("--version", help="release the change ships in, e.g. 6.6.0")
    ap.add_argument("--flavour", choices=sorted(FLAVOUR_COLOURS), help="only when one client can see it")
    ap.add_argument("--option", help="screenshot of the options row")
    ap.add_argument("--no-squeeze", action="store_true", help="keep the option row as captured")
    ap.add_argument("--before", help="screenshot before the change (omit for a brand new feature)")
    ap.add_argument("--after", required=True, help="screenshot after the change")
    ap.add_argument("--before-label", default="Before")
    ap.add_argument("--after-label", default=None)
    ap.add_argument("--out", required=True)
    a = ap.parse_args()

    accent = hex_rgb(MODULE_COLOURS[a.module])
    after_label = a.after_label or ("After" if a.before else "New")
    shots = [Image.open(p).convert("RGB") for p in ([a.before] if a.before else []) + [a.after]]
    shots = [fit(s, MAX_SHOT_W) for s in shots]
    pair_w = sum(s.width for s in shots) + GUTTER * (len(shots) - 1)

    option = None
    if a.option:
        option = Image.open(a.option).convert("RGB")
        if not a.no_squeeze:
            option = squeeze_row(option)

    f_brand, f_title, f_sub, f_label = font(BOLD_FONTS, 18), font(BOLD_FONTS, 34), font(REGULAR_FONTS, 22), font(BOLD_FONTS, 22)
    width = max(pair_w, 760, option.width if option else 0) + 2 * GUTTER
    if option and option.width > width - 2 * GUTTER:
        option = fit(option, width - 2 * GUTTER)

    # Measure, then draw.
    y = GUTTER + 6 + 26 + 46 + (34 if a.subtitle else 0) + GUTTER
    if option:
        y += option.height + GUTTER
    y += 36 + max(s.height for s in shots) + GUTTER + 30
    card = Image.new("RGB", (width, y), BG)
    d = ImageDraw.Draw(card)

    d.rectangle((0, 0, width, 6), fill=accent)
    y = GUTTER + 6
    tag = f"HORIZON SUITE  ·  {a.module.upper()}"
    d.text((GUTTER, y), tag, font=f_brand, fill=accent)
    x = GUTTER + d.textlength(tag, font=f_brand)
    if a.flavour:
        ftxt = f"  ·  {a.flavour.upper()} ONLY"
        d.text((x, y), ftxt, font=f_brand, fill=hex_rgb(FLAVOUR_COLOURS[a.flavour]))
    if a.version:
        vtxt = f"v{a.version}"
        d.text((width - GUTTER - d.textlength(vtxt, font=f_brand), y), vtxt, font=f_brand, fill=MUTED)
    y += 26
    d.text((GUTTER, y), a.title, font=f_title, fill=TEXT)
    y += 46
    if a.subtitle:
        d.text((GUTTER, y), a.subtitle, font=f_sub, fill=MUTED)
        y += 34
    y += GUTTER

    if option:
        card.paste(option, (GUTTER, y))
        d.rectangle((GUTTER - 1, y - 1, GUTTER + option.width, y + option.height), outline=accent)
        y += option.height + GUTTER

    x = GUTTER + (width - 2 * GUTTER - pair_w) // 2
    labels = ([a.before_label] if a.before else []) + [after_label]
    colours = ([BEFORE] if a.before else []) + [AFTER]
    for shot, label, colour in zip(shots, labels, colours):
        d.text((x, y), label, font=f_label, fill=colour)
        card.paste(shot, (x, y + 36))
        x += shot.width + GUTTER
    y += 36 + max(s.height for s in shots) + GUTTER

    d.text((GUTTER, y), "github.com/Tacit-Labs/Horizon-Suite", font=font(REGULAR_FONTS, 16), fill=MUTED)

    card.save(a.out)
    print(f"{a.out}  {card.width}x{card.height}")


if __name__ == "__main__":
    main()
