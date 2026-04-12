#!/bin/bash
set -e
# Fetches open GitHub issues and generates Discord embed payloads.
# Requires gh CLI and GITHUB_TOKEN (or gh auth).
# Output: .release/discord-issuelog-payload-{bugs,features,improvements,ideas}.json
# One message per type; each message has its own 6000-char limit (avoids Discord total-embed limit).

export GITHUB_REPOSITORY="${GITHUB_REPOSITORY:-Tacit-Labs/Horizon-Suite}"

# Fetch all open issues (paginated; default limit would miss issues past 100)
ISSUES="[]"
page=1
while true; do
  batch=$(gh issue list --state open --json number,title,labels,body,url --limit 100 --page "$page" 2>/dev/null || echo "[]")
  cnt=$(echo "$batch" | jq 'length')
  if [ "$cnt" -eq 0 ]; then
    break
  fi
  ISSUES=$(jq -n --argjson acc "$ISSUES" --argjson b "$batch" '$acc + $b')
  if [ "$cnt" -lt 100 ]; then
    break
  fi
  page=$((page + 1))
  if [ "$page" -gt 50 ]; then
    echo "Warning: stopped pagination after 50 pages" >&2
    break
  fi
done

BUGS=""
FEATURES=""
IMPROVEMENTS=""
IDEAS=""

while IFS= read -r line; do
  num=$(echo "$line" | jq -r '.number')
  title=$(echo "$line" | jq -r '.title')
  url=$(echo "$line" | jq -r '.url')
  labels=$(echo "$line" | jq -r '.labels[].name' | tr '\n' ' ')
  labels_lc=$(echo "$labels" | tr '[:upper:]' '[:lower:]')
  body=$(echo "$line" | jq -r '.body // ""')

  # Determine module tag (plain names or GitLab-parity [Module] … labels)
  module=""
  if [[ "$labels_lc" =~ \[module\]\ focus ]]; then module="[Focus] "
  elif [[ "$labels_lc" =~ \[module\]\ presence ]]; then module="[Presence] "
  elif [[ "$labels_lc" =~ \[module\]\ axis ]] || [[ "$labels_lc" =~ \[module\]\ core ]]; then module="[Core] "
  elif [[ "$labels_lc" =~ \[module\]\ vista ]]; then module="[Vista] "
  elif [[ "$labels_lc" =~ \[module\]\ cache ]]; then module="[Cache] "
  elif [[ "$labels_lc" =~ \[module\]\ pulse ]]; then module="[Pulse] "
  elif [[ "$labels_lc" =~ \[module\]\ insight ]]; then module="[Insight] "
  elif [[ "$labels_lc" =~ \[module\]\ verse ]]; then module="[Verse] "
  elif [[ "$labels_lc" =~ \[module\]\ essence ]]; then module="[Essence] "
  elif [[ "$labels_lc" =~ \[module\]\ flow ]]; then module="[Flow] "
  elif [[ "$labels_lc" =~ (^|[[:space:]])focus($|[[:space:]]) ]]; then module="[Focus] "
  elif [[ "$labels_lc" =~ (^|[[:space:]])presence($|[[:space:]]) ]]; then module="[Presence] "
  elif [[ "$labels_lc" =~ (^|[[:space:]])core($|[[:space:]]) ]]; then module="[Core] "
  elif [[ "$labels_lc" =~ (^|[[:space:]])vista($|[[:space:]]) ]]; then module="[Vista] "
  elif [[ "$labels_lc" =~ (^|[[:space:]])cache($|[[:space:]]) ]]; then module="[Cache] "
  elif [[ "$labels_lc" =~ (^|[[:space:]])pulse($|[[:space:]]) ]]; then module="[Pulse] "
  elif [[ "$labels_lc" =~ (^|[[:space:]])insight($|[[:space:]]) ]]; then module="[Insight] "
  elif [[ "$labels_lc" =~ (^|[[:space:]])verse($|[[:space:]]) ]]; then module="[Verse] "
  fi

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

  # Route to bucket: legacy GitHub labels (bug, feature, …) or GitLab-parity [Enhancement] …
  if [[ "$labels_lc" =~ (^|[[:space:]])bug($|[[:space:]]) ]]; then
    BUGS="${BUGS}${bullet}"$'\n'
  elif [[ "$labels_lc" =~ \[enhancement\]\ feature ]] || [[ "$labels_lc" =~ (^|[[:space:]])feature($|[[:space:]]) ]]; then
    FEATURES="${FEATURES}${bullet}"$'\n'
  elif [[ "$labels_lc" =~ \[enhancement\]\ improvement ]] || [[ "$labels_lc" =~ \[enhancement\]\ localization ]] || [[ "$labels_lc" =~ (^|[[:space:]])improvement($|[[:space:]]) ]]; then
    IMPROVEMENTS="${IMPROVEMENTS}${bullet}"$'\n'
  elif [[ "$labels_lc" =~ (^|[[:space:]])idea($|[[:space:]]) ]]; then
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

# Helper: truncate content to max chars (Discord embed description limit 4096)
truncate_content() {
  local content="$1"
  local max="${2:-4096}"
  printf '%s' "$content" | jq -Rs --argjson max "$max" 'if length > $max then .[0:$max] else . end'
}

# Helper: write a payload file with one or more embeds
write_payload() {
  local outfile="$1"
  local embeds_json="$2"
  jq -n \
    --arg user "HorizonSuite Issue Bot" \
    --arg avatar "https://github.githubassets.com/images/modules/logos_page/GitHub-Mark.png" \
    --argjson embeds "$embeds_json" \
    '{username: $user, avatar_url: $avatar, embeds: $embeds}' \
    > "$outfile"
  echo "Generated $outfile"
}

mkdir -p .release

# Remove old single-payload file if present
rm -f .release/discord-issuelog-payload.json

# Header embed (title, url, timestamp)
HEADER_EMBED=$(jq -n \
  --arg title "HorizonSuite — Open Issues" \
  --arg url "$REPO_URL/issues" \
  --argjson color $COLOR_HEADER \
  --arg ts "$TIMESTAMP" \
  '{title: $title, url: $url, color: $color, timestamp: $ts}')

# 1. Bugs: header + bugs embed (always post; header establishes context)
if [ -n "$BUGS" ]; then
  BUGS_DESC=$(truncate_content "$BUGS" 4096)
  BUGS_EMBED=$(jq -n \
    --arg name "🐛 Known Bugs" \
    --argjson desc "$BUGS_DESC" \
    --argjson color $COLOR_BUGS \
    '{title: $name, description: $desc, color: $color}')
  BUGS_EMBEDS=$(jq -n --argjson h "$HEADER_EMBED" --argjson b "$BUGS_EMBED" '[$h, $b]')
else
  BUGS_EMBEDS=$(jq -n --argjson h "$HEADER_EMBED" '[$h]')
fi
write_payload .release/discord-issuelog-payload-bugs.json "$BUGS_EMBEDS"

# 2. Features: one embed (only if non-empty)
if [ -n "$FEATURES" ]; then
  FEATURES_DESC=$(truncate_content "$FEATURES" 4096)
  FEATURES_EMBEDS=$(jq -n \
    --arg name "✨ Feature Requests" \
    --argjson desc "$FEATURES_DESC" \
    --argjson color $COLOR_FEATURES \
    '[{title: $name, description: $desc, color: $color}]')
  write_payload .release/discord-issuelog-payload-features.json "$FEATURES_EMBEDS"
else
  rm -f .release/discord-issuelog-payload-features.json
fi

# 3. Improvements: one embed (only if non-empty)
if [ -n "$IMPROVEMENTS" ]; then
  IMPROVEMENTS_DESC=$(truncate_content "$IMPROVEMENTS" 4096)
  IMPROVEMENTS_EMBEDS=$(jq -n \
    --arg name "🔧 Improvements" \
    --argjson desc "$IMPROVEMENTS_DESC" \
    --argjson color $COLOR_IMPROVEMENTS \
    '[{title: $name, description: $desc, color: $color}]')
  write_payload .release/discord-issuelog-payload-improvements.json "$IMPROVEMENTS_EMBEDS"
else
  rm -f .release/discord-issuelog-payload-improvements.json
fi

# 4. Ideas: one embed (only if non-empty)
if [ -n "$IDEAS" ]; then
  IDEAS_DESC=$(truncate_content "$IDEAS" 4096)
  IDEAS_EMBEDS=$(jq -n \
    --arg name "💡 Ideas" \
    --argjson desc "$IDEAS_DESC" \
    --argjson color $COLOR_IDEAS \
    '[{title: $name, description: $desc, color: $color}]')
  write_payload .release/discord-issuelog-payload-ideas.json "$IDEAS_EMBEDS"
else
  rm -f .release/discord-issuelog-payload-ideas.json
fi

# Show generated files
for f in .release/discord-issuelog-payload-*.json; do
  [ -f "$f" ] && cat "$f" | jq .
done
