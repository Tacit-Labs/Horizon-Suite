#!/usr/bin/env python3
"""Tests for tools/build_news.py. Run: python3 tools/test_build_news.py"""
import os
import struct
import sys
import tempfile
import unittest
import zlib

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import build_news as bn  # noqa: E402


def write_png(path, w, h):
    def chunk(tag, data):
        return struct.pack(">I", len(data)) + tag + data + struct.pack(">I", zlib.crc32(tag + data))
    raw = b"".join(b"\x00" + b"\x00\x00\x00" * w for _ in range(h))
    with open(path, "wb") as fh:
        fh.write(b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", struct.pack(">IIBBBBB", w, h, 8, 2, 0, 0, 0))
                 + chunk(b"IDAT", zlib.compress(raw)) + chunk(b"IEND", b""))


GOOD = """---
id: hello-world
title: Hello world
priority: 200
from: 2026-10-01
until: 2026-11-01
button: Open Focus
action: module focus
---
First paragraph
wraps here.

Second | paragraph "quoted".
"""


class Base(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.news = os.path.join(self.tmp.name, "news")
        self.media = os.path.join(self.tmp.name, "media")
        os.makedirs(self.news)
        os.makedirs(self.media)

    def tearDown(self):
        self.tmp.cleanup()

    def story(self, name, text):
        with open(os.path.join(self.news, name), "w", newline="\n") as fh:
            fh.write(text)

    def build(self):
        return bn.build(self.news, self.media)

    def assertRejects(self, text, fragment, name="hello-world.md"):
        self.story(name, text)
        with self.assertRaises(bn.StoryError) as ctx:
            self.build()
        self.assertIn(fragment, str(ctx.exception))


class BuildTests(Base):
    def test_good_story_compiles(self):
        self.story("hello-world.md", GOOD)
        lua = self.build()
        self.assertIn('id = "hello-world",', lua)
        self.assertIn('priority = 200,', lua)
        self.assertIn('fromDate = "2026-10-01",', lua)
        self.assertIn('untilDate = "2026-11-01",', lua)
        self.assertIn('action = { type = "module", moduleKey = "focus" },', lua)
        self.assertIn('"First paragraph wraps here.",', lua)
        self.assertIn('"Second || paragraph \\"quoted\\".",', lua)
        self.assertIn('layout = "card",', lua)

    def test_crlf_input_is_accepted(self):
        self.story("hello-world.md", GOOD.replace("\n", "\r\n"))
        self.assertIn('id = "hello-world",', self.build())

    def test_output_is_deterministic(self):
        self.story("hello-world.md", GOOD)
        self.story("another.md", GOOD.replace("hello-world", "another"))
        self.assertEqual(self.build(), self.build())
        self.assertLess(self.build().index('"another"'), self.build().index('"hello-world"'))

    def test_no_stories_gives_empty_feed(self):
        self.assertIn("addon.DashboardNewsFeed = {\n}", self.build())

    def test_url_action(self):
        self.story("hello-world.md", GOOD.replace("action: module focus", "action: url https://example.com/x"))
        self.assertIn('action = { type = "copy_url", url = "https://example.com/x" },', self.build())

    def test_featured_with_image(self):
        write_png(os.path.join(self.media, "pic.png"), 512, 256)
        self.story("hello-world.md", GOOD.replace("priority: 200", "priority: 200\nlayout: featured\nimage: pic.png"))
        lua = self.build()
        self.assertIn('image = "Interface/AddOns/HorizonSuite/media/news/pic.png",', lua)
        self.assertIn('layout = "featured",', lua)


class FormatTests(Base):
    def test_summary_and_blocks(self):
        self.story("hello-world.md", GOOD)
        lua = self.build()
        self.assertIn('summary = "First paragraph wraps here.",', lua)
        self.assertIn('{ kind = "p", text = "First paragraph wraps here." },', lua)
        self.assertIn('{ kind = "p", text = "Second || paragraph \\"quoted\\"." },', lua)
        self.assertIn("paragraphs = {", lua)

    def test_list_block(self):
        body = "Intro line.\n\n- one\n-   two\n  wrapped no\n\nAfter.\n"
        self.story("hello-world.md", GOOD.split("---\nFirst")[0] + "---\n" + body)
        lua = self.build()
        # a block with a non-bullet line is a paragraph, not a list
        self.assertIn('{ kind = "p", text = "- one - two wrapped no" },', lua)
        body = "Intro line.\n\n- one\n-   two  words\n\nAfter.\n"
        self.story("hello-world.md", GOOD.split("---\nFirst")[0] + "---\n" + body)
        lua = self.build()
        self.assertIn('{ kind = "list", items = { "one", "two words" } },', lua)
        self.assertIn('{ kind = "p", text = "After." },', lua)
        # list items are not paragraphs
        para = lua.split("paragraphs = {")[1]
        self.assertNotIn("two words", para)
        self.assertIn('"After."', para)

    def test_bold(self):
        body = "Has **bold** and **two | pipes**.\n\n- item **b**\n"
        self.story("hello-world.md", GOOD.split("---\nFirst")[0] + "---\n" + body)
        lua = self.build()
        self.assertIn('text = "Has |cffffffffbold|r and |cfffffffftwo || pipes|r." }', lua)
        self.assertIn('items = { "item |cffffffffb|r" }', lua)
        self.assertIn('summary = "Has |cffffffffbold|r and', lua)

    def test_literal_color_code_is_neutralised(self):
        body = "Try |cffff0000red|r here.\n"
        self.story("hello-world.md", GOOD.split("---\nFirst")[0] + "---\n" + body)
        self.assertIn("||cffff0000red||r", self.build())

    def test_unbalanced_bold_rejected(self):
        self.assertRejects(GOOD.replace("First paragraph", "First **paragraph"), "unbalanced")

    def test_must_start_with_paragraph(self):
        self.assertRejects(GOOD.split("---\nFirst")[0] + "---\n- a\n- b\n\nText.\n", "start with a paragraph")

    def test_button2_pairing(self):
        self.story("hello-world.md", GOOD.replace("action: module focus", "action: module focus\nbutton2: Guide\naction2: guide"))
        lua = self.build()
        self.assertIn('button2 = "Guide",', lua)
        self.assertIn('action2 = { type = "guide" },', lua)

    def test_button2_without_action2(self):
        self.assertRejects(GOOD.replace("action: module focus", "action: module focus\nbutton2: Guide"), "button2")

    def test_action2_without_button2(self):
        self.assertRejects(GOOD.replace("action: module focus", "action: module focus\naction2: guide"), "button2")

    def test_button2_needs_button(self):
        text = GOOD.replace("button: Open Focus\naction: module focus\n", "button2: Guide\naction2: guide\n")
        self.assertRejects(text, "needs 'button'")

    def test_bad_action2(self):
        self.assertRejects(GOOD.replace("action: module focus", "action: module focus\nbutton2: x\naction2: launch"), "unknown action")

    def test_modules(self):
        self.story("hello-world.md", GOOD.replace("priority: 200", "priority: 200\nmodules: vista, focus"))
        self.assertIn('modules = { "vista", "focus" },', self.build())

    def test_unknown_module_tag(self):
        self.assertRejects(GOOD.replace("priority: 200", "modules: vista, meridian"), "unknown module 'meridian'")

    def test_too_many_modules(self):
        self.assertRejects(GOOD.replace("priority: 200", "modules: vista, focus, axis, echo"), "at most 3")

    def test_duplicate_modules(self):
        self.assertRejects(GOOD.replace("priority: 200", "modules: vista, vista"), "duplicate module")

    def test_from_required(self):
        self.assertRejects(GOOD.replace("from: 2026-10-01\n", ""), "missing required field 'from'")


class RejectTests(Base):
    def test_missing_front_matter(self):
        self.assertRejects("no front matter\n", "front matter")

    def test_missing_title(self):
        self.assertRejects(GOOD.replace("title: Hello world\n", ""), "missing required field 'title'")

    def test_unknown_field(self):
        self.assertRejects(GOOD.replace("priority: 200", "colour: red"), "unknown field 'colour'")

    def test_id_must_match_file(self):
        self.assertRejects(GOOD, "must match the file name", name="other.md")

    def test_bad_id(self):
        self.assertRejects(GOOD.replace("id: hello-world", "id: Hello_World"), "id", name="Hello_World.md")

    def test_duplicate_field(self):
        self.assertRejects(GOOD.replace("priority: 200", "priority: 200\npriority: 3"), "duplicate field")

    def test_long_title(self):
        self.assertRejects(GOOD.replace("Hello world", "x" * 61), "60 characters")

    def test_bad_layout(self):
        self.assertRejects(GOOD.replace("priority: 200", "layout: banner"), "layout")

    def test_bad_priority(self):
        self.assertRejects(GOOD.replace("priority: 200", "priority: high"), "priority")

    def test_bad_date(self):
        self.assertRejects(GOOD.replace("2026-10-01", "2026-13-01"), "from")

    def test_until_before_from(self):
        self.assertRejects(GOOD.replace("until: 2026-11-01", "until: 2026-09-01"), "before")

    def test_bad_version(self):
        self.assertRejects(GOOD.replace("priority: 200", "untilVersion: six"), "untilVersion")

    def test_missing_image(self):
        self.assertRejects(GOOD.replace("priority: 200", "image: nope.png"), "not found")

    def test_image_not_power_of_two(self):
        write_png(os.path.join(self.media, "pic.png"), 500, 256)
        self.assertRejects(GOOD.replace("priority: 200", "image: pic.png"), "power of two")

    def test_image_too_big(self):
        write_png(os.path.join(self.media, "pic.png"), 2048, 256)
        self.assertRejects(GOOD.replace("priority: 200", "image: pic.png"), "1024")

    def test_image_not_png(self):
        with open(os.path.join(self.media, "pic.png"), "wb") as fh:
            fh.write(b"GIF89a" + b"\x00" * 30)
        self.assertRejects(GOOD.replace("priority: 200", "image: pic.png"), "not a PNG")

    def test_featured_needs_image(self):
        self.assertRejects(GOOD.replace("priority: 200", "layout: featured"), "needs an image")

    def test_button_without_action(self):
        self.assertRejects(GOOD.replace("action: module focus\n", ""), "both")

    def test_unknown_module(self):
        self.assertRejects(GOOD.replace("module focus", "module meridian"), "unknown module")

    def test_http_url(self):
        self.assertRejects(GOOD.replace("module focus", "url http://example.com"), "https")

    def test_unknown_action(self):
        self.assertRejects(GOOD.replace("module focus", "launch"), "unknown action")

    def test_empty_body(self):
        self.assertRejects(GOOD.split("---\nFirst")[0] + "---\n\n", "no text")


class CheckModeTests(Base):
    def test_check_passes_then_fails_after_edit(self):
        self.story("hello-world.md", GOOD)
        out = os.path.join(self.tmp.name, "Feed.lua")
        self.assertEqual(bn.main(["--news", self.news, "--media", self.media, "--out", out]), 0)
        self.assertEqual(bn.main(["--check", "--news", self.news, "--media", self.media, "--out", out]), 0)
        self.story("hello-world.md", GOOD.replace("Hello world", "Changed"))
        self.assertEqual(bn.main(["--check", "--news", self.news, "--media", self.media, "--out", out]), 1)

    def test_check_ignores_crlf_difference(self):
        self.story("hello-world.md", GOOD)
        out = os.path.join(self.tmp.name, "Feed.lua")
        bn.main(["--news", self.news, "--media", self.media, "--out", out])
        with open(out, "rb") as fh:
            data = fh.read()
        with open(out, "wb") as fh:
            fh.write(data.replace(b"\r\n", b"\n"))
        self.assertEqual(bn.main(["--check", "--news", self.news, "--media", self.media, "--out", out]), 0)

    def test_invalid_story_exits_2(self):
        self.story("hello-world.md", "nope\n")
        out = os.path.join(self.tmp.name, "Feed.lua")
        self.assertEqual(bn.main(["--news", self.news, "--media", self.media, "--out", out]), 2)


if __name__ == "__main__":
    unittest.main()
