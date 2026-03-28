#!/usr/bin/env node
/**
 * ARCHIVED — one-time consumer migration (2026). Mapping is complete.
 * Kept for reference; do not re-run (would no-op on symbolic keys).
 */

const fs = require('fs');
const path = require('path');

const ROOT = path.resolve(__dirname, '..', '..');
const mapping = JSON.parse(fs.readFileSync(path.join(ROOT, 'tools', 'locale-key-mapping.json'), 'utf8'));
const keys = Object.keys(mapping).sort((a, b) => b.length - a.length);

function escapeRe(s) {
    return s.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}

function replaceInContent(text) {
    let out = text;
    for (const oldKey of keys) {
        const sym = mapping[oldKey];
        const reL = new RegExp('L\\["' + escapeRe(oldKey) + '"\\]', 'g');
        out = out.replace(reL, `L["${sym}"]`);
        const reAL = new RegExp('addon\\.L\\["' + escapeRe(oldKey) + '"\\]', 'g');
        out = out.replace(reAL, `addon.L["${sym}"]`);
    }
    return out;
}

function walkLua(dir, callback) {
    if (!fs.existsSync(dir)) return;
    for (const name of fs.readdirSync(dir)) {
        const p = path.join(dir, name);
        const st = fs.statSync(p);
        if (st.isDirectory()) walkLua(p, callback);
        else if (name.endsWith('.lua')) callback(p);
    }
}

const skipDir = (p) =>
    p.includes(`${path.sep}Localisation${path.sep}`) ||
    p.includes(`${path.sep}locales${path.sep}`) ||
    p.includes(`${path.sep}tools${path.sep}`);

let files = 0;
for (const sub of ['modules', 'options', 'core']) {
    walkLua(path.join(ROOT, sub), (p) => {
        if (skipDir(p)) return;
        let t = fs.readFileSync(p, 'utf8');
        const n = replaceInContent(t);
        if (n !== t) {
            fs.writeFileSync(p, n, 'utf8');
            files++;
        }
    });
}

const utilPath = path.join(ROOT, 'Utilities.lua');
if (fs.existsSync(utilPath)) {
    let t = fs.readFileSync(utilPath, 'utf8');
    const n = replaceInContent(t);
    if (n !== t) {
        fs.writeFileSync(utilPath, n, 'utf8');
        files++;
    }
}

console.log(`Updated ${files} Lua files.`);
