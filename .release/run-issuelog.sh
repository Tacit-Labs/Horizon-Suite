#!/bin/bash
set -e
# Generates the Discord issue log payloads.
# Hero Message & Category Messages (Bugs / Features / Improvements) with an optional 'None'.
# Requires gh CLI and GITHUB_TOKEN (or gh auth).

# Output files:
#  .release/discord-issuelog-payload-....
#  ....hero.json
#  ....bugs.json
#  ....features.json
#  ....improvements.json
#  ....ideas.json
#  ....none.json (when applicable)

export GITHUB_REPOSITORY="${GITHUB_REPOSITORY:-Tacit-Labs/Horizon-Suite}"
REPO_URL="https://github.com/${GITHUB_REPOSITORY}"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

HORIZON_LOGO="https://raw.githubusercontent.com/Tacit-Labs/Horizon-Suite/main/assets/social/issuelog-logo.png"
AVATAR_URL="$HORIZON_LOGO"
USERNAME="Horizon Suite Issue Bot"

# --- Fetch open issues (auto-paginated via GraphQL) ---
# GraphQL is required because the REST endpoint used by `gh issue list --json` doesn't expose GitHub's Issue Types (Bug / Enhancement / ...).
OWNER="${GITHUB_REPOSITORY%/*}"
NAME="${GITHUB_REPOSITORY#*/}"
ISSUES_RAW=$(gh api graphql --paginate \
  -F owner="$OWNER" -F name="$NAME" \
  -f query="query($owner: String!, $name: String!, $endCursor: String) {
        repository(owner: $owner, name: $name) {
        issues(first: 100, states: OPEN, after: $endCursor) {
        pageInfo { hasNextPage endCursor }
        
        nodes {
        number title url body createdAt
        labels(first: 30) { nodes { name } }
        issueType { name }
      }
    }
  }
}" 2>&1)

# Flatten pages (each `gh --paginate` response is its own JSON doc) into a single array shaped like the old REST response, plus an `issueType` field.
ISSUES=$(printf '%s' "$ISSUES_RAW" | jq -s '[ .[].data.repository.issues.nodes[] | {
      number, title, url, body, createdAt,
      labels: [.labels.nodes[] | {name}],
      issueType: (.issueType.name // "") } ]' 2>&1)

if ! echo "$ISSUES" | jq -e 'type == "array"' >/dev/null 2>&1; then
  echo "Error: GraphQL open-issues fetch failed or returned unexpected shape." >&2
  echo "--- raw GraphQL output (first 1200 bytes) ---" >&2
  printf '%s' "$ISSUES_RAW" | head -c 1200 >&2
  echo "" >&2
  echo "--- transform output (first 1200 bytes) ---" >&2
  printf '%s' "$ISSUES" | head -c 1200 >&2
  echo "" >&2
  exit 1
fi
open_total=$(echo "$ISSUES" | jq 'length')
echo "Fetched ${open_total} open issue(s)"
now_s=$(date -u +%s)

# --- Per-category accumulators ---
count_bugs=""; count_features=""; count_improvements=""; count_none=""

declare -A MODULES

while IFS= read -r line; do
  [ -z "$line" ] && continue
  title=$(echo "$line" | jq -r '.title')
  url=$(echo "$line" | jq -r '.url')
  labels=$(echo "$line" | jq -r '.labels[].name' | tr '\n' ' ')
  labels_lc=$(echo "$labels" | tr '[:upper:]' '[:lower:]')
  issue_type=$(echo "$line" | jq -r '.issueType // ""')
  issue_type_lc=$(echo "$issue_type" | tr '[:upper:]' '[:lower:]')
  
  module=""
  if    [[ "$labels_lc" =~ \[Module\]\ Axis ]]; then module="Axis"
  elif [[ "$labels_lc" =~ \[Module\]\ Cache ]]; then module="Cache"
  elif [[ "$labels_lc" =~ \[Module\]\ Essence ]]; then module="Essence"
  elif [[ "$labels_lc" =~ \[Module\]\ Flow ]]; then module="Flow"
  elif [[ "$labels_lc" =~ \[Module\]\ Focus ]]; then module="Focus"
  elif [[ "$labels_lc" =~ \[Module\]\ Insight ]]; then module="Insight"
  elif [[ "$labels_lc" =~ \[Module\]\ Meridian ]]; then module="Meridian"
  elif [[ "$labels_lc" =~ \[Module\]\ Presence ]]; then module="Presence"
  elif [[ "$labels_lc" =~ \[Module\]\ Vista ]]; then module="Vista"
  fi

  # Priority glyph + rank
  prio=""
  prio_rank=5
  if    [[ "$labels_lc" =~ \[Priority\]\ Critical ]]       then prio="🔴 "; prio_rank=1
  elif [[ "$labels_lc" =~ \[Priority\]\ High ]]         then prio="🟠 "; prio_rank=2
  elif [[ "$labels_lc" =~ \[Priority\]\ Medium ]]    then prio="🟡 "; prio_rank=3
  elif [[ "$labels_lc" =~ \[Priority\]\ Low ]]          then prio="🟢 "; prio_rank=4
  else prio="👋 "; prio_rank=0
  fi

  created_at=$(echo "$line" | jq -r '.createdAt // ""')
  age_days=0
  if [ -n "$created_at" ]; then
    created_s=$(date -u -d "$created_at" +%s 2>/dev/null || echo "$now_s")
    age_days=$(( (now_s - created_s) / 86400 ))
  fi

  meta=""
  if  [ "$age_days" -gt 0 ];
  then meta=" \`${age_days}d\`"
  fi

  # Module shown via sub-heading.
  bullet="${prio}[${title}](${url})${meta}"

  # Group-by-module sort key.
  mod_key="${module:-Other}"
  sort_line=$(printf '%s\t%d\t%d\t%s' "$mod_key" "$prio_rank" "$age_days" "$bullet")

 # Classification precedence:
  #   1. GitHub Issue Type (Bug / Enhancement) — authoritative when set
  #   2. Module Labels
  #   3. No Category
  bucket=""
     if [ "$issue_type_lc" = "Bug" ]; then bucket="bugs"
        BUGS="${BUGS}${sort_line}"$'\n'
        count_bugs=$((count_bugs + 1))
  elif [ "$issue_type_lc" = "Feature" ]; then bucket="features"
        FEATURES="${FEATURES}${sort_line}"$'\n'
        count_features=$((count_features + 1))
  elif [ "$issue_type_lc" = "Improvement" ]; then bucket="improvements"
        IMPROVEMENTS="${IMPROVEMENTS}${sort_line}"$'\n'
        count_improvements=$((count_improvements + 1))
  else
    bucket="none"
    NONE="${NONE}${sort_line}"$'\n'
    count_none=$((count_none + 1))
  fi

  MODULES["$mod_key"]=$((${MODULES["$mod_key"]:-0} + 1))

done < <(echo "$ISSUES" | jq -c '.[]' 2>/dev/null || true)

# --- Progress bar (20 cells, proportional per category) ---
bar_cells=20
make_bar() {
  local cells="$1" filled_char="$2"
  local bar=""
  local i=0
  while [ "$i" -lt "$cells" ]; do bar="${bar}${filled_char}"; i=$((i + 1)); done
  while [ "$i" -lt "$bar_cells" ]; do bar="${bar}░"; i=$((i + 1)); done
  printf '%s' "$bar"
}
cells_for() {
  local n="$1"
  if [ "$total" -le 0 ] || [ "$n" -le 0 ]; then echo 0; return; fi
  local c=$(( (n * bar_cells + total / 2) / total ))
  [ "$c" -gt "$bar_cells" ] && c=$bar_cells
  echo "$c"
}
bug_cells=$(cells_for "$count_bugs")
feature_cells=$(cells_for "$count_features")
improvement_cells=$(cells_for "$count_improvements")
none_cells=$(cells_for "$count_none")

# Pad labels so the progress bar lines up inside the code block (monospaced).
# 'None' is only rendered when non-zero (keeps the normal view clean).
progress_block=$(printf \
  "Bugs          %s %3d\nFeatures      %s %3d\nImprovements  %s %3d"\
  "$(make_bar "$bug_cells" '█')" "$count_bugs" \
  "$(make_bar "$feature_cells" '█')" "$count_features" \
  "$(make_bar "$improvement_cells" '█')" "$count_improvements" )
if [ "$count_none" -gt 0 ];
then progress_block="${progress_block}"$'\n'"$(printf 'No Category %s %3d' "$(make_bar "$none_cells" '█')" "$count_none")"
fi

# --- Top modules (pill style) ---
module_pills=""
if [ ${#MODULES[@]} -gt 0 ]; then
  module_pills=$(
    for key in "${!MODULES[@]}"; do
      printf '%d\t%s\n' "${MODULES[$key]}" "$key"
    done | sort -rn | head -5 | awk -F'\t' '{printf "`%s·%s` ", $2, $1}'
  )
fi

HERO_DESC=$(printf "%s · **%d** open issues\n\n\n%s\n\n**This week**   \033[38;5;9m↗ \033[39m%d  \033[38;5;10m↘ \033[39m%d  \033[38;5;11m→ \033[39mNet %s\n")
if [ -n "$module_pills" ]; then
  HERO_DESC="${HERO_DESC}"$'\n'"**Prevalence** ${module_pills}"
fi

# --- Payload helpers ---
truncate_content() {
  local content="$1"
  local max="${2:-4096}"
  printf '%s' "$content" | jq -Rs --argjson max "$max" 'if length > $max then .[0:$max-1] + "…" else . end'
}

# Module display emoji — keeps sub-headings compact and branded.
module_emoji() {
  case "$1" in
    Axis)      printf '🌐' ;;
    Cache)     printf '🎒' ;;
    Essence)   printf '📜' ;;
    Flow)      printf '💬' ;;
    Focus)     printf '🎯' ;;
    Insight)   printf '🔍' ;;
    Meridian)  printf '🧭' ;;
    Presence)  printf '🎬' ;;
    Vista)     printf '🗺️' ;;
  esac
}

write_payload() {
  local outfile="$1"
  local embeds_json="$2"
  jq -n \
    --arg user "$USERNAME" \
    --arg avatar "$AVATAR_URL" \
    --argjson embeds "$embeds_json" \
    '{username: $user, avatar_url: $avatar, embeds: $embeds}' \
    > "$outfile"
  echo "Generated $outfile"
}

# Build a category's embed array — groups bullets under module sub-headings
# and spills into continuation embeds (no title) so all items are shown.
# Returns a JSON array of embed objects.
build_category_embeds() {
  local title="$1"
  local color="$2"
  local raw="$3"

  # 1. Rank modules by count (desc)
  local -A MOD_COUNT=()
  while IFS=$'\t' read -r mod _ _ _; do
    [ -z "$mod" ] && continue
    MOD_COUNT["$mod"]=$((${MOD_COUNT["$mod"]:-0} + 1))
  done < <(printf '%s' "$raw" | grep -v '^$')

  local mod_order
  mod_order=$(
    for key in "${!MOD_COUNT[@]}"; do
      local tier=0
      [ "$key" = "Other" ] && tier=1
      printf '%d\t%d\t%s\n' "$tier" "${MOD_COUNT[$key]}" "$key"
    done | sort -t$'\t' -k1,1n -k2,2rn -k3,3 | cut -f3-
  )

  local max=4000  # leaves slack under the 4096 hard cap
  local embeds_json='[]'
  local cur_desc=""
  local first=1

  flush_embed() {
    local is_last="$1"
    local embed
    if [ "$first" -eq 1 ]; then
      if [ "$is_last" -eq 1 ]; then
        embed=$(jq -n --arg title "$title" --argjson color "$color" --arg desc "$cur_desc" --arg ts "$TIMESTAMP" \
          '{title: $title, color: $color, description: $desc, timestamp: $ts}')
      else
        embed=$(jq -n --arg title "$title" --argjson color "$color" --arg desc "$cur_desc" \
          '{title: $title, color: $color, description: $desc}')
      fi
      first=0
    else
      if [ "$is_last" -eq 1 ]; then
        embed=$(jq -n --argjson color "$color" --arg desc "$cur_desc" --arg ts "$TIMESTAMP" \
          '{color: $color, description: $desc, timestamp: $ts}')
      else
        embed=$(jq -n --argjson color "$color" --arg desc "$cur_desc" \
          '{color: $color, description: $desc}')
      fi
    fi
    embeds_json=$(jq -n --argjson arr "$embeds_json" --argjson e "$embed" '$arr + [$e]')
    cur_desc=""
  }

  local mod
  while IFS= read -r mod; do
    [ -z "$mod" ] && continue
    local emoji
    emoji=$(module_emoji "$mod")
    local count="${MOD_COUNT[$mod]}"
    local header="**${emoji} ${mod}** · ${count}"$'\n'

    # Extract a module's bullets, sorted by priority then age.
    local bullets
    bullets=$(printf '%s' "$raw" | grep -v '^$' | awk -F'\t' -v m="$mod" '$1==m' | sort -t$'\t' -k2,2n -k3,3rn | cut -f4-)

    # Trailing blank line adds breathing room between modules in Discord's rendering.
    local block="${header}${bullets}"$'\n\n'
    if [ $(( ${#cur_desc} + ${#block} )) -le "$max" ];
    then cur_desc="${cur_desc}${block}"
      continue
    fi

    if [ -n "$cur_desc" ];
    then flush_embed 0
    fi

    if [ ${#block} -le "$max" ];
    then cur_desc="$block"
      continue
    fi

    cur_desc="$header"
    while IFS= read -r b; do
      [ -z "$b" ] && continue
      local line="${b}"$'\n'
      if [ $(( ${#cur_desc} + ${#line} )) -gt "$max" ];
      then flush_embed 0
      else
        cur_desc="${cur_desc}${line}"
      fi
    done <<< "$bullets"
  done <<< "$mod_order"

  [ -n "$cur_desc" ] && flush_embed 1

  # Discord allows up to 10 embeds per message.
  local n
  n=$(jq 'length' <<< "$embeds_json")
  if [ "$n" -gt 10 ]; then
    echo "Warning: ${title} exceeded 10 embeds (${n}); truncating to 10" >&2
    embeds_json=$(jq '.[0:10]' <<< "$embeds_json")
  fi
  printf '%s' "$embeds_json"
}

# --- Embed colors (decimal) ---
COLOR_BUGS=15548997         # red
COLOR_FEATURES=5763719      # green
COLOR_IMPROVEMENTS=3447003  # blue
COLOR_NONE=9807270         # slate gray

mkdir -p .release
rm -f .release/discord-issuelog-payload-*.json

# --- Hero payload (always emitted) ---
HERO_DESC_JSON=$(truncate_content "$HERO_DESC" 4096)
HERO_EMBED=$(jq -n \
  --arg title "HorizonSuite ▸ Open Issues" \
  --arg url "$REPO_URL/issues" \
  --argjson desc "$HERO_DESC_JSON" \
  --arg thumb "$HORIZON_LOGO" \
  --arg ts "$TIMESTAMP" \
  '{title: $title, url: $url, description: $desc, color: $color, thumbnail: {url: $thumb}, timestamp: $ts}')
HERO_EMBEDS=$(jq -n --argjson h "$HERO_EMBED" '[$h]')
write_payload .release/discord-issuelog-payload-hero.json "$HERO_EMBEDS"

if [ "$count_bugs" -gt 0 ];
then BUGS_EMBEDS=$(build_category_embeds "🐛 Bugs" "$COLOR_BUGS" "$BUGS" "$count_bugs")
write_payload .release/discord-issuelog-payload-bugs.json "$BUGS_EMBEDS"
fi

if [ "$count_features" -gt 0 ];
then FEATURES_EMBEDS=$(build_category_embeds "🎁 Features" "$COLOR_FEATURES" "$FEATURES" "$count_features")
  write_payload .release/discord-issuelog-payload-features.json "$FEATURES_EMBEDS"
fi

if [ "$count_improvements" -gt 0 ];
then IMPROVEMENTS_EMBEDS=$(build_category_embeds "💐 Improvements" "$COLOR_IMPROVEMENTS" "$IMPROVEMENTS" "$count_improvements")
  write_payload .release/discord-issuelog-payload-improvements.json "$IMPROVEMENTS_EMBEDS"
fi

if [ "$count_none" -gt 0 ];
then NONE_EMBEDS=$(build_category_embeds "🕵 No Category" "$COLOR_NONE" "$NONE" "$count_none")
  write_payload .release/discord-issuelog-payload-uncategorised.json "$NONE_EMBEDS"
fi

# Show generated files (helpful when running locally / in CI logs)
for f in .release/discord-issuelog-payload-*.json; do
  [ -f "$f" ] && jq . "$f"
done
