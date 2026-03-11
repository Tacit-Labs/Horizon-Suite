#!/bin/bash
set -e
# Fetches open GitLab issues and generates Discord embed payload.
# Uses GitLab API. Requires PROJECT_ACCESS_TOKEN, GITLAB_TOKEN, or CI_JOB_TOKEN.
# Output: .release/discord-issuelog-payload.json

PROJECT_ID="${CI_PROJECT_ID:-}"
PROJECT_PATH="${CI_PROJECT_PATH:-Crystilac/horizon-suite}"
PROJECT_PATH_ENC=$(echo "$PROJECT_PATH" | sed 's|/|%2F|g')
API_BASE="${CI_API_V4_URL:-https://gitlab.com/api/v4}"
TOKEN="${PROJECT_ACCESS_TOKEN:-$GITLAB_TOKEN}"
if [ -z "$TOKEN" ]; then
  TOKEN="${CI_JOB_TOKEN:-}"
fi

if [ -z "$TOKEN" ]; then
  echo "Error: No PROJECT_ACCESS_TOKEN, GITLAB_TOKEN, or CI_JOB_TOKEN set."
  exit 1
fi

# Fetch open issues (scope=all to get all project issues, not just created_by_me)
if [ -n "$PROJECT_ID" ]; then
  ISSUES=$(curl -s -H "PRIVATE-TOKEN: ${TOKEN}" \
    "${API_BASE}/projects/${PROJECT_ID}/issues?state=opened&scope=all&per_page=100" 2>/dev/null || echo "[]")
else
  ISSUES=$(curl -s -H "PRIVATE-TOKEN: ${TOKEN}" \
    "${API_BASE}/projects/${PROJECT_PATH_ENC}/issues?state=opened&scope=all&per_page=100" 2>/dev/null || echo "[]")
fi

if [ "${ISSUES}" = "[]" ] || [ -z "${ISSUES}" ]; then
  ISSUES="[]"
fi

BUGS=""
FEATURES=""
IMPROVEMENTS=""
IDEAS=""

while IFS= read -r line; do
  title=$(echo "$line" | jq -r '.title')
  url=$(echo "$line" | jq -r '.web_url')
  # GitLab uses labels as array of strings
  labels=$(echo "$line" | jq -r '.labels[]?' 2>/dev/null | tr '\n' ' ')
  body=$(echo "$line" | jq -r '.description // ""')

  # Determine module tag (case-insensitive)
  module=""
  labels_lower=$(echo "$labels" | tr '[:upper:]' '[:lower:]')
  [[ "$labels_lower" =~ focus ]]    && module="[Focus] "
  [[ "$labels_lower" =~ presence ]] && module="[Presence] "
  [[ "$labels_lower" =~ core ]]     && module="[Core] "
  [[ "$labels_lower" =~ vista ]]    && module="[Vista] "
  [[ "$labels_lower" =~ yield ]]    && module="[Yield] "
  [[ "$labels_lower" =~ pulse ]]    && module="[Pulse] "
  [[ "$labels_lower" =~ insight ]]  && module="[Insight] "
  [[ "$labels_lower" =~ verse ]]    && module="[Verse] "

  # Extract ### Description section from body (text between ### Description and next ###)
  desc=$(printf '%s' "$body" | awk '
    /^### Description/ { found=1; next }
    found && /^###/    { exit }
    found              { print }
  ' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | tr -s ' \n' ' ' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

  # Fallback: if no ### Description, use first paragraph
  if [ -z "$desc" ]; then
    desc=$(printf '%s' "$body" | awk '
      /^$/ { if (found) exit; next }
      { found=1; print }
    ' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | tr -s ' \n' ' ' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
  fi

  # Remove residual markdown: bold, italic, code, links
  desc=$(printf '%s' "$desc" | sed 's/\*\*//g; s/\*//g; s/`//g; s/\[//g; s/\]([^)]*)//g')

  # Truncate to 120 chars
  if [ ${#desc} -gt 120 ]; then
    desc="${desc:0:120}…"
  fi

  # Build bullet line
  if [ -n "$desc" ]; then
    bullet="• ${module}[${title}](${url}) — ${desc}"
  else
    bullet="• ${module}[${title}](${url})"
  fi

  # Route to bucket by type label (case-insensitive)
  if [[ "$labels_lower" =~ bug ]]; then
    BUGS="${BUGS}${bullet}"$'\n'
  elif [[ "$labels_lower" =~ feature ]]; then
    FEATURES="${FEATURES}${bullet}"$'\n'
  elif [[ "$labels_lower" =~ improvement ]]; then
    IMPROVEMENTS="${IMPROVEMENTS}${bullet}"$'\n'
  elif [[ "$labels_lower" =~ idea ]]; then
    IDEAS="${IDEAS}${bullet}"$'\n'
  fi

done < <(echo "$ISSUES" | jq -c '.[]' 2>/dev/null || true)

# Embed colours (decimal)
COLOR_HEADER=5793266
COLOR_BUGS=15548997
COLOR_FEATURES=5763719
COLOR_IMPROVEMENTS=3447003
COLOR_IDEAS=16776960

REPO_URL="${CI_PROJECT_URL:-https://gitlab.com/${PROJECT_PATH}}/-/issues"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Build embeds array — start with header embed
EMBEDS_JSON=$(jq -n \
  --arg title "HorizonSuite — Open Issues" \
  --arg url "$REPO_URL" \
  --argjson color $COLOR_HEADER \
  --arg ts "$TIMESTAMP" \
  '[{title: $title, url: $url, color: $color, timestamp: $ts}]')

# Helper: append an embed if bucket is non-empty
append_embed() {
  local name="$1"
  local content="$2"
  local color="$3"
  if [ -n "$content" ]; then
    # Guard: truncate to 4096 chars (Discord embed description limit)
    local truncated
    truncated=$(printf '%s' "$content" | jq -Rs 'if length > 4096 then .[0:4096] else . end')
    EMBEDS_JSON=$(echo "$EMBEDS_JSON" | jq \
      --arg name "$name" \
      --argjson desc "$truncated" \
      --argjson color "$color" \
      '. + [{title: $name, description: $desc, color: $color}]')
  fi
}

append_embed "🐛 Known Bugs"       "$BUGS"         $COLOR_BUGS
append_embed "✨ Feature Requests" "$FEATURES"     $COLOR_FEATURES
append_embed "🔧 Improvements"     "$IMPROVEMENTS" $COLOR_IMPROVEMENTS
append_embed "💡 Ideas"            "$IDEAS"         $COLOR_IDEAS

mkdir -p .release
jq -n \
  --arg user "HorizonSuite Issue Bot" \
  --arg avatar "https://about.gitlab.com/images/press/logo/png/gitlab-logo-500.png" \
  --argjson embeds "$EMBEDS_JSON" \
  '{username: $user, avatar_url: $avatar, embeds: $embeds}' \
  > .release/discord-issuelog-payload.json

echo "Generated .release/discord-issuelog-payload.json"
cat .release/discord-issuelog-payload.json | jq .
