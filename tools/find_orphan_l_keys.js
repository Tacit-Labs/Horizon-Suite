const fs = require('fs');
const path = require('path');

const ROOT = path.resolve(__dirname, '..');
const mapping = JSON.parse(fs.readFileSync(path.join(ROOT, 'tools', 'locale-key-mapping.json'), 'utf8'));
const validKeys = new Set(Object.values(mapping));

const enUS = fs.readFileSync(path.join(ROOT, 'Localisation', 'enUS.lua'), 'utf8');
let m;
const reEn = /^L\["([^"]+)"\]\s*=/gm;
while ((m = reEn.exec(enUS))) {
    validKeys.add(m[1]);
}

function walk(dir, out) {
    for (const name of fs.readdirSync(dir)) {
        const p = path.join(dir, name);
        if (fs.statSync(p).isDirectory()) walk(p, out);
        else if (name.endsWith('.lua')) out.push(p);
    }
}

const dirs = ['modules', 'options', 'core'].map((d) => path.join(ROOT, d));
const files = [path.join(ROOT, 'Utilities.lua')];
for (const d of dirs) walk(d, files);

const re = /(?:^|[^.\w])L\["([^"]+)"\]/g;
const reAddon = /addon\.L\["([^"]+)"\]/g;
const used = new Set();
const orphans = new Set();

for (const f of files) {
    if (f.includes(`${path.sep}locales${path.sep}`) || f.includes(`${path.sep}Localisation${path.sep}`)) continue;
    const t = fs.readFileSync(f, 'utf8');
    while ((m = re.exec(t))) used.add(m[1]);
    while ((m = reAddon.exec(t))) used.add(m[1]);
}

for (const k of used) {
    if (!validKeys.has(k)) orphans.add(k);
}

console.log([...orphans].sort().join('\n'));
console.error('orphan count', orphans.size);
