#!/usr/bin/env python3
"""Convert enUS.lua to LocaleBase.lua. Run when enUS template is updated."""
import re

with open("options/enUS.lua", "r", encoding="utf-8") as f:
    content = f.read()

def repl(m):
    key = m.group(1)
    esc = key.replace("\\", "\\\\").replace('"', '\\"')
    return f'L["{esc}"] = "{esc}"'

content = re.sub(r'L\["([^"]+)"\] = true', repl, content)
content = re.sub(r"\nreturn L\s*$", "", content)
content = content.strip()

content = re.sub(r"^-- Translation template.*\n", "", content)
content = re.sub(r"^local L = \{\}\n", "", content)
content = re.sub(r"\n-- This file is intentionally not loaded.*\n", "\n", content)
content = re.sub(r"\n-- Use it as a source when creating.*\n", "\n", content)
content = re.sub(r"\nlocal L = \{\}\n", "\n", content)

header = """--[[
    Horizon Suite - Locale Base (enUS)
    Loaded for all clients. Locale-specific files override with fallback to this.
]]

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite
if not addon then return end

local L = {}

"""

footer = """

addon.L = setmetatable(L, { __index = function(t, k) return k end })
"""

with open("options/LocaleBase.lua", "w", encoding="utf-8") as f:
    f.write(header + content + footer)

print("Created options/LocaleBase.lua")
