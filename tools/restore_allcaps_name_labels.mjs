/**
 * For Options `name` keys: if git HEAD enUS had an all-caps (no a-z) value,
 * restore that string in the working tree. Run after a mistaken titlecase pass.
 */
import { execFileSync } from "node:child_process";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const root = path.join(__dirname, "..");
const optionsDataPath = path.join(root, "options", "OptionsData.lua");
const enusPath = path.join(root, "Localisation", "enUS.lua");

function getNameKeys() {
  const s = fs.readFileSync(optionsDataPath, "utf8");
  const re = /name\s*=\s*L\["([A-Z0-9_]+)"\]/g;
  const keys = new Set();
  let m;
  while ((m = re.exec(s)) !== null) keys.add(m[1]);
  return keys;
}

function parseDq(content, key) {
  const re = new RegExp(`^L\\["${key}"\\]\\s*=\\s*"((?:\\\\.|[^"\\\\])*)"`, "m");
  const m = content.match(re);
  if (m) return m[1].replace(/\\n/g, "\n").replace(/\\"/g, '"').replace(/\\\\/g, "\\");
  return null;
}

function luaEscapeDq(s) {
  return s.replace(/\\/g, "\\\\").replace(/"/g, '\\"');
}

function isAllCapsLabel(s) {
  if (!s) return false;
  const noColor = s.replace(/\|c[0-9a-fA-F]{8}[^|]*\|r/g, "");
  if (!/[A-Za-z]/.test(noColor)) return false;
  return !/[a-z]/.test(noColor);
}

function setLine(content, key, newValue) {
  const re = new RegExp(`^L\\["${key}"\\]\\s*=\\s*"((?:\\\\.|[^"\\\\])*)"`, "m");
  if (!re.test(content)) return { ok: false, content };
  const esc = luaEscapeDq(newValue);
  return { ok: true, content: content.replace(re, `L["${key}"] = "${esc}"`) };
}

const nameKeys = getNameKeys();
let head;
try {
  head = execFileSync("git", ["show", "HEAD:localisation/horizon/enUS.lua"], { cwd: root, encoding: "utf8" });
} catch {
  console.error("No git or HEAD:localisation/horizon/enUS.lua; nothing to do.");
  process.exit(0);
}

let c = fs.readFileSync(enusPath, "utf8");
const restored = [];
for (const k of nameKeys) {
  const vHead = parseDq(head, k);
  if (vHead === null) continue;
  if (!isAllCapsLabel(vHead)) continue;
  const vWork = parseDq(c, k);
  if (vWork === vHead) continue;
  const r = setLine(c, k, vHead);
  if (!r.ok) continue;
  c = r.content;
  restored.push({ key: k, from: vWork, to: vHead });
}

if (restored.length) {
  fs.writeFileSync(enusPath, c, "utf8");
  console.error("Restored", restored.length, "all-caps name labels from HEAD enUS");
  for (const x of restored) console.log(JSON.stringify(x));
} else {
  console.error("No all-caps name keys to restore from HEAD (0 changes).");
}
