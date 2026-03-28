#!/usr/bin/env node
/**
 * Mark translation metadata as validated (tools/locale-meta/<locale>.json).
 *
 * Usage:
 *   node tools/locale_validate.js deDE OPTIONS_FOCUS
 *   node tools/locale_validate.js deDE --all-unvalidated
 *
 * Uses GIT_AUTHOR_NAME, USER, or USERNAME for reviewer when not passed.
 */

const fs = require('fs');
const path = require('path');
const { parseEnUS, parseLocaleTranslations } = require('./lib/parseLocalisationEnUS.js');
const { hashFromLuaRhs } = require('./lib/localeHash.js');

const ROOT = path.resolve(__dirname, '..');
const LOC = path.join(ROOT, 'Localisation');
const META = path.join(ROOT, 'tools', 'locale-meta');

const locale = process.argv[2];
const keyArg = process.argv[3];

if (!locale || !keyArg) {
    console.error('Usage: node tools/locale_validate.js <locale> <SYMBOLIC_KEY|--all-unvalidated>');
    process.exit(1);
}

const enUSPath = path.join(LOC, 'enUS.lua');
const { entries } = parseEnUS(enUSPath);
const enByKey = {};
for (const e of entries) {
    if (e.type === 'key') enByKey[e.symKey] = e.valueRaw;
}

const metaPath = path.join(META, `${locale}.json`);
fs.mkdirSync(META, { recursive: true });
let meta = {};
if (fs.existsSync(metaPath)) {
    try {
        meta = JSON.parse(fs.readFileSync(metaPath, 'utf8'));
    } catch {
        meta = {};
    }
}

const reviewer =
    process.env.GIT_AUTHOR_NAME || process.env.USER || process.env.USERNAME || 'reviewer';
const date = new Date().toISOString().slice(0, 10);

function validateKey(symKey) {
    const enRhs = enByKey[symKey];
    if (!enRhs) {
        console.error('Unknown key:', symKey);
        return false;
    }
    const h = hashFromLuaRhs(enRhs);
    const prev = meta[symKey] || {};
    meta[symKey] = {
        ...prev,
        status: 'validated',
        translator: reviewer,
        date,
        source_hash: h,
    };
    return true;
}

if (keyArg === '--all-unvalidated') {
    const translated = parseLocaleTranslations(path.join(LOC, `${locale}.lua`));
    let n = 0;
    for (const k of Object.keys(translated)) {
        if (!enByKey[k]) continue;
        const st = (meta[k] && meta[k].status) || 'unvalidated';
        if (st !== 'validated') {
            if (validateKey(k)) n++;
        }
    }
    console.log(`Validated ${n} keys for ${locale}`);
} else {
    if (!validateKey(keyArg)) process.exit(1);
    console.log(`Validated ${keyArg} for ${locale}`);
}

fs.writeFileSync(metaPath, JSON.stringify(meta, null, 2) + '\n', 'utf8');
