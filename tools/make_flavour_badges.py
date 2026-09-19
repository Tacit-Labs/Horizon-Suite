#!/usr/bin/env python3
"""Turn a game logo into the small TGA badge the patch-notes renderer draws inline.

The in-game patch notes tag a bullet with the client it applies to. That tag can
carry a logo, which has to be a texture the WoW client will load: uncompressed
32-bit TGA. Non power-of-two is fine — the addon already ships 776x150 and 128x19
TGAs in media/dashboard/footer.

A source that already carries alpha is used as it is. One that does not — a logo
flattened onto white — has its background removed by flooding inwards from the
corners, so that only white connected to an edge is dropped and the near-white
lettering inside the mark survives. The choice is automatic; --force-key overrides.

Usage:
    python3 tools/make_flavour_badges.py forever.png media/flavours/forever.tga
    python3 tools/make_flavour_badges.py --height 96 --preview midnight.png media/flavours/retail.tga

--preview writes <out>.preview.png at the size the badge is actually drawn in the
UI, which is the only honest way to judge whether a detailed logo survives being
shrunk to the height of a line of text.
"""

import argparse
import sys
from collections import deque

try:
    from PIL import Image
except ImportError:
    sys.exit("Pillow is required: python3 -m pip install Pillow")

# Height the badge is stored at. Drawn far smaller, but storing a little larger
# than the draw size keeps the client's downscale from looking chewed.
DEFAULT_HEIGHT = 64
# Height the escape draws at, used only for the preview.
DRAW_HEIGHT = 20


def strip_background(im, tolerance):
    """Clear pixels reachable from any edge that are within tolerance of white.

    Flood fill rather than a global colour key: white inside the artwork is kept
    because it is not connected to an edge.
    """
    im = im.convert("RGBA")
    w, h = im.size
    px = im.load()
    seen = bytearray(w * h)
    queue = deque()

    def near_white(p):
        return p[0] >= tolerance and p[1] >= tolerance and p[2] >= tolerance

    for x in range(w):
        for y in (0, h - 1):
            queue.append((x, y))
    for y in range(h):
        for x in (0, w - 1):
            queue.append((x, y))

    while queue:
        x, y = queue.popleft()
        if x < 0 or y < 0 or x >= w or y >= h:
            continue
        idx = y * w + x
        if seen[idx]:
            continue
        seen[idx] = 1
        p = px[x, y]
        if p[3] == 0:
            pass
        elif not near_white(p):
            continue
        px[x, y] = (p[0], p[1], p[2], 0)
        queue.extend(((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)))

    return im


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("source", help="source logo (PNG, JPG, WEBP)")
    ap.add_argument("out", help="destination .tga")
    ap.add_argument("--height", type=int, default=DEFAULT_HEIGHT,
                    help=f"stored height in px (default {DEFAULT_HEIGHT})")
    ap.add_argument("--tolerance", type=int, default=244,
                    help="channel value at or above which an edge-connected pixel "
                         "counts as background (default 244)")
    ap.add_argument("--force-key", action="store_true",
                    help="key the background out even if the source already has alpha")
    ap.add_argument("--preview", action="store_true",
                    help=f"also write <out>.preview.png at {DRAW_HEIGHT}px, the drawn size")
    args = ap.parse_args()

    im = Image.open(args.source).convert("RGBA")

    # Only key out a background when there is one. A source that already carries
    # alpha is left alone: flooding it would march through the soft edge of the
    # artwork and eat near-white lettering, which is exactly what the FOREVER and
    # WORLD OF WARCRAFT wordmarks are made of.
    px = im.load()
    w0, h0 = im.size
    corners = (px[0, 0], px[w0 - 1, 0], px[0, h0 - 1], px[w0 - 1, h0 - 1])
    if args.force_key or any(c[3] != 0 for c in corners):
        im = strip_background(im, args.tolerance)
    else:
        print("source already has a transparent background; leaving alpha alone")

    bbox = im.getbbox()
    if bbox:
        im = im.crop(bbox)

    w, h = im.size
    target_h = args.height
    target_w = max(1, round(w * target_h / h))
    im = im.resize((target_w, target_h), Image.LANCZOS)

    im.save(args.out)
    draw_w = max(1, round(target_w * DRAW_HEIGHT / target_h))
    print(f"{args.out}: {im.size[0]}x{im.size[1]} RGBA uncompressed TGA")
    # The escape only makes sense for a path inside the addon, so only offer it then.
    if not args.out.startswith(("/", "..")):
        tex = args.out.replace("/", chr(92))
        print(f"  draw it as |TInterface\\AddOns\\HorizonSuite\\{tex}:{DRAW_HEIGHT}:{draw_w}|t")
    else:
        print("  (out is outside the addon; move it under media/ for an in-game path)")

    if args.preview:
        prev_w = max(1, round(target_w * DRAW_HEIGHT / target_h))
        im.resize((prev_w, DRAW_HEIGHT), Image.LANCZOS).save(args.out + ".preview.png")
        print(f"  preview at drawn size: {args.out}.preview.png ({prev_w}x{DRAW_HEIGHT})")


if __name__ == "__main__":
    main()
