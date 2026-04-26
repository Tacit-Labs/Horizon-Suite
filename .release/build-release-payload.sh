#!/bin/bash
# Build a Discord embed JSON payload for a release tag.
#
# Usage:
#   .release/build-release-payload.sh                  # uses latest v* tag
#   .release/build-release-payload.sh v4.16.1          # specific tag
#
# Output: .release/discord-release-payload.json
#
# Preview-post locally without touching GitHub Actions:
#   bash .release/build-release-payload.sh v4.16.1
#   curl -X POST -H "Content-Type: application/json" \
#        -d @.release/discord-release-payload.json "$DISCORD_TEST_WEBHOOK"
#
# Used by .github/workflows/release.yml.

set -euo pipefail

TAG="${1:-}"
if [ -z "$TAG" ]; then
  TAG=$(git describe --tags --abbrev=0 --match 'v*' 2>/dev/null || echo "")
fi
if [ -z "$TAG" ]; then
  echo "No tag found and none provided. Pass a tag like v4.16.1." >&2
  exit 1
fi

VERSION="${TAG#v}"
REPO="${GITHUB_REPOSITORY:-Tacit-Labs/Horizon-Suite}"
REPO_NAME="${REPO##*/}"

BODY=$(VERSION="$VERSION" python3 <<'PYEOF'
import os, re
version = os.environ['VERSION']
content = open('CHANGELOG.md').read()
# Match `## [VERSION] ...` heading and capture until next `## [` or end of file.
pattern = r'##\s*\[' + re.escape(version) + r'\][^\n]*\n+(.*?)(?=\n##\s*\[|\Z)'
m = re.search(pattern, content, re.DOTALL)
body = m.group(1).strip() if m else ''
body = re.sub(r'\n---\s*$', '', body).strip()
print(body)
PYEOF
)

LINKS="**Download:** [GitHub](https://github.com/${REPO}/releases/tag/${TAG}) · [CurseForge](https://www.curseforge.com/projects/1457844) · [Wago](https://addons.wago.io/addons/jK8gY56y)"
if [ -n "$BODY" ]; then
  DESC="${LINKS}"$'\n\n'"${BODY}"
else
  DESC="${LINKS}"$'\n\n'"See the [GitHub release page](https://github.com/${REPO}/releases/tag/${TAG}) for full notes."
fi

# Discord embed description hard limit is 4096 chars.
DESC_FILE=$(mktemp)
trap 'rm -f "$DESC_FILE"' EXIT
printf '%s' "$DESC" | jq -Rs 'if length > 4096 then .[0:4093] + "..." else . end' > "$DESC_FILE"

mkdir -p .release
jq -n \
  --arg user "Addon Release Bot" \
  --arg avatar "https://raw.githubusercontent.com/Tacit-Labs/Horizon-Suite/main/assets/social/issuelog-logo.png" \
  --arg title "New Release: ${REPO_NAME} ${TAG}" \
  --arg url "https://github.com/${REPO}/releases/tag/${TAG}" \
  --arg footer "Tacit Labs · ${REPO_NAME} ${TAG}" \
  --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  --slurpfile desc "$DESC_FILE" \
  '{
    username: $user,
    avatar_url: $avatar,
    embeds: [{
      title: $title,
      url: $url,
      description: $desc[0],
      color: 5763719,
      thumbnail: { url: $avatar },
      footer: { text: $footer },
      timestamp: $ts
    }]
  }' > .release/discord-release-payload.json

echo "Built .release/discord-release-payload.json for ${TAG}"
