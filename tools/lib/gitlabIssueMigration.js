function normalizeGithubLabelList(gitlabLabels) {
    const labels = Array.isArray(gitlabLabels) ? gitlabLabels : [];
    const seen = {};
    const normalized = [];

    for (const raw of labels) {
        if (typeof raw !== 'string') {
            continue;
        }

        const name = raw.trim();
        if (!name || seen[name]) {
            continue;
        }

        seen[name] = true;
        normalized.push(name);
    }

    return normalized;
}

function mapGithubLabels(gitlabLabels) {
    return normalizeGithubLabelList(gitlabLabels);
}

function formatAuthor(author) {
    if (!author) {
        return 'Unknown';
    }
    const name = author.name || author.username || 'Unknown';
    return author.username ? `${name} (@${author.username})` : name;
}

function normalizeBody(description) {
    const body = (description || '').trim();
    return body || '_No description provided in the original GitLab issue._';
}

function buildGithubDraft(issue) {
    const labels = mapGithubLabels(issue.labels || []);
    const sourceLines = [
        `Migrated from GitLab issue #${issue.iid}`,
        `Original URL: ${issue.web_url || ''}`,
        `Original author: ${formatAuthor(issue.author)}`,
        `Original created: ${issue.created_at || ''}`,
        `Original state: ${issue.state || ''}`,
    ];

    const body = `${sourceLines.join('\n')}\n\n---\n\n${normalizeBody(issue.description)}`;

    return {
        gitlabIid: issue.iid,
        title: issue.title,
        labels,
        body,
        source: {
            gitlabLabels: issue.labels || [],
            webUrl: issue.web_url || null,
            state: issue.state || null,
        },
    };
}

function isOpenIssue(issue) {
    return issue && issue.state === 'opened';
}

function collectUniqueGitlabLabelsFromIssues(issues) {
    const safeIssues = Array.isArray(issues) ? issues : [];
    const catalog = [];

    for (const issue of safeIssues) {
        for (const label of issue.labels || []) {
            catalog.push(label);
        }
    }

    const normalized = normalizeGithubLabelList(catalog);
    normalized.sort((a, b) => a.localeCompare(b));
    return normalized;
}

function buildDryRunReport(issues) {
    const safeIssues = Array.isArray(issues) ? issues : [];
    const openIssues = safeIssues.filter(isOpenIssue);
    const drafts = openIssues.map(buildGithubDraft);
    const labelCatalog = collectUniqueGitlabLabelsFromIssues(safeIssues);

    return {
        generatedAt: new Date().toISOString(),
        counts: {
            total: safeIssues.length,
            open: openIssues.length,
            skippedClosed: safeIssues.length - openIssues.length,
        },
        labelCatalog,
        idMap: drafts.map((draft) => ({
            gitlabIid: draft.gitlabIid,
            githubNumber: null,
        })),
        drafts,
    };
}

module.exports = {
    buildGithubDraft,
    buildDryRunReport,
    mapGithubLabels,
};
