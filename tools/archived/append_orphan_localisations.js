#!/usr/bin/env node
/**
 * ARCHIVED — one-time: merged OptionsData-only strings into enUS + mapping (2026).
 */

const fs = require('fs');
const path = require('path');

const ROOT = path.resolve(__dirname, '..', '..');
const mappingPath = path.join(ROOT, 'tools', 'locale-key-mapping.json');
const enUSPath = path.join(ROOT, 'Localisation', 'enUS.lua');

function makeSlug(s) {
    return s
        .replace(/%[sd%]/g, 'X')
        .replace(/[^a-zA-Z0-9]+/g, '_')
        .replace(/^_+|_+$/g, '')
        .toUpperCase()
        .substring(0, 55)
        .replace(/_+$/, '') || 'STRING';
}

function uniqueSym(prefix, slug, used) {
    let k = `${prefix}_${slug}`;
    if (!used.has(k)) {
        used.add(k);
        return k;
    }
    for (let i = 2; i < 99999; i++) {
        const k2 = `${prefix}_${slug}_${i}`;
        if (!used.has(k2)) {
            used.add(k2);
            return k2;
        }
    }
}

function walk(dir, out) {
    for (const name of fs.readdirSync(dir)) {
        const p = path.join(dir, name);
        if (fs.statSync(p).isDirectory()) walk(p, out);
        else if (name.endsWith('.lua')) out.push(p);
    }
}

const mapping = JSON.parse(fs.readFileSync(mappingPath, 'utf8'));
const validKeys = new Set(Object.values(mapping));
const enUS = fs.readFileSync(enUSPath, 'utf8');
let m;
const reEn = /^L\["([^"]+)"\]\s*=/gm;
while ((m = reEn.exec(enUS))) {
    validKeys.add(m[1]);
}

const dirs = ['modules', 'options', 'core'].map((d) => path.join(ROOT, d));
const files = [path.join(ROOT, 'Utilities.lua')];
for (const d of dirs) walk(d, files);

const re = /(?:^|[^.\w])L\["([^"]+)"\]/g;
const reAddon = /addon\.L\["([^"]+)"\]/g;
const used = new Set();
for (const f of files) {
    if (f.includes(`${path.sep}locales${path.sep}`) || f.includes(`${path.sep}Localisation${path.sep}`)) continue;
    const t = fs.readFileSync(f, 'utf8');
    while ((m = re.exec(t))) used.add(m[1]);
    while ((m = reAddon.exec(t))) used.add(m[1]);
}

const orphans = [...used].filter((k) => !validKeys.has(k)).sort();

function prefixForString(s, fileHint) {
    if (/RARE DEFEATED|Scenario Complete|Level up/i.test(s) && fileHint.includes('Presence')) return 'PRESENCE';
    if (/Optional reagents|Finishing reagents/i.test(s)) return 'FOCUS';
    if (fileHint.includes('Focus')) return 'FOCUS';
    if (fileHint.includes('Presence')) return 'PRESENCE';
    if (fileHint.includes('Vista')) return 'VISTA';
    if (fileHint.includes('Insight')) return 'INSIGHT';
    return 'OPTIONS';
}

// First pass: find file hint per orphan (first file containing L["orphan"])
const orphanFile = new Map();
for (const o of orphans) {
    for (const f of files) {
        if (f.includes('locales') || f.includes('Localisation')) continue;
        const t = fs.readFileSync(f, 'utf8');
        const needle = 'L["' + o.replace(/\\/g, '\\\\').replace(/"/g, '\\"') + '"]';
        if (t.includes(needle)) {
            orphanFile.set(o, f);
            break;
        }
    }
}

const usedSyms = new Set(validKeys);
const additions = [];

for (const o of orphans) {
    const hint = orphanFile.get(o) || '';
    const prefix = prefixForString(o, hint);
    const slug = makeSlug(o);
    const sym = uniqueSym(prefix, slug, usedSyms);
    mapping[o] = sym;
    additions.push({ o, sym });
}

const block = [
    '',
    '-- =====================================================================',
    '-- Inline option / module strings (not in legacy LocaleBase; added for symbolic keys)',
    '-- =====================================================================',
    '',
];

function luaQuoted(s) {
    return '"' + s.replace(/\\/g, '\\\\').replace(/"/g, '\\"').replace(/\n/g, '\\n').replace(/\r/g, '\\r') + '"';
}

for (const { o, sym } of additions) {
    const ctx = (o.length > 100 ? o.substring(0, 97) + '...' : o).replace(/\n/g, ' ');
    block.push(`-- Context: ${ctx}`);
    block.push(`L["${sym}"] = ${luaQuoted(o)}`);
    block.push('');
}

fs.writeFileSync(mappingPath, JSON.stringify(mapping, null, 2) + '\n', 'utf8');
fs.writeFileSync(enUSPath, enUS.trimEnd() + '\n' + block.join('\n') + '\n', 'utf8');

console.log('Added', additions.length, 'orphan strings to enUS.lua and locale-key-mapping.json');
