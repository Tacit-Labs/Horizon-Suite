const test = require('node:test');
const assert = require('node:assert/strict');

const { buildGithubDraft, buildDryRunReport } = require('../lib/gitlabIssueMigration.js');

test('buildGithubDraft maps a GitLab open issue to a GitHub dry-run draft', () => {
    const gitlabIssue = {
        iid: 123,
        title: 'Quest list sometimes resizes to default height',
        description: '### Description\nTracker height resets after zoning.\n\n### Use case\nKeep my preferred height.',
        labels: ['[Enhancement] Improvement', '[Module] Focus'],
        state: 'opened',
        web_url: 'https://gitlab.com/Crystilac/horizon-suite/-/issues/123',
        created_at: '2026-04-01T12:30:00Z',
        author: { username: 'tester', name: 'Test User' },
    };

    const draft = buildGithubDraft(gitlabIssue);

    assert.equal(draft.title, gitlabIssue.title);
    assert.deepEqual(draft.labels, ['[Enhancement] Improvement', '[Module] Focus']);
    assert.match(draft.body, /Migrated from GitLab issue #123/);
    assert.match(draft.body, /Original URL: https:\/\/gitlab\.com\/Crystilac\/horizon-suite\/-\/issues\/123/);
    assert.match(draft.body, /Original author: Test User \(@tester\)/);
    assert.match(draft.body, /Original created: 2026-04-01T12:30:00Z/);
    assert.match(draft.body, /### Description/);
});

test('buildDryRunReport keeps only open issues and records the GitLab to GitHub preview map', () => {
    const issues = [
        {
            iid: 7,
            title: 'Open issue',
            description: 'Open description',
            labels: ['bug', '[Module] Core'],
            state: 'opened',
            web_url: 'https://gitlab.com/example/issues/7',
            created_at: '2026-04-02T00:00:00Z',
            author: { username: 'alpha', name: 'Alpha' },
        },
        {
            iid: 8,
            title: 'Closed issue',
            description: 'Closed description',
            labels: ['bug', '[Module] Core'],
            state: 'closed',
            web_url: 'https://gitlab.com/example/issues/8',
            created_at: '2026-04-03T00:00:00Z',
            author: { username: 'beta', name: 'Beta' },
        },
    ];

    const report = buildDryRunReport(issues);

    assert.equal(report.counts.total, 2);
    assert.equal(report.counts.open, 1);
    assert.equal(report.drafts.length, 1);
    assert.deepEqual([...report.labelCatalog].sort(), ['bug', '[Module] Core'].sort());
    assert.deepEqual(report.idMap, [{ gitlabIid: 7, githubNumber: null }]);
});
