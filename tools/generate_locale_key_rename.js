#!/usr/bin/env node
/**
 * Build tools/locale-key-rename.json (oldKey -> shorter newKey) from current enUS.lua.
 * Convention: OPTIONS_<MODULE>_<hook>; DASH_* drops redundant DASHBOARD_;
 * collisions: OPTIONS_SHOW_* sources map to OPTIONS_<mod>_SHOW_<hook> (not numeric _2).
 * Once enUS keys are already migrated, this often proposes a second compression;
 * review before apply. If you only need collision fixes, use semantic_collision_rename.json.
 *
 * Run: node tools/generate_locale_key_rename.js
 * Then: node tools/apply_locale_key_rename.js
 */

const fs = require('fs');
const path = require('path');

const ROOT = path.resolve(__dirname, '..');
const enUSPath = path.join(ROOT, 'Localisation', 'enUS.lua');
const outPath = path.join(ROOT, 'tools', 'locale-key-rename.json');

/* Keep SHOW/SHOWS out of STOP so OPTIONS_*_SHOW_* keys stay distinct (e.g. SHOW_ENDEAVORS vs section ENDEAVORS). */
const STOP = new Set(
    `THE AND FOR IN TO ON AT BY OR AS IS IT USE USES USED WHEN WITH FROM NOT ALL ANY ITS THAN THAT THIS WILL ARE WAS HAS HAVE BUT OFF OUT OVER INTO ALSO ONLY BEEN SUCH JUST EACH BOTH FEW MORE MOST OTHER SOME TIME VERY CAN WAY WHO HOW HER OUR BE DO IF NO SO UP WE ME GO SET NEW MAN THEN THEM THESE HIS VIA MAY NOW ONE TWO GET GOT LET PUT SAY SEE TRY OWN TOO ANY DAY DID NOR YET NON`.split(
        /\s+/
    )
);

const MODULES = new Set([
    'FOCUS',
    'PRESENCE',
    'VISTA',
    'INSIGHT',
    'ESSENCE',
    'CACHE',
    'AXIS',
    'CORE',
    'SLASH',
    'KEYBIND',
    'UI',
    'LOCALE',
    'DASH',
]);

/** Max tokens kept after stop-word filter (prefix keeps COLOR_FOR_* etc. distinct). */
const OPTIONS_BODY_MAX = 6;
const OPTIONS_NESTED_TAIL_MAX = 4;
const DASH_REST_MAX = 5;
const SURFACE_REST_MAX = 5;

function filterTokens(parts) {
    return parts.filter((p) => p && !STOP.has(p) && !/^\d+$/.test(p));
}

function shortenTokens(parts, maxTokens) {
    const filtered = filterTokens(parts);
    if (filtered.length === 0) return '';
    if (filtered.length <= maxTokens) return filtered.join('_');
    return filtered.slice(0, maxTokens).join('_');
}

function inferModule(sectionLine) {
    const s = sectionLine.replace(/^--\s*/, '');
    if (/OptionsData\.lua\s*Category names/i.test(s)) return 'AXIS';
    if (/OptionsData\.lua\s*Profiles/i.test(s)) return 'AXIS';
    if (/OptionsData\.lua\s*Modules/i.test(s)) return 'AXIS';
    if (/OptionsData\.lua\s*Module Toggles/i.test(s)) return 'AXIS';
    if (/OptionsData\.lua.*\bPresence\b/i.test(s)) return 'PRESENCE';
    if (/OptionsData\.lua.*\bVista\b/i.test(s)) return 'VISTA';
    if (/OptionsData\.lua/i.test(s)) return 'FOCUS';
    if (/OptionsPanel|OptionsWidgets|SettingsBridge/i.test(s)) return 'FOCUS';
    if (/modules\/Focus/i.test(s)) return 'FOCUS';
    if (/modules\/Presence/i.test(s)) return 'PRESENCE';
    if (/modules\/Vista|Minimap/i.test(s)) return 'VISTA';
    if (/modules\/Insight/i.test(s)) return 'INSIGHT';
    if (/modules\/Essence/i.test(s)) return 'ESSENCE';
    if (/Slash|Keybind/i.test(s)) return 'SLASH';
    if (/Utilities/i.test(s)) return 'UI';
    if (/Locale|localisation/i.test(s)) return 'LOCALE';
    return 'CORE';
}

function buildOptionsKey(mod, bodyParts) {
    if (bodyParts.length === 0) return `OPTIONS_${mod}_FIELD`;

    if (bodyParts.length === 1 && bodyParts[0] === mod) {
        return `OPTIONS_${mod}_GROUP`;
    }
    if (bodyParts.length === 1 && bodyParts[0] === 'AXIS' && mod === 'AXIS') {
        return `OPTIONS_AXIS_NAV`;
    }

    if (MODULES.has(bodyParts[0]) && bodyParts[0] !== 'KO' && bodyParts.length >= 2) {
        const m = bodyParts[0];
        const tailStr = shortenTokens(bodyParts.slice(1), OPTIONS_NESTED_TAIL_MAX);
        return tailStr ? `OPTIONS_${m}_${tailStr}` : `OPTIONS_${m}_FIELD`;
    }

    const tailStr = shortenTokens(bodyParts, OPTIONS_BODY_MAX);
    if (!tailStr) {
        return `OPTIONS_${mod}_${bodyParts[bodyParts.length - 1]}`;
    }
    return `OPTIONS_${mod}_${tailStr}`;
}

function buildDashKey(parts) {
    const rest = parts.slice(1);
    const trimmed = rest.filter((p, i) => !(i === 0 && p === 'DASHBOARD'));
    if (trimmed.length <= DASH_REST_MAX) {
        return `DASH_${trimmed.join('_')}`;
    }
    return `DASH_${shortenTokens(trimmed, DASH_REST_MAX)}`;
}

function buildSurfaceKey(surface, parts) {
    const rest = parts.slice(1);
    if (rest.length <= SURFACE_REST_MAX) {
        return `${surface}_${rest.join('_')}`;
    }
    return `${surface}_${shortenTokens(rest, SURFACE_REST_MAX)}`;
}

/** When two long keys compress to the same stem, prefer OPTIONS_<mod>_SHOW_<hook> if the source was OPTIONS_SHOW_* */
function disambiguateOptionsCollision(oldKey, baseNk, sectionLine) {
    const parts = oldKey.split('_');
    if (parts[0] !== 'OPTIONS') return null;
    const body = parts.slice(1);
    if (body[0] === 'SHOW' && body.length >= 2) {
        const mod = inferModule(sectionLine);
        const hook = shortenTokens(body.slice(1), OPTIONS_BODY_MAX);
        return hook ? `OPTIONS_${mod}_SHOW_${hook}` : null;
    }
    return null;
}

function computeNewKey(oldKey, sectionLine) {
    const parts = oldKey.split('_');
    const surface = parts[0];

    if (surface === 'DASH') {
        const nk = buildDashKey(parts);
        if (nk === oldKey && parts.length > DASH_REST_MAX + 1) {
            const rest = parts.slice(1);
            return `DASH_${shortenTokens(rest, DASH_REST_MAX)}`;
        }
        return nk;
    }

    if (surface === 'OPTIONS') {
        const mod = inferModule(sectionLine);
        const body = parts.slice(1);
        return buildOptionsKey(mod, body);
    }

    if (['PRESENCE', 'FOCUS', 'SLASH', 'KEYBIND', 'UI', 'LOCALE', 'VISTA', 'INSIGHT', 'ESSENCE'].includes(surface)) {
        return buildSurfaceKey(surface, parts);
    }

    return oldKey;
}

function parseEnUSWithSections(filePath) {
    const lines = fs.readFileSync(filePath, 'utf8').split(/\r?\n/);
    const rows = [];
    let sectionLine = '-- (start)';
    let i = 0;
    while (i < lines.length) {
        const line = lines[i];
        if (/^-- =+$/.test(line)) {
            i++;
            if (i < lines.length && /^-- /.test(lines[i])) {
                sectionLine = lines[i];
            }
            i++;
            continue;
        }
        const m = line.match(/^L\["([^"]+)"\]\s*=/);
        if (m) {
            rows.push({ oldKey: m[1], sectionLine });
            i++;
            continue;
        }
        i++;
    }
    return rows;
}

function main() {
    const rows = parseEnUSWithSections(enUSPath);
    const sectionByOld = new Map();
    for (const { oldKey, sectionLine } of rows) {
        sectionByOld.set(oldKey, sectionLine);
    }

    const proposed = [];

    for (const { oldKey, sectionLine } of rows) {
        const nk = computeNewKey(oldKey, sectionLine);
        proposed.push({ oldKey, nk });
    }

    const newKeyCounts = new Map();
    for (const { nk } of proposed) {
        newKeyCounts.set(nk, (newKeyCounts.get(nk) || 0) + 1);
    }

    const rename = {};
    const perNew = new Map();
    for (const { oldKey, nk } of proposed) {
        if (nk === oldKey) continue;
        if (!perNew.has(nk)) perNew.set(nk, []);
        perNew.get(nk).push(oldKey);
    }

    for (const { oldKey, nk } of proposed) {
        if (nk === oldKey) continue;
        const list = perNew.get(nk) || [];
        if (list.length === 1) {
            rename[oldKey] = nk;
            continue;
        }
        list.sort();
        const idx = list.indexOf(oldKey);
        if (idx === 0) {
            rename[oldKey] = nk;
        } else {
            const dis = disambiguateOptionsCollision(oldKey, nk, sectionByOld.get(oldKey));
            rename[oldKey] = dis || `${nk}_${idx + 1}`;
        }
    }

    const seen = new Set();
    const finalRename = {};
    const sortedOld = Object.keys(rename).sort((a, b) => b.length - a.length);
    for (const oldKey of sortedOld) {
        const base = rename[oldKey];
        let nk = base;
        let bump = 2;
        while (seen.has(nk)) {
            nk = `${base}_${bump++}`;
        }
        seen.add(nk);
        finalRename[oldKey] = nk;
    }

    fs.writeFileSync(outPath, JSON.stringify(finalRename, null, 2) + '\n', 'utf8');
    console.log('Wrote', outPath, 'renames:', Object.keys(finalRename).length);
    const unchanged = rows.length - Object.keys(finalRename).length;
    console.log('Unchanged:', unchanged);

    const longSamples = Object.entries(finalRename)
        .filter(([a, b]) => b.length > 45)
        .slice(0, 8);
    console.log('Still long (>45 chars):', longSamples.length ? longSamples : 'none');
    console.log(
        'Sample:',
        Object.entries(finalRename).slice(0, 12)
    );
}

main();
