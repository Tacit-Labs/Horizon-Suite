#!/usr/bin/env node
/**
 * Sync Localisation/{locale}.lua to match Localisation/enUS.lua key order and sections.
 * Normalizes enUS first (removes per-key `-- Context:` lines; drops blank lines between keys;
 * aligns `=` and values in a fixed column from max `L["KEY"]` width).
 * Untranslated keys become commented-out assignments (leading `--` only; runtime falls back to enUS).
 * Assignments whose string equals enUS are treated as untranslated (comment only) so
 * locales fall back via __index to enUS — no duplicate English to maintain.
 * Regenerates Localisation/locale_template.lua for new translators.
 *
 * Usage: node tools/restructure_locales.js
 */

const fs = require('fs');
const path = require('path');
const {
    parseEnUS,
    parseLocaleTranslations,
    rewriteEnUSNormalized,
    computeMaxLhsLen,
    formatLocaleAssignment,
} = require('./lib/parseLocalisationEnUS.js');
const { decodedStringFromLuaRhs } = require('./lib/localeHash.js');

const ROOT = path.resolve(__dirname, '..');
const LOC = path.join(ROOT, 'Localisation');
const enUSPath = path.join(LOC, 'enUS.lua');

const LOCALES = ['deDE', 'frFR', 'koKR', 'ptBR', 'ruRU', 'esES', 'zhCN'];

/** Normalize decoded locale text for comparison with enUS (legacy marker inside strings). */
function localeCompareString(s) {
    return s.replace(/\s*-- NEEDS TRANSLATION/g, '');
}

function readStandardFont(localePath) {
    if (!fs.existsSync(localePath)) return 'UNIT_NAME_FONT';
    const head = fs.readFileSync(localePath, 'utf8').split(/\r?\n/).slice(0, 15).join('\n');
    const m = head.match(/addon\.StandardFont\s*=\s*(\S+)/);
    return m ? m[1].trim() : 'UNIT_NAME_FONT';
}

function generateLocaleFile(localeCode, entries, translated, standardFont, maxLhsLen) {
    const lines = [];
    lines.push(`if GetLocale() ~= "${localeCode}" then return end`);
    lines.push('');
    lines.push('local addon = _G.HorizonSuite');
    lines.push('if not addon then return end');
    lines.push('');
    lines.push('local L = setmetatable({}, { __index = addon.L })');
    lines.push('addon.L = L');
    lines.push(`addon.StandardFont = ${standardFont}`);
    lines.push('');

    for (const e of entries) {
        if (e.type === 'raw') {
            continue;
        }
        if (e.type === 'separator' || e.type === 'comment') {
            lines.push(e.raw);
            continue;
        }
        if (e.type === 'blank') {
            lines.push('');
            continue;
        }
        if (e.type === 'key') {
            const rhs = translated[e.symKey];
            const enStr = decodedStringFromLuaRhs(e.valueRaw);
            if (rhs !== undefined) {
                const locStr = decodedStringFromLuaRhs(rhs);
                if (localeCompareString(locStr) === enStr) {
                    lines.push(
                        formatLocaleAssignment({
                            symKey: e.symKey,
                            rhsRaw: e.valueRaw,
                            commented: true,
                            maxLhsLen,
                        }),
                    );
                } else {
                    lines.push(
                        formatLocaleAssignment({
                            symKey: e.symKey,
                            rhsRaw: rhs,
                            commented: false,
                            maxLhsLen,
                        }),
                    );
                }
            } else {
                lines.push(
                    formatLocaleAssignment({
                        symKey: e.symKey,
                        rhsRaw: e.valueRaw,
                        commented: true,
                        maxLhsLen,
                    }),
                );
            }
        }
    }

    return lines.join('\n') + '\n';
}

function generateTemplate(entries, maxLhsLen) {
    const lines = [];
    lines.push('--[[');
    lines.push('    Horizon Suite — Translation template (not loaded by the addon).');
    lines.push('    Copy to Localisation/<yourLocale>.lua, set GetLocale() guard, translate values.');
    lines.push(']]');
    lines.push('');
    lines.push('if GetLocale() ~= "LOCALE_CODE" then return end');
    lines.push('');
    lines.push('local addon = _G.HorizonSuite');
    lines.push('if not addon then return end');
    lines.push('');
    lines.push('local L = setmetatable({}, { __index = addon.L })');
    lines.push('addon.L = L');
    lines.push('addon.StandardFont = UNIT_NAME_FONT');
    lines.push('');

    for (const e of entries) {
        if (e.type === 'raw') {
            continue;
        }
        if (e.type === 'separator' || e.type === 'comment') {
            lines.push(e.raw);
            continue;
        }
        if (e.type === 'blank') {
            lines.push('');
            continue;
        }
        if (e.type === 'key') {
            lines.push(
                formatLocaleAssignment({
                    symKey: e.symKey,
                    rhsRaw: e.valueRaw,
                    commented: false,
                    maxLhsLen,
                }),
            );
        }
    }

    return lines.join('\n') + '\n';
}

console.log('Normalizing Localisation/enUS.lua (section headers only; no per-key Context)...');
rewriteEnUSNormalized(enUSPath);
console.log('Parsing Localisation/enUS.lua...');
const { entries, keys } = parseEnUS(enUSPath);
const maxLhsLen = computeMaxLhsLen(entries);
console.log(`  Keys: ${keys.length}`);

for (const locale of LOCALES) {
    const filePath = path.join(LOC, `${locale}.lua`);
    const standardFont = readStandardFont(filePath);
    const translated = parseLocaleTranslations(filePath);
    const out = generateLocaleFile(locale, entries, translated, standardFont, maxLhsLen);
    fs.writeFileSync(filePath, out, 'utf8');
    console.log(`  Written ${filePath}`);
}

const templatePath = path.join(LOC, 'locale_template.lua');
fs.writeFileSync(templatePath, generateTemplate(entries, maxLhsLen), 'utf8');
console.log(`  Written ${templatePath}`);
console.log('Done.');
