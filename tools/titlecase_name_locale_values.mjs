/**
 * AP-style title case for Options `name` locale values only.
 * Preserves |cff / |r blocks. If the whole label has no lowercase letters (all-caps, e.g. ACHIEVEMENTS, LFR), it is not changed.
 *
 *   node tools/titlecase_name_locale_values.mjs
 *   node tools/titlecase_name_locale_values.mjs --write
 */
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const root = path.join(__dirname, "..");
const optionsDataPath = path.join(root, "options", "OptionsData.lua");
const enusPath = path.join(root, "localisation/horizon/enUS.lua");

const SMALL = new Set(
  "a an and as at but by for in nor of on or the to with vs is it if as per be so up we us re".split(" ")
);

function isPreservedAllCaps(w) {
  const core = w.replace(/^[^A-Za-z0-9+]+|[^A-Za-z0-9+]+$/g, "");
  if (core.length < 2 || core.length > 5) return false;
  return core === core.toUpperCase() && /[A-Z0-9]/.test(core);
}

function doCapWord(w) {
  if (!w) return w;
  const lower = w.toLowerCase();
  if (lower === "blizzard+") return "Blizzard+";
  if (lower === "wowhead") return "WoWhead";
  if (lower === "lfr") return "LFR";
  if (lower === "m+") return "M+";
  if (lower === "pve" || w === "PvE" || w === "PVE") return "PvE";
  if (lower === "pvp" || w === "PvP" || w === "PVP") return "PvP";
  if (lower === "ui" || w === "UI") return "UI";
  if (lower === "npc" || w === "NPC") return "NPC";
  if (isPreservedAllCaps(w)) return w;
  if (/^[\d%]+$/.test(w) || /^\d+D$/i.test(w)) return w;
  if (/^\+$/.test(w)) return w;
  if (/[–—-]/.test(w)) {
    return w.split(/([–—-])/).map((p) => (/[–—-]/.test(p) ? p : doCapWord(p))).join("");
  }
  return w.charAt(0).toUpperCase() + lower.slice(1);
}

function capToken(token) {
  if (!/[A-Za-z]/.test(token)) return token;
  const m = token.match(/^([^A-Za-z0-9%]*)([A-Za-z0-9%][A-Za-z0-9%'.+&-]*)([^A-Za-z0-9%'.+&-]*)$/);
  if (!m) return token;
  return m[1] + doCapWord(m[2]) + (m[3] || "");
}

function toTitlePlain(s) {
  const sp = s.split(/(\s+)/);
  const wordIdxs = sp.map((t, i) => (!/^\s+$/.test(t) && /[A-Za-z]/.test(t) ? i : -1)).filter((i) => i >= 0);
  if (wordIdxs.length === 0) return s;
  return sp
    .map((t, i) => {
      if (/^\s+$/.test(t) || !/[A-Za-z]/.test(t)) return t;
      const at = wordIdxs.indexOf(i);
      if (at < 0) return t;
      const isFirst = at === 0;
      const isLast = at === wordIdxs.length - 1;
      const m2 = t.match(/^([^A-Za-z0-9%]*)([A-Za-z0-9%][A-Za-z0-9%'.+&-]*)(.*)$/);
      if (!m2) return t;
      const pre = m2[1];
      const w = m2[2];
      const after = m2[3] || "";
      const wLower = w.toLowerCase();
      if (!isFirst && !isLast && SMALL.has(wLower)) {
        return pre + wLower + after;
      }
      return pre + (w.includes("-") && !/^[0-9]/.test(w) ? w.split("-").map((h) => doCapWord(h)).join("-") : doCapWord(w)) + after;
    })
    .join("");
}

/** If every letter in user-visible text is uppercase, keep as-is (e.g. ACHIEVEMENTS, LFR). */
function isFullyCapitalised(s) {
  if (!s) return false;
  const noColor = s.replace(/\|c[0-9a-fA-F]{8}[^|]*\|r/g, "");
  if (!/[A-Za-z]/.test(noColor)) return false;
  return !/[a-z]/.test(noColor);
}

function toTitle(s) {
  if (!s) return s;
  if (isFullyCapitalised(s)) return s;
  return s
    .split(/(\|c[0-9a-fA-F]{8}[^|]*\|r)/g)
    .map((b) => (b && b.startsWith("|c") && b.includes("|r") ? b : toTitlePlain(b)))
    .join("");
}

function luaEscapeDq(s) {
  return s.replace(/\\/g, "\\\\").replace(/"/g, '\\"');
}

function getNameKeys() {
  const s = fs.readFileSync(optionsDataPath, "utf8");
  const re = /name\s*=\s*L\["([A-Z0-9_]+)"\]/g;
  const keys = new Set();
  let m;
  while ((m = re.exec(s)) !== null) keys.add(m[1]);
  return keys;
}

/** Single-line: L["KEY"] = "..."  */
function parseEnusDqString(content, key) {
  const re = new RegExp(`^L\\["${key}"\\]\\s*=\\s*"((?:\\\\.|[^"\\\\])*)"`, "m");
  const m = content.match(re);
  if (m) return m[1].replace(/\\n/g, "\n").replace(/\\"/g, '"').replace(/\\\\/g, "\\");
  return null;
}

function setEnusDqString(content, key, newValue) {
  const re = new RegExp(`^L\\["${key}"\\]\\s*=\\s*"((?:\\\\.|[^"\\\\])*)"`, "m");
  if (!re.test(content)) {
    return { ok: false, content };
  }
  const escaped = luaEscapeDq(newValue);
  return {
    ok: true,
    content: content.replace(re, `L["${key}"] = "${escaped}"`),
  };
}

const nameKeys = getNameKeys();
const enus = fs.readFileSync(enusPath, "utf8");
const doWrite = process.argv.includes("--write");

const multiline = [];
const changes = [];

for (const k of nameKeys) {
  const raw = parseEnusDqString(enus, k);
  if (raw === null) {
    multiline.push(k);
    continue;
  }
  const next = toTitle(raw);
  if (next !== raw) changes.push({ key: k, from: raw, to: next });
}

console.error(
  "name=%d, parsed: %d, multiline/unknown: %d, changes: %d",
  nameKeys.size,
  nameKeys.size - multiline.length,
  multiline.length,
  changes.length
);
if (multiline.length) {
  console.error("Not simple quoted (manual check):", multiline.join(", "));
}
for (const c of changes) {
  process.stdout.write(JSON.stringify(c) + "\n");
}

if (doWrite) {
  let c = enus;
  for (const ch of changes) {
    const r = setEnusDqString(c, ch.key, ch.to);
    if (!r.ok) {
      console.error("Failed to replace", ch.key);
      process.exit(1);
    }
    c = r.content;
  }
  fs.writeFileSync(enusPath, c, "utf8");
  console.error("Wrote", changes.length, "title-case updates to localisation/horizon/enUS.lua");
}
