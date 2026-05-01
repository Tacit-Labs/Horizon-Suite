/**
 * Parse localisation/horizon/enUS.lua into ordered entries (sections, comments, keys).
 * Per-key `-- Context:` lines are ignored (section headers carry the same info).
 * Blanks between consecutive keys are dropped when parsing / rewriting.
 */

/**
 * @param {string[]} lines Body lines starting at the first `-- ===` section rule.
 * @param {string[]} keys Mutated: symbolic keys in file order.
 * @returns {object[]}
 */
function parseBodyLines(lines, keys) {
    const entries = [];
    let i = 0;

    while (i < lines.length) {
        const line = lines[i];

        // Must run before separator handling: Context after closing `====` would otherwise become a `comment` entry.
        if (line.startsWith('-- Context:')) {
            i++;
            continue;
        }

        if (/^-- =+$/.test(line)) {
            entries.push({ type: 'separator', raw: line });
            i++;
            while (i < lines.length && lines[i].startsWith('-- Context:')) {
                i++;
            }
            if (i < lines.length && /^-- /.test(lines[i]) && !/^L\[/.test(lines[i])) {
                entries.push({ type: 'comment', raw: lines[i] });
                i++;
            }
            continue;
        }

        const kvMatch = line.match(/^L\["([^"]+)"\]\s*=\s*(.*)$/);
        if (kvMatch) {
            const symKey = kvMatch[1];
            let rest = kvMatch[2];
            let valueRaw = rest;

            if (rest.startsWith('"') && !/^"([^"\\]|\\.)*"\s*$/.test(rest)) {
                let acc = rest;
                i++;
                while (i < lines.length) {
                    acc += '\n' + lines[i];
                    if (/^"([^"\\]|\\.)*"\s*$/.test(acc.replace(/^.*=\s*/, ''))) {
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

            keys.push(symKey);
            entries.push({
                type: 'key',
                symKey,
                valueRaw,
            });
            i++;
            continue;
        }

        if (line.trim() === '') {
            entries.push({ type: 'blank' });
            i++;
            continue;
        }

        if (
            line.startsWith('--[[') ||
            line.startsWith('local addon') ||
            line.startsWith('if not addon') ||
            line.startsWith('local L = addon.L')
        ) {
            entries.push({ type: 'raw', raw: line });
            i++;
            continue;
        }

        if (line.startsWith('--')) {
            entries.push({ type: 'comment', raw: line });
            i++;
            continue;
        }

        i++;
    }

    return entries;
}

/**
 * Drop blank entries that sit directly between two keys (section headers stay spaced).
 * @param {object[]} entries
 * @returns {object[]}
 */
function compactLocaleEntries(entries) {
    const out = [];
    for (let i = 0; i < entries.length; i++) {
        const e = entries[i];
        if (e.type === 'blank') {
            const prev = out[out.length - 1];
            let j = i + 1;
            while (j < entries.length && entries[j].type === 'blank') j++;
            const next = entries[j];
            if (prev && prev.type === 'key' && next && next.type === 'key') {
                continue;
            }
        }
        out.push(e);
    }
    return out;
}

/** Spaces between `L["KEY"]` and `=`; also ensures stub lines (`-- `) align `=` with active lines (padStub >= 0). */
const LOCALE_LHS_PAD_MIN = 3;

function localeLhs(symKey) {
    return `L["${symKey}"]`;
}

/**
 * Max length of `L["symKey"]` over all key entries (for column alignment).
 * @param {object[]} entries
 * @returns {number}
 */
function computeMaxLhsLen(entries) {
    let m = 0;
    for (const e of entries) {
        if (e.type === 'key') {
            const n = localeLhs(e.symKey).length;
            if (n > m) m = n;
        }
    }
    return m;
}

/**
 * One assignment line (or first line + multiline rhs) with aligned `=`.
 * @param {{ symKey: string, rhsRaw: string, commented: boolean, maxLhsLen: number }} opts
 * @returns {string}
 */
function formatLocaleAssignment(opts) {
    const { symKey, rhsRaw, commented, maxLhsLen } = opts;
    const lhs = localeLhs(symKey);
    const spActive = Math.max(LOCALE_LHS_PAD_MIN, maxLhsLen - lhs.length + 1);
    const padStub = Math.max(0, spActive - 3);
    const rhsLines = rhsRaw.split('\n');
    const firstRhs = rhsLines[0];
    const restRhs = rhsLines.slice(1);
    let firstLine;
    if (commented) {
        firstLine = `-- ${lhs}${' '.repeat(padStub)}= ${firstRhs}`;
    } else {
        firstLine = `${lhs}${' '.repeat(spActive)}= ${firstRhs}`;
    }
    if (restRhs.length === 0) {
        return firstLine;
    }
    if (commented) {
        return firstLine + '\n' + restRhs.map((line) => `-- ${line}`).join('\n');
    }
    return firstLine + '\n' + restRhs.join('\n');
}

/**
 * Serialize body entries (no raw header lines) to Lua source.
 * @param {object[]} entries
 * @param {number} maxLhsLen from {@link computeMaxLhsLen} on the same entries
 * @returns {string}
 */
function serializeLocaleEntries(entries, maxLhsLen) {
    const lines = [];
    for (const e of entries) {
        if (e.type === 'separator' || e.type === 'comment' || e.type === 'raw') {
            lines.push(e.raw);
        } else if (e.type === 'blank') {
            lines.push('');
        } else if (e.type === 'key') {
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
    return lines.join('\n');
}

/**
 * Rewrite enUS.lua: strip `-- Context:`, compact blanks between keys; preserve header before first section.
 * @param {string} filePath
 */
function rewriteEnUSNormalized(filePath) {
    const fs = require('fs');
    const text = fs.readFileSync(filePath, 'utf8');
    const lines = text.split(/\r?\n/);
    const firstSection = lines.findIndex((l) => /^-- =+$/.test(l));
    if (firstSection === -1) {
        throw new Error('enUS.lua: no section delimiter (-- ===) found');
    }
    const headerLines = lines.slice(0, firstSection);
    const bodyLines = lines.slice(firstSection);
    const keys = [];
    let bodyEntries = parseBodyLines(bodyLines, keys);
    bodyEntries = compactLocaleEntries(bodyEntries);
    const maxLhsLen = computeMaxLhsLen(bodyEntries);
    const out = headerLines.join('\n') + '\n' + serializeLocaleEntries(bodyEntries, maxLhsLen) + '\n';
    fs.writeFileSync(filePath, out, 'utf8');
}

/**
 * @param {string} filePath
 * @returns {{ entries: object[], keys: string[] }}
 */
function parseEnUS(filePath) {
    const fs = require('fs');
    const lines = fs.readFileSync(filePath, 'utf8').split(/\r?\n/);
    const firstSection = lines.findIndex((l) => /^-- =+$/.test(l));
    if (firstSection === -1) {
        throw new Error('enUS.lua: no section delimiter (-- ===) found');
    }
    const headerLines = lines.slice(0, firstSection);
    const bodyLines = lines.slice(firstSection);
    const keys = [];
    let bodyEntries = parseBodyLines(bodyLines, keys);
    bodyEntries = compactLocaleEntries(bodyEntries);
    const headerEntries = headerLines.map((raw) => ({ type: 'raw', raw }));
    return { entries: [...headerEntries, ...bodyEntries], keys };
}

/**
 * @param {string} filePath
 * @returns {Record<string, string>} symKey -> rhs raw (e.g. "foo" including quotes)
 */
function parseLocaleTranslations(filePath) {
    const fs = require('fs');
    if (!fs.existsSync(filePath)) return {};
    const text = fs.readFileSync(filePath, 'utf8');
    const out = {};
    const marker = 'L["';
    let pos = 0;
    while (true) {
        const idx = text.indexOf(marker, pos);
        if (idx === -1) break;
        const keyStart = idx + marker.length;
        const keyEnd = text.indexOf('"]', keyStart);
        if (keyEnd === -1) break;
        const symKey = text.slice(keyStart, keyEnd);
        let after = keyEnd + 2;
        while (after < text.length && /\s/.test(text[after])) after++;
        if (text[after] !== '=') {
            pos = keyStart;
            continue;
        }
        after++;
        while (after < text.length && /\s/.test(text[after])) after++;
        if (text.slice(after, after + 2) === '--') {
            pos = after;
            continue;
        }
        try {
            const { raw, end } = parseValueAt(text, after);
            out[symKey] = raw;
            pos = end;
        } catch {
            pos = keyStart + 1;
        }
    }
    return out;
}

function parseValueAt(text, start) {
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
        throw new Error('unterminated');
    }
    if (text[start] === '[') {
        const sub = text.slice(start);
        const openM = sub.match(/^\[=*\[/);
        if (!openM) throw new Error('bad long');
        const open = openM[0];
        const eqCount = open.length - 2;
        const close = ']' + '='.repeat(eqCount) + ']';
        const closeIdx = text.indexOf(close, start + open.length);
        if (closeIdx === -1) throw new Error('unterminated long');
        return { raw: text.slice(start, closeIdx + close.length), end: closeIdx + close.length };
    }
    throw new Error('unknown');
}

module.exports = {
    parseEnUS,
    parseLocaleTranslations,
    rewriteEnUSNormalized,
    compactLocaleEntries,
    serializeLocaleEntries,
    computeMaxLhsLen,
    formatLocaleAssignment,
};
