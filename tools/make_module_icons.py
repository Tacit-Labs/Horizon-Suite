#!/usr/bin/env python3
"""Render the dashboard's monoline module icons from tools/icons/*.svg.

Each source is a 24x24 SVG of stroked <path>, <circle> and <rect> elements (no fills, no
transforms). Each is drawn at 8x size and downsampled, giving a 128x128 white TGA with
anti-aliased alpha in media/icons/modules/. The game tints it (module colour, grey or the
sidebar's muted tone), so one file serves every surface and size.

Usage:
  python3 tools/make_module_icons.py          # render every icon
  python3 tools/make_module_icons.py --check  # exit 1 if a committed icon is stale

Path data supports M L H V C S Q A Z (absolute and relative); write arc flags space-separated.

Requires Pillow (dev tooling only; nothing here ships).
"""
import argparse
import io
import math
import os
import re
import sys
import xml.etree.ElementTree as ET

try:
    from PIL import Image, ImageChops, ImageDraw
except ImportError:  # pragma: no cover
    sys.exit("make_module_icons: Pillow is required (pip install Pillow)")

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DEFAULT_SRC = os.path.join(REPO, "tools", "icons")
DEFAULT_OUT = os.path.join(REPO, "media", "icons", "modules")

SIZE = 128          # output pixels
SUPERSAMPLE = 8     # drawn at SIZE * SUPERSAMPLE, then downsampled
VIEWBOX = 24.0
CURVE_STEPS = 32    # line segments per curve or arc
CIRCLE_STEPS = 128

# Any letter is a command token, so an unsupported one is rejected rather than skipped.
TOKEN_RE = re.compile(r"[A-DF-Za-df-z]|[-+]?(?:\d+\.?\d*|\.\d+)(?:[eE][-+]?\d+)?")
ARGS = {"M": 2, "L": 2, "H": 1, "V": 1, "C": 6, "S": 4, "Q": 4, "A": 7, "Z": 0}


class IconError(Exception):
    pass


def _cubic(p0, p1, p2, p3, steps=CURVE_STEPS):
    out = []
    for i in range(1, steps + 1):
        t = i / steps
        u = 1 - t
        out.append((u ** 3 * p0[0] + 3 * u * u * t * p1[0] + 3 * u * t * t * p2[0] + t ** 3 * p3[0],
                    u ** 3 * p0[1] + 3 * u * u * t * p1[1] + 3 * u * t * t * p2[1] + t ** 3 * p3[1]))
    return out


def _quad(p0, p1, p2, steps=CURVE_STEPS):
    out = []
    for i in range(1, steps + 1):
        t = i / steps
        u = 1 - t
        out.append((u * u * p0[0] + 2 * u * t * p1[0] + t * t * p2[0],
                    u * u * p0[1] + 2 * u * t * p1[1] + t * t * p2[1]))
    return out


def _arc(p1, rx, ry, phi_deg, large, sweep, p2, steps=CURVE_STEPS):
    """SVG endpoint arc to points (SVG 1.1 implementation notes, F.6.5)."""
    (x1, y1), (x2, y2) = p1, p2
    if (x1, y1) == (x2, y2):
        return []
    rx, ry = abs(rx), abs(ry)
    if rx == 0 or ry == 0:
        return [p2]
    phi = math.radians(phi_deg)
    cos_p, sin_p = math.cos(phi), math.sin(phi)
    dx, dy = (x1 - x2) / 2, (y1 - y2) / 2
    x1p = cos_p * dx + sin_p * dy
    y1p = -sin_p * dx + cos_p * dy
    lam = (x1p * x1p) / (rx * rx) + (y1p * y1p) / (ry * ry)
    if lam > 1:
        rx, ry = rx * math.sqrt(lam), ry * math.sqrt(lam)
    num = rx * rx * ry * ry - rx * rx * y1p * y1p - ry * ry * x1p * x1p
    den = rx * rx * y1p * y1p + ry * ry * x1p * x1p
    coef = math.sqrt(max(0.0, num / den)) if den else 0.0
    if bool(large) == bool(sweep):
        coef = -coef
    cxp = coef * rx * y1p / ry
    cyp = -coef * ry * x1p / rx
    cx = cos_p * cxp - sin_p * cyp + (x1 + x2) / 2
    cy = sin_p * cxp + cos_p * cyp + (y1 + y2) / 2

    def angle(ux, uy, vx, vy):
        return math.atan2(ux * vy - uy * vx, ux * vx + uy * vy)

    th1 = angle(1, 0, (x1p - cxp) / rx, (y1p - cyp) / ry)
    dth = angle((x1p - cxp) / rx, (y1p - cyp) / ry, (-x1p - cxp) / rx, (-y1p - cyp) / ry)
    if not sweep and dth > 0:
        dth -= 2 * math.pi
    elif sweep and dth < 0:
        dth += 2 * math.pi
    out = []
    for i in range(1, steps + 1):
        th = th1 + dth * i / steps
        out.append((cx + rx * math.cos(th) * cos_p - ry * math.sin(th) * sin_p,
                    cy + rx * math.cos(th) * sin_p + ry * math.sin(th) * cos_p))
    out[-1] = p2
    return out


def parse_path(d):
    """Return a list of (points, closed) subpaths in viewBox units."""
    tokens = TOKEN_RE.findall(d)
    subpaths, pts = [], None
    cur = start = (0.0, 0.0)
    last_ctrl = None
    cmd = None
    i = 0

    def take(n):
        nonlocal i
        vals = tokens[i:i + n]
        if len(vals) < n or any(v.isalpha() for v in vals):
            raise IconError(f"path command {cmd!r} expects {n} numbers near token {i}")
        i += n
        return [float(v) for v in vals]

    while i < len(tokens):
        if tokens[i].isalpha():
            cmd = tokens[i]
            i += 1
        elif cmd is None:
            raise IconError("path data must start with a command")
        up, rel = cmd.upper(), cmd.islower()
        if up not in ARGS:
            raise IconError(f"unsupported path command {cmd!r}")
        ox, oy = cur if rel else (0.0, 0.0)
        if up == "Z":
            if i < len(tokens) and not tokens[i].isalpha():
                raise IconError("numbers after Z need a command letter")
            if pts:
                subpaths.append((pts, True))
            pts, cur, last_ctrl = None, start, None
            continue
        a = take(ARGS[up])
        if up == "M":
            if pts and len(pts) > 1:
                subpaths.append((pts, False))
            cur = start = (ox + a[0], oy + a[1])
            pts, last_ctrl = [cur], None
            cmd = "l" if rel else "L"  # extra pairs after M are implicit lines
            continue
        if pts is None:
            pts = [cur]
        if up == "L":
            nxt = (ox + a[0], oy + a[1])
            pts.append(nxt)
            last_ctrl = None
        elif up == "H":
            nxt = ((cur[0] if rel else 0.0) + a[0], cur[1])
            pts.append(nxt)
            last_ctrl = None
        elif up == "V":
            nxt = (cur[0], (cur[1] if rel else 0.0) + a[0])
            pts.append(nxt)
            last_ctrl = None
        elif up == "C":
            c1, c2, nxt = (ox + a[0], oy + a[1]), (ox + a[2], oy + a[3]), (ox + a[4], oy + a[5])
            pts.extend(_cubic(cur, c1, c2, nxt))
            last_ctrl = c2
        elif up == "S":
            c1 = (2 * cur[0] - last_ctrl[0], 2 * cur[1] - last_ctrl[1]) if last_ctrl else cur
            c2, nxt = (ox + a[0], oy + a[1]), (ox + a[2], oy + a[3])
            pts.extend(_cubic(cur, c1, c2, nxt))
            last_ctrl = c2
        elif up == "Q":
            c1, nxt = (ox + a[0], oy + a[1]), (ox + a[2], oy + a[3])
            pts.extend(_quad(cur, c1, nxt))
            last_ctrl = None
        elif up == "A":
            nxt = (ox + a[5], oy + a[6])
            pts.extend(_arc(cur, a[0], a[1], a[2], a[3], a[4], nxt))
            last_ctrl = None
        cur = nxt
    if pts and len(pts) > 1:
        subpaths.append((pts, False))
    return subpaths


def _circle(cx, cy, r):
    pts = [(cx + r * math.cos(2 * math.pi * k / CIRCLE_STEPS),
            cy + r * math.sin(2 * math.pi * k / CIRCLE_STEPS)) for k in range(CIRCLE_STEPS)]
    return [(pts, True)]


def _rect(x, y, w, h, rx):
    rx = min(rx, w / 2, h / 2)
    if rx <= 0:
        return [([(x, y), (x + w, y), (x + w, y + h), (x, y + h)], True)]
    d = (f"M{x + rx} {y}H{x + w - rx}A{rx} {rx} 0 0 1 {x + w} {y + rx}V{y + h - rx}"
         f"A{rx} {rx} 0 0 1 {x + w - rx} {y + h}H{x + rx}A{rx} {rx} 0 0 1 {x} {y + h - rx}"
         f"V{y + rx}A{rx} {rx} 0 0 1 {x + rx} {y}Z")
    return parse_path(d)


def load_svg(text):
    """Return (subpaths, stroke_width) for an icon source."""
    root = ET.fromstring(text)
    if root.get("viewBox", "").split() != ["0", "0", "24", "24"]:
        raise IconError("viewBox must be '0 0 24 24'")
    width = float(root.get("stroke-width", "1.6"))
    subpaths = []
    for el in root.iter():
        tag = el.tag.split("}")[-1]
        if tag == "svg":
            continue
        if el.get("transform"):
            raise IconError(f"<{tag}> has a transform; bake it into the coordinates")
        if tag == "path":
            subpaths += parse_path(el.get("d", ""))
        elif tag == "circle":
            subpaths += _circle(float(el.get("cx", 0)), float(el.get("cy", 0)), float(el.get("r")))
        elif tag == "rect":
            subpaths += _rect(float(el.get("x", 0)), float(el.get("y", 0)), float(el.get("width")),
                              float(el.get("height")), float(el.get("rx", 0)))
        else:
            raise IconError(f"unsupported element <{tag}> (use path, circle or rect)")
    if not subpaths:
        raise IconError("icon draws nothing")
    return subpaths, width


def render(text):
    """Render an icon source to a SIZE x SIZE RGBA image: white, alpha from the stroke."""
    subpaths, stroke = load_svg(text)
    big = SIZE * SUPERSAMPLE
    scale = big / VIEWBOX
    w = stroke * scale
    r = w / 2
    mask = Image.new("L", (big, big), 0)
    draw = ImageDraw.Draw(mask)
    for pts, closed in subpaths:
        px = [(x * scale, y * scale) for x, y in pts]
        if closed:
            px.append(px[0])
        draw.line(px, fill=255, width=max(1, round(w)))
        for x, y in px:  # round caps and joins
            draw.ellipse((x - r, y - r, x + r, y + r), fill=255)
    alpha = mask.resize((SIZE, SIZE), Image.LANCZOS)
    img = Image.new("RGBA", (SIZE, SIZE), (255, 255, 255, 0))
    img.putalpha(alpha)
    return img


def tga_bytes(img):
    buf = io.BytesIO()
    img.save(buf, format="TGA", compression=None)
    return buf.getvalue()


# Floating-point rasterising can differ by a unit between platforms (the committed icons are
# rendered on macOS, CI runs on Linux), so --check allows a tiny alpha difference rather than
# demanding identical bytes. A real edit to a source moves far more than this.
CHECK_TOLERANCE = 2


def matches(path, img):
    """Whether the committed icon at `path` matches a fresh render within CHECK_TOLERANCE."""
    try:
        committed = Image.open(path)
        committed.load()
    except (FileNotFoundError, OSError):
        return False
    if committed.size != img.size or committed.mode != img.mode:
        return False
    diff = ImageChops.difference(committed, img)
    return all(hi <= CHECK_TOLERANCE for _, hi in diff.getextrema())


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--check", action="store_true", help="exit 1 if a committed icon is stale")
    ap.add_argument("--src", default=DEFAULT_SRC)
    ap.add_argument("--out", default=DEFAULT_OUT)
    args = ap.parse_args(argv)
    names = sorted(n[:-4] for n in os.listdir(args.src) if n.endswith(".svg"))
    if not names:
        print("make_module_icons: no .svg sources found", file=sys.stderr)
        return 2
    stale = []
    for name in names:
        with open(os.path.join(args.src, name + ".svg"), encoding="utf-8") as fh:
            try:
                img = render(fh.read())
            except (IconError, ET.ParseError, ValueError, TypeError) as e:
                print(f"make_module_icons: {name}.svg: {e}", file=sys.stderr)
                return 2
        out = os.path.join(args.out, name + ".tga")
        if args.check:
            if not matches(out, img):
                stale.append(name)
        else:
            os.makedirs(args.out, exist_ok=True)
            with open(out, "wb") as fh:
                fh.write(tga_bytes(img))
    if stale:
        print("make_module_icons: out of date: " + ", ".join(stale)
              + "; run `python3 tools/make_module_icons.py` and commit the result", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
