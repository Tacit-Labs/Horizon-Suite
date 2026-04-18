#!/usr/bin/env node
/**
 * One-off: extract OPTIONS_CORE_* rename targets by value-matching against a
 * reference enUS.lua that has already done the routing.
 *
 * For each OPTIONS_CORE_X key in our enUS.lua, look up the same English value
 * in the reference file and use the reference's key as the rename target,
 * provided the target uses a taxonomy-valid prefix or is bare.
 *
 * Writes tools/locale-key-rename.json (overwrites). Keys not confidently
 * matched are left untouched (OPTIONS_CORE_* stays).
 *
 * Usage: node tools/match_reference_renames.js <reference-enus-path>
 */

const fs = require('fs');
const path = require('path');

const ROOT = path.resolve(__dirname, '..');
const ourPath = path.join(ROOT, 'Localisation', 'enUS.lua');
const outPath = path.join(ROOT, 'tools', 'locale-key-rename.json');
const reportPath = path.join(ROOT, 'tools', 'reference-match-report.json');
const refPath = process.argv[2];

if (!refPath) {
    console.error('Usage: node tools/match_reference_renames.js <reference-enus-path>');
    process.exit(1);
}

const VALID_PREFIXES = ['FOCUS_', 'PRESENCE_', 'VISTA_', 'INSIGHT_', 'ESSENCE_', 'CACHE_',
                        'AXIS_', 'DASH_', 'HOME_', 'NAME_', 'TRACKER_', 'UI_', 'RECIPES_'];

function parseKeys(filePath) {
    const out = new Map();
    const text = fs.readFileSync(filePath, 'utf8');
    const lines = text.split(/\r?\n/);
    for (const line of lines) {
        const m = line.match(/^(?:--\s*)?L\["([^"]+)"\]\s*=\s*(.+?)\s*$/);
        if (!m) continue;
        if (line.trimStart().startsWith('--')) continue;
        const key = m[1];
        const rhs = m[2];
        let value;
        const doubleQuoted = rhs.match(/^"((?:[^"\\]|\\.)*)"/);
        const longBracket = rhs.match(/^\[=\[([\s\S]*?)\]=\]/);
        if (doubleQuoted) {
            value = doubleQuoted[1].replace(/\\"/g, '"').replace(/\\\\/g, '\\');
        } else if (longBracket) {
            value = longBracket[1];
        } else {
            continue;
        }
        out.set(key, value);
    }
    return out;
}

function normaliseValue(v) {
    return v
        .replace(/\s+/g, ' ')
        .trim()
        .toLowerCase()
        .replace(/colou?r/g, 'colo')
        .replace(/colou?rs/g, 'colos')
        .replace(/organi[sz]e/g, 'organi')
        .replace(/organi[sz]ation/g, 'organition')
        .replace(/customi[sz]e/g, 'customi')
        .replace(/recogni[sz]e/g, 'recogni');
}

function looksTaxonomyValid(key) {
    if (key.startsWith('OPTIONS_')) return false;
    for (const p of VALID_PREFIXES) {
        if (key.startsWith(p)) return true;
    }
    // Bare key: allowed when the bare-key policy is relaxed — accept any
    // UPPER_SNAKE_CASE identifier.
    if (/^[A-Z][A-Z0-9_]*$/.test(key)) return true;
    return false;
}

const MODULE_PREFIXES = ['FOCUS_', 'PRESENCE_', 'VISTA_', 'INSIGHT_', 'ESSENCE_', 'CACHE_', 'AXIS_'];

function scoreCandidate(key) {
    // The user's "partial routing" directive: only the 7 real modules get
    // priority over bare. Other prefixes (HOME_, DASH_, UI_, TRACKER_, NAME_,
    // RECIPES_) can still be picked, but we prefer bare for short/generic
    // values when the only non-bare candidate is one of those.
    for (const p of MODULE_PREFIXES) {
        if (key.startsWith(p)) return 3;
    }
    // Bare keys come next.
    if (!key.includes('_') || /^[A-Z]+(_[A-Z0-9]+){0,3}$/.test(key)) return 2;
    // Everything else (HOME_, DASH_, UI_, TRACKER_, etc.) — valid but lower
    // priority than short bare keys for these ambiguous cases.
    return 1;
}

function main() {
    const ours = parseKeys(ourPath);
    const ref = parseKeys(refPath);
    console.log(`Our keys: ${ours.size}`);
    console.log(`Reference keys: ${ref.size}`);

    const refByValue = new Map();
    const refValueCollisions = new Set();
    for (const [k, v] of ref) {
        const nv = normaliseValue(v);
        if (!nv) continue;
        if (refByValue.has(nv)) {
            refValueCollisions.add(nv);
            refByValue.get(nv).push(k);
        } else {
            refByValue.set(nv, [k]);
        }
    }

    const rename = {};
    const unmatched = [];
    const invalidTargets = [];
    const collisions = [];

    for (const [ourKey, ourVal] of ours) {
        if (!ourKey.startsWith('OPTIONS_CORE_')) continue;
        const nv = normaliseValue(ourVal);
        const candidates = refByValue.get(nv);
        if (!candidates || candidates.length === 0) {
            unmatched.push({ ourKey, ourVal });
            continue;
        }
        const validCandidates = candidates.filter(looksTaxonomyValid);
        if (validCandidates.length === 0) {
            invalidTargets.push({ ourKey, ourVal, candidates });
            continue;
        }
        const sorted = [...validCandidates].sort((a, b) => scoreCandidate(b) - scoreCandidate(a));
        let target = null;
        for (const c of sorted) {
            if (c === ourKey) continue;
            if (ours.has(c)) continue;
            target = c;
            break;
        }
        if (!target) {
            collisions.push({ ourKey, ourVal, candidates: sorted, reason: 'all candidates collide with existing keys or self' });
            continue;
        }
        if (sorted.length > 1) {
            collisions.push({ ourKey, ourVal, candidates: sorted, chose: target });
        }
        rename[ourKey] = target;
    }

    const seen = new Map();
    for (const [old, nw] of Object.entries(rename)) {
        if (seen.has(nw)) {
            collisions.push({ ourKey: old, newKey: nw, reason: 'two old keys -> same new key; first: ' + seen.get(nw) });
            delete rename[old];
        } else {
            seen.set(nw, old);
        }
    }

    fs.writeFileSync(outPath, JSON.stringify(rename, null, 2) + '\n', 'utf8');
    fs.writeFileSync(reportPath, JSON.stringify({
        matched: Object.keys(rename).length,
        unmatched: unmatched.length,
        invalidTargets: invalidTargets.length,
        collisions: collisions.length,
        unmatchedSample: unmatched.slice(0, 20),
        invalidTargetsSample: invalidTargets.slice(0, 20),
        collisionsSample: collisions.slice(0, 20),
    }, null, 2) + '\n', 'utf8');

    console.log(`Matched: ${Object.keys(rename).length}`);
    console.log(`Unmatched: ${unmatched.length}`);
    console.log(`Invalid targets (bare-but-too-long etc.): ${invalidTargets.length}`);
    console.log(`Collisions: ${collisions.length}`);
    console.log(`Report: ${reportPath}`);
}

main();
