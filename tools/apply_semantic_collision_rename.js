#!/usr/bin/env node
/**
 * Apply tools/semantic_collision_rename.json (numeric _2 collision keys -> readable names).
 * Same replacement rules as apply_locale_key_rename.js; updates locale-key-mapping.json values.
 *
 * Usage: node tools/apply_semantic_collision_rename.js [--dry-run]
 */

const fs = require('fs');
const path = require('path');

const ROOT = path.resolve(__dirname, '..');
const semanticPath = path.join(ROOT, 'tools', 'semantic_collision_rename.json');
const mappingPath = path.join(ROOT, 'tools', 'locale-key-mapping.json');

const dryRun = process.argv.includes('--dry-run');

function escapeRe(s) {
    return s.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}

function replaceInContent(text, pairs) {
    let out = text;
    for (const { oldKey, newKey } of pairs) {
        if (oldKey === newKey) continue;
        const o = escapeRe(oldKey);
        const reL = new RegExp(`L\\["${o}"\\]`, 'g');
        out = out.replace(reL, `L["${newKey}"]`);
        const reAL = new RegExp(`addon\\.L\\["${o}"\\]`, 'g');
        out = out.replace(reAL, `addon.L["${newKey}"]`);
    }
    return out;
}

function walkLuaFiles(dir, out) {
    if (!fs.existsSync(dir)) return;
    for (const name of fs.readdirSync(dir)) {
        const p = path.join(dir, name);
        const st = fs.statSync(p);
        if (st.isDirectory()) walkLuaFiles(p, out);
        else if (name.endsWith('.lua')) out.push(p);
    }
}

function main() {
    if (!fs.existsSync(semanticPath)) {
        console.error('Missing', semanticPath);
        process.exit(1);
    }
    const rename = JSON.parse(fs.readFileSync(semanticPath, 'utf8'));
    const pairs = Object.entries(rename)
        .map(([oldKey, newKey]) => ({ oldKey, newKey }))
        .sort((a, b) => b.oldKey.length - a.oldKey.length);

    const roots = [
        path.join(ROOT, 'modules'),
        path.join(ROOT, 'options'),
        path.join(ROOT, 'core'),
        path.join(ROOT, 'Localisation'),
    ];
    const files = [];
    for (const d of roots) walkLuaFiles(d, files);
    const utilPath = path.join(ROOT, 'Utilities.lua');
    if (fs.existsSync(utilPath)) files.push(utilPath);

    let touched = 0;
    for (const filePath of files) {
        const t = fs.readFileSync(filePath, 'utf8');
        const n = replaceInContent(t, pairs);
        if (n !== t) {
            touched++;
            if (!dryRun) fs.writeFileSync(filePath, n, 'utf8');
        }
    }

    if (fs.existsSync(mappingPath)) {
        const mapping = JSON.parse(fs.readFileSync(mappingPath, 'utf8'));
        let mapChanged = 0;
        for (const phrase of Object.keys(mapping)) {
            const v = mapping[phrase];
            if (rename[v]) {
                mapping[phrase] = rename[v];
                mapChanged++;
            }
        }
        if (mapChanged && !dryRun) {
            fs.writeFileSync(mappingPath, JSON.stringify(mapping, null, 2) + '\n', 'utf8');
        }
        console.log(dryRun ? `[dry-run] Would update ${mapChanged} locale-key-mapping entries` : `Updated ${mapChanged} locale-key-mapping entries`);
    }

    console.log(dryRun ? `[dry-run] Would touch ${touched} Lua files` : `Updated ${touched} Lua files`);
}

main();
