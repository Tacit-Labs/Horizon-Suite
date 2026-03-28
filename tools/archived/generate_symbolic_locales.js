#!/usr/bin/env node
/**
 * ARCHIVED — one-time migration (2026). Requires removed `locales/` tree from git history.
 * Current workflow: edit Localisation/enUS.lua + node tools/restructure_locales.js
 *
 * Was: LocaleBase.lua -> Localisation/enUS.lua, locale-key-mapping.json, Localisation/{lang}.lua
 */

const fs = require('fs');
const path = require('path');

const ROOT = path.resolve(__dirname, '..', '..');
const LEGACY = path.join(ROOT, 'locales');
const OUT_DIR = path.join(ROOT, 'Localisation');
const MAPPING_PATH = path.join(ROOT, 'tools', 'locale-key-mapping.json');

function sectionToPrefix(commentLine) {
    const m = commentLine.match(/^--\s+(.+)/);
    if (!m) return 'UI';
    const head = m[1].split('—')[0].trim();
    if (/OptionsPanel|OptionsData|SettingsBridge/i.test(head)) return 'OPTIONS';
    if (/DashboardPanel/i.test(head)) return 'DASH';
    if (/Presence/i.test(head)) return 'PRESENCE';
    if (/Focus/i.test(head)) return 'FOCUS';
    if (/Vista|Minimap/i.test(head)) return 'VISTA';
    if (/Insight/i.test(head)) return 'INSIGHT';
    if (/Essence/i.test(head)) return 'ESSENCE';
    if (/Slash/i.test(head)) return 'SLASH';
    if (/Keybind/i.test(head)) return 'KEYBIND';
    if (/Utilities|Core\.lua/i.test(head)) return 'UI';
    if (/Locale|locale_template/i.test(head)) return 'LOCALE';
    return 'UI';
}

function makeSlug(englishKey) {
    let s = englishKey
        .replace(/%[sd%]/g, 'X')
        .replace(/[^a-zA-Z0-9]+/g, '_')
        .replace(/^_+|_+$/g, '')
        .toUpperCase();
    if (s.length > 52) s = s.substring(0, 52).replace(/_+$/, '');
    if (!s) s = 'STRING';
    return s;
}

function uniqueSymbolic(prefix, slug, used) {
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
    throw new Error('Too many collisions');
}

function parseValue(text, start) {
    if (text[start] === '"') {
        let i = start + 1;
        while (i < text.length) {
            if (text[i] === '\\') {
                i += 2;
                continue;
            }
            if (text[i] === '"') {
                return { raw: text.slice(start, i + 1), end: i + 1 };
            }
            i++;
        }
        throw new Error('Unterminated string at ' + start);
    }
    if (text[start] === '[') {
        const sub = text.slice(start);
        const openM = sub.match(/^\[=*\[/);
        if (!openM) throw new Error('Bad long string at ' + start);
        const open = openM[0];
        const eqCount = open.length - 2;
        const close = ']' + '='.repeat(eqCount) + ']';
        const closeIdx = text.indexOf(close, start + open.length);
        if (closeIdx === -1) throw new Error('Unterminated long string');
        return { raw: text.slice(start, closeIdx + close.length), end: closeIdx + close.length };
    }
    throw new Error('Unknown value at ' + start + ': ' + JSON.stringify(text.slice(start, start + 40)));
}

function extractKeysFromLocaleFile(filePath) {
    const text = fs.readFileSync(filePath, 'utf8');
    const keys = [];
    let pos = 0;
    const marker = 'L["';
    while (true) {
        const idx = text.indexOf(marker, pos);
        if (idx === -1) break;
        const keyStart = idx + marker.length;
        const keyEnd = text.indexOf('"]', keyStart);
        if (keyEnd === -1) break;
        const oldKey = text.slice(keyStart, keyEnd);
        let after = keyEnd + 2;
        while (after < text.length && /\s/.test(text[after])) after++;
        if (text[after] !== '=') {
            pos = keyStart;
            continue;
        }
        after++;
        while (after < text.length && /\s/.test(text[after])) after++;
        try {
            const { raw, end } = parseValue(text, after);
            keys.push({ oldKey, valueRaw: raw });
            pos = end;
        } catch {
            pos = keyStart + 1;
        }
    }
    return keys;
}

function parseLocaleBaseStructured() {
    const filePath = path.join(LEGACY, 'LocaleBase.lua');
    const lines = fs.readFileSync(filePath, 'utf8').split(/\r?\n/);
    const entries = [];
    let i = 0;
    let currentSectionComment = '-- (header)';

    while (i < lines.length) {
        const line = lines[i];
        if (/^addon\.L\s*=\s*setmetatable/.test(line.trim())) break;

        if (/^-- =+$/.test(line)) {
            entries.push({ type: 'separator', raw: line });
            i++;
            if (i < lines.length && /^-- /.test(lines[i]) && !lines[i].startsWith('-- L[')) {
                currentSectionComment = lines[i];
                entries.push({ type: 'comment', raw: lines[i], section: currentSectionComment });
                i++;
            }
            continue;
        }

        const kvMatch = line.match(/^L\["(.+?)"\]\s*=\s*(.*)$/);
        if (kvMatch) {
            const oldKey = kvMatch[1];
            let rest = kvMatch[2];
            let valueRaw = rest;
            if (rest.startsWith('"') && !rest.match(/^"([^"\\]|\\.)*"\s*$/)) {
                let acc = rest;
                i++;
                while (i < lines.length) {
                    acc += '\n' + lines[i];
                    const q = acc.match(/(")((?:\\.|[^"\\])*)"\s*$/);
                    if (q) {
                        valueRaw = acc.replace(/\s*$/, '');
                        break;
                    }
                    i++;
                }
            } else if (rest.startsWith('[=')) {
                let acc = rest;
                if (!/\]=\]\s*$/.test(acc)) {
                    i++;
                    while (i < lines.length) {
                        acc += '\n' + lines[i];
                        if (/\]=\]\s*$/.test(acc)) break;
                        i++;
                    }
                }
                valueRaw = acc.replace(/\s*$/, '');
            } else {
                valueRaw = rest.replace(/\s*$/, '');
            }

            const prefix = sectionToPrefix(currentSectionComment);
            entries.push({
                type: 'key',
                oldKey,
                valueRaw,
                sectionComment: currentSectionComment,
                prefix,
            });
            i++;
            continue;
        }

        if (line.trim() === '') {
            entries.push({ type: 'blank' });
            i++;
            continue;
        }

        if (line.startsWith('--[[') || line.startsWith('local addon') || line.startsWith('if not addon')) {
            i++;
            continue;
        }

        i++;
    }

    return entries;
}

function buildSymbolicEntries(entries) {
    const used = new Set();
    const mapping = {};
    const out = [];

    for (const e of entries) {
        if (e.type !== 'key') {
            out.push(e);
            continue;
        }
        let sym = mapping[e.oldKey];
        if (!sym) {
            const slug = makeSlug(e.oldKey);
            sym = uniqueSymbolic(e.prefix, slug, used);
            mapping[e.oldKey] = sym;
        }
        out.push({
            ...e,
            symKey: sym,
        });
    }

    return { entries: out, mapping };
}

function escapeLuaKey(s) {
    return s.replace(/\\/g, '\\\\').replace(/"/g, '\\"');
}

function luaAssign(symKey, valueRaw, contextLine) {
    const ctx = contextLine
        ? `-- Context: ${contextLine.replace(/^--\s*/, '').trim()}`
        : '-- Context: (see section header)';
    return `${ctx}\nL["${escapeLuaKey(symKey)}"] = ${valueRaw}`;
}

function shortContext(sectionComment) {
    const m = sectionComment.match(/^--\s+(.+)/);
    return m ? m[1].trim().substring(0, 120) : '';
}

function generateEnUS(entriesWithSym) {
    const lines = [];
    lines.push('--[[');
    lines.push('    Horizon Suite — English (enUS) source strings');
    lines.push('    Symbolic keys; other locales override via metatable chain.');
    lines.push(']]');
    lines.push('');
    lines.push('local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite');
    lines.push('if not addon then return end');
    lines.push('');
    lines.push('local L = addon.L');
    lines.push('');

    for (const e of entriesWithSym) {
        if (e.type === 'separator' || e.type === 'comment') {
            lines.push(e.raw);
            continue;
        }
        if (e.type === 'blank') {
            lines.push('');
            continue;
        }
        if (e.type === 'key') {
            const ctx = shortContext(e.sectionComment);
            lines.push(luaAssign(e.symKey, e.valueRaw, `-- ${ctx}`));
            lines.push('');
        }
    }

    return lines.join('\n').replace(/\n\n\n+/g, '\n\n') + '\n';
}

function parseLegacyLocaleValues(filePath) {
    const pairs = extractKeysFromLocaleFile(filePath);
    const map = {};
    for (const p of pairs) {
        map[p.oldKey] = p.valueRaw;
    }
    return map;
}

function generateLocaleFile(localeCode, entriesWithSym, translatedMap) {
    const lines = [];
    lines.push(`if GetLocale() ~= "${localeCode}" then return end`);
    lines.push('');
    lines.push('local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite');
    lines.push('if not addon then return end');
    lines.push('');
    lines.push('local L = setmetatable({}, { __index = addon.L })');
    lines.push('addon.L = L');
    lines.push('addon.StandardFont = UNIT_NAME_FONT');
    lines.push('');

    for (const e of entriesWithSym) {
        if (e.type === 'separator' || e.type === 'comment') {
            lines.push(e.raw);
            continue;
        }
        if (e.type === 'blank') {
            lines.push('');
            continue;
        }
        if (e.type === 'key') {
            const sym = e.symKey;
            const rhs = translatedMap[e.oldKey];
            if (rhs !== undefined) {
                lines.push(`L["${sym}"] = ${rhs}`);
            } else {
                lines.push(`-- L["${sym}"] = ${e.valueRaw}  -- NEEDS TRANSLATION`);
            }
        }
    }

    return lines.join('\n') + '\n';
}

function main() {
    console.log('Parsing LocaleBase.lua structure...');
    const structured = parseLocaleBaseStructured();
    const keyCount = structured.filter((e) => e.type === 'key').length;
    console.log(`  Structured keys: ${keyCount}`);

    const { entries: withSym, mapping } = buildSymbolicEntries(structured);
    console.log(`  Symbolic keys: ${Object.keys(mapping).length}`);

    fs.mkdirSync(OUT_DIR, { recursive: true });
    fs.writeFileSync(path.join(OUT_DIR, 'enUS.lua'), generateEnUS(withSym), 'utf8');
    console.log('Written Localisation/enUS.lua');

    fs.writeFileSync(MAPPING_PATH, JSON.stringify(mapping, null, 2) + '\n', 'utf8');
    console.log('Written tools/locale-key-mapping.json');

    const LOCALES = ['deDE', 'esES', 'frFR', 'koKR', 'ptBR', 'ruRU', 'zhCN'];
    for (const loc of LOCALES) {
        const legacyPath = path.join(LEGACY, `${loc}.lua`);
        if (!fs.existsSync(legacyPath)) continue;
        const translatedMap = parseLegacyLocaleValues(legacyPath);
        const out = generateLocaleFile(loc, withSym, translatedMap);
        fs.writeFileSync(path.join(OUT_DIR, `${loc}.lua`), out, 'utf8');
        console.log(`Written Localisation/${loc}.lua`);
    }

    console.log('Done.');
}

main();
