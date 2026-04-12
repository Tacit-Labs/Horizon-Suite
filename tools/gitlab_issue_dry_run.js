#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const { buildDryRunReport } = require('./lib/gitlabIssueMigration.js');

const ROOT = path.resolve(__dirname, '..');
const DEFAULT_PROJECT = 'Crystilac/horizon-suite';
const DEFAULT_OUTPUT = path.join(ROOT, 'tools', 'gitlab-issues-dry-run.json');
const DEFAULT_LABEL_CATALOG = path.join(ROOT, 'tools', 'gitlab-label-catalog.json');

function parseArgs(argv) {
    const args = {
        project: DEFAULT_PROJECT,
        output: DEFAULT_OUTPUT,
        input: null,
    };

    for (let i = 0; i < argv.length; i++) {
        const arg = argv[i];
        if (arg === '--project' && argv[i + 1]) {
            args.project = argv[++i];
        } else if (arg === '--output' && argv[i + 1]) {
            args.output = path.resolve(argv[++i]);
        } else if (arg === '--input' && argv[i + 1]) {
            args.input = path.resolve(argv[++i]);
        } else if (arg === '--help' || arg === '-h') {
            args.help = true;
        }
    }

    return args;
}

function printHelp() {
    console.log('Usage: node tools/gitlab_issue_dry_run.js [--project namespace/project] [--input issues.json] [--output report.json]');
    console.log('');
    console.log('Without --input, the script fetches GitLab issues from the public API (all states, paginated).');
    console.log('With --input, the script reads a saved GitLab issues JSON file instead.');
    console.log('');
    console.log(`Also writes ${path.relative(ROOT, DEFAULT_LABEL_CATALOG)} based on the union of labels attached to those issues.`);
}

function inferLabelCatalogEntry(name) {
    if (name.indexOf('[Enhancement]') === 0) {
        if (name === '[Enhancement] Improvement') {
            return { name, color: '84b6eb', description: 'GitLab label (parity)' };
        }
        if (name === '[Enhancement] Localization') {
            return { name, color: 'c5def5', description: 'GitLab label (parity)' };
        }
        return { name, color: 'a2eeef', description: 'GitLab label (parity)' };
    }

    if (name.indexOf('[Module]') === 0) {
        return { name, color: '1d76db', description: 'GitLab label (parity)' };
    }

    if (name.indexOf('[Status]') === 0) {
        return { name, color: 'd4c5f9', description: 'GitLab label (parity)' };
    }

    return { name, color: 'ededed', description: 'GitLab label (parity)' };
}

async function fetchGitlabIssuePage(project, page) {
    const encoded = encodeURIComponent(project);
    const url = `https://gitlab.com/api/v4/projects/${encoded}/issues?state=all&scope=all&per_page=100&page=${page}`;

    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), 20000);

    try {
        const response = await fetch(url, {
            headers: { Accept: 'application/json' },
            signal: controller.signal,
        });
        if (!response.ok) {
            throw new Error(`GitLab API returned HTTP ${response.status}`);
        }
        return await response.json();
    } finally {
        clearTimeout(timeout);
    }
}

async function fetchAllGitlabIssues(project) {
    const issues = [];
    let page = 1;

    while (true) {
        const batch = await fetchGitlabIssuePage(project, page);
        if (!Array.isArray(batch) || batch.length === 0) {
            break;
        }

        issues.push(...batch);
        if (batch.length < 100) {
            break;
        }

        page += 1;
    }

    return issues;
}

function readIssuesFromFile(inputPath) {
    return JSON.parse(fs.readFileSync(inputPath, 'utf8'));
}

function writeLabelCatalogFromReport(report) {
    const names = Array.isArray(report.labelCatalog) ? report.labelCatalog : [];
    const entries = names.map((name) => inferLabelCatalogEntry(name));
    fs.writeFileSync(DEFAULT_LABEL_CATALOG, JSON.stringify(entries, null, 2) + '\n', 'utf8');
}

async function main() {
    const args = parseArgs(process.argv.slice(2));
    if (args.help) {
        printHelp();
        return;
    }

    const issues = args.input ? readIssuesFromFile(args.input) : await fetchAllGitlabIssues(args.project);
    const report = buildDryRunReport(issues);

    fs.writeFileSync(args.output, JSON.stringify(report, null, 2) + '\n', 'utf8');
    writeLabelCatalogFromReport(report);

    console.log(`GitLab project: ${args.project}`);
    console.log(`Issues scanned: ${report.counts.total}`);
    console.log(`Open issues drafted: ${report.counts.open}`);
    console.log(`Skipped closed issues: ${report.counts.skippedClosed}`);
    console.log(`Unique GitLab labels (union): ${report.labelCatalog.length}`);
    console.log(`Dry-run report: ${args.output}`);
    console.log(`Label catalog: ${DEFAULT_LABEL_CATALOG}`);
}

main().catch((error) => {
    console.error(`Dry run failed: ${error.message}`);
    process.exitCode = 1;
});
