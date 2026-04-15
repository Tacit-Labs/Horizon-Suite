#!/bin/bash
set -e
# Parallel v2 of run-issuelog.sh — generates a redesigned Discord issue log.
# Posts a Hero message (always) plus four category messages (Bugs / Features /
# Improvements / Ideas). Lives alongside v1 so both can run independently while
# the redesign is iterated on. Requires gh CLI and GITHUB_TOKEN (or gh auth).
#
# Output files:
#   .release/discord-issuelog-v2-payload-hero.json
#   .release/discord-issuelog-v2-payload-bugs.json
#   .release/discord-issuelog-v2-payload-features.json
#   .release/discord-issuelog-v2-payload-improvements.json
#   .release/discord-issuelog-v2-payload-ideas.json
#
# Design goals (see branch description):
#   1. Visual polish   — logo thumbnail, health-colored hero, progress bar, pill tags
#   2. Urgency signal  — spotlight + Critical/High vs Other split + stale/assigned counts
#   3. Momentum        — weekly new / closed / net delta

export GITHUB_REPOSITORY="${GITHUB_REPOSITORY:-Tacit-Labs/Horizon-Suite}"
REPO_URL="https://github.com/${GITHUB_REPOSITORY}"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
DATE_HUMAN=$(date -u +"%b %-d, %Y")

# Horizon logo thumbnail: GitHub serves org avatars from this URL.
# Swap for a dedicated asset later by editing this single constant.
HORIZON_LOGO="https://github.com/Tacit-Labs.png"
AVATAR_URL="$HORIZON_LOGO"
USERNAME="HorizonSuite Issue Bot"

# --- Fetch open issues (auto-paginated) ---
ISSUES=$(gh issue list --state open --json number,title,labels,body,url,createdAt,updatedAt,assignees --limit 1000 2>&1)
if ! echo "$ISSUES" | jq empty >/dev/null 2>&1; then
  echo "Error: gh issue list (open) failed or returned non-JSON:" >&2
  echo "$ISSUES" | head -c 1200 >&2
  exit 1
fi
open_total=$(echo "$ISSUES" | jq 'length')
echo "Fetched ${open_total} open issue(s)"

# --- Fetch all issues updated in the last 14 days (for weekly momentum math) ---
# We ask for state=all and a generous cap; we'll filter by timestamp ourselves.
RECENT=$(gh issue list --state all --json number,title,state,createdAt,closedAt,labels --limit 500 --search "updated:>=$(date -u -d '14 days ago' +%Y-%m-%d)" 2>&1 || echo '[]')
if ! echo "$RECENT" | jq empty >/dev/null 2>&1; then
  echo "Warning: recent issue fetch failed — momentum counts will be zero" >&2
  RECENT='[]'
fi

# --- Shared timestamps ---
now_s=$(date -u +%s)
week_ago_s=$((now_s - 7 * 86400))

# --- Weekly momentum ---
week_new=$(echo "$RECENT" | jq --argjson cutoff "$week_ago_s" '[.[] | select((.createdAt // "" | if . == "" then 0 else (. | fromdateiso8601) end) >= $cutoff)] | length')
week_closed=$(echo "$RECENT" | jq --argjson cutoff "$week_ago_s" '[.[] | select(.state == "CLOSED" and (.closedAt // "" | if . == "" then 0 else (. | fromdateiso8601) end) >= $cutoff)] | length')
week_net=$((week_new - week_closed))
if [ "$week_net" -gt 0 ]; then
  week_arrow="↗ +${week_net}"
elif [ "$week_net" -lt 0 ]; then
  week_arrow="↘ ${week_net}"
else
  week_arrow="→ 0"
fi

# --- Per-category accumulators ---
BUGS_CRIT=""; BUGS_OTHER=""
FEATURES_CRIT=""; FEATURES_OTHER=""
IMPROVEMENTS_CRIT=""; IMPROVEMENTS_OTHER=""
IDEAS_CRIT=""; IDEAS_OTHER=""

count_bugs=0; count_features=0; count_improvements=0; count_ideas=0
stale_bugs=0; stale_features=0; stale_improvements=0; stale_ideas=0
assigned_bugs=0; assigned_features=0; assigned_improvements=0; assigned_ideas=0

declare -A MODULES

# Spotlight tracking: highest-severity, oldest issue
spot_rank=9
spot_age=-1
spot_title=""
spot_url=""
spot_module=""
spot_prio=""
spot_assignee=""

while IFS= read -r line; do
  [ -z "$line" ] && continue
  num=$(echo "$line" | jq -r '.number')
  title=$(echo "$line" | jq -r '.title')
  url=$(echo "$line" | jq -r '.url')
  labels=$(echo "$line" | jq -r '.labels[].name' | tr '\n' ' ')
  labels_lc=$(echo "$labels" | tr '[:upper:]' '[:lower:]')
  body=$(echo "$line" | jq -r '.body // ""')

  # Module tag (matches v1 detection)
  module=""
  if [[ "$labels_lc" =~ \[module\]\ focus ]]; then module="Focus"
  elif [[ "$labels_lc" =~ \[module\]\ presence ]]; then module="Presence"
  elif [[ "$labels_lc" =~ \[module\]\ axis ]] || [[ "$labels_lc" =~ \[module\]\ core ]]; then module="Core"
  elif [[ "$labels_lc" =~ \[module\]\ vista ]]; then module="Vista"
  elif [[ "$labels_lc" =~ \[module\]\ cache ]]; then module="Cache"
  elif [[ "$labels_lc" =~ \[module\]\ pulse ]]; then module="Pulse"
  elif [[ "$labels_lc" =~ \[module\]\ insight ]]; then module="Insight"
  elif [[ "$labels_lc" =~ \[module\]\ verse ]]; then module="Verse"
  elif [[ "$labels_lc" =~ \[module\]\ essence ]]; then module="Essence"
  elif [[ "$labels_lc" =~ \[module\]\ flow ]]; then module="Flow"
  elif [[ "$labels_lc" =~ (^|[[:space:]])focus($|[[:space:]]) ]]; then module="Focus"
  elif [[ "$labels_lc" =~ (^|[[:space:]])presence($|[[:space:]]) ]]; then module="Presence"
  elif [[ "$labels_lc" =~ (^|[[:space:]])core($|[[:space:]]) ]]; then module="Core"
  elif [[ "$labels_lc" =~ (^|[[:space:]])vista($|[[:space:]]) ]]; then module="Vista"
  elif [[ "$labels_lc" =~ (^|[[:space:]])cache($|[[:space:]]) ]]; then module="Cache"
  elif [[ "$labels_lc" =~ (^|[[:space:]])pulse($|[[:space:]]) ]]; then module="Pulse"
  elif [[ "$labels_lc" =~ (^|[[:space:]])insight($|[[:space:]]) ]]; then module="Insight"
  elif [[ "$labels_lc" =~ (^|[[:space:]])verse($|[[:space:]]) ]]; then module="Verse"
  fi
  module_pill=""
  [ -n "$module" ] && module_pill="\`${module}\` "

  # Priority glyph + rank
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

  created_at=$(echo "$line" | jq -r '.createdAt // ""')
  updated_at=$(echo "$line" | jq -r '.updatedAt // ""')
  assignee=$(echo "$line" | jq -r '.assignees[0].login // ""')

  age_days=0
  if [ -n "$created_at" ]; then
    created_s=$(date -u -d "$created_at" +%s 2>/dev/null || echo "$now_s")
    age_days=$(( (now_s - created_s) / 86400 ))
  fi
  is_stale=0
  stale=""
  if [ -n "$updated_at" ]; then
    updated_s=$(date -u -d "$updated_at" +%s 2>/dev/null || echo "$now_s")
    if [ $(( (now_s - updated_s) / 86400 )) -gt 30 ]; then
      stale="⏳ "
      is_stale=1
    fi
  fi

  meta=""
  if [ "$age_days" -gt 0 ] && [ -n "$assignee" ]; then
    meta=" \`${age_days}d · @${assignee}\`"
  elif [ "$age_days" -gt 0 ]; then
    meta=" \`${age_days}d\`"
  elif [ -n "$assignee" ]; then
    meta=" \`@${assignee}\`"
  fi

  # Build the bullet — shorter than v1 since we split across fields and field
  # value cap is 1024. Drop body excerpt; lean on title + module + meta.
  bullet="• ${prio}${stale}${module_pill}[${title}](${url})${meta}"

  sort_line=$(printf '%d\t%d\t%s' "$prio_rank" "$age_days" "$bullet")
  critical=0
  [ "$prio_rank" -le 1 ] && critical=1

  # Route to bucket
  bucket=""
  if [[ "$labels_lc" =~ (^|[[:space:]])bug($|[[:space:]]) ]]; then
    bucket="bugs"
    if [ "$critical" -eq 1 ]; then BUGS_CRIT="${BUGS_CRIT}${sort_line}"$'\n'; else BUGS_OTHER="${BUGS_OTHER}${sort_line}"$'\n'; fi
    count_bugs=$((count_bugs + 1))
    [ "$is_stale" -eq 1 ] && stale_bugs=$((stale_bugs + 1))
    [ -n "$assignee" ] && assigned_bugs=$((assigned_bugs + 1))
  elif [[ "$labels_lc" =~ \[enhancement\]\ feature ]] || [[ "$labels_lc" =~ (^|[[:space:]])feature($|[[:space:]]) ]]; then
    bucket="features"
    if [ "$critical" -eq 1 ]; then FEATURES_CRIT="${FEATURES_CRIT}${sort_line}"$'\n'; else FEATURES_OTHER="${FEATURES_OTHER}${sort_line}"$'\n'; fi
    count_features=$((count_features + 1))
    [ "$is_stale" -eq 1 ] && stale_features=$((stale_features + 1))
    [ -n "$assignee" ] && assigned_features=$((assigned_features + 1))
  elif [[ "$labels_lc" =~ \[enhancement\]\ improvement ]] || [[ "$labels_lc" =~ \[enhancement\]\ localization ]] || [[ "$labels_lc" =~ (^|[[:space:]])improvement($|[[:space:]]) ]]; then
    bucket="improvements"
    if [ "$critical" -eq 1 ]; then IMPROVEMENTS_CRIT="${IMPROVEMENTS_CRIT}${sort_line}"$'\n'; else IMPROVEMENTS_OTHER="${IMPROVEMENTS_OTHER}${sort_line}"$'\n'; fi
    count_improvements=$((count_improvements + 1))
    [ "$is_stale" -eq 1 ] && stale_improvements=$((stale_improvements + 1))
    [ -n "$assignee" ] && assigned_improvements=$((assigned_improvements + 1))
  elif [[ "$labels_lc" =~ (^|[[:space:]])idea($|[[:space:]]) ]]; then
    bucket="ideas"
    if [ "$critical" -eq 1 ]; then IDEAS_CRIT="${IDEAS_CRIT}${sort_line}"$'\n'; else IDEAS_OTHER="${IDEAS_OTHER}${sort_line}"$'\n'; fi
    count_ideas=$((count_ideas + 1))
    [ "$is_stale" -eq 1 ] && stale_ideas=$((stale_ideas + 1))
    [ -n "$assignee" ] && assigned_ideas=$((assigned_ideas + 1))
  fi

  if [ -n "$bucket" ]; then
    mod_key="${module:-Other}"
    MODULES["$mod_key"]=$((${MODULES["$mod_key"]:-0} + 1))

    # Spotlight: pick the lowest prio_rank, tie-break by age_days desc
    if [ "$prio_rank" -lt "$spot_rank" ] || { [ "$prio_rank" -eq "$spot_rank" ] && [ "$age_days" -gt "$spot_age" ]; }; then
      spot_rank=$prio_rank
      spot_age=$age_days
      spot_title="$title"
      spot_url="$url"
      spot_module="$module"
      spot_prio="$prio"
      spot_assignee="$assignee"
    fi
  fi

done < <(echo "$ISSUES" | jq -c '.[]' 2>/dev/null || true)

# --- Embed colors (decimal) ---
COLOR_BUGS=15548997         # red
COLOR_FEATURES=5763719      # green
COLOR_IMPROVEMENTS=3447003  # blue
COLOR_IDEAS=16776960        # yellow
COLOR_HEALTH_GREEN=5763719
COLOR_HEALTH_YELLOW=16776960
COLOR_HEALTH_ORANGE=15105570
COLOR_HEALTH_RED=15548997

# --- Health color based on total open ---
total=$((count_bugs + count_features + count_improvements + count_ideas))
if [ "$count_bugs" -ge 15 ] || [ "$total" -ge 80 ]; then
  health_color=$COLOR_HEALTH_RED
  health_label="🔴 Needs attention"
elif [ "$count_bugs" -ge 8 ] || [ "$total" -ge 50 ]; then
  health_color=$COLOR_HEALTH_ORANGE
  health_label="🟠 Elevated load"
elif [ "$count_bugs" -ge 3 ] || [ "$total" -ge 20 ]; then
  health_color=$COLOR_HEALTH_YELLOW
  health_label="🟡 Steady"
else
  health_color=$COLOR_HEALTH_GREEN
  health_label="🟢 Healthy"
fi

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
b_cells=$(cells_for "$count_bugs")
f_cells=$(cells_for "$count_features")
i_cells=$(cells_for "$count_improvements")
d_cells=$(cells_for "$count_ideas")

# Pad labels so the progress bar lines up inside the code block (monospaced).
progress_block=$(printf 'Bugs          %s %3d\nFeatures      %s %3d\nImprovements  %s %3d\nIdeas         %s %3d' \
  "$(make_bar "$b_cells" '█')" "$count_bugs" \
  "$(make_bar "$f_cells" '█')" "$count_features" \
  "$(make_bar "$i_cells" '█')" "$count_improvements" \
  "$(make_bar "$d_cells" '█')" "$count_ideas")

# --- Top modules (pill style) ---
module_pills=""
if [ ${#MODULES[@]} -gt 0 ]; then
  module_pills=$(
    for key in "${!MODULES[@]}"; do
      printf '%d\t%s\n' "${MODULES[$key]}" "$key"
    done | sort -rn | head -5 | awk -F'\t' '{printf "`%s·%s` ", $2, $1}'
  )
fi

# --- Spotlight block ---
spotlight=""
if [ -n "$spot_title" ]; then
  spot_meta=""
  if [ "$spot_age" -gt 0 ] && [ -n "$spot_assignee" ]; then
    spot_meta=" — ${spot_age}d old, @${spot_assignee}"
  elif [ "$spot_age" -gt 0 ]; then
    spot_meta=" — ${spot_age}d old, unassigned"
  elif [ -n "$spot_assignee" ]; then
    spot_meta=" — @${spot_assignee}"
  fi
  spot_mod_pill=""
  [ -n "$spot_module" ] && spot_mod_pill="\`${spot_module}\` "
  spotlight="🔥 **Spotlight** — ${spot_prio}${spot_mod_pill}[${spot_title}](${spot_url})${spot_meta}"
fi

# --- Compose hero description ---
HERO_DESC=$(printf '%s · **%d** open issues\n\n```\n%s\n```\n📈 **This week** — ↗ %d new · ↘ %d closed · %s net\n' \
  "$health_label" "$total" "$progress_block" "$week_new" "$week_closed" "$week_arrow")
if [ -n "$module_pills" ]; then
  HERO_DESC="${HERO_DESC}"$'\n'"**Top modules** ${module_pills}"
fi
if [ -n "$spotlight" ]; then
  HERO_DESC="${HERO_DESC}"$'\n\n'"${spotlight}"
fi

# --- Payload helpers ---
truncate_content() {
  local content="$1"
  local max="${2:-4096}"
  printf '%s' "$content" | jq -Rs --argjson max "$max" 'if length > $max then .[0:$max-1] + "…" else . end'
}

# Build a field value from a sort-prefixed bucket chunk, capped at 1000 chars
# (Discord field limit is 1024; leave slack for the "… and N more" tail).
build_field_value() {
  local raw="$1"
  local total_in="$2"
  local max=1000
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
  local remaining=$((total_in - shown))
  if [ "$remaining" -gt 0 ]; then
    desc="${desc}• … and ${remaining} more"
  fi
  [ -z "$desc" ] && desc="_None_"
  printf '%s' "$desc"
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

# Build one category embed: returns JSON for a single embed with fields.
build_category_embed() {
  local title="$1"
  local color="$2"
  local crit_raw="$3"
  local other_raw="$4"
  local total_in="$5"
  local stale_in="$6"
  local assigned_in="$7"

  local crit_count=0
  local other_count=0
  crit_count=$(printf '%s' "$crit_raw" | grep -c '^.' || true)
  other_count=$(printf '%s' "$other_raw" | grep -c '^.' || true)

  local crit_value other_value
  crit_value=$(build_field_value "$crit_raw" "$crit_count")
  other_value=$(build_field_value "$other_raw" "$other_count")

  local footer_parts=""
  footer_parts="${total_in} open"
  [ "$stale_in" -gt 0 ] && footer_parts="${footer_parts} · ${stale_in} stale"
  [ "$assigned_in" -gt 0 ] && footer_parts="${footer_parts} · ${assigned_in} assigned"

  jq -n \
    --arg title "$title" \
    --argjson color "$color" \
    --arg crit "$crit_value" \
    --arg other "$other_value" \
    --arg footer "$footer_parts" \
    --arg ts "$TIMESTAMP" \
    '{
      title: $title,
      color: $color,
      fields: [
        {name: "🚨 Critical & High", value: $crit, inline: false},
        {name: "📋 Other", value: $other, inline: false}
      ],
      footer: {text: $footer},
      timestamp: $ts
    }'
}

mkdir -p .release

# Clean stale v2 payloads so empty categories don't linger
rm -f .release/discord-issuelog-v2-payload-*.json

# --- Hero payload (always emitted) ---
HERO_DESC_JSON=$(truncate_content "$HERO_DESC" 4096)
HERO_EMBED=$(jq -n \
  --arg title "HorizonSuite — Open Issues" \
  --arg url "$REPO_URL/issues" \
  --argjson desc "$HERO_DESC_JSON" \
  --argjson color "$health_color" \
  --arg thumb "$HORIZON_LOGO" \
  --arg footer "Auto-updated · ${DATE_HUMAN}" \
  --arg ts "$TIMESTAMP" \
  '{title: $title, url: $url, description: $desc, color: $color, thumbnail: {url: $thumb}, footer: {text: $footer}, timestamp: $ts}')
HERO_EMBEDS=$(jq -n --argjson h "$HERO_EMBED" '[$h]')
write_payload .release/discord-issuelog-v2-payload-hero.json "$HERO_EMBEDS"

# --- Bugs (posted even when empty so readers see a "zero bugs" status) ---
BUGS_EMBED=$(build_category_embed "🐛 Known Bugs" "$COLOR_BUGS" "$BUGS_CRIT" "$BUGS_OTHER" "$count_bugs" "$stale_bugs" "$assigned_bugs")
write_payload .release/discord-issuelog-v2-payload-bugs.json "$(jq -n --argjson b "$BUGS_EMBED" '[$b]')"

# --- Features ---
if [ "$count_features" -gt 0 ]; then
  FEATURES_EMBED=$(build_category_embed "✨ Feature Requests" "$COLOR_FEATURES" "$FEATURES_CRIT" "$FEATURES_OTHER" "$count_features" "$stale_features" "$assigned_features")
  write_payload .release/discord-issuelog-v2-payload-features.json "$(jq -n --argjson b "$FEATURES_EMBED" '[$b]')"
fi

# --- Improvements ---
if [ "$count_improvements" -gt 0 ]; then
  IMPROVEMENTS_EMBED=$(build_category_embed "🔧 Improvements" "$COLOR_IMPROVEMENTS" "$IMPROVEMENTS_CRIT" "$IMPROVEMENTS_OTHER" "$count_improvements" "$stale_improvements" "$assigned_improvements")
  write_payload .release/discord-issuelog-v2-payload-improvements.json "$(jq -n --argjson b "$IMPROVEMENTS_EMBED" '[$b]')"
fi

# --- Ideas ---
if [ "$count_ideas" -gt 0 ]; then
  IDEAS_EMBED=$(build_category_embed "💡 Ideas" "$COLOR_IDEAS" "$IDEAS_CRIT" "$IDEAS_OTHER" "$count_ideas" "$stale_ideas" "$assigned_ideas")
  write_payload .release/discord-issuelog-v2-payload-ideas.json "$(jq -n --argjson b "$IDEAS_EMBED" '[$b]')"
fi

# Show generated files (helpful when running locally / in CI logs)
for f in .release/discord-issuelog-v2-payload-*.json; do
  [ -f "$f" ] && jq . "$f"
done
