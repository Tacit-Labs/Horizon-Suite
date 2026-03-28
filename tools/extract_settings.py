#!/usr/bin/env python3
"""
Extract Horizon Suite settings from OptionsData.lua for review.
Parses the Lua file statically and generates an HTML review document.
"""

import re
import os
import json
from pathlib import Path

# Paths relative to script location (tools/ at addon root)
SCRIPT_DIR = Path(__file__).resolve().parent
ADDON_ROOT = SCRIPT_DIR.parent
OPTIONS_DATA = ADDON_ROOT / "options" / "OptionsData.lua"
OUTPUT_HTML = ADDON_ROOT / "docs" / "SettingsReview.html"

MODULE_LABELS = {
    None: "Core",
    "focus": "Focus",
    "presence": "Presence",
    "vista": "Vista",
    "insight": "Insight",
    "cache": "Cache",
}

DEV_ONLY_MODULES = {"insight", "cache"}


def extract_lua_string(expr: str) -> str:
    """Extract display string from L['key'] or 'fallback' or 'literal'."""
    if not expr or not isinstance(expr, str):
        return "(unknown)"
    expr = expr.strip()
    # (L and L["key"]) or "fallback" -> prefer fallback (no $ so trailing ) doesn't break)
    m = re.search(r'\bor\s+["\']([^"\']*)["\']', expr)
    if m:
        return m.group(1)
    # "literal" or 'literal' at start
    m = re.search(r'^["\']([^"\']*)["\']', expr)
    if m:
        return m.group(1)
    # L["Key"] without fallback -> use key as display (often readable)
    m = re.search(r'L\[["\']([^"\']*)["\']\]', expr)
    if m:
        return m.group(1)
    # function() -> dynamic
    if "function" in expr:
        return "(dynamic)"
    return "(unknown)"


def extract_field(content: str, key: str) -> str | None:
    """Extract value for a key from Lua table content. Handles multi-line."""
    # Match key = value, where value can be string, nil, or expression
    patterns = [
        rf'{key}\s*=\s*["\']([^"\']*)["\']',
        rf'{key}\s*=\s*\(L\s+and\s+L\[["\'][^"\']*["\']\]\)\s+or\s+["\']([^"\']*)["\']',
        rf'{key}\s*=\s*(L\[["\'][^"\']*["\']\]\s*(?:\s+or\s+["\'][^"\']*["\'])?)',
        rf'{key}\s*=\s*(function\s*\([^)]*\)[^e]*end)',
        rf'{key}\s*=\s*(nil)',
        rf'{key}\s*=\s*([^,\n}}]+)',
    ]
    for i, pat in enumerate(patterns):
        m = re.search(pat, content, re.DOTALL)
        if m:
            raw = m.group(1).strip()
            if raw == "nil":
                return None
            if i == 1:
                return raw
            if raw.startswith('L[') or raw.startswith('"') or raw.startswith("'"):
                return extract_lua_string(raw)
            if "function" in raw:
                return "(dynamic)"
            return raw
    return None


def find_matching_brace(text: str, start: int) -> int:
    """Find the closing brace matching the one at start."""
    depth = 0
    i = start
    while i < len(text):
        c = text[i]
        if c == "{":
            depth += 1
        elif c == "}":
            depth -= 1
            if depth == 0:
                return i
        elif c in '"\'':
            quote = c
            i += 1
            while i < len(text) and text[i] != quote:
                if text[i] == "\\":
                    i += 1
                i += 1
        i += 1
    return -1


def parse_option_block(content: str) -> dict | None:
    """Parse a single option table block into a dict."""
    opt_type = extract_field(content, "type")
    if not opt_type:
        return None

    name = extract_field(content, "name")
    if not name and opt_type != "section":
        name = extract_field(content, "labelText")
    if not name:
        db_key = extract_field(content, "dbKey")
        if db_key and "_profiles_spec_" in str(db_key):
            name = "Spec profile"
        else:
            name = "(no name)"

    desc = extract_field(content, "desc") or extract_field(content, "tooltip")
    # Special types: add note when no description
    if not desc and opt_type in ("colorMatrixFull", "colorMatrix"):
        desc = "(complex color matrix)"
    elif not desc and opt_type == "blacklistGrid":
        desc = "(blacklist management)"
    elif not desc and opt_type == "presencePreview":
        desc = "(preview widget)"

    return {
        "type": opt_type,
        "name": name,
        "dbKey": extract_field(content, "dbKey"),
        "desc": desc,
        "tooltip": extract_field(content, "tooltip"),
    }


def parse_options_from_table(text: str, start: int) -> list[dict]:
    """Parse options from a Lua table starting at start."""
    options = []
    i = start
    while i < len(text):
        # Find next { that starts an option (type = "..." at top level)
        next_brace = text.find("{", i)
        if next_brace == -1:
            break
        end = find_matching_brace(text, next_brace)
        if end == -1:
            break
        block = text[next_brace : end + 1]
        # Check if it looks like an option (has type =)
        if 'type =' in block[:200]:
            opt = parse_option_block(block)
            if opt:
                options.append(opt)
        i = end + 1
    return options


def parse_options_from_function(text: str, opts_pos: int) -> list[dict]:
    """Parse options from a function body (opts[#opts + 1] = {...} pattern)."""
    options = []
    # Find function() - may be wrapped in ( ) for IIFE
    search_from = text[opts_pos:]
    func_match = re.search(r'\(?\s*function\s*\([^)]*\)', search_from)
    if not func_match:
        return options
    body_start = opts_pos + func_match.end()
    # Find matching 'end' for this function (skip nested function ends)
    depth = 1  # we're inside the options function
    i = body_start
    body_end = -1
    while i < len(text):
        # Skip line comments
        if i + 1 < len(text) and text[i:i+2] == "--":
            i = text.find("\n", i)
            if i == -1:
                break
            continue
        # Skip strings
        if text[i] in '"\'':
            q = text[i]
            i += 1
            while i < len(text) and text[i] != q:
                if text[i] == "\\":
                    i += 1
                i += 1
            i += 1
            continue
        if i + 2 < len(text) and text[i:i+3] == "end":
            if (i + 3 >= len(text) or text[i+3] in " \t\n,)") and (i == 0 or text[i-1] in " \t\n;}"):
                depth -= 1
                if depth == 0:
                    body_end = i
                    break
        elif i + 7 < len(text) and text[i:i+8] == "function":
            depth += 1
        elif i + 1 < len(text) and text[i:i+2] == "if" and (i == 0 or text[i-1] in " \t\n;}"):
            if (i + 2 >= len(text) or text[i+2] in " \t\n("):
                depth += 1
        elif i + 2 < len(text) and text[i:i+3] == "for" and (i == 0 or text[i-1] in " \t\n;}"):
            if (i + 3 >= len(text) or text[i+3] in " \t\n"):
                depth += 1
        elif i + 4 < len(text) and text[i:i+5] == "while" and (i == 0 or text[i-1] in " \t\n;}"):
            if (i + 5 >= len(text) or text[i+5] in " \t\n"):
                depth += 1
        elif i + 5 < len(text) and text[i:i+6] == "repeat" and (i == 0 or text[i-1] in " \t\n;}"):
            depth += 1
        i += 1
    if body_end == -1:
        return options
    body = text[body_start:body_end]
    if not body or body_end == -1:
        return options

    # Handle: return { { type = "section", ... }, ... } (VistaAppearance, etc.)
    return_match = re.search(r'return\s*\{', body)
    if return_match:
        brace_start = return_match.end() - 1
        end = find_matching_brace(body, brace_start)
        if end != -1:
            table_content = body[brace_start : end + 1]
            opts_from_return = parse_options_from_table(table_content, 1)
            if opts_from_return:
                options = opts_from_return

    # Also handle: local opts = { { type = "section", ... }, { type = "toggle", ... } }
    opts_table = re.search(r'local\s+opts\s*=\s*\{', body)
    if opts_table:
        brace_start = opts_table.end() - 1
        end = find_matching_brace(body, brace_start)
        if end != -1:
            table_content = body[brace_start : end + 1]
            opts_from_table = parse_options_from_table(table_content, 1)  # skip outer {
            if opts_from_table:
                options = opts_from_table

    # Find all opts[#opts + 1] = { ... }
    pos = 0
    while pos < len(body):
        m = re.search(r'opts\[#opts\s*\+\s*1\]\s*=\s*\{', body[pos:])
        if not m:
            break
        brace_start = pos + m.end() - 1  # position of {
        end = find_matching_brace(body, brace_start)
        if end == -1:
            break
        block = body[brace_start : end + 1]
        if "type =" in block[:200]:
            opt = parse_option_block(block)
            if opt:
                options.append(opt)
        pos = end + 1
    return options


def parse_categories(lua_content: str) -> list[dict]:
    """Parse OptionCategories from the Lua file."""
    # Find OptionCategories = { ... }
    cat_match = re.search(r'local OptionCategories\s*=\s*\{', lua_content)
    if not cat_match:
        return []

    table_start = cat_match.end() - 1
    table_end = find_matching_brace(lua_content, table_start)
    if table_end == -1:
        return []
    table_content = lua_content[table_start + 1 : table_end]

    # Find each category block: { key = "...", ... },
    categories = []
    pos = 0
    while pos < len(table_content):
        # Find next { that starts a category (followed by key = ")
        m = re.search(r'\{\s*key\s*=\s*["\']', table_content[pos:])
        if not m:
            break
        cat_start = pos + m.start()
        end = find_matching_brace(table_content, cat_start)
        if end == -1:
            break
        cat_block = table_content[cat_start : end + 1]
        key = extract_field(cat_block, "key")
        if not key:
            pos = end + 1
            continue
        name = extract_field(cat_block, "name")
        if not name:
            name = key
        module_key = extract_field(cat_block, "moduleKey")
        if module_key == "nil" or module_key == "(unknown)":
            module_key = None

        options = []
        opts_match = re.search(r'options\s*=\s*', cat_block)
        if opts_match:
            opts_pos = opts_match.end()
            rest = cat_block[opts_pos:].strip()
            if rest.startswith("function") or rest.startswith("("):
                options = parse_options_from_function(cat_block, opts_pos)
            elif rest.startswith("{"):
                brace_start = cat_block.find("{", opts_pos)
                options = parse_options_from_table(cat_block, brace_start + 1)  # skip outer {

        categories.append({
            "key": key,
            "name": name,
            "moduleKey": module_key,
            "options": options,
        })
        pos = end + 1

    return categories


def generate_html(categories: list[dict]) -> str:
    """Generate HTML review document."""
    html_parts = [
        """<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Horizon Suite — Settings Review</title>
    <style>
        :root { --bg: #0d0d0f; --surface: #141418; --border: #252530; --text: #e0e0e8; --muted: #8888a0; --accent: #2aa8c9; }
        * { box-sizing: border-box; }
        body { font-family: 'Segoe UI', system-ui, sans-serif; background: var(--bg); color: var(--text); margin: 0; padding: 24px; line-height: 1.5; }
        h1 { font-size: 1.5rem; margin: 0 0 8px; }
        .subtitle { color: var(--muted); font-size: 0.9rem; margin-bottom: 20px; }
        #search { width: 100%; max-width: 400px; padding: 10px 14px; margin-bottom: 20px; background: var(--surface); border: 1px solid var(--border); color: var(--text); border-radius: 6px; font-size: 14px; }
        #search:focus { outline: none; border-color: var(--accent); }
        .module { margin-bottom: 24px; }
        .module-header { font-size: 1.1rem; font-weight: 600; color: var(--accent); margin-bottom: 8px; padding: 8px 0; border-bottom: 1px solid var(--border); }
        .module-header.dev-only::after { content: " (dev-only)"; font-weight: 400; color: var(--muted); font-size: 0.85rem; }
        .category { margin: 12px 0; }
        details { background: var(--surface); border: 1px solid var(--border); border-radius: 6px; margin-bottom: 8px; }
        summary { padding: 12px 16px; cursor: pointer; font-weight: 500; }
        summary:hover { background: rgba(255,255,255,0.03); }
        .section-name { color: var(--muted); font-size: 0.85rem; margin: 4px 0 8px; }
        table { width: 100%; border-collapse: collapse; font-size: 13px; }
        th, td { padding: 8px 12px; text-align: left; border-bottom: 1px solid var(--border); }
        th { color: var(--muted); font-weight: 500; font-size: 0.8rem; text-transform: uppercase; }
        tr:hover { background: rgba(255,255,255,0.02); }
        .type-badge { display: inline-block; padding: 2px 6px; border-radius: 4px; font-size: 0.75rem; background: rgba(42,168,201,0.2); color: var(--accent); }
        .no-results { padding: 24px; color: var(--muted); text-align: center; }
    </style>
</head>
<body>
    <h1>Horizon Suite — Settings Review</h1>
    <p class="subtitle">All settings from the Dashboard options panel. Source: OptionsData.lua</p>
    <input type="text" id="search" placeholder="Search by name, dbKey, or description..." autocomplete="off">
""",
    ]

    for cat in categories:
        module_key = cat.get("moduleKey")
        module_label = MODULE_LABELS.get(module_key, str(module_key or "Core"))
        is_dev = module_key in DEV_ONLY_MODULES

        # Group options by section
        current_section = ""
        sections = {}
        for opt in cat.get("options", []):
            if opt["type"] == "section":
                current_section = opt["name"]
                if current_section not in sections:
                    sections[current_section] = []
            else:
                if current_section not in sections:
                    sections[current_section] = []
                sections[current_section].append(opt)

        # If no sections, use category name
        if not sections:
            sections[cat["name"]] = []

        cat_id = re.sub(r"[^a-z0-9]", "-", cat["key"].lower())
        html_parts.append(f'    <div class="module" data-module="{module_label}">')
        html_parts.append(f'        <div class="module-header{" dev-only" if is_dev else ""}">{module_label} — {cat["name"]}</div>')

        for section_name, opts in sections.items():
            if not opts and section_name:
                continue
            section_id = re.sub(r"[^a-z0-9]", "-", section_name.lower())[:30]
            html_parts.append(f'        <details class="category" data-category="{cat["key"]}">')
            html_parts.append(f'            <summary>{section_name or "General"}</summary>')
            html_parts.append(f'            <div class="section-name">Section: {section_name or "(none)"}</div>')
            html_parts.append('            <table>')
            html_parts.append("                <thead><tr><th>Name</th><th>Type</th><th>dbKey</th><th>Description</th></tr></thead>")
            html_parts.append("                <tbody>")
            for o in opts:
                desc = (o.get("desc") or o.get("tooltip") or "").replace("<", "&lt;").replace(">", "&gt;")
                dbk = o.get("dbKey") or "—"
                searchable = f' data-search="{o.get("name","").lower()} {dbk.lower()} {desc.lower()}"'
                html_parts.append(
                    f'                <tr{searchable}><td>{o.get("name","—")}</td><td><span class="type-badge">{o.get("type","")}</span></td><td><code>{dbk}</code></td><td>{desc or "—"}</td></tr>'
                )
            html_parts.append("                </tbody>")
            html_parts.append("            </table>")
            html_parts.append("        </details>")
        html_parts.append("    </div>")

    html_parts.append("""
    <script>
        const search = document.getElementById('search');
        search.addEventListener('input', function() {
            const q = this.value.trim().toLowerCase();
            document.querySelectorAll('.module').forEach(mod => {
                if (!q) {
                    mod.style.display = '';
                    mod.querySelectorAll('details').forEach(d => { d.style.display = ''; });
                    mod.querySelectorAll('tr[data-search]').forEach(r => { r.style.display = ''; });
                    return;
                }
                let modHasMatch = false;
                mod.querySelectorAll('details').forEach(d => {
                    let sectionHasMatch = false;
                    d.querySelectorAll('tr[data-search]').forEach(r => {
                        const match = r.dataset.search && r.dataset.search.includes(q);
                        r.style.display = match ? '' : 'none';
                        if (match) sectionHasMatch = true;
                    });
                    d.style.display = sectionHasMatch ? '' : 'none';
                    if (sectionHasMatch) modHasMatch = true;
                });
                mod.style.display = modHasMatch ? '' : 'none';
            });
        });
    </script>
</body>
</html>
""")
    return "\n".join(html_parts)


def main():
    if not OPTIONS_DATA.exists():
        print(f"Error: {OPTIONS_DATA} not found")
        return 1

    content = OPTIONS_DATA.read_text(encoding="utf-8", errors="replace")
    categories = parse_categories(content)

    if not categories:
        print("Warning: No categories parsed. Check OptionsData.lua structure.")

    html = generate_html(categories)
    OUTPUT_HTML.parent.mkdir(parents=True, exist_ok=True)
    OUTPUT_HTML.write_text(html, encoding="utf-8")
    total_opts = sum(len(c.get("options", [])) for c in categories)
    print(f"Wrote {OUTPUT_HTML} - {len(categories)} categories, {total_opts} settings")
    return 0


if __name__ == "__main__":
    exit(main())
