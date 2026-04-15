#!/usr/bin/env python3
"""
gen_options_viz.py
Parses HorizonSuite/options/OptionsData.lua and generates a self-contained
interactive HTML visualizer for reviewing and planning option changes.

Usage:  python tools/gen_options_viz.py
Output: tools/options_viz.html
"""

import re
import json
import sys
from pathlib import Path
from datetime import date

# ---------------------------------------------------------------------------
# Paths
# ---------------------------------------------------------------------------
ADDON_ROOT = Path(__file__).resolve().parent.parent
LUA_FILE   = ADDON_ROOT / "options" / "OptionsData.lua"
OUT_FILE   = Path(__file__).resolve().parent / "options_viz.html"

# ---------------------------------------------------------------------------
# Module metadata
# ---------------------------------------------------------------------------
MODULE_ORDER  = [None, "focus", "presence", "vista", "insight", "cache", "essence"]
MODULE_LABELS = {
    None:       "Global",
    "focus":    "Focus",
    "presence": "Presence",
    "vista":    "Vista",
    "insight":  "Insight",
    "cache":    "Cache",
    "essence":  "Essence",
}

# ---------------------------------------------------------------------------
# Lua parsing helpers
# ---------------------------------------------------------------------------

def lua_key_to_label(key: str) -> str:
    """Turn OPTIONS_FOCUS_PANEL_WIDTH → 'Panel Width'."""
    for prefix in ("OPTIONS_", "DASH_", "PRESENCE_", "DASHBOARD_"):
        key = key.replace(prefix, "")
    parts = key.split("_")
    return " ".join(p.capitalize() for p in parts if p)


def extract_str(text: str, field: str) -> str | None:
    """
    Extract a string field value from a chunk of Lua option text.
    Handles:
      field = L["KEY"] or "fallback"
      field = "direct string"
      field = BrandModule("modulename")
      field = L["KEY"]
    """
    # L["KEY"] or "fallback"
    m = re.search(rf'\b{field}\s*=\s*L\["[^"]+"\]\s*or\s*"([^"]*)"', text)
    if m:
        return m.group(1).strip()

    # "direct string"  (but not inside a larger expression on the same line)
    m = re.search(rf'\b{field}\s*=\s*"([^"]*)"', text)
    if m:
        val = m.group(1).strip()
        if val:
            return val

    # BrandModule("modulename")
    m = re.search(rf'\b{field}\s*=\s*BrandModule\s*\(\s*"([^"]+)"\s*\)', text)
    if m:
        return m.group(1).capitalize()

    # (BrandModule("name") or "Fallback") .. suffix  — grab the "Fallback"
    m = re.search(rf'\b{field}\s*=\s*\(BrandModule\("[^"]+"\)\s*or\s*"([^"]+)"\)', text)
    if m:
        return m.group(1).strip()

    # L["KEY"]  — convert key to readable label
    m = re.search(rf'\b{field}\s*=\s*L\["([^"]+)"\]', text)
    if m:
        return lua_key_to_label(m.group(1))

    return None


def extract_num(text: str, field: str) -> int | None:
    m = re.search(rf'\b{field}\s*=\s*(-?\d+)', text)
    return int(m.group(1)) if m else None


def extract_lua_key(text: str, field: str) -> str | None:
    """Extract the L["KEY"] identifier, e.g. OPTIONS_FOCUS_PANEL_WIDTH."""
    m = re.search(rf'\b{field}\s*=\s*L\["([^"]+)"\]', text)
    return m.group(1) if m else None


# ---------------------------------------------------------------------------
# Brace-depth scanner
# ---------------------------------------------------------------------------

def find_matching_brace(text: str, start: int) -> int:
    """
    Given text and the index of an opening '{', return the index of the
    matching '}'. Skips over Lua strings and function...end blocks.
    Returns -1 if not found.
    """
    depth = 0
    i = start
    in_string_sq = False
    in_string_dq = False
    n = len(text)

    while i < n:
        c = text[i]

        # Skip Lua long strings [[ ... ]]  (simplified)
        if not in_string_sq and not in_string_dq and text[i:i+2] == "[[":
            end = text.find("]]", i + 2)
            i = end + 2 if end != -1 else n
            continue

        # Toggle double-quote strings
        if c == '"' and not in_string_sq:
            in_string_dq = not in_string_dq
            i += 1
            continue
        if c == "'" and not in_string_dq:
            in_string_sq = not in_string_sq
            i += 1
            continue

        if in_string_sq or in_string_dq:
            if c == '\\':
                i += 2  # skip escaped char
            else:
                i += 1
            continue

        # Skip Lua comments
        if text[i:i+2] == "--":
            eol = text.find("\n", i)
            i = eol + 1 if eol != -1 else n
            continue

        if c == '{':
            depth += 1
        elif c == '}':
            depth -= 1
            if depth == 0:
                return i

        i += 1

    return -1


# ---------------------------------------------------------------------------
# Option entry parser
# ---------------------------------------------------------------------------

KNOWN_TYPES = {
    "section", "toggle", "slider", "dropdown", "color",
    "button", "editbox", "header", "reorderList",
    "presencePreview", "moduleReloadPrompt", "colorMatrixFull", "blacklistGrid",
}

TYPE_RE  = re.compile(r'\btype\s*=\s*"([^"]+)"')
DBKEY_RE = re.compile(r'\bdbKey\s*=\s*"([^"]+)"')


def parse_option_entry(chunk: str) -> dict | None:
    """Parse a single option entry text chunk into a dict."""
    tm = TYPE_RE.search(chunk)
    if not tm:
        return None
    opt_type = tm.group(1)

    opt: dict = {"type": opt_type}

    name = extract_str(chunk, "name")
    if name:
        opt["name"] = name

    name_key = extract_lua_key(chunk, "name")
    if name_key:
        opt["nameKey"] = name_key

    desc = extract_str(chunk, "desc")
    if desc:
        opt["desc"] = desc

    dm = DBKEY_RE.search(chunk)
    if dm:
        opt["dbKey"] = dm.group(1)

    if opt_type == "slider":
        mn = extract_num(chunk, "min")
        mx = extract_num(chunk, "max")
        if mn is not None:
            opt["min"] = mn
        if mx is not None:
            opt["max"] = mx

    return opt


def extract_option_entries(options_text: str) -> list[dict]:
    """
    Scan a block of Lua text (the body of an options table or function)
    and return a list of parsed option dicts.

    Strategy: find every `type = "..."` occurrence, then back-scan for
    the enclosing `{` and forward-scan to the matching `}`.
    """
    entries = []
    seen_spans: list[tuple[int, int]] = []

    for m in TYPE_RE.finditer(options_text):
        opt_type = m.group(1)
        if opt_type not in KNOWN_TYPES:
            continue

        pos = m.start()

        # Back-scan to find opening '{' of this entry
        brace_start = options_text.rfind("{", 0, pos)
        if brace_start == -1:
            continue

        # Check this isn't inside an already-parsed span
        if any(s <= brace_start < e for s, e in seen_spans):
            continue

        brace_end = find_matching_brace(options_text, brace_start)
        if brace_end == -1:
            continue

        chunk = options_text[brace_start:brace_end + 1]
        opt = parse_option_entry(chunk)
        if opt:
            entries.append(opt)
            seen_spans.append((brace_start, brace_end))

    return entries


# ---------------------------------------------------------------------------
# Category parser
# ---------------------------------------------------------------------------

CAT_KEY_RE    = re.compile(r'\bkey\s*=\s*"([^"]+)"')
MODULE_KEY_RE = re.compile(r'\bmoduleKey\s*=\s*(?:"([^"]+)"|(nil))')


def parse_category_block(block: str) -> dict | None:
    """Parse a single category block (the text between the outer { })."""
    km = CAT_KEY_RE.search(block)
    if not km:
        return None

    cat: dict = {"key": km.group(1)}

    # Find where options= starts so metadata extraction only sees the preamble,
    # preventing option names/descs from polluting category-level fields.
    options_match = re.search(r'\boptions\s*=\s*', block)
    preamble = block[:options_match.start()] if options_match else block

    name = extract_str(preamble, "name")
    cat["name"] = name or cat["key"]

    desc = extract_str(preamble, "desc")
    if desc:
        cat["desc"] = desc

    mm = MODULE_KEY_RE.search(preamble)
    if not mm:
        mm = MODULE_KEY_RE.search(block[:300])  # fallback
    if mm:
        cat["moduleKey"] = mm.group(1) if mm.group(1) else None
    else:
        cat["moduleKey"] = None

    if not options_match:
        cat["sections"] = []
        return cat

    opts_start = options_match.end()
    opts_text  = block[opts_start:]
    stripped   = opts_text.lstrip()

    if stripped.startswith("{"):
        # Direct table — extract only the interior of the braces
        brace_pos = opts_start + opts_text.index("{")
        brace_end = find_matching_brace(block, brace_pos)
        content = block[brace_pos + 1:brace_end] if brace_end != -1 else opts_text
    else:
        # Function, IIFE, or anything else:
        # Don't try to find the function boundary — just pass the entire
        # remaining text to extract_option_entries, which scans for
        # `type = "..."` patterns and is safe to run over extra text.
        content = opts_text

    raw_options = extract_option_entries(content)

    # Group by section
    sections: list[dict] = []
    current_section: dict | None = None

    for opt in raw_options:
        if opt["type"] == "section":
            current_section = {
                "name": opt.get("name", ""),
                "options": [],
            }
            sections.append(current_section)
        else:
            if current_section is None:
                current_section = {"name": "", "options": []}
                sections.append(current_section)
            current_section["options"].append(opt)

    cat["sections"] = sections
    return cat


# ---------------------------------------------------------------------------
# Main parser
# ---------------------------------------------------------------------------

def parse_options_data(lua_path: Path) -> list[dict]:
    text = lua_path.read_text(encoding="utf-8")

    # Find OptionCategories table
    start_match = re.search(r'\blocal\s+OptionCategories\s*=\s*\{', text)
    if not start_match:
        sys.exit(f"ERROR: Could not find 'OptionCategories' in {lua_path}")

    table_start = start_match.end() - 1  # index of the opening '{'
    table_end   = find_matching_brace(text, table_start)
    if table_end == -1:
        sys.exit("ERROR: Could not find end of OptionCategories table")

    table_body = text[table_start + 1:table_end]

    # Split into top-level category blocks (depth-1 entries)
    categories: list[dict] = []
    i = 0
    n = len(table_body)

    while i < n:
        # Find the next top-level '{'
        brace = table_body.find("{", i)
        if brace == -1:
            break

        end = find_matching_brace(table_body, brace)
        if end == -1:
            break

        block = table_body[brace + 1:end]
        cat = parse_category_block(block)
        if cat and cat.get("key"):
            categories.append(cat)

        i = end + 1

    return categories


# ---------------------------------------------------------------------------
# Build JSON structure
# ---------------------------------------------------------------------------

def build_data(categories: list[dict]) -> dict:
    # Group categories by moduleKey preserving MODULE_ORDER
    module_groups: dict = {}
    for mk in MODULE_ORDER:
        module_groups[str(mk)] = {
            "moduleKey": mk,
            "label": MODULE_LABELS[mk],
            "categories": [],
        }

    # Assign categories to groups; any unknown module goes last
    for cat in categories:
        mk = cat.get("moduleKey")
        key = str(mk)
        if key not in module_groups:
            module_groups[key] = {
                "moduleKey": mk,
                "label": (mk or "Other").capitalize(),
                "categories": [],
            }
        module_groups[key]["categories"].append(cat)

    return {
        "generated": str(date.today()),
        "moduleOrder": [str(mk) for mk in MODULE_ORDER],
        "modules": module_groups,
        "categories": categories,
    }


# ---------------------------------------------------------------------------
# HTML generator
# ---------------------------------------------------------------------------

TYPE_COLORS = {
    "toggle":           "#3b82f6",
    "slider":           "#22c55e",
    "dropdown":         "#f59e0b",
    "color":            "#ec4899",
    "button":           "#a855f7",
    "editbox":          "#6b7280",
    "header":           "#6b7280",
    "reorderList":      "#6b7280",
    "presencePreview":  "#6b7280",
    "moduleReloadPrompt": "#6b7280",
    "colorMatrixFull":  "#6b7280",
    "blacklistGrid":    "#6b7280",
}


def generate_html(data: dict, pages_mode: bool = False) -> str:
    """
    Generate the visualizer HTML.

    standalone (default): DATA embedded, no server calls, SESSION_ID = null.
    pages_mode=True:      DATA embedded at build time; SESSION_ID read from URL
                          params at runtime (Cloudflare Pages / GitHub deploy).
    """
    # Sentinel strings replaced after the f-string is built (avoids escaping issues).
    DATA_SENTINEL       = "__DATA_SENTINEL__"
    SESSION_ID_SENTINEL = "__SESSION_ID_SENTINEL__"
    IS_HOSTED_SENTINEL  = "__IS_HOSTED_SENTINEL__"

    data_json  = json.dumps(data, ensure_ascii=False)
    today      = data["generated"]

    html = f"""<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>HorizonSuite Options Visualizer</title>
<style>
*,*::before,*::after{{box-sizing:border-box;margin:0;padding:0}}
:root{{
  --bg:        #0f1117;
  --surface:   #1a1d27;
  --surface2:  #22263a;
  --surface3:  #2a2f45;
  --border:    #333852;
  --text:      #e2e8f0;
  --muted:     #8892a4;
  --accent:    #6366f1;
  --accent-h:  #818cf8;
  --danger:    #ef4444;
  --warn:      #f59e0b;
  --sidebar-w: 220px;
  --plan-w:    260px;
  --header-h:  52px;
}}
html,body{{height:100%;overflow:hidden;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',sans-serif;font-size:13px;background:var(--bg);color:var(--text)}}

/* ── Layout ── */
#app{{display:flex;flex-direction:column;height:100vh}}
#header{{
  height:var(--header-h);flex-shrink:0;
  display:flex;align-items:center;justify-content:space-between;
  padding:0 16px;background:var(--surface);border-bottom:1px solid var(--border);
  gap:12px;
}}
#header h1{{font-size:15px;font-weight:600;letter-spacing:0.02em;white-space:nowrap}}
#header-right{{display:flex;gap:8px;align-items:center}}
#columns{{display:flex;flex:1;overflow:hidden}}

/* ── Sidebar ── */
#sidebar{{
  width:var(--sidebar-w);flex-shrink:0;
  overflow-y:auto;background:var(--surface);border-right:1px solid var(--border);
  padding:8px 0;
}}
.mod-group{{margin-bottom:4px}}
.mod-label{{
  padding:6px 14px 4px;font-size:10px;font-weight:700;letter-spacing:0.1em;
  text-transform:uppercase;color:var(--muted);cursor:default;
}}
.mod-label.has-cats{{cursor:pointer;user-select:none}}
.mod-label.has-cats:hover{{color:var(--text)}}
.cat-list{{}}
.cat-item{{
  padding:5px 14px 5px 22px;cursor:pointer;
  color:var(--muted);font-size:12.5px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;
  border-left:2px solid transparent;transition:all 0.1s;
}}
.cat-item:hover{{color:var(--text);background:var(--surface2)}}
.cat-item.active{{color:var(--text);border-left-color:var(--accent);background:var(--surface2);font-weight:500}}

/* ── Main ── */
#main{{
  flex:1;overflow-y:auto;padding:16px 20px;
  display:flex;flex-direction:column;gap:0;
}}
#main-title{{font-size:20px;font-weight:700;margin-bottom:4px}}
#main-desc{{color:var(--muted);font-size:12px;margin-bottom:16px;line-height:1.5}}
#main-stats{{font-size:11px;color:var(--muted);margin-bottom:16px}}

/* ── Section cards ── */
.section-card{{
  background:var(--surface);border:1px solid var(--border);border-radius:8px;
  margin-bottom:10px;overflow:hidden;
}}
.section-head{{
  display:flex;align-items:center;justify-content:space-between;
  padding:9px 12px;cursor:pointer;user-select:none;
  background:var(--surface2);
}}
.section-head:hover{{background:var(--surface3)}}
.section-head-left{{display:flex;align-items:center;gap:8px}}
.section-chevron{{font-size:10px;color:var(--muted);transition:transform 0.15s}}
.section-card.collapsed .section-chevron{{transform:rotate(-90deg)}}
.section-name{{font-size:12px;font-weight:600;letter-spacing:0.03em}}
.section-count{{font-size:10px;color:var(--muted);background:var(--surface3);padding:1px 6px;border-radius:99px}}
.section-card.collapsed .section-count{{background:var(--border)}}
.section-body{{padding:4px 0}}
.section-card.collapsed .section-body{{display:none}}
.empty-section{{padding:10px 14px;color:var(--muted);font-size:11px;font-style:italic}}

/* ── Option rows ── */
.opt-row{{
  display:flex;align-items:flex-start;gap:0;
  padding:6px 8px;margin:2px 6px;border-radius:6px;
  border:1px solid transparent;cursor:pointer;position:relative;
  transition:background 0.1s,border-color 0.1s;
  user-select:none;
}}
.opt-row:hover{{background:var(--surface2)}}
.opt-row.selected{{background:var(--surface3);border-color:var(--accent)}}
.opt-row.marked-remove{{background:#3a1212;border-color:#7f1d1d}}
.opt-row.marked-combine{{border-color:var(--warn)}}

/* Drag handle */
.drag-handle{{
  cursor:grab;padding:2px 6px 2px 2px;color:var(--border);
  font-size:14px;line-height:1;flex-shrink:0;margin-top:1px;
}}
.drag-handle:hover{{color:var(--muted)}}
.drag-handle:active{{cursor:grabbing}}
.opt-row.drag-over-top{{border-top:2px solid var(--accent)}}
.opt-row.drag-over-bottom{{border-bottom:2px solid var(--accent)}}

/* Selection dot */
.sel-dot{{
  width:14px;height:14px;border-radius:50%;border:2px solid var(--border);
  flex-shrink:0;margin-top:2px;margin-right:8px;transition:all 0.1s;
}}
.opt-row.selected .sel-dot{{background:var(--accent);border-color:var(--accent)}}
.opt-row.marked-remove .sel-dot{{background:#ef4444;border-color:#ef4444}}

/* Content */
.opt-content{{flex:1;min-width:0}}
.opt-title{{display:flex;align-items:baseline;gap:8px}}
.opt-name{{font-size:13px;font-weight:500;flex:1;min-width:0;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}}
.opt-row.marked-remove .opt-name{{color:#f87171;text-decoration:line-through}}
.type-badge{{
  font-size:9.5px;font-weight:600;letter-spacing:0.05em;text-transform:uppercase;
  padding:1px 5px;border-radius:3px;flex-shrink:0;opacity:0.85;
}}
.opt-desc{{font-size:11px;color:var(--muted);margin-top:2px;line-height:1.4;overflow:hidden;display:-webkit-box;-webkit-line-clamp:2;-webkit-box-orient:vertical}}
.opt-dbkey{{font-size:10px;font-family:'SF Mono',Menlo,Consolas,monospace;color:var(--border);margin-top:2px}}
.combine-badge{{
  font-size:9px;font-weight:700;padding:1px 5px;border-radius:3px;
  background:var(--warn);color:#000;flex-shrink:0;align-self:flex-start;margin-top:2px;
}}
.slider-range{{font-size:10px;color:var(--muted);margin-left:4px}}

/* ── Buttons ── */
.btn{{
  padding:5px 12px;border-radius:5px;border:none;cursor:pointer;font-size:12px;font-weight:500;
  transition:background 0.1s;
}}
.btn-primary{{background:var(--accent);color:#fff}}
.btn-primary:hover{{background:var(--accent-h)}}
.btn-sm{{padding:3px 8px;font-size:11px}}
.btn-ghost{{background:transparent;color:var(--muted);border:1px solid var(--border)}}
.btn-ghost:hover{{color:var(--text);background:var(--surface2)}}
.btn-danger{{background:#7f1d1d;color:#fca5a5}}
.btn-danger:hover{{background:#991b1b}}

/* ── Toolbar ── */
#toolbar{{
  display:flex;gap:8px;align-items:center;padding:8px 16px;
  background:var(--surface);border-bottom:1px solid var(--border);flex-shrink:0;
}}
#toolbar .sep{{width:1px;height:20px;background:var(--border);margin:0 4px}}
#sel-count{{font-size:11px;color:var(--muted)}}

/* ── Planning panel ── */
#plan-panel{{
  width:var(--plan-w);flex-shrink:0;overflow-y:auto;
  background:var(--surface);border-left:1px solid var(--border);padding:12px;
  display:flex;flex-direction:column;gap:12px;
}}
.plan-section-title{{
  font-size:10px;font-weight:700;text-transform:uppercase;letter-spacing:0.08em;
  color:var(--muted);margin-bottom:6px;display:flex;align-items:center;justify-content:space-between;
}}
.plan-list{{display:flex;flex-direction:column;gap:4px}}
.plan-item{{
  font-size:11px;color:var(--text);padding:4px 8px;border-radius:4px;
  background:var(--surface2);line-height:1.4;
}}
.plan-item-cat{{font-size:9px;color:var(--muted);display:block;margin-bottom:1px}}
.plan-item.remove-item{{background:#3a1212;color:#f87171}}
.combine-group-header{{
  font-size:10px;font-weight:600;color:var(--warn);margin:4px 0 2px;
}}
.plan-empty{{font-size:11px;color:var(--border);font-style:italic;padding:4px 0}}
#plan-clear{{
  margin-top:auto;padding-top:12px;border-top:1px solid var(--border);
}}

/* ── L[] key display ── */
.opt-lkey{{
  font-size:10px;font-family:'SF Mono',Menlo,Consolas,monospace;
  color:var(--border);margin-top:1px;opacity:0.8;
}}

/* ── Rename suggestion ── */
.rename-badge{{
  font-size:9px;font-weight:700;padding:1px 5px;border-radius:3px;
  background:#854d0e;color:#fef08a;flex-shrink:0;align-self:flex-start;margin-top:1px;
}}
.opt-name-original{{text-decoration:line-through;color:var(--muted);font-size:11px}}
.opt-name-suggested{{color:#fef08a;font-weight:600}}
.rename-input{{
  flex:1;background:var(--surface);color:var(--text);
  border:1px solid var(--accent);border-radius:3px;
  padding:2px 7px;font-size:13px;font-weight:500;outline:none;min-width:0;
}}
.plan-item.rename-item{{background:#2c2200;color:#fef08a;word-break:break-all}}
.plan-rename-arrow{{color:var(--muted);margin:0 4px;font-size:10px}}
.plan-rename-key{{font-size:9px;font-family:'SF Mono',Menlo,Consolas,monospace;color:var(--muted);display:block;margin-top:1px}}

/* ── Context menu ── */
#ctx-menu{{
  position:fixed;z-index:1000;background:var(--surface2);border:1px solid var(--border);
  border-radius:6px;box-shadow:0 8px 24px rgba(0,0,0,0.5);min-width:190px;padding:4px 0;
  display:none;
}}
.ctx-item{{
  padding:7px 14px;cursor:pointer;font-size:12px;color:var(--text);
  display:flex;align-items:center;gap:8px;
}}
.ctx-item:hover{{background:var(--surface3)}}
.ctx-item.danger{{color:#f87171}}
.ctx-item.danger:hover{{background:#3a1212}}
.ctx-sep{{height:1px;background:var(--border);margin:3px 0}}

/* ── Search ── */
#search{{
  background:var(--surface2);border:1px solid var(--border);border-radius:5px;
  color:var(--text);padding:4px 10px;font-size:12px;width:200px;
}}
#search:focus{{outline:none;border-color:var(--accent)}}
#search::placeholder{{color:var(--border)}}

/* ── Session status ── */
.save-status{{font-size:11px;color:var(--muted);min-width:70px;text-align:right;transition:color 0.2s;white-space:nowrap}}
.save-status.saved{{color:#22c55e}}
.save-status.unsaved,.save-status.error{{color:var(--warn)}}

/* ── No category ── */
#empty-state{{
  flex:1;display:flex;flex-direction:column;align-items:center;justify-content:center;
  color:var(--muted);gap:8px;font-size:14px;
}}

/* ── Scrollbar ── */
::-webkit-scrollbar{{width:6px;height:6px}}
::-webkit-scrollbar-track{{background:transparent}}
::-webkit-scrollbar-thumb{{background:var(--border);border-radius:3px}}
::-webkit-scrollbar-thumb:hover{{background:var(--muted)}}
</style>
</head>
<body>

<div id="app">
  <!-- Header -->
  <div id="header">
    <h1>HorizonSuite Options Visualizer</h1>
    <div id="header-right">
      <input id="search" type="text" placeholder="Search options…">
      <span id="save-status" class="save-status"></span>
      <button id="btn-copy-link" class="btn btn-sm btn-ghost" onclick="copyLink()" style="display:none">Copy Link</button>
      <button id="btn-sync"      class="btn btn-sm btn-ghost" onclick="syncFromServer()" style="display:none">↺ Sync</button>
      <button class="btn btn-primary" onclick="exportMarkdown()">Export Markdown ↓</button>
    </div>
  </div>

  <!-- Toolbar -->
  <div id="toolbar">
    <span id="sel-count">No selection</span>
    <div class="sep"></div>
    <button class="btn btn-sm btn-ghost" onclick="markRemove()">🗑 Mark Removal</button>
    <button class="btn btn-sm btn-ghost" onclick="markCombineNew()">🔗 New Combine Group</button>
    <button class="btn btn-sm btn-ghost" onclick="markCombineExisting()" id="btn-add-group" style="display:none">+ Add to Group</button>
    <div class="sep"></div>
    <button class="btn btn-sm btn-ghost" onclick="clearSelection()">Clear Selection</button>
  </div>

  <!-- Three-column layout -->
  <div id="columns">
    <!-- Sidebar -->
    <div id="sidebar"></div>

    <!-- Main content -->
    <div id="main">
      <div id="empty-state">
        <div style="font-size:32px">☰</div>
        <div>Select a category from the sidebar</div>
      </div>
    </div>

    <!-- Planning panel -->
    <div id="plan-panel">
      <div>
        <div class="plan-section-title">🗑 Removals <span id="remove-count">0</span></div>
        <div class="plan-list" id="plan-remove-list">
          <div class="plan-empty">None marked yet</div>
        </div>
      </div>
      <div>
        <div class="plan-section-title">🔗 Combine Groups <span id="combine-count">0</span></div>
        <div id="plan-combine-list">
          <div class="plan-empty">None marked yet</div>
        </div>
      </div>
      <div>
        <div class="plan-section-title">✏ Renames <span id="rename-count">0</span></div>
        <div class="plan-list" id="plan-rename-list">
          <div class="plan-empty">None suggested yet</div>
        </div>
      </div>
      <div id="plan-clear">
        <button class="btn btn-sm btn-ghost" style="width:100%" onclick="clearAllMarks()">Clear All Marks</button>
      </div>
    </div>
  </div>
</div>

<!-- Context menu -->
<div id="ctx-menu">
  <div class="ctx-item" onclick="ctxMarkRemove()">🗑 Mark for Removal</div>
  <div class="ctx-item" onclick="ctxMarkCombineNew()">🔗 New Combine Group</div>
  <div class="ctx-item" id="ctx-add-group" onclick="ctxMarkCombineExisting()">+ Add to Latest Group</div>
  <div class="ctx-sep"></div>
  <div class="ctx-item" id="ctx-rename" onclick="ctxSuggestRename()">✏ Suggest Rename</div>
  <div class="ctx-sep"></div>
  <div class="ctx-item" onclick="ctxClearMarks()">✕ Clear Marks</div>
</div>

<script>
// ────────────────────────────────────────────────────────────────
// Data & session
// ────────────────────────────────────────────────────────────────
const DATA       = {DATA_SENTINEL};
const IS_HOSTED  = {IS_HOSTED_SENTINEL};  // true when served by Cloudflare (Pages or Worker)
const SESSION_ID = {SESSION_ID_SENTINEL}; // null → standalone, URL param → Pages, injected → Worker

// ────────────────────────────────────────────────────────────────
// Type colour map
// ────────────────────────────────────────────────────────────────
const TYPE_COLORS = {json.dumps(TYPE_COLORS)};

function typeColor(t) {{
  return TYPE_COLORS[t] || '#6b7280';
}}

// ────────────────────────────────────────────────────────────────
// State
// ────────────────────────────────────────────────────────────────
const state = {{
  activeCat:     null,     // current category key
  selected:      new Set(),// selected option ids
  removed:       new Set(),// ids marked for removal
  combineGroups: [],       // array of Set<id>
  renames:       {{}},      // id → {{ original, suggested, nameKey }}
  // maps optionId → {{catKey,secIdx,optIdx}}
  optionMeta:    {{}},
  // current rendered order per section
  sectionOrders: {{}},     // "catKey/secIdx" → [optId, ...]
  searchQuery:   '',
}};

// Stable ID for an option
function optId(catKey, secIdx, optIdx) {{
  return `${{catKey}}/${{secIdx}}/${{optIdx}}`;
}}

// ────────────────────────────────────────────────────────────────
// Build sidebar
// ────────────────────────────────────────────────────────────────
function buildSidebar() {{
  const sb = document.getElementById('sidebar');
  sb.innerHTML = '';

  for (const mk of DATA.moduleOrder) {{
    const grp = DATA.modules[mk];
    if (!grp || !grp.categories.length) continue;

    const groupEl = document.createElement('div');
    groupEl.className = 'mod-group';

    const lbl = document.createElement('div');
    lbl.className = 'mod-label';
    lbl.textContent = grp.label;
    groupEl.appendChild(lbl);

    const catList = document.createElement('div');
    catList.className = 'cat-list';

    for (const cat of grp.categories) {{
      const item = document.createElement('div');
      item.className = 'cat-item';
      item.dataset.catKey = cat.key;
      item.textContent = cat.name;
      item.title = cat.desc || cat.name;
      item.onclick = () => selectCategory(cat.key);
      catList.appendChild(item);
    }}
    groupEl.appendChild(catList);
    sb.appendChild(groupEl);
  }}
}}

// ────────────────────────────────────────────────────────────────
// Category selection
// ────────────────────────────────────────────────────────────────
function selectCategory(catKey) {{
  state.activeCat = catKey;
  state.selected.clear();
  updateSelCount();

  // Sidebar highlight
  document.querySelectorAll('.cat-item').forEach(el => {{
    el.classList.toggle('active', el.dataset.catKey === catKey);
  }});

  const cat = DATA.categories.find(c => c.key === catKey);
  if (!cat) return;

  renderCategory(cat);
}}

// ────────────────────────────────────────────────────────────────
// Render category
// ────────────────────────────────────────────────────────────────
function renderCategory(cat) {{
  const main = document.getElementById('main');
  main.innerHTML = '';

  const titleEl = document.createElement('div');
  titleEl.id = 'main-title';
  titleEl.textContent = cat.name;
  main.appendChild(titleEl);

  if (cat.desc) {{
    const descEl = document.createElement('div');
    descEl.id = 'main-desc';
    descEl.textContent = cat.desc;
    main.appendChild(descEl);
  }}

  let totalOpts = 0;
  cat.sections.forEach(s => {{ totalOpts += s.options.length; }});

  const stats = document.createElement('div');
  stats.id = 'main-stats';
  stats.textContent = `${{cat.sections.length}} section${{cat.sections.length !== 1 ? 's' : ''}} · ${{totalOpts}} option${{totalOpts !== 1 ? 's' : ''}}`;
  main.appendChild(stats);

  cat.sections.forEach((sec, secIdx) => {{
    const card = buildSectionCard(cat, secIdx);
    main.appendChild(card);
  }});
}}

function buildSectionCard(cat, secIdx) {{
  const sec  = cat.sections[secIdx];
  const sKey = `${{cat.key}}/${{secIdx}}`;

  // Initialise order if not set
  if (!state.sectionOrders[sKey]) {{
    state.sectionOrders[sKey] = sec.options.map((_, oi) => optId(cat.key, secIdx, oi));
  }}

  const card = document.createElement('div');
  card.className = 'section-card';
  card.dataset.skey = sKey;

  // Header
  const head = document.createElement('div');
  head.className = 'section-head';
  head.innerHTML = `
    <div class="section-head-left">
      <span class="section-chevron">▾</span>
      <span class="section-name">${{sec.name || '(Unnamed section)'}}</span>
    </div>
    <span class="section-count">${{sec.options.length}}</span>
  `;
  head.onclick = () => card.classList.toggle('collapsed');
  card.appendChild(head);

  // Body
  const body = document.createElement('div');
  body.className = 'section-body';
  body.dataset.skey = sKey;

  if (sec.options.length === 0) {{
    body.innerHTML = '<div class="empty-section">No options in this section</div>';
  }} else {{
    const order = state.sectionOrders[sKey];
    order.forEach(id => {{
      const [, , oiStr] = id.split('/');
      const oi = parseInt(oiStr, 10);
      const opt = sec.options[oi];
      if (!opt) return;

      // Register metadata
      state.optionMeta[id] = {{ catKey: cat.key, catName: cat.name, secIdx, optIdx: oi, secName: sec.name }};

      const row = buildOptRow(id, opt, cat, secIdx, oi);
      body.appendChild(row);
    }});
  }}

  card.appendChild(body);
  return card;
}}

function buildOptRow(id, opt, cat, secIdx, oi) {{
  const row = document.createElement('div');
  row.className = 'opt-row';
  row.dataset.id = id;
  row.draggable = true;

  // Apply marks
  if (state.removed.has(id))  row.classList.add('marked-remove');
  const gIdx = state.combineGroups.findIndex(g => g.has(id));
  if (gIdx !== -1)              row.classList.add('marked-combine');
  if (state.selected.has(id))  row.classList.add('selected');

  const color = typeColor(opt.type);

  let combineHtml = '';
  if (gIdx !== -1) {{
    combineHtml = `<span class="combine-badge">G${{gIdx + 1}}</span>`;
  }}

  let rangeHtml = '';
  if (opt.type === 'slider' && (opt.min !== undefined || opt.max !== undefined)) {{
    rangeHtml = `<span class="slider-range">${{opt.min ?? '?'}}–${{opt.max ?? '?'}}</span>`;
  }}

  // Build L[] key display string
  const lkeyHtml = opt.nameKey
    ? `<div class="opt-lkey">L["${{esc(opt.nameKey)}}"]</div>`
    : '';

  // Build meta line: dbKey + lkey
  const metaLine = [
    opt.dbKey ? `<div class="opt-dbkey">${{esc(opt.dbKey)}}</div>` : '',
    lkeyHtml,
  ].join('');

  row.innerHTML = `
    <span class="drag-handle" title="Drag to reorder">⠿</span>
    <div class="sel-dot"></div>
    <div class="opt-content">
      <div class="opt-title">
        <span class="opt-name" title="Double-click to suggest rename">${{esc(opt.name || opt.type)}}</span>
        ${{rangeHtml}}
        ${{combineHtml}}
        <span class="type-badge" style="background:${{color}}22;color:${{color}}">${{opt.type}}</span>
      </div>
      ${{opt.desc ? `<div class="opt-desc">${{esc(opt.desc)}}</div>` : ''}}
      ${{metaLine}}
    </div>
  `;

  // Click: selection
  row.addEventListener('click', e => {{
    if (e.target.closest('.drag-handle')) return;
    handleRowClick(id, e);
  }});

  // Double-click on name: suggest rename
  row.addEventListener('dblclick', e => {{
    if (e.target.closest('.drag-handle')) return;
    e.preventDefault();
    clearSelection();
    activateRenameInput(id);
  }});

  // Right-click: context menu
  row.addEventListener('contextmenu', e => {{
    e.preventDefault();
    if (!state.selected.has(id)) {{
      state.selected.clear();
      state.selected.add(id);
      refreshAllRowHighlights();
      updateSelCount();
    }}
    showCtxMenu(e.clientX, e.clientY);
  }});

  // Drag-and-drop
  row.addEventListener('dragstart', e => {{
    e.dataTransfer.setData('text/plain', id);
    e.dataTransfer.effectAllowed = 'move';
    row.style.opacity = '0.4';
  }});
  row.addEventListener('dragend', () => {{ row.style.opacity = ''; }});

  row.addEventListener('dragover', e => {{
    e.preventDefault();
    e.dataTransfer.dropEffect = 'move';
    const rect = row.getBoundingClientRect();
    const half = rect.top + rect.height / 2;
    row.classList.toggle('drag-over-top',    e.clientY < half);
    row.classList.toggle('drag-over-bottom', e.clientY >= half);
  }});
  row.addEventListener('dragleave', () => {{
    row.classList.remove('drag-over-top','drag-over-bottom');
  }});
  row.addEventListener('drop', e => {{
    e.preventDefault();
    row.classList.remove('drag-over-top','drag-over-bottom');
    const draggedId = e.dataTransfer.getData('text/plain');
    if (!draggedId || draggedId === id) return;

    // Determine position
    const rect = row.getBoundingClientRect();
    const before = e.clientY < rect.top + rect.height / 2;
    moveOption(draggedId, id, before, cat.key, secIdx);
  }});

  return row;
}}

// ────────────────────────────────────────────────────────────────
// Drag-and-drop: move option
// ────────────────────────────────────────────────────────────────
function moveOption(draggedId, targetId, before, catKey, secIdx) {{
  const [dCat, dSec] = draggedId.split('/');
  const [tCat, tSec] = targetId.split('/');

  const dSKey = `${{dCat}}/${{dSec}}`;
  const tSKey = `${{tCat}}/${{tSec}}`;

  // Remove from source
  const srcOrder = state.sectionOrders[dSKey];
  if (!srcOrder) return;
  const srcIdx = srcOrder.indexOf(draggedId);
  if (srcIdx === -1) return;
  srcOrder.splice(srcIdx, 1);

  // Insert at destination
  let dstOrder = state.sectionOrders[tSKey];
  if (!dstOrder) return;
  const dstIdx = dstOrder.indexOf(targetId);
  const insertAt = before ? dstIdx : dstIdx + 1;
  dstOrder.splice(insertAt, 0, draggedId);

  // Re-render current category
  const cat = DATA.categories.find(c => c.key === catKey);
  if (cat) renderCategory(cat);
  scheduleSave();
}}

// ────────────────────────────────────────────────────────────────
// Selection
// ────────────────────────────────────────────────────────────────
let lastSelected = null;

function handleRowClick(id, e) {{
  if (e.shiftKey && lastSelected) {{
    // Range select within visible rows
    const rows = [...document.querySelectorAll('.opt-row')];
    const ids  = rows.map(r => r.dataset.id);
    const a = ids.indexOf(lastSelected);
    const b = ids.indexOf(id);
    if (a !== -1 && b !== -1) {{
      const [lo, hi] = a < b ? [a, b] : [b, a];
      ids.slice(lo, hi + 1).forEach(rid => state.selected.add(rid));
    }}
  }} else if (e.metaKey || e.ctrlKey) {{
    if (state.selected.has(id)) state.selected.delete(id);
    else state.selected.add(id);
    lastSelected = id;
  }} else {{
    const wasSoleSelected = state.selected.size === 1 && state.selected.has(id);
    state.selected.clear();
    if (!wasSoleSelected) {{ state.selected.add(id); lastSelected = id; }}
  }}
  refreshAllRowHighlights();
  updateSelCount();
}}

function clearSelection() {{
  state.selected.clear();
  refreshAllRowHighlights();
  updateSelCount();
}}

function refreshAllRowHighlights() {{
  document.querySelectorAll('.opt-row').forEach(row => {{
    const id = row.dataset.id;
    row.classList.toggle('selected', state.selected.has(id));
  }});
}}

function updateSelCount() {{
  const n = state.selected.size;
  document.getElementById('sel-count').textContent =
    n === 0 ? 'No selection' : `${{n}} selected`;
  const hasCombineGroups = state.combineGroups.length > 0;
  document.getElementById('btn-add-group').style.display =
    n > 0 && hasCombineGroups ? '' : 'none';
}}

// ────────────────────────────────────────────────────────────────
// Marking: removal
// ────────────────────────────────────────────────────────────────
function markRemove() {{
  state.selected.forEach(id => state.removed.add(id));
  refreshRowMarks();
  updatePlanPanel();
  clearSelection();
  scheduleSave();
}}

function ctxMarkRemove() {{
  hideCtxMenu();
  markRemove();
}}

// ────────────────────────────────────────────────────────────────
// Marking: combine groups
// ────────────────────────────────────────────────────────────────
function markCombineNew() {{
  if (!state.selected.size) return;
  const grp = new Set(state.selected);
  state.combineGroups.push(grp);
  refreshRowMarks();
  updatePlanPanel();
  clearSelection();
  scheduleSave();
}}

function markCombineExisting() {{
  if (!state.selected.size || !state.combineGroups.length) return;
  const grp = state.combineGroups[state.combineGroups.length - 1];
  state.selected.forEach(id => grp.add(id));
  refreshRowMarks();
  updatePlanPanel();
  clearSelection();
  scheduleSave();
}}

function ctxMarkCombineNew() {{ hideCtxMenu(); markCombineNew(); }}
function ctxMarkCombineExisting() {{ hideCtxMenu(); markCombineExisting(); }}

// ────────────────────────────────────────────────────────────────
// Rename suggestions
// ────────────────────────────────────────────────────────────────
function ctxSuggestRename() {{
  hideCtxMenu();
  if (state.selected.size !== 1) return;
  const id = [...state.selected][0];
  clearSelection();
  activateRenameInput(id);
}}

function activateRenameInput(id) {{
  const row = document.querySelector(`.opt-row[data-id="${{id}}"]`);
  if (!row) return;
  const nameEl = row.querySelector('.opt-name');
  if (!nameEl) return;

  const meta    = state.optionMeta[id];
  const catData = DATA.categories.find(c => c.key === meta?.catKey);
  const sec     = catData?.sections[meta?.secIdx];
  const opt     = sec?.options[meta?.optIdx];
  if (!opt) return;

  const current = state.renames[id]?.suggested || opt.name || opt.type || '';

  const input = document.createElement('input');
  input.type      = 'text';
  input.className = 'rename-input';
  input.value     = current;

  nameEl.style.display = 'none';
  nameEl.parentNode.insertBefore(input, nameEl);
  input.focus();
  input.select();

  let done = false;

  function commit() {{
    if (done) return; done = true;
    const newName = input.value.trim();
    const original = opt.name || opt.type || '';
    if (newName && newName !== original) {{
      state.renames[id] = {{ original, suggested: newName, nameKey: opt.nameKey || null }};
    }} else {{
      delete state.renames[id];
    }}
    input.remove();
    nameEl.style.display = '';
    refreshRowMarks();
    updatePlanPanel();
    scheduleSave();
  }}

  function cancel() {{
    if (done) return; done = true;
    input.remove();
    nameEl.style.display = '';
  }}

  input.addEventListener('keydown', e => {{
    if (e.key === 'Enter')  {{ e.preventDefault(); commit(); }}
    else if (e.key === 'Escape') cancel();
  }});
  input.addEventListener('blur',  commit);
  input.addEventListener('click', e => e.stopPropagation());
}}

// ────────────────────────────────────────────────────────────────
// Marking: clear
// ────────────────────────────────────────────────────────────────
function ctxClearMarks() {{
  hideCtxMenu();
  state.selected.forEach(id => {{
    state.removed.delete(id);
    state.combineGroups.forEach(g => g.delete(id));
    delete state.renames[id];
  }});
  // Remove empty groups
  state.combineGroups = state.combineGroups.filter(g => g.size > 0);
  refreshRowMarks();
  updatePlanPanel();
  scheduleSave();
}}

function clearAllMarks() {{
  state.removed.clear();
  state.combineGroups = [];
  state.renames = {{}};
  refreshRowMarks();
  updatePlanPanel();
  scheduleSave();
}}

function refreshRowMarks() {{
  document.querySelectorAll('.opt-row').forEach(row => {{
    const id = row.dataset.id;
    row.classList.toggle('marked-remove', state.removed.has(id));
    const gIdx = state.combineGroups.findIndex(g => g.has(id));
    row.classList.toggle('marked-combine', gIdx !== -1);

    // Update combine badge
    let badge = row.querySelector('.combine-badge');
    if (gIdx !== -1) {{
      if (!badge) {{
        badge = document.createElement('span');
        badge.className = 'combine-badge';
        const titleDiv = row.querySelector('.opt-title');
        const typeBadge = titleDiv.querySelector('.type-badge');
        titleDiv.insertBefore(badge, typeBadge);
      }}
      badge.textContent = `G${{gIdx + 1}}`;
    }} else if (badge) {{
      badge.remove();
    }}

    // Rename badge + name display
    const renameData = state.renames[id];
    let renameBadge = row.querySelector('.rename-badge');
    if (renameData) {{
      if (!renameBadge) {{
        renameBadge = document.createElement('span');
        renameBadge.className = 'rename-badge';
        const titleDiv = row.querySelector('.opt-title');
        const typeBadge = titleDiv?.querySelector('.type-badge');
        if (titleDiv && typeBadge) titleDiv.insertBefore(renameBadge, typeBadge);
      }}
      renameBadge.textContent = '✏';
    }} else if (renameBadge) {{
      renameBadge.remove();
    }}

    // Update opt-name display
    const nameEl = row.querySelector('.opt-name');
    if (nameEl) {{
      if (renameData) {{
        nameEl.innerHTML = `<span class="opt-name-original">${{esc(renameData.original)}}</span><span class="plan-rename-arrow">→</span><span class="opt-name-suggested">${{esc(renameData.suggested)}}</span>`;
        nameEl.style.textDecoration = '';
        nameEl.style.color = '';
      }} else {{
        // Restore to original text (may have been replaced by rename display)
        const meta = state.optionMeta[id];
        const catData = DATA.categories.find(c => c.key === meta?.catKey);
        const sec = catData?.sections[meta?.secIdx];
        const opt = sec?.options[meta?.optIdx];
        nameEl.textContent = opt?.name || opt?.type || '';
        nameEl.style.textDecoration = state.removed.has(id) ? 'line-through' : '';
        nameEl.style.color = state.removed.has(id) ? '#f87171' : '';
      }}
    }}
  }});
}}

// ────────────────────────────────────────────────────────────────
// Plan panel
// ────────────────────────────────────────────────────────────────
function updatePlanPanel() {{
  // Removals
  const removeList = document.getElementById('plan-remove-list');
  document.getElementById('remove-count').textContent = state.removed.size;

  if (state.removed.size === 0) {{
    removeList.innerHTML = '<div class="plan-empty">None marked yet</div>';
  }} else {{
    // Group by category
    const byCat = {{}};
    state.removed.forEach(id => {{
      const meta = state.optionMeta[id];
      if (!meta) return;
      const catName = meta.catName || meta.catKey;
      if (!byCat[catName]) byCat[catName] = [];
      byCat[catName].push(id);
    }});

    removeList.innerHTML = '';
    for (const [catName, ids] of Object.entries(byCat)) {{
      ids.forEach(id => {{
        const meta = state.optionMeta[id];
        const catData = DATA.categories.find(c => c.key === meta.catKey);
        const sec  = catData?.sections[meta.secIdx];
        const opt  = sec?.options[meta.optIdx];
        if (!opt) return;
        const item = document.createElement('div');
        item.className = 'plan-item remove-item';
        item.innerHTML = `<span class="plan-item-cat">${{esc(catName)}} › ${{esc(sec?.name || '')}}</span>${{esc(opt.name || opt.type)}}`;
        removeList.appendChild(item);
      }});
    }}
  }}

  // Combine groups
  const combineList = document.getElementById('plan-combine-list');
  const totalCombine = state.combineGroups.reduce((s, g) => s + g.size, 0);
  document.getElementById('combine-count').textContent = state.combineGroups.length;

  if (state.combineGroups.length === 0) {{
    combineList.innerHTML = '<div class="plan-empty">None marked yet</div>';
  }} else {{
    combineList.innerHTML = '';
    state.combineGroups.forEach((grp, gIdx) => {{
      const hdr = document.createElement('div');
      hdr.className = 'combine-group-header';
      hdr.textContent = `Group ${{gIdx + 1}} (${{grp.size}} options)`;
      combineList.appendChild(hdr);

      grp.forEach(id => {{
        const meta = state.optionMeta[id];
        if (!meta) return;
        const catData = DATA.categories.find(c => c.key === meta.catKey);
        const sec  = catData?.sections[meta.secIdx];
        const opt  = sec?.options[meta.optIdx];
        if (!opt) return;
        const item = document.createElement('div');
        item.className = 'plan-item';
        item.innerHTML = `<span class="plan-item-cat">${{esc(meta.catName || meta.catKey)}}</span>${{esc(opt.name || opt.type)}}`;
        combineList.appendChild(item);
      }});
    }});
  }}

  // Renames
  const renameList = document.getElementById('plan-rename-list');
  const renameIds  = Object.keys(state.renames);
  document.getElementById('rename-count').textContent = renameIds.length;

  if (renameIds.length === 0) {{
    renameList.innerHTML = '<div class="plan-empty">None suggested yet</div>';
  }} else {{
    renameList.innerHTML = '';
    renameIds.forEach(id => {{
      const r    = state.renames[id];
      const meta = state.optionMeta[id];
      if (!meta) return;
      const catData = DATA.categories.find(c => c.key === meta.catKey);
      const sec  = catData?.sections[meta.secIdx];
      const item = document.createElement('div');
      item.className = 'plan-item rename-item';
      const keyLine = r.nameKey
        ? `<span class="plan-rename-key">L["${{esc(r.nameKey)}}"]</span>` : '';
      item.innerHTML = `<span class="plan-item-cat">${{esc(meta.catName || meta.catKey)}} › ${{esc(sec?.name || '')}}</span>${{esc(r.original)}}<span class="plan-rename-arrow">→</span><strong>${{esc(r.suggested)}}</strong>${{keyLine}}`;
      renameList.appendChild(item);
    }});
  }}

  updateSelCount();
}}

// ────────────────────────────────────────────────────────────────
// Context menu
// ────────────────────────────────────────────────────────────────
function showCtxMenu(x, y) {{
  const menu = document.getElementById('ctx-menu');
  const hasGroups = state.combineGroups.length > 0;
  document.getElementById('ctx-add-group').style.display = hasGroups ? '' : 'none';
  // Rename only makes sense for a single option
  document.getElementById('ctx-rename').style.display = state.selected.size === 1 ? '' : 'none';
  menu.style.display = 'block';
  menu.style.left = `${{Math.min(x, window.innerWidth  - 210)}}px`;
  menu.style.top  = `${{Math.min(y, window.innerHeight - 180)}}px`;
}}

function hideCtxMenu() {{
  document.getElementById('ctx-menu').style.display = 'none';
}}

document.addEventListener('click',      hideCtxMenu);
document.addEventListener('keydown', e => {{ if (e.key === 'Escape') {{ hideCtxMenu(); clearSelection(); }} }});

// ────────────────────────────────────────────────────────────────
// Search
// ────────────────────────────────────────────────────────────────
document.getElementById('search').addEventListener('input', function() {{
  state.searchQuery = this.value.toLowerCase().trim();
  applySearch();
}});

function applySearch() {{
  const q = state.searchQuery;
  document.querySelectorAll('.opt-row').forEach(row => {{
    if (!q) {{ row.style.display = ''; return; }}
    const id   = row.dataset.id;
    const meta = state.optionMeta[id];
    if (!meta) {{ row.style.display = ''; return; }}
    const cat  = DATA.categories.find(c => c.key === meta.catKey);
    const sec  = cat?.sections[meta.secIdx];
    const opt  = sec?.options[meta.optIdx];
    if (!opt)  {{ row.style.display = ''; return; }}
    const haystack = [opt.name || '', opt.desc || '', opt.dbKey || '', opt.type, opt.nameKey || ''].join(' ').toLowerCase();
    row.style.display = haystack.includes(q) ? '' : 'none';
  }});

  // Hide sections where all options are hidden
  document.querySelectorAll('.section-card').forEach(card => {{
    const rows = card.querySelectorAll('.opt-row');
    const visible = [...rows].filter(r => r.style.display !== 'none').length;
    card.style.display = (rows.length > 0 && visible === 0) ? 'none' : '';
  }});
}}

// ────────────────────────────────────────────────────────────────
// Export Markdown
// ────────────────────────────────────────────────────────────────
function exportMarkdown() {{
  const lines = [];
  lines.push(`# Options Review Plan — HorizonSuite`);
  lines.push(`\\nGenerated: ${{DATA.generated}}\\n`);

  // Removals
  lines.push(`## Removals\\n`);
  if (state.removed.size === 0) {{
    lines.push(`_None marked._\\n`);
  }} else {{
    const byCat = {{}};
    state.removed.forEach(id => {{
      const meta = state.optionMeta[id];
      if (!meta) return;
      if (!byCat[meta.catKey]) byCat[meta.catKey] = [];
      byCat[meta.catKey].push(id);
    }});
    for (const [catKey, ids] of Object.entries(byCat)) {{
      const catData = DATA.categories.find(c => c.key === catKey);
      lines.push(`### ${{catData?.name || catKey}}\\n`);
      ids.forEach(id => {{
        const meta = state.optionMeta[id];
        const sec  = catData?.sections[meta.secIdx];
        const opt  = sec?.options[meta.optIdx];
        if (!opt) return;
        const dbk  = opt.dbKey ? ' (' + opt.dbKey + ')' : '';
        const desc = opt.desc  ? ` — "${{opt.desc.slice(0, 80)}}${{opt.desc.length > 80 ? '…' : ''}}"` : '';
        lines.push(`- **${{opt.name || opt.type}}**${{dbk}} (${{opt.type}})${{desc}}`);
      }});
      lines.push('');
    }}
  }}

  // Combine candidates
  lines.push(`## Combine Candidates\\n`);
  if (state.combineGroups.length === 0) {{
    lines.push(`_None marked._\\n`);
  }} else {{
    state.combineGroups.forEach((grp, gIdx) => {{
      lines.push(`### Group ${{gIdx + 1}}\\n`);
      grp.forEach(id => {{
        const meta = state.optionMeta[id];
        if (!meta) return;
        const catData = DATA.categories.find(c => c.key === meta.catKey);
        const sec  = catData?.sections[meta.secIdx];
        const opt  = sec?.options[meta.optIdx];
        if (!opt) return;
        const rangeStr = opt.type === 'slider' && opt.min !== undefined
          ? ` (range: ${{opt.min}}–${{opt.max}})` : '';
        lines.push(`- **${{opt.name || opt.type}}** (${{opt.type}}${{rangeStr}}) — ${{catData?.name || meta.catKey}} › ${{sec?.name || ''}}`);
      }});
      lines.push('');
    }});
  }}

  // Reorder changes
  lines.push(`## Reorder Changes\\n`);
  let hasReorders = false;
  for (const [sKey, order] of Object.entries(state.sectionOrders)) {{
    const [catKey, secIdxStr] = sKey.split('/');
    const secIdx = parseInt(secIdxStr, 10);
    const catData = DATA.categories.find(c => c.key === catKey);
    if (!catData) continue;
    const sec = catData.sections[secIdx];
    if (!sec) continue;

    const originalOrder = sec.options.map((_, oi) => optId(catKey, secIdx, oi));
    const changed = !order.every((id, i) => id === originalOrder[i]);
    if (!changed) continue;

    hasReorders = true;
    lines.push(`### ${{catData.name}} › ${{sec.name || `Section ${{secIdx + 1}}`}}\\n`);
    order.forEach((id, pos) => {{
      const [, , oiStr] = id.split('/');
      const oi  = parseInt(oiStr, 10);
      const opt = sec.options[oi];
      lines.push(`${{pos + 1}}. ${{opt?.name || opt?.type || id}}`);
    }});
    lines.push('');
  }}
  if (!hasReorders) lines.push(`_No reorder changes._\\n`);

  // Rename suggestions
  lines.push(`## Rename Suggestions\\n`);
  const renameIds = Object.keys(state.renames);
  if (renameIds.length === 0) {{
    lines.push(`_None suggested._\\n`);
  }} else {{
    renameIds.forEach(id => {{
      const r    = state.renames[id];
      const meta = state.optionMeta[id];
      if (!meta) return;
      const catData = DATA.categories.find(c => c.key === meta.catKey);
      const sec  = catData?.sections[meta.secIdx];
      const keyStr = r.nameKey ? ` (L["${{r.nameKey}}"])` : '';
      lines.push(`- **${{r.original}}**${{keyStr}} → **${{r.suggested}}** — ${{catData?.name || meta.catKey}} › ${{sec?.name || ''}}`);
    }});
    lines.push('');
  }}

  const blob = new Blob([lines.join('\\n')], {{type:'text/markdown'}});
  const a = document.createElement('a');
  a.href = URL.createObjectURL(blob);
  a.download = 'options_plan.md';
  a.click();
}}

// ────────────────────────────────────────────────────────────────
// Session — collaborative persistence (no-ops when SESSION_ID null)
// ────────────────────────────────────────────────────────────────
let _saveTimer = null;

function _serializeState() {{
  return {{
    removed:       [...state.removed],
    combineGroups: state.combineGroups.map(g => [...g]),
    renames:       state.renames,
    sectionOrders: state.sectionOrders,
  }};
}}

function _deserializeState(saved) {{
  if (!saved) return;
  state.removed       = new Set(saved.removed || []);
  state.combineGroups = (saved.combineGroups || []).map(g => new Set(g));
  state.renames       = saved.renames || {{}};
  // Merge saved section orders (don't clobber sections not in saved data)
  for (const [k, v] of Object.entries(saved.sectionOrders || {{}})) {{
    state.sectionOrders[k] = v;
  }}
}}

function _setSaveStatus(text, cls) {{
  const el = document.getElementById('save-status');
  if (el) {{ el.textContent = text; el.className = 'save-status ' + (cls || ''); }}
}}

function scheduleSave() {{
  if (!IS_HOSTED || !SESSION_ID) return;
  if (_saveTimer) clearTimeout(_saveTimer);
  _setSaveStatus('Unsaved…', 'unsaved');
  _saveTimer = setTimeout(_saveToServer, 800);
}}

async function _saveToServer() {{
  if (!IS_HOSTED || !SESSION_ID) return;
  _saveTimer = null;
  _setSaveStatus('Saving…', '');
  try {{
    const r = await fetch('/api/sessions/' + SESSION_ID, {{
      method:  'PUT',
      headers: {{'Content-Type': 'application/json'}},
      body:    JSON.stringify(_serializeState()),
    }});
    if (!r.ok) throw new Error(await r.text());
    _setSaveStatus('Saved ✓', 'saved');
    setTimeout(() => _setSaveStatus('', ''), 3000);
  }} catch (err) {{
    _setSaveStatus('Save failed ✗', 'error');
    console.error('Save failed:', err);
  }}
}}

async function syncFromServer() {{
  if (!IS_HOSTED || !SESSION_ID) return;
  _setSaveStatus('Syncing…', '');
  try {{
    const r = await fetch('/api/sessions/' + SESSION_ID);
    if (!r.ok) throw new Error(await r.text());
    const {{ state: saved }} = await r.json();
    _deserializeState(saved);
    const cat = DATA.categories.find(c => c.key === state.activeCat);
    if (cat) renderCategory(cat);
    refreshRowMarks();
    updatePlanPanel();
    _setSaveStatus('Synced ✓', 'saved');
    setTimeout(() => _setSaveStatus('', ''), 3000);
  }} catch (err) {{
    _setSaveStatus('Sync failed ✗', 'error');
    console.error('Sync failed:', err);
  }}
}}

function copyLink() {{
  navigator.clipboard.writeText(window.location.href).then(() => {{
    const btn = document.getElementById('btn-copy-link');
    if (btn) {{ const t = btn.textContent; btn.textContent = 'Copied!'; setTimeout(() => btn.textContent = t, 2000); }}
  }});
}}

async function _initSession() {{
  if (!IS_HOSTED) return;

  // Pages mode: no session ID in URL yet → create one and redirect
  if (!SESSION_ID) {{
    try {{
      const r = await fetch('/api/sessions', {{
        method: 'POST', headers: {{'Content-Type': 'application/json'}}
      }});
      if (r.ok) {{
        const {{ id }} = await r.json();
        window.location.replace(window.location.pathname + '?s=' + id);
      }}
    }} catch (err) {{ console.error('Session create failed:', err); }}
    return;
  }}

  // Show session UI buttons now that we have a session
  const btnCopy = document.getElementById('btn-copy-link');
  const btnSync = document.getElementById('btn-sync');
  if (btnCopy) btnCopy.style.display = '';
  if (btnSync) btnSync.style.display = '';

  try {{
    const r = await fetch('/api/sessions/' + SESSION_ID);
    if (!r.ok) return;
    const {{ state: saved }} = await r.json();
    if (!saved || !Object.keys(saved).length) return;
    _deserializeState(saved);
    const cat = DATA.categories.find(c => c.key === state.activeCat);
    if (cat) renderCategory(cat);
    refreshRowMarks();
    updatePlanPanel();
  }} catch (err) {{
    console.warn('Could not load session state:', err);
  }}
}}

// ────────────────────────────────────────────────────────────────
// Utility
// ────────────────────────────────────────────────────────────────
function esc(str) {{
  return String(str)
    .replace(/&/g,'&amp;')
    .replace(/</g,'&lt;')
    .replace(/>/g,'&gt;')
    .replace(/"/g,'&quot;');
}}

// ────────────────────────────────────────────────────────────────
// Init
// ────────────────────────────────────────────────────────────────
buildSidebar();

// Auto-select first category, then load session state from server
if (DATA.categories.length > 0) {{
  selectCategory(DATA.categories[0].key);
}}
_initSession();
</script>
</body>
</html>"""

    # Substitute sentinels depending on mode
    if pages_mode:
        # Pages: DATA embedded at build time; SESSION_ID read from URL at runtime
        html = html.replace(DATA_SENTINEL,       data_json)
        html = html.replace(SESSION_ID_SENTINEL,
                            "new URLSearchParams(window.location.search).get('s')")
        html = html.replace(IS_HOSTED_SENTINEL,  "true")
    else:
        # Standalone local file — no API calls
        html = html.replace(DATA_SENTINEL,       data_json)
        html = html.replace(SESSION_ID_SENTINEL, "null")
        html = html.replace(IS_HOSTED_SENTINEL,  "false")

    return html


# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------

# Default sibling clone of Tacit-Labs/Horizon-Suite-Options
DEFAULT_PAGES_OUT = ADDON_ROOT.parent / "Horizon-Suite-Options"


def _parse_out_dir(argv):
    """Extract --out-dir <path> from argv, returning Path or None."""
    for i, arg in enumerate(argv):
        if arg == "--out-dir" and i + 1 < len(argv):
            return Path(argv[i + 1]).expanduser().resolve()
        if arg.startswith("--out-dir="):
            return Path(arg.split("=", 1)[1]).expanduser().resolve()
    return None


def main():
    pages_mode = "--pages" in sys.argv
    out_dir    = _parse_out_dir(sys.argv) or DEFAULT_PAGES_OUT

    if not LUA_FILE.exists():
        sys.exit(f"ERROR: Cannot find {LUA_FILE}")

    print(f"Parsing {LUA_FILE} …")
    categories = parse_options_data(LUA_FILE)
    print(f"  → found {len(categories)} categories")

    total_opts = sum(
        len(sec["options"])
        for cat in categories
        for sec in cat["sections"]
    )
    total_secs = sum(len(cat["sections"]) for cat in categories)
    print(f"  → {total_secs} sections, {total_opts} options")

    data = build_data(categories)

    # Always write standalone HTML for local review
    html = generate_html(data, pages_mode=False)
    OUT_FILE.write_text(html, encoding="utf-8")
    print(f"Written → {OUT_FILE}")
    print(f"  Open: file:///{OUT_FILE.as_posix()}")

    if pages_mode:
        # Pages build: embed DATA, client-side session handling
        pages_html = generate_html(data, pages_mode=True)
        public_dir = out_dir / "public"
        pages_out  = public_dir / "index.html"
        if not out_dir.exists():
            sys.exit(
                f"ERROR: --out-dir {out_dir} does not exist.\n"
                f"       Clone Tacit-Labs/Horizon-Suite-Options as a sibling of HorizonSuite,\n"
                f"       or pass --out-dir <path> explicitly."
            )
        public_dir.mkdir(parents=True, exist_ok=True)
        pages_out.write_text(pages_html, encoding="utf-8")
        print(f"Written → {pages_out}")
        print(f"\nNext: cd {out_dir} && git add public/index.html && git commit && git push")


if __name__ == "__main__":
    main()
