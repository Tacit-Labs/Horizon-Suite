#!/usr/bin/env python3
"""Tests for tools/make_module_icons.py. Run: python3 tools/test_make_module_icons.py"""
import os
import shutil
import sys
import tempfile
import unittest

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import make_module_icons as mi  # noqa: E402

HEAD = ('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="#fff" '
        'stroke-width="1.6">')


def svg(body):
    return HEAD + body + "</svg>"


def close(a, b, tol=1e-6):
    return abs(a[0] - b[0]) < tol and abs(a[1] - b[1]) < tol


class PathTests(unittest.TestCase):
    def test_lines_absolute_and_relative(self):
        (pts, closed), = mi.parse_path("M2 3L5 3l0 4H1v-2z")
        self.assertTrue(closed)
        self.assertEqual(pts, [(2, 3), (5, 3), (5, 7), (1, 7), (1, 5)])

    def test_implicit_lineto_after_move(self):
        (pts, _), = mi.parse_path("m1 1 2 0 0 2")
        self.assertEqual(pts, [(1, 1), (3, 1), (3, 3)])

    def test_multiple_subpaths(self):
        subs = mi.parse_path("M1 1h4M1 5h4")
        self.assertEqual(len(subs), 2)

    def test_cubic_ends_on_endpoint(self):
        (pts, _), = mi.parse_path("M0 0C0 10 10 10 10 0")
        self.assertTrue(close(pts[-1], (10, 0)))
        self.assertGreater(max(y for _, y in pts), 7)

    def test_smooth_cubic_reflects_control(self):
        (pts, _), = mi.parse_path("M0 0C0 4 4 4 4 0S8 -4 8 0")
        self.assertTrue(close(pts[-1], (8, 0)))
        self.assertLess(min(y for _, y in pts), -2)

    def test_quadratic(self):
        (pts, _), = mi.parse_path("M0 0Q5 10 10 0")
        self.assertTrue(close(pts[-1], (10, 0)))

    def test_relative_arc_is_a_semicircle(self):
        (pts, _), = mi.parse_path("M2 12a10 10 0 0 1 20 0")
        self.assertTrue(close(pts[-1], (22, 12)))
        for x, y in pts[1:]:
            self.assertAlmostEqual(((x - 12) ** 2 + (y - 12) ** 2) ** 0.5, 10, places=6)
        self.assertLess(min(y for _, y in pts), 2.5)  # sweep=1 goes over the top

    def test_compact_numbers(self):
        (pts, _), = mi.parse_path("M5.5 20c.8-3.6 3.3-5.6 6.5-5.6")
        self.assertTrue(close(pts[-1], (12, 14.4)))

    def test_bad_command(self):
        with self.assertRaises(mi.IconError):
            mi.parse_path("M0 0T5 5")

    def test_missing_numbers(self):
        with self.assertRaises(mi.IconError):
            mi.parse_path("M0 0L5")

    def test_numbers_after_close_are_rejected_not_looped(self):
        with self.assertRaises(mi.IconError):
            mi.parse_path("M0 0L1 1Z 2 2")


class RenderTests(unittest.TestCase):
    def test_render_is_white_rgba_of_the_right_size(self):
        img = mi.render(svg('<circle cx="12" cy="12" r="8"/>'))
        self.assertEqual(img.size, (mi.SIZE, mi.SIZE))
        self.assertEqual(img.mode, "RGBA")
        for band in "RGB":
            self.assertEqual(img.getchannel(band).getextrema(), (255, 255), band)
        alpha = img.getchannel("A")
        self.assertEqual(alpha.getpixel((64, 64)), 0)        # centre is empty
        self.assertGreater(alpha.getpixel((64, 64 - 43)), 200)  # on the ring (r=8 -> 42.7px)

    def test_render_is_deterministic(self):
        src = svg('<rect x="3" y="3" width="18" height="18" rx="4"/><path d="M7 12h10"/>')
        self.assertEqual(mi.tga_bytes(mi.render(src)), mi.tga_bytes(mi.render(src)))

    def test_rejects_transform(self):
        with self.assertRaises(mi.IconError):
            mi.render(svg('<path transform="scale(2)" d="M1 1h4"/>'))

    def test_rejects_other_elements(self):
        with self.assertRaises(mi.IconError):
            mi.render(svg('<ellipse cx="12" cy="12" rx="4" ry="2"/>'))

    def test_rejects_other_viewbox(self):
        with self.assertRaises(mi.IconError):
            mi.render('<svg viewBox="0 0 32 32"><path d="M1 1h4"/></svg>')

    def test_shipped_sources_all_render(self):
        src = os.path.join(mi.REPO, "tools", "icons")
        names = sorted(n for n in os.listdir(src) if n.endswith(".svg"))
        self.assertEqual(len(names), 13)  # 9 module glyphs + welcome, news, search, patch notes
        for n in names:
            with open(os.path.join(src, n), encoding="utf-8") as fh:
                self.assertEqual(mi.render(fh.read()).size, (mi.SIZE, mi.SIZE), n)


class CheckModeTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.mkdtemp()
        self.src = os.path.join(self.tmp, "src")
        self.out = os.path.join(self.tmp, "out")
        os.makedirs(self.src)
        with open(os.path.join(self.src, "dot.svg"), "w") as fh:
            fh.write(svg('<circle cx="12" cy="12" r="5"/>'))

    def tearDown(self):
        shutil.rmtree(self.tmp)

    def run_main(self, *extra):
        return mi.main(["--src", self.src, "--out", self.out, *extra])

    def test_check_passes_then_fails_after_edit(self):
        self.assertEqual(self.run_main(), 0)
        self.assertEqual(self.run_main("--check"), 0)
        with open(os.path.join(self.src, "dot.svg"), "w") as fh:
            fh.write(svg('<circle cx="12" cy="12" r="6"/>'))
        self.assertEqual(self.run_main("--check"), 1)

    def test_check_fails_when_output_missing(self):
        self.assertEqual(self.run_main("--check"), 1)

    def test_invalid_source_exits_2(self):
        with open(os.path.join(self.src, "dot.svg"), "w") as fh:
            fh.write(svg('<polygon points="1,1 2,2"/>'))
        self.assertEqual(self.run_main(), 2)

    def test_circle_without_radius_exits_2(self):
        with open(os.path.join(self.src, "dot.svg"), "w") as fh:
            fh.write(svg('<circle cx="12" cy="12"/>'))
        self.assertEqual(self.run_main(), 2)

    def test_check_tolerates_one_unit_platform_noise(self):
        self.assertEqual(self.run_main(), 0)
        path = os.path.join(self.out, "dot.tga")
        img = mi.Image.open(path).convert("RGBA")
        r, g, b, a = img.split()
        a = a.point(lambda v: min(255, v + 1) if v else v)
        mi.Image.merge("RGBA", (r, g, b, a)).save(path, format="TGA", compression=None)
        self.assertEqual(self.run_main("--check"), 0)


if __name__ == "__main__":
    unittest.main()
