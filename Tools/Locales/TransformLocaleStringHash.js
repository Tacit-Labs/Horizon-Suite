/**
 * djb2 hash of English string for translation invalidation (6 hex chars).
 * @param {string} s
 */
function sourceHash(s) {
    let h = 5381;
    for (let i = 0; i < s.length; i++) {
        h = (h * 33 + s.charCodeAt(i)) | 0;
    }
    const u = h >>> 0;
    return u.toString(16).padStart(6, '0').slice(0, 6);
}

/** Decode Lua string RHS to JS string (normalises "..." and [=[...]=]). */
function decodedStringFromLuaRhs(valueRaw) {
    const t = valueRaw.trim();
    if (t.startsWith('"')) {
        try {
            return JSON.parse(t);
        } catch {
            return t.replace(/^"|"$/g, '').replace(/\\n/g, '\n');
        }
    }
    if (t.startsWith('[')) {
        const openM = t.match(/^\[=*\[/);
        if (!openM) return t;
        const eq = openM[0].length - 2;
        const close = ']' + '='.repeat(eq) + ']';
        if (t.length < openM[0].length + close.length) return t;
        return t.slice(openM[0].length, t.length - close.length);
    }
    return t;
}

/** @param {string} valueRaw Lua RHS e.g. "hello" or [=[x]=] */
function hashFromLuaRhs(valueRaw) {
    return sourceHash(decodedStringFromLuaRhs(valueRaw));
}

module.exports = { sourceHash, hashFromLuaRhs, decodedStringFromLuaRhs };
