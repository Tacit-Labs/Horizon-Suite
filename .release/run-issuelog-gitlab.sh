#!/bin/bash
set -e
# Fetches open GitLab issues and generates Discord embed payload.
# Uses GitLab API. Requires PROJECT_ACCESS_TOKEN, GITLAB_TOKEN, or CI_JOB_TOKEN.
# DRY_RUN=1: use glab (uses its own auth) for local testing; no token needed.
# Output: .release/discord-issuelog-payload.json

PROJECT_ID="${CI_PROJECT_ID:-}"
PROJECT_PATH="${CI_PROJECT_PATH:-Crystilac/horizon-suite}"
PROJECT_PATH_ENC=$(echo "$PROJECT_PATH" | sed 's|/|%2F|g')
API_BASE="${CI_API_V4_URL:-https://gitlab.com/api/v4}"
TOKEN="${PROJECT_ACCESS_TOKEN:-$GITLAB_TOKEN}"
if [ -z "$TOKEN" ]; then
  TOKEN="${CI_JOB_TOKEN:-}"
fi

# Fetch open issues
if [ "${DRY_RUN}" = "1" ]; then
  echo "DRY_RUN: fetching via glab..."
  GLAB="${GLAB:-glab}"
  ISSUES=$("$GLAB" issue list -O json -P 100 2>/dev/null || echo "[]")
elif [ -n "$TOKEN" ]; then
  if [ -n "$PROJECT_ID" ]; then
    ISSUES=$(curl -s -H "PRIVATE-TOKEN: ${TOKEN}" \
      "${API_BASE}/projects/${PROJECT_ID}/issues?state=opened&scope=all&per_page=100" 2>/dev/null || echo "[]")
  else
    ISSUES=$(curl -s -H "PRIVATE-TOKEN: ${TOKEN}" \
      "${API_BASE}/projects/${PROJECT_PATH_ENC}/issues?state=opened&scope=all&per_page=100" 2>/dev/null || echo "[]")
  fi
else
  echo "Error: No PROJECT_ACCESS_TOKEN, GITLAB_TOKEN, or CI_JOB_TOKEN set. Use DRY_RUN=1 with glab for local run."
  exit 1
fi

if [ "${ISSUES}" = "[]" ] || [ -z "${ISSUES}" ]; then
  ISSUES="[]"
fi

# Buckets: BUGS, FEATURES, IMPROVEMENTS, IDEAS
# Sub-buckets by module: _Focus, _Presence, _Core, _Vista, _Yield, _Pulse, _Insight, _Verse, _Cache, _Profile, _Flow, _Other
declare -A BUGS FEATURES IMPROVEMENTS IDEAS
MODULE_ORDER="Focus Presence Core Vista Yield Pulse Insight Verse Cache Profile Flow Other"

while IFS= read -r line; do
  title=$(echo "$line" | jq -r '.title')
  url=$(echo "$line" | jq -r '.web_url')
  # GitLab uses labels as array of strings
  labels=$(echo "$line" | jq -r '.labels[]?' 2>/dev/null | tr '\n' ' ')
  body=$(echo "$line" | jq -r '.description // ""')

  # Determine module from labels (for grouping and display)
  # Labels categorise by module: [Module] Focus, [Module] Presence, Core, etc.
  module_key="Other"
  module_tag=""
  labels_lower=$(echo "$labels" | tr '[:upper:]' '[:lower:]')
  if [[ "$labels_lower" =~ focus ]]; then
    module_key="Focus"; module_tag="[Focus] "
  elif [[ "$labels_lower" =~ presence ]]; then
    module_key="Presence"; module_tag="[Presence] "
  elif [[ "$labels_lower" =~ vista ]]; then
    module_key="Vista"; module_tag="[Vista] "
  elif [[ "$labels_lower" =~ insight ]]; then
    module_key="Insight"; module_tag="[Insight] "
  elif [[ "$labels_lower" =~ cache ]]; then
    module_key="Cache"; module_tag="[Cache] "
  elif [[ "$labels_lower" =~ profile ]]; then
    module_key="Profile"; module_tag="[Profile] "
  elif [[ "$labels_lower" =~ flow ]]; then
    module_key="Flow"; module_tag="[Flow] "
  elif [[ "$labels_lower" =~ core ]] || [[ "$labels_lower" =~ axis ]] || [[ "$labels_lower" =~ system ]]; then
    module_key="Core"; module_tag="[Core] "
  elif [[ "$labels_lower" =~ yield ]]; then
    module_key="Yield"; module_tag="[Yield] "
  elif [[ "$labels_lower" =~ pulse ]]; then
    module_key="Pulse"; module_tag="[Pulse] "
  elif [[ "$labels_lower" =~ verse ]]; then
    module_key="Verse"; module_tag="[Verse] "
  fi

  # Determine status tag from [Status] labels (first match wins)
  status=""
  if [[ "$labels_lower" =~ in-progress ]]; then
    status="[In-Progress] "
  elif [[ "$labels_lower" =~ manifested ]]; then
    status="[Manifested] "
  elif [[ "$labels_lower" =~ logged ]]; then
    status="[Logged] "
  elif [[ "$labels_lower" =~ resolved ]]; then
    status="[Resolved] "
  fi

  # Build bullet line (status + title link only; heading is enough)
  bullet="• ${status}[${title}](${url})"

  # Route to bucket by issue_type, then sub-bucket by module
  # Issues = bugs, Tasks = features or improvements
  issue_type=$(echo "$line" | jq -r '.issue_type // "issue"')
  if [[ "$labels_lower" =~ idea ]]; then
    IDEAS[$module_key]="${IDEAS[$module_key]:-}${bullet}"$'\n'
  elif [[ "$issue_type" == "issue" ]] || [[ "$issue_type" == "incident" ]]; then
    BUGS[$module_key]="${BUGS[$module_key]:-}${bullet}"$'\n'
  elif [[ "$issue_type" == "task" ]]; then
    if [[ "$labels_lower" =~ feature ]]; then
      FEATURES[$module_key]="${FEATURES[$module_key]:-}${bullet}"$'\n'
    else
      IMPROVEMENTS[$module_key]="${IMPROVEMENTS[$module_key]:-}${bullet}"$'\n'
    fi
  elif [[ "$issue_type" == "test_case" ]]; then
    IMPROVEMENTS[$module_key]="${IMPROVEMENTS[$module_key]:-}${bullet}"$'\n'
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

# Helper: build content from bucket associative array with module sub-sections
build_bucket_content() {
  local -n bucket=$1
  local out=""
  for mod in $MODULE_ORDER; do
    local val="${bucket[$mod]:-}"
    val=$(echo "$val" | sed '/^$/d')
    if [ -n "$val" ]; then
      [ -n "$out" ] && out="${out}"$'\n\n'
      out="${out}**${mod}**"$'\n'"${val}"
    fi
  done
  echo "$out"
}

# Helper: append an embed if bucket has content
append_embed() {
  local name="$1"
  local content="$2"
  local color="$3"
  if [ -n "$content" ]; then
    local truncated
    truncated=$(printf '%s' "$content" | jq -Rs 'if length > 4096 then .[0:4096] else . end')
    EMBEDS_JSON=$(echo "$EMBEDS_JSON" | jq \
      --arg name "$name" \
      --argjson desc "$truncated" \
      --argjson color "$color" \
      '. + [{title: $name, description: $desc, color: $color}]')
  fi
}

append_embed "🐛 Known Bugs"       "$(build_bucket_content BUGS)"         $COLOR_BUGS
append_embed "✨ Feature Requests" "$(build_bucket_content FEATURES)"     $COLOR_FEATURES
append_embed "🔧 Improvements"     "$(build_bucket_content IMPROVEMENTS)" $COLOR_IMPROVEMENTS
append_embed "💡 Ideas"            "$(build_bucket_content IDEAS)"        $COLOR_IDEAS

mkdir -p .release
jq -n \
  --arg user "HorizonSuite Issue Bot" \
  --arg avatar "https://about.gitlab.com/images/press/logo/png/gitlab-logo-500.png" \
  --argjson embeds "$EMBEDS_JSON" \
  '{username: $user, avatar_url: $avatar, embeds: $embeds}' \
  > .release/discord-issuelog-payload.json

echo "Generated .release/discord-issuelog-payload.json"
cat .release/discord-issuelog-payload.json | jq .
