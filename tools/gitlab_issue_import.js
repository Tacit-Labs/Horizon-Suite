#!/usr/bin/env node
/**
 * Create GitHub issues from a gitlab_issue_dry_run.js report (drafts[]).
 * Uses `gh issue create` (GitHub CLI). Requires `gh auth` and repo access.
 *
 * Usage:
 *   node tools/gitlab_issue_import.js --from tools/gitlab-issues-dry-run.json
 *   node tools/gitlab_issue_import.js --from tools/gitlab-issues-dry-run.json --execute
 *   node tools/gitlab_issue_import.js --from ... --execute --limit 5
 *   node tools/gitlab_issue_import.js --from ... --execute --no-skip-existing
 *
 * Options:
 *   --from <path>     Dry-run JSON (default: tools/gitlab-issues-dry-run.json)
 *   --repo owner/name  Override repo (default: parsed from `git remote get-url origin`)
 *   --execute         Actually run `gh issue create` (default is print-only)
 *   --limit <n>       Import at most n drafts (in file order); 0 = all
 *   --skip-existing   Skip drafts whose GitLab IID already appears in a GitHub issue body (default: on)
 *   --no-skip-existing
 *   --delay-ms <n>    Pause between creates (default 400)
 */

const fs = require('fs');
const path = require('path');
const os = require('os');
const { spawnSync } = require('child_process');
const { setTimeout: delay } = require('timers/promises');

const ROOT = path.resolve(__dirname, '..');
const DEFAULT_FROM = path.join(ROOT, 'tools', 'gitlab-issues-dry-run.json');
const MIGRATED_LINE_RE = /Migrated from GitLab issue #(\d+)/;

function parseGitRemoteRepo() {
    try {
        const r = spawnSync('git', ['remote', 'get-url', 'origin'], {
            cwd: ROOT,
            encoding: 'utf8',
        });
        if (r.status !== 0) {
            return null;
        }
        const url = (r.stdout || '').trim();
        const m = url.match(/github\.com[:/]([^/]+\/[^/.]+?)(?:\.git)?$/i);
        return m ? m[1] : null;
    } catch {
        return null;
    }
}

function parseArgs(argv) {
    const args = {
        from: DEFAULT_FROM,
        repo: parseGitRemoteRepo(),
        execute: false,
        limit: 0,
        skipExisting: true,
        delayMs: 400,
        help: false,
    };

    for (let i = 0; i < argv.length; i++) {
        const arg = argv[i];
        if (arg === '--from' && argv[i + 1]) {
            args.from = path.resolve(argv[++i]);
        } else if (arg === '--repo' && argv[i + 1]) {
            args.repo = argv[++i];
        } else if (arg === '--execute') {
            args.execute = true;
        } else if (arg === '--limit' && argv[i + 1]) {
            args.limit = Math.max(0, parseInt(argv[++i], 10) || 0);
        } else if (arg === '--skip-existing') {
            args.skipExisting = true;
        } else if (arg === '--no-skip-existing') {
            args.skipExisting = false;
        } else if (arg === '--delay-ms' && argv[i + 1]) {
            args.delayMs = Math.max(0, parseInt(argv[++i], 10) || 0);
        } else if (arg === '--help' || arg === '-h') {
            args.help = true;
        }
    }

    return args;
}

function printHelp() {
    console.log(`Usage: node tools/gitlab_issue_import.js [--from report.json] [--repo owner/name] [--limit N] [--execute]`);
    console.log('');
    console.log('Without --execute, prints planned imports only.');
    console.log('With --execute, runs gh issue create for each draft (respects --skip-existing by default).');
}

function ghSpawn(args, opts) {
    const r = spawnSync('gh', args, {
        encoding: 'utf8',
        maxBuffer: 64 * 1024 * 1024,
        ...opts,
    });
    return r;
}

function listGithubIssuesForMigrationScan(repo) {
    const all = [];
    let page = 1;
    const perPage = 100;

    while (true) {
        const pathArg = `/repos/${repo}/issues?state=all&per_page=${perPage}&page=${page}`;
        const r = ghSpawn(['api', '-H', 'Accept: application/vnd.github+json', pathArg], {});
        if (r.status !== 0) {
            throw new Error(`gh api failed (${r.status}): ${(r.stderr || r.stdout || '').trim()}`);
        }
        const batch = JSON.parse(r.stdout || '[]');
        if (!Array.isArray(batch) || batch.length === 0) {
            break;
        }
        for (const item of batch) {
            if (item && item.pull_request) {
                continue;
            }
            all.push(item);
        }
        if (batch.length < perPage) {
            break;
        }
        page += 1;
        if (page > 500) {
            throw new Error('Too many GitHub issues pages while scanning for existing migrations (abort).');
        }
    }

    return all;
}

function buildMigratedGitlabIidSet(issues) {
    const set = {};
    for (const issue of issues) {
        if (!issue || issue.pull_request) {
            continue;
        }
        const body = issue.body || '';
        const m = body.match(MIGRATED_LINE_RE);
        if (m) {
            const iid = parseInt(m[1], 10);
            if (iid > 0) {
                set[iid] = issue.number;
            }
        }
    }
    return set;
}

function parseCreatedIssueUrl(stdout) {
    const text = (stdout || '').trim();
    const m = text.match(/\/issues\/(\d+)\s*$/m) || text.match(/github\.com\/[^/]+\/[^/]+\/issues\/(\d+)/);
    return m ? parseInt(m[1], 10) : null;
}

function createGithubIssue(draft, repo) {
    const tmpDir = fs.mkdtempSync(path.join(os.tmpdir(), 'hs-gl-import-'));
    try {
        const bodyFile = path.join(tmpDir, 'body.md');
        fs.writeFileSync(bodyFile, draft.body, 'utf8');

        const args = ['issue', 'create', '-R', repo, '--title', draft.title, '--body-file', bodyFile];
        const labels = Array.isArray(draft.labels) ? draft.labels : [];
        for (const label of labels) {
            if (typeof label === 'string' && label.length) {
                args.push('--label', label);
            }
        }

        const r = ghSpawn(args, {});
        if (r.status !== 0) {
            return {
                ok: false,
                error: (r.stderr || r.stdout || 'gh issue create failed').trim(),
            };
        }

        const number = parseCreatedIssueUrl(r.stdout);
        return { ok: true, number, url: (r.stdout || '').trim() };
    } finally {
        try {
            fs.rmSync(tmpDir, { recursive: true, force: true });
        } catch {
            /* ignore */
        }
    }
}

async function main() {
    const args = parseArgs(process.argv.slice(2));
    if (args.help) {
        printHelp();
        return;
    }

    if (!args.repo) {
        console.error('Could not determine GitHub repo. Pass --repo owner/name or set origin to a github.com remote.');
        process.exitCode = 1;
        return;
    }

    if (!fs.existsSync(args.from)) {
        console.error(`Report not found: ${args.from}`);
        process.exitCode = 1;
        return;
    }

    const report = JSON.parse(fs.readFileSync(args.from, 'utf8'));
    const drafts = Array.isArray(report.drafts) ? report.drafts : [];
    if (drafts.length === 0) {
        console.error('No drafts found in report (expected report.drafts[]).');
        process.exitCode = 1;
        return;
    }

    let selected = drafts;
    if (args.limit > 0) {
        selected = drafts.slice(0, args.limit);
    }

    let migratedMap = {};
    if (args.execute && args.skipExisting) {
        console.log(`Scanning ${args.repo} for existing GitLab migrations...`);
        const ghIssues = listGithubIssuesForMigrationScan(args.repo);
        migratedMap = buildMigratedGitlabIidSet(ghIssues);
        console.log(`Found ${Object.keys(migratedMap).length} already-imported GitLab IIDs.`);
    }

    const results = [];
    for (const draft of selected) {
        const iid = draft.gitlabIid;
        if (!iid) {
            results.push({ gitlabIid: null, ok: false, error: 'draft missing gitlabIid' });
            continue;
        }

        if (args.execute && args.skipExisting && migratedMap[iid]) {
            const existing = migratedMap[iid];
            console.log(`Skip GitLab #${iid} -> already GitHub #${existing}`);
            results.push({ gitlabIid: iid, ok: true, skipped: true, githubNumber: existing });
            continue;
        }

        if (!args.execute) {
            console.log(`Would create: GitLab #${iid} -> "${draft.title}" labels=${JSON.stringify(draft.labels || [])}`);
            results.push({ gitlabIid: iid, ok: true, dryRun: true });
            continue;
        }

        console.log(`Creating GitLab #${iid}: ${draft.title}`);
        const created = createGithubIssue(draft, args.repo);
        if (!created.ok) {
            console.error(`FAILED GitLab #${iid}: ${created.error}`);
            results.push({ gitlabIid: iid, ok: false, error: created.error });
            process.exitCode = 1;
            break;
        }

        console.log(`  -> GitHub #${created.number} ${created.url || ''}`);
        migratedMap[iid] = created.number;
        results.push({
            gitlabIid: iid,
            ok: true,
            githubNumber: created.number,
            url: created.url,
        });

        if (args.delayMs) {
            await delay(args.delayMs);
        }
    }

    const outPath = path.join(ROOT, 'tools', 'gitlab-issue-import-results.json');
    fs.writeFileSync(
        outPath,
        JSON.stringify(
            {
                generatedAt: new Date().toISOString(),
                repo: args.repo,
                execute: args.execute,
                from: args.from,
                results,
            },
            null,
            2,
        ) + '\n',
        'utf8',
    );
    console.log(`Wrote ${path.relative(ROOT, outPath)}`);
}

main().catch((err) => {
    console.error(err);
    process.exitCode = 1;
});
