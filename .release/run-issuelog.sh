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
  batch=$(gh issue list --state open --json number,title,labels,body,url,createdAt,updatedAt,assignees --limit 100 --page "$page" 2>/dev/null || echo "[]")
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

# Stats accumulators (used to build the header description)
count_bugs=0
count_features=0
count_improvements=0
count_ideas=0
declare -A MODULES

# Timestamp for age / staleness math (evaluated once, not per-issue)
now_s=$(date -u +%s)

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

  # Determine priority glyph + rank (rank used for sort ordering within bucket)
  prio=""
  prio_rank=4
  if [[ "$labels_lc" =~ \[priority\]\ critical ]] || [[ "$labels_lc" =~ (^|[[:space:]])p0($|[[:space:]]) ]] || [[ "$labels_lc" =~ (^|[[:space:]])critical($|[[:space:]]) ]]; then
    prio="🔴 "; prio_rank=0
  elif [[ "$labels_lc" =~ \[priority\]\ high ]] || [[ "$labels_lc" =~ (^|[[:space:]])p1($|[[:space:]]) ]] || [[ "$labels_lc" =~ (^|[[:space:]])high($|[[:space:]]) ]]; then
    prio="🟠 "; prio_rank=1
  elif [[ "$labels_lc" =~ \[priority\]\ medium ]] || [[ "$labels_lc" =~ (^|[[:space:]])p2($|[[:space:]]) ]] || [[ "$labels_lc" =~ (^|[[:space:]])medium($|[[:space:]]) ]]; then
    prio="🟡 "; prio_rank=2
  elif [[ "$labels_lc" =~ \[priority\]\ low ]] || [[ "$labels_lc" =~ (^|[[:space:]])p3($|[[:space:]]) ]] || [[ "$labels_lc" =~ (^|[[:space:]])low($|[[:space:]]) ]]; then
    prio="🟢 "; prio_rank=3
  fi

  # Age (days since createdAt) and stale marker (>30d since updatedAt)
  created_at=$(echo "$line" | jq -r '.createdAt // ""')
  updated_at=$(echo "$line" | jq -r '.updatedAt // ""')
  assignee=$(echo "$line" | jq -r '.assignees[0].login // ""')

  age_days=0
  if [ -n "$created_at" ]; then
    created_s=$(date -u -d "$created_at" +%s 2>/dev/null || echo "$now_s")
    age_days=$(( (now_s - created_s) / 86400 ))
  fi
  stale=""
  if [ -n "$updated_at" ]; then
    updated_s=$(date -u -d "$updated_at" +%s 2>/dev/null || echo "$now_s")
    if [ $(( (now_s - updated_s) / 86400 )) -gt 30 ]; then
      stale="⏳ "
    fi
  fi

  # Meta suffix: "(42d, @handle)" — omit parts that are unavailable
  meta=""
  if [ "$age_days" -gt 0 ] && [ -n "$assignee" ]; then
    meta=" (${age_days}d, @${assignee})"
  elif [ "$age_days" -gt 0 ]; then
    meta=" (${age_days}d)"
  elif [ -n "$assignee" ]; then
    meta=" (@${assignee})"
  fi

  # Extract ### Description section from body (text between ### Description and next ###)
  desc=$(printf '%s' "$body" | awk '
    /^### Description/ { found=1; next }
    found && /^###/    { exit }
    found              { print }
  ' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | tr -s ' \n' ' ' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

  # Remove residual markdown: bold, italic, code, links
  desc=$(printf '%s' "$desc" | sed 's/\*\*//g; s/\*//g; s/`//g; s/\[//g; s/\]([^)]*)//g')

  # Truncate to 90 chars (shrunk from 120 to make room for enrichments)
  if [ ${#desc} -gt 90 ]; then
    desc="${desc:0:90}…"
  fi

  # Build bullet line
  if [ -n "$desc" ]; then
    bullet="• ${prio}${stale}${module}[${title}](${url}) — ${desc}${meta}"
  else
    bullet="• ${prio}${stale}${module}[${title}](${url})${meta}"
  fi

  # Sort-key-prefixed line: <prio_rank>\t<age_days>\t<bullet>
  # Later sorted with -k1,1n -k2,2rn so most-urgent + oldest survive truncation.
  sort_line=$(printf '%d\t%d\t%s' "$prio_rank" "$age_days" "$bullet")

  # Track module tallies for header stats (only for issues that land in a bucket)
  module_key="${module:-[Other] }"

  # Route to bucket: legacy GitHub labels (bug, feature, …) or GitLab-parity [Enhancement] …
  if [[ "$labels_lc" =~ (^|[[:space:]])bug($|[[:space:]]) ]]; then
    BUGS="${BUGS}${sort_line}"$'\n'
    count_bugs=$((count_bugs + 1))
    MODULES["$module_key"]=$((${MODULES["$module_key"]:-0} + 1))
  elif [[ "$labels_lc" =~ \[enhancement\]\ feature ]] || [[ "$labels_lc" =~ (^|[[:space:]])feature($|[[:space:]]) ]]; then
    FEATURES="${FEATURES}${sort_line}"$'\n'
    count_features=$((count_features + 1))
    MODULES["$module_key"]=$((${MODULES["$module_key"]:-0} + 1))
  elif [[ "$labels_lc" =~ \[enhancement\]\ improvement ]] || [[ "$labels_lc" =~ \[enhancement\]\ localization ]] || [[ "$labels_lc" =~ (^|[[:space:]])improvement($|[[:space:]]) ]]; then
    IMPROVEMENTS="${IMPROVEMENTS}${sort_line}"$'\n'
    count_improvements=$((count_improvements + 1))
    MODULES["$module_key"]=$((${MODULES["$module_key"]:-0} + 1))
  elif [[ "$labels_lc" =~ (^|[[:space:]])idea($|[[:space:]]) ]]; then
    IDEAS="${IDEAS}${sort_line}"$'\n'
    count_ideas=$((count_ideas + 1))
    MODULES["$module_key"]=$((${MODULES["$module_key"]:-0} + 1))
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

# Helper: assemble a bucket's embed description from sort-key-prefixed lines.
# Sorts by priority (asc) then age (desc), strips prefix, caps cumulative length
# at 3900 chars, and appends a "… and N more" tail link when truncated.
# Usage: build_bucket_desc <raw_lines> <total_count>
build_bucket_desc() {
  local raw="$1"
  local total="$2"
  local max=3900
  local desc=""
  local shown=0
  local sorted
  sorted=$(printf '%s' "$raw" | grep -v '^$' | sort -t$'\t' -k1,1n -k2,2rn | cut -f3-)
  while IFS= read -r bullet; do
    [ -z "$bullet" ] && continue
    if [ $(( ${#desc} + ${#bullet} + 1 )) -gt "$max" ]; then
      break
    fi
    desc="${desc}${bullet}"$'\n'
    shown=$((shown + 1))
  done <<< "$sorted"
  local remaining=$((total - shown))
  if [ "$remaining" -gt 0 ]; then
    desc="${desc}• … and ${remaining} more — see [all open issues](${REPO_URL}/issues)"
  fi
  printf '%s' "$desc"
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

# Build header stats line: bucket totals + top modules
total=$((count_bugs + count_features + count_improvements + count_ideas))
HEADER_DESC="Bugs: ${count_bugs} · Features: ${count_features} · Improvements: ${count_improvements} · Ideas: ${count_ideas} · Total: ${total}"

if [ ${#MODULES[@]} -gt 0 ]; then
  top_modules=$(
    for key in "${!MODULES[@]}"; do
      v=${MODULES[$key]}
      # Strip "[" prefix and "] ..." suffix → bare module name (e.g. "[Focus] " → "Focus")
      k=${key#[}
      k=${k%%]*}
      [ -z "$k" ] && k="Other"
      printf '%d\t%s\n' "$v" "$k"
    done | sort -rn | head -5 | awk -F'\t' 'BEGIN{s=""} {if(s)s=s", "; s=s $2 " " $1} END{print s}'
  )
  if [ -n "$top_modules" ]; then
    HEADER_DESC="${HEADER_DESC}"$'\n'"Top modules: ${top_modules}"
  fi
fi

# Header embed (title, url, stats, timestamp)
HEADER_EMBED=$(jq -n \
  --arg title "HorizonSuite — Open Issues" \
  --arg url "$REPO_URL/issues" \
  --arg desc "$HEADER_DESC" \
  --argjson color $COLOR_HEADER \
  --arg ts "$TIMESTAMP" \
  '{title: $title, url: $url, description: $desc, color: $color, timestamp: $ts}')

# 1. Bugs: header + bugs embed (always post; header establishes context)
if [ -n "$BUGS" ]; then
  BUGS_DESC=$(truncate_content "$(build_bucket_desc "$BUGS" "$count_bugs")" 4096)
  BUGS_EMBED=$(jq -n \
    --arg name "🐛 Known Bugs" \
    --argjson desc "$BUGS_DESC" \
    --argjson color $COLOR_BUGS \
    --arg footer "${count_bugs} issue(s)" \
    '{title: $name, description: $desc, color: $color, footer: {text: $footer}}')
  BUGS_EMBEDS=$(jq -n --argjson h "$HEADER_EMBED" --argjson b "$BUGS_EMBED" '[$h, $b]')
else
  BUGS_EMBEDS=$(jq -n --argjson h "$HEADER_EMBED" '[$h]')
fi
write_payload .release/discord-issuelog-payload-bugs.json "$BUGS_EMBEDS"

# 2. Features: one embed (only if non-empty)
if [ -n "$FEATURES" ]; then
  FEATURES_DESC=$(truncate_content "$(build_bucket_desc "$FEATURES" "$count_features")" 4096)
  FEATURES_EMBEDS=$(jq -n \
    --arg name "✨ Feature Requests" \
    --argjson desc "$FEATURES_DESC" \
    --argjson color $COLOR_FEATURES \
    --arg footer "${count_features} issue(s)" \
    '[{title: $name, description: $desc, color: $color, footer: {text: $footer}}]')
  write_payload .release/discord-issuelog-payload-features.json "$FEATURES_EMBEDS"
else
  rm -f .release/discord-issuelog-payload-features.json
fi

# 3. Improvements: one embed (only if non-empty)
if [ -n "$IMPROVEMENTS" ]; then
  IMPROVEMENTS_DESC=$(truncate_content "$(build_bucket_desc "$IMPROVEMENTS" "$count_improvements")" 4096)
  IMPROVEMENTS_EMBEDS=$(jq -n \
    --arg name "🔧 Improvements" \
    --argjson desc "$IMPROVEMENTS_DESC" \
    --argjson color $COLOR_IMPROVEMENTS \
    --arg footer "${count_improvements} issue(s)" \
    '[{title: $name, description: $desc, color: $color, footer: {text: $footer}}]')
  write_payload .release/discord-issuelog-payload-improvements.json "$IMPROVEMENTS_EMBEDS"
else
  rm -f .release/discord-issuelog-payload-improvements.json
fi

# 4. Ideas: one embed (only if non-empty)
if [ -n "$IDEAS" ]; then
  IDEAS_DESC=$(truncate_content "$(build_bucket_desc "$IDEAS" "$count_ideas")" 4096)
  IDEAS_EMBEDS=$(jq -n \
    --arg name "💡 Ideas" \
    --argjson desc "$IDEAS_DESC" \
    --argjson color $COLOR_IDEAS \
    --arg footer "${count_ideas} issue(s)" \
    '[{title: $name, description: $desc, color: $color, footer: {text: $footer}}]')
  write_payload .release/discord-issuelog-payload-ideas.json "$IDEAS_EMBEDS"
else
  rm -f .release/discord-issuelog-payload-ideas.json
fi

# Show generated files
for f in .release/discord-issuelog-payload-*.json; do
  [ -f "$f" ] && cat "$f" | jq .
done
