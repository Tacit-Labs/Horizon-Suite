#!/bin/bash
set -e
export GITHUB_REPOSITORY="${GITHUB_REPOSITORY:-Tacit-Labs/Horizon-Suite}"

LAST_TAG=$(git describe --tags --abbrev=0 --match 'v*' 2>/dev/null || echo "")
if [ -n "$LAST_TAG" ]; then
  TAG_DATE=$(git log -1 --format=%cd --date=short "$LAST_TAG")
fi

FEATURES=""
IMPROVEMENTS=""
FIXES=""
while IFS= read -r line; do
  num=$(echo "$line" | jq -r '.number')
  title=$(echo "$line" | jq -r '.title')
  labels=$(echo "$line" | jq -r '.labels[].name' | tr '\n' ' ')
  module=""
  [[ "$labels" =~ \bFocus\b ]] && module="(Focus) "
  [[ "$labels" =~ \bPresence\b ]] && module="(Presence) "
  [[ "$labels" =~ \bAxis\b ]] && module="(Axis) "
  [[ "$labels" =~ \bVista\b ]] && module="(Vista) "
  [[ "$labels" =~ \bCache\b ]] && module="(Cache) "
  [[ "$labels" =~ \bEssence\b ]] && module="(Essence) "
  [[ "$labels" =~ \bInsight\b ]] && module="(Insight) "
  [[ "$labels" =~ \bMeridian\b ]] && module="(Meridian) "
  bullet="- ${module}${title} (#${num})"
  if [[ "$labels" =~ \bfeature\b ]]; then
    FEATURES="${FEATURES}${bullet}"$'\n'
  elif [[ "$labels" =~ \bimprovement\b ]]; then
    IMPROVEMENTS="${IMPROVEMENTS}${bullet}"$'\n'
  elif [[ "$labels" =~ \bbug\b ]]; then
    FIXES="${FIXES}${bullet}"$'\n'
  fi
done < <(gh issue list --state closed --search "closed:>=${TAG_DATE}" --json number,title,labels,closedAt --limit 100 2>/dev/null | jq -c --arg tagdate "$TAG_DATE" '.[] | select(.closedAt != null) | select(.closedAt >= ($tagdate + "T00:00:00Z")) | {number, title, labels}' 2>/dev/null || true)

SECTIONS=""
[ -n "$FEATURES" ] && SECTIONS="${SECTIONS}### ✨ New Features"$'\n\n'"$FEATURES"$'\n'
[ -n "$IMPROVEMENTS" ] && SECTIONS="${SECTIONS}### 🔧 Improvements"$'\n\n'"$IMPROVEMENTS"$'\n'
[ -n "$FIXES" ] && SECTIONS="${SECTIONS}### 🐛 Fixes"$'\n\n'"$FIXES"$'\n'

printf '%s' "$BODY" | jq -Rs 'if length > 4096 then .[0:4096] else . end' > /tmp/changelog-desc.json
REPO_NAME="${GITHUB_REPOSITORY##*/}"
jq -n \
  --slurpfile desc /tmp/changelog-desc.json \
  '{username: $user, avatar_url: $avatar, embeds: [{title: $title, url: $url, description: $desc[0]}]}' \
  > .release/discord-payload.json

echo "Generated .release/discord-payload.json"
cat .release/discord-payload.json | jq .
