#!/usr/bin/env node
/**
 * Restructure locale files for Horizon Suite.
 *
 * Parses LocaleBase.lua to extract all keys + section structure,
 * then for each locale file: outputs all keys in order, with
 * untranslated keys commented out and marked "NEEDS TRANSLATION".
 *
 * Also generates locale_template.lua for new translators.
 *
 * Usage: node tools/restructure_locales.js
 * Run from the HorizonSuite root directory.
 */

const fs = require('fs');
const path = require('path');

const ROOT = path.resolve(__dirname, '..');
const OPTIONS = path.join(ROOT, 'locales');

// ── Parse LocaleBase.lua ──────────────────────────────────────────────

function parseLocaleBase() {
    const src = fs.readFileSync(path.join(OPTIONS, 'LocaleBase.lua'), 'utf8');
    const lines = src.split(/\r?\n/);

    // We extract two things: the ordered list of entries (sections + keys),
    // and a set of all keys.
    const entries = [];  // { type: 'section'|'key'|'blank', ... }
    const allKeys = new Set();

    for (const line of lines) {
        // Section comment block
        const sectionMatch = line.match(/^-- =+$/);
        if (sectionMatch) {
            entries.push({ type: 'separator', raw: line });
            continue;
        }

        const sectionHeader = line.match(/^-- (.+)$/);
        if (sectionHeader && !line.startsWith('-- L[')) {
            entries.push({ type: 'comment', raw: line });
            continue;
        }

        // Key-value line: L["key"] = "value"
        // Match the key and the full right-hand side
        const kvMatch = line.match(/^L\["(.+?)"\]\s*=\s*(.+)$/);
        if (kvMatch) {
            const key = kvMatch[1];
            const value = kvMatch[2].replace(/\s*$/, '');
            allKeys.add(key);
            entries.push({ type: 'key', key, value, raw: line });
            continue;
        }

        // Blank line
        if (line.trim() === '') {
            entries.push({ type: 'blank' });
            continue;
        }

        // Other lines (header comment block, addon reference, etc) - skip for structure
    }

    // Strip leading blank entries
    while (entries.length > 0 && entries[0].type === 'blank') {
        entries.shift();
    }

    return { entries, allKeys };
}

// ── Parse a locale file to extract its translated keys ────────────────

function parseLocaleFile(filePath) {
    const src = fs.readFileSync(filePath, 'utf8');
    const lines = src.split(/\r?\n/);
    const translated = {};

    // Also capture the StandardFont line if present
    let standardFont = null;

    for (const line of lines) {
        // Active key-value: L["key"] = "translated value"
        const kvMatch = line.match(/^L\["(.+?)"\]\s*=\s*(.+)$/);
        if (kvMatch) {
            translated[kvMatch[1]] = kvMatch[2].replace(/\s*$/, '');
            continue;
        }

        const fontMatch = line.match(/^addon\.StandardFont\s*=\s*(.+)$/);
        if (fontMatch) {
            standardFont = fontMatch[1].trim();
        }
    }

    return { translated, standardFont };
}

// ── Generate restructured locale file ─────────────────────────────────

function generateLocaleFile(localeCode, entries, translated, standardFont) {
    const lines = [];

    lines.push(`if GetLocale() ~= "${localeCode}" then return end`);
    lines.push('');
    lines.push('local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite');
    lines.push('if not addon then return end');
    lines.push('');
    lines.push('local L = setmetatable({}, { __index = addon.L })');
    lines.push('addon.L = L');
    lines.push(`addon.StandardFont = ${standardFont || 'UNIT_NAME_FONT'}`);
    lines.push('');

    for (const entry of entries) {
        if (entry.type === 'separator' || entry.type === 'comment') {
            lines.push(entry.raw);
            continue;
        }
        if (entry.type === 'blank') {
            lines.push('');
            continue;
        }
        if (entry.type === 'key') {
            const key = entry.key;
            if (translated[key] !== undefined) {
                // Translated — output active line
                // Pad key to align = signs (matching LocaleBase style)
                const padded = `L["${key}"]`.padEnd(72);
                lines.push(`${padded}= ${translated[key]}`);
            } else {
                // Untranslated — comment out with NEEDS TRANSLATION marker
                const padded = `L["${key}"]`.padEnd(72);
                lines.push(`-- ${padded}= ${entry.value}  -- NEEDS TRANSLATION`);
            }
        }
    }

    // Ensure file ends with newline
    return lines.join('\n') + '\n';
}

// ── Generate template file ────────────────────────────────────────────

function generateTemplate(entries) {
    const lines = [];

    lines.push('--[[');
    lines.push('    Horizon Suite — Translation Template');
    lines.push('');
    lines.push('    HOW TO TRANSLATE:');
    lines.push('    1. Copy this file and rename it to your locale code (e.g., itIT.lua)');
    lines.push('    2. Replace "LOCALE_CODE" on line 17 with your locale code');
    lines.push('       Valid codes: deDE, frFR, esES, esMX, ptBR, ruRU, koKR, zhCN, zhTW, itIT');
    lines.push('    3. Translate each value (the text on the RIGHT side of the = sign)');
    lines.push('       DO NOT change the keys (the text inside L["..."] on the left side)');
    lines.push('    4. Comment out or delete any lines you cannot translate —');
    lines.push('       English will show automatically for missing translations.');
    lines.push('    5. Submit the completed file to the Horizon Suite Discord for review.');
    lines.push('');
    lines.push('    This file is NOT loaded by the addon. It is a reference for translators.');
    lines.push(']]');
    lines.push('');
    lines.push('if GetLocale() ~= "LOCALE_CODE" then return end');
    lines.push('');
    lines.push('local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite');
    lines.push('if not addon then return end');
    lines.push('');
    lines.push('local L = setmetatable({}, { __index = addon.L })');
    lines.push('addon.L = L');
    lines.push('addon.StandardFont = UNIT_NAME_FONT  -- Change only if your locale needs a different font');
    lines.push('');

    for (const entry of entries) {
        if (entry.type === 'separator' || entry.type === 'comment') {
            lines.push(entry.raw);
            continue;
        }
        if (entry.type === 'blank') {
            lines.push('');
            continue;
        }
        if (entry.type === 'key') {
            const padded = `L["${entry.key}"]`.padEnd(72);
            lines.push(`${padded}= ${entry.value}`);
        }
    }

    return lines.join('\n') + '\n';
}

// ── Main ──────────────────────────────────────────────────────────────

const LOCALES = ['deDE', 'frFR', 'koKR', 'ptBR', 'ruRU', 'esES', 'zhCN'];

console.log('Parsing LocaleBase.lua...');
const { entries, allKeys } = parseLocaleBase();
console.log(`  Found ${allKeys.size} keys`);

for (const locale of LOCALES) {
    const filePath = path.join(OPTIONS, `${locale}.lua`);
    if (!fs.existsSync(filePath)) {
        console.log(`  Skipping ${locale} (file not found)`);
        continue;
    }

    console.log(`Processing ${locale}...`);
    const { translated, standardFont } = parseLocaleFile(filePath);
    const translatedCount = Object.keys(translated).length;
    console.log(`  ${translatedCount}/${allKeys.size} keys translated (${Math.round(translatedCount / allKeys.size * 100)}%)`);

    const output = generateLocaleFile(locale, entries, translated, standardFont);
    fs.writeFileSync(filePath, output, 'utf8');
    console.log(`  Written: ${filePath}`);
}

// Generate template
console.log('Generating locale_template.lua...');
const template = generateTemplate(entries);
fs.writeFileSync(path.join(OPTIONS, 'locale_template.lua'), template, 'utf8');
console.log(`  Written: ${path.join(OPTIONS, 'locale_template.lua')}`);

console.log('Done!');
