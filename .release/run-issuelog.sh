#!/bin/bash
set -e
export GITHUB_REPOSITORY="${GITHUB_REPOSITORY:-Crystilac93/Horizon-Suite}"

# Fetch all open issues (number, title, labels, body, url)
ISSUES=$(gh issue list --state open --json number,title,labels,body,url --limit 100 2>/dev/null || echo "[]")

BUGS=""
FEATURES=""
IMPROVEMENTS=""
IDEAS=""

while IFS= read -r line; do
  num=$(echo "$line" | jq -r '.number')
  title=$(echo "$line" | jq -r '.title')
  url=$(echo "$line" | jq -r '.url')
  labels=$(echo "$line" | jq -r '.labels[].name' | tr '\n' ' ')
  body=$(echo "$line" | jq -r '.body // ""')

  # Determine module tag
  module=""
  [[ "$labels" =~ Focus ]]    && module="[Focus] "
  [[ "$labels" =~ Presence ]] && module="[Presence] "
  [[ "$labels" =~ Core ]]     && module="[Core] "
  [[ "$labels" =~ Vista ]]    && module="[Vista] "
  [[ "$labels" =~ Yield ]]    && module="[Yield] "
  [[ "$labels" =~ Pulse ]]    && module="[Pulse] "
  [[ "$labels" =~ Insight ]]  && module="[Insight] "
  [[ "$labels" =~ Verse ]]    && module="[Verse] "

  # Extract ### Description section from body (text between ### Description and next ###)
  desc=$(printf '%s' "$body" | awk '
    /^### Description/ { found=1; next }
    found && /^###/    { exit }
    found              { print }
  ' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | tr -s ' \n' ' ' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

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

  # Route to bucket by type label
  if [[ "$labels" =~ bug ]]; then
    BUGS="${BUGS}${bullet}"$'\n'
  elif [[ "$labels" =~ feature ]]; then
    FEATURES="${FEATURES}${bullet}"$'\n'
  elif [[ "$labels" =~ improvement ]]; then
    IMPROVEMENTS="${IMPROVEMENTS}${bullet}"$'\n'
  elif [[ "$labels" =~ idea ]]; then
    IDEAS="${IDEAS}${bullet}"$'\n'
  fi

done < <(echo "$ISSUES" | jq -c '.[]' 2>/dev/null || true)

# Embed colours (decimal)
COLOR_HEADER=5793266
COLOR_BUGS=15548997
COLOR_FEATURES=5763719
COLOR_IMPROVEMENTS=3447003
COLOR_IDEAS=16776960

REPO_URL="https://github.com/${GITHUB_REPOSITORY}"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Build embeds array — start with header embed
EMBEDS_JSON=$(jq -n \
  --arg title "HorizonSuite — Open Issues" \
  --arg url "$REPO_URL/issues" \
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

jq -n \
  --arg user "HorizonSuite Issue Bot" \
  --arg avatar "https://github.githubassets.com/images/modules/logos_page/GitHub-Mark.png" \
  --argjson embeds "$EMBEDS_JSON" \
  '{username: $user, avatar_url: $avatar, embeds: $embeds}' \
  > .release/discord-issuelog-payload.json

echo "Generated .release/discord-issuelog-payload.json"
cat .release/discord-issuelog-payload.json | jq .
