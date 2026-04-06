#!/usr/bin/env node
/**
 * Locale coverage vs Localisation/enUS.lua.
 *
 * "Translated" = active L["key"] assignment whose string differs from enUS (real locale text).
 * Fallback via __index (commented stub or identical copy) counts as not translated.
 *
 * Usage:
 *   node tools/locale_audit.js
 *   node tools/locale_audit.js --missing
 *   node tools/locale_audit.js --strict   (exit 1 if any locale file out of sync with enUS)
 */

const fs = require('fs');
const path = require('path');
const { parseEnUS, parseLocaleTranslations } = require('./lib/parseLocalisationEnUS.js');
const { hashFromLuaRhs, decodedStringFromLuaRhs } = require('./lib/localeHash.js');

const ROOT = path.resolve(__dirname, '..');
const LOC = path.join(ROOT, 'Localisation');
const META = path.join(ROOT, 'tools', 'locale-meta');

const LOCALES = ['deDE', 'frFR', 'koKR', 'ptBR', 'ruRU', 'esES', 'zhCN'];

const showMissing = process.argv.includes('--missing');
const strict = process.argv.includes('--strict');

function loadMeta(locale) {
    const p = path.join(META, `${locale}.json`);
    if (!fs.existsSync(p)) return {};
    try {
        return JSON.parse(fs.readFileSync(p, 'utf8'));
    } catch {
        return {};
    }
}

/** Each enUS key must appear as an active or commented L["key"] = row (restructure output). */
function keyRowInLocale(text, symKey) {
    const escaped = symKey.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
    const re = new RegExp(`^\\s*(?:--\\s*)?L\\["${escaped}"\\]\\s*=`, 'gm');
    return re.test(text);
}

function isReallyTranslated(k, translated, enRhs) {
    const rhs = translated[k];
    if (rhs === undefined) return false;
    if (!enRhs) return true;
    return decodedStringFromLuaRhs(rhs) !== decodedStringFromLuaRhs(enRhs);
}

const enUSPath = path.join(LOC, 'enUS.lua');
const { entries, keys } = parseEnUS(enUSPath);
const enByKey = {};
for (const e of entries) {
    if (e.type === 'key') {
        enByKey[e.symKey] = e.valueRaw;
    }
}

console.log('\nHorizon Suite — Locale audit (Localisation/)');
console.log(`${'='.repeat(55)}`);
console.log(`enUS keys: ${keys.length}\n`);

const rows = [];
let strictFail = false;

for (const locale of LOCALES) {
    const filePath = path.join(LOC, `${locale}.lua`);
    const fileContent = fs.readFileSync(filePath, 'utf8');
    const translated = parseLocaleTranslations(filePath);
    const meta = loadMeta(locale);
    const translatedCount = keys.filter((k) => isReallyTranslated(k, translated, enByKey[k])).length;
    const missingCount = keys.length - translatedCount;
    const pct = keys.length ? Math.round((translatedCount / keys.length) * 100) : 0;
    const missingKeys = keys.filter((k) => !isReallyTranslated(k, translated, enByKey[k]));
    const structuralMissing = keys.filter((k) => !keyRowInLocale(fileContent, k));

    let v = 0,
        u = 0,
        r = 0;
    for (const k of keys) {
        const m = meta[k];
        if (!m || !m.status) continue;
        if (m.status === 'validated') v++;
        else if (m.status === 'unvalidated') u++;
        else if (m.status === 'needs_review') r++;
    }

    const hashMismatch = [];
    for (const k of keys) {
        if (!isReallyTranslated(k, translated, enByKey[k])) continue;
        const m = meta[k];
        if (!m || m.status !== 'validated') continue;
        const enRhs = enByKey[k];
        if (!enRhs) continue;
        const cur = hashFromLuaRhs(enRhs);
        if (m.source_hash && m.source_hash !== cur) {
            hashMismatch.push(k);
        }
    }

    rows.push({
        locale,
        translatedCount,
        missing: missingCount,
        pct,
        missingKeys,
        structuralMissing,
        v,
        u,
        r,
        hashMismatch,
    });
    if (structuralMissing.length) strictFail = true;
}

console.log(
    `${'Locale'.padEnd(10)} ${'Translated'.padEnd(12)} ${'enUS fallbk'.padEnd(12)} ${'Coverage'.padEnd(10)} meta: val/unval/review`
);
console.log(`${'─'.repeat(10)} ${'─'.repeat(12)} ${'─'.repeat(10)} ${'─'.repeat(10)} ${'─'.repeat(28)}`);

for (const row of rows) {
    console.log(
        `${row.locale.padEnd(10)} ${String(row.translatedCount).padEnd(12)} ${String(row.missing).padEnd(12)} ${String(row.pct + '%').padEnd(10)} ${row.v}/${row.u}/${row.r}${row.hashMismatch.length ? ' !hash:' + row.hashMismatch.length : ''}`
    );
}

if (showMissing) {
    console.log('');
    for (const row of rows) {
        if (row.missingKeys.length === 0) continue;
        console.log(`\n── ${row.locale} — ${row.missingKeys.length} not translated (enUS fallback) ──`);
        for (const k of row.missingKeys) {
            const rhs = enByKey[k] || '""';
            const en = decodedStringFromLuaRhs(rhs);
            console.log(`  ${k}`);
            console.log(`    en: ${en.substring(0, 120)}${en.length > 120 ? '...' : ''}`);
        }
    }
}

console.log('');
if (strict && strictFail) {
    console.error('strict: one or more locales are out of sync (missing L["key"] row per enUS) (exit 1)');
    for (const row of rows) {
        if (row.structuralMissing.length === 0) continue;
        console.error(`  ${row.locale}: ${row.structuralMissing.length} structural gaps (e.g. run node tools/restructure_locales.js)`);
    }
    process.exit(1);
}
