#!/usr/bin/env node
/**
 * Locale coverage audit for Horizon Suite.
 *
 * Parses LocaleBase.lua and each locale file, reports translation
 * coverage per locale with optional --missing flag to list missing keys.
 *
 * Usage:
 *   node tools/locale_audit.js           # Summary table
 *   node tools/locale_audit.js --missing # Also list missing keys per locale
 *
 * Run from the HorizonSuite root directory.
 */

const fs = require('fs');
const path = require('path');

const ROOT = path.resolve(__dirname, '..');
const OPTIONS = path.join(ROOT, 'locales');
const showMissing = process.argv.includes('--missing');

const LOCALES = ['deDE', 'frFR', 'koKR', 'ptBR', 'ruRU', 'esES', 'zhCN'];

// ── Parse keys from a Lua file ────────────────────────────────────────

function parseKeys(filePath) {
    const src = fs.readFileSync(filePath, 'utf8');
    const keys = new Set();
    for (const line of src.split(/\r?\n/)) {
        const m = line.match(/^L\["(.+?)"\]\s*=/);
        if (m) keys.add(m[1]);
    }
    return keys;
}

// ── Main ──────────────────────────────────────────────────────────────

const baseKeys = parseKeys(path.join(OPTIONS, 'LocaleBase.lua'));
const total = baseKeys.size;

console.log(`\nHorizon Suite — Locale Coverage Audit`);
console.log(`${'='.repeat(50)}`);
console.log(`Base keys (LocaleBase.lua): ${total}\n`);

const rows = [];

for (const locale of LOCALES) {
    const filePath = path.join(OPTIONS, `${locale}.lua`);
    if (!fs.existsSync(filePath)) {
        rows.push({ locale, translated: 0, missing: total, pct: '0%' });
        continue;
    }

    const localeKeys = parseKeys(filePath);
    const translated = [...baseKeys].filter(k => localeKeys.has(k)).length;
    const missingKeys = [...baseKeys].filter(k => !localeKeys.has(k));
    const pct = Math.round(translated / total * 100);

    rows.push({ locale, translated, missing: missingKeys.length, pct: `${pct}%`, missingKeys });
}

// Print table
console.log(`${'Locale'.padEnd(8)} ${'Translated'.padEnd(12)} ${'Missing'.padEnd(10)} Coverage`);
console.log(`${'─'.repeat(8)} ${'─'.repeat(12)} ${'─'.repeat(10)} ${'─'.repeat(8)}`);

for (const row of rows) {
    console.log(
        `${row.locale.padEnd(8)} ${String(row.translated).padEnd(12)} ${String(row.missing).padEnd(10)} ${row.pct}`
    );
}

// Print missing keys if requested
if (showMissing) {
    console.log('');
    for (const row of rows) {
        if (row.missingKeys && row.missingKeys.length > 0) {
            console.log(`\n── ${row.locale} — ${row.missingKeys.length} missing keys ──`);
            for (const key of row.missingKeys) {
                console.log(`  ${key}`);
            }
        }
    }
}

console.log('');
