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
#   2. Urgency signal  — spotlight + priority glyphs + stale/assigned counts
#   3. Momentum        — weekly new / closed / net delta
#
# Category layout: bullets are grouped under module sub-headings in a single
# embed description. When a description approaches the 4096-char cap we spill
# into a continuation embed (Discord allows up to 10 embeds per message), so
# every item is shown — no "… and N more" tail.

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
# Each line is tab-separated: <module>\t<prio_rank>\t<age_days>\t<bullet>
# Grouped by module at render time.
BUGS=""; FEATURES=""; IMPROVEMENTS=""; IDEAS=""; UNCATEGORIZED=""

count_bugs=0; count_features=0; count_improvements=0; count_ideas=0; count_uncategorized=0
stale_bugs=0; stale_features=0; stale_improvements=0; stale_ideas=0; stale_uncategorized=0
assigned_bugs=0; assigned_features=0; assigned_improvements=0; assigned_ideas=0; assigned_uncategorized=0

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

  # Build the bullet — module shown via sub-heading, so we drop it from the
  # per-line pill. Title + priority glyph + stale marker + meta is enough.
  bullet="• ${prio}${stale}[${title}](${url})${meta}"

  # Group-by-module sort key. Render order within a module: priority asc, age desc.
  mod_key="${module:-Other}"
  sort_line=$(printf '%s\t%d\t%d\t%s' "$mod_key" "$prio_rank" "$age_days" "$bullet")

  bucket=""
  if [[ "$labels_lc" =~ (^|[[:space:]])bug($|[[:space:]]) ]]; then
    bucket="bugs"
    BUGS="${BUGS}${sort_line}"$'\n'
    count_bugs=$((count_bugs + 1))
    [ "$is_stale" -eq 1 ] && stale_bugs=$((stale_bugs + 1))
    [ -n "$assignee" ] && assigned_bugs=$((assigned_bugs + 1))
  elif [[ "$labels_lc" =~ \[enhancement\]\ feature ]] || [[ "$labels_lc" =~ (^|[[:space:]])feature($|[[:space:]]) ]]; then
    bucket="features"
    FEATURES="${FEATURES}${sort_line}"$'\n'
    count_features=$((count_features + 1))
    [ "$is_stale" -eq 1 ] && stale_features=$((stale_features + 1))
    [ -n "$assignee" ] && assigned_features=$((assigned_features + 1))
  elif [[ "$labels_lc" =~ \[enhancement\]\ improvement ]] || [[ "$labels_lc" =~ \[enhancement\]\ localization ]] || [[ "$labels_lc" =~ (^|[[:space:]])improvement($|[[:space:]]) ]]; then
    bucket="improvements"
    IMPROVEMENTS="${IMPROVEMENTS}${sort_line}"$'\n'
    count_improvements=$((count_improvements + 1))
    [ "$is_stale" -eq 1 ] && stale_improvements=$((stale_improvements + 1))
    [ -n "$assignee" ] && assigned_improvements=$((assigned_improvements + 1))
  elif [[ "$labels_lc" =~ (^|[[:space:]])idea($|[[:space:]]) ]]; then
    bucket="ideas"
    IDEAS="${IDEAS}${sort_line}"$'\n'
    count_ideas=$((count_ideas + 1))
    [ "$is_stale" -eq 1 ] && stale_ideas=$((stale_ideas + 1))
    [ -n "$assignee" ] && assigned_ideas=$((assigned_ideas + 1))
  else
    # Didn't match any category label — surface in the log so it can be
    # triaged instead of silently dropped from the totals.
    bucket="uncategorized"
    UNCATEGORIZED="${UNCATEGORIZED}${sort_line}"$'\n'
    count_uncategorized=$((count_uncategorized + 1))
    [ "$is_stale" -eq 1 ] && stale_uncategorized=$((stale_uncategorized + 1))
    [ -n "$assignee" ] && assigned_uncategorized=$((assigned_uncategorized + 1))
  fi

  MODULES["$mod_key"]=$((${MODULES["$mod_key"]:-0} + 1))

  # Spotlight: pick the lowest prio_rank, tie-break by age_days desc.
  # Uncategorized issues are excluded so the spotlight points at something
  # actionable rather than an unlabeled triage item.
  if [ "$bucket" != "uncategorized" ]; then
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
COLOR_UNCAT=9807270         # slate gray
COLOR_HEALTH_GREEN=5763719
COLOR_HEALTH_YELLOW=16776960
COLOR_HEALTH_ORANGE=15105570
COLOR_HEALTH_RED=15548997

# --- Health color based on total open ---
# `total` is the TRUE open-issue count (from the gh fetch). The per-bucket sum
# may be lower if some issues carry no category label, so we sanity-check and
# prefer the real count — anything that didn't match a category was routed to
# `count_uncategorized` above.
total="$open_total"
bucket_sum=$((count_bugs + count_features + count_improvements + count_ideas + count_uncategorized))
if [ "$bucket_sum" -ne "$total" ]; then
  echo "Warning: bucket sum (${bucket_sum}) != open total (${total}); some issues may be missing" >&2
fi
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
u_cells=$(cells_for "$count_uncategorized")

# Pad labels so the progress bar lines up inside the code block (monospaced).
# Uncategorized is only rendered when non-zero (keeps the normal view clean).
progress_block=$(printf 'Bugs          %s %3d\nFeatures      %s %3d\nImprovements  %s %3d\nIdeas         %s %3d' \
  "$(make_bar "$b_cells" '█')" "$count_bugs" \
  "$(make_bar "$f_cells" '█')" "$count_features" \
  "$(make_bar "$i_cells" '█')" "$count_improvements" \
  "$(make_bar "$d_cells" '█')" "$count_ideas")
if [ "$count_uncategorized" -gt 0 ]; then
  progress_block="${progress_block}"$'\n'"$(printf 'Uncategorized %s %3d' "$(make_bar "$u_cells" '█')" "$count_uncategorized")"
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

# Module display emoji — keeps sub-headings compact and branded.
module_emoji() {
  case "$1" in
    Focus)     printf '🎯' ;;
    Presence)  printf '🎬' ;;
    Vista)     printf '🗺️' ;;
    Insight)   printf '🔍' ;;
    Cache)     printf '🎒' ;;
    Essence)   printf '📜' ;;
    Flow)      printf '💬' ;;
    Core)      printf '🧩' ;;
    Pulse)     printf '❤️' ;;
    Verse)     printf '🎨' ;;
    Other)     printf '📦' ;;
    *)         printf '📦' ;;
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
  local total_in="$4"
  local stale_in="$5"
  local assigned_in="$6"

  # Footer text shared across the whole category (attached to the last embed).
  local footer="${total_in} open"
  [ "$stale_in" -gt 0 ] && footer="${footer} · ${stale_in} stale"
  [ "$assigned_in" -gt 0 ] && footer="${footer} · ${assigned_in} assigned"

  # Empty category → single placeholder embed.
  if [ -z "$raw" ] || [ "$total_in" -eq 0 ]; then
    jq -n \
      --arg title "$title" \
      --argjson color "$color" \
      --arg desc "_No open issues in this category._" \
      --arg footer "$footer" \
      --arg ts "$TIMESTAMP" \
      '[{title: $title, color: $color, description: $desc, footer: {text: $footer}, timestamp: $ts}]'
    return
  fi

  # 1. Rank modules by count (desc); push "Other" to the end so unlabeled
  #    issues don't dominate the layout.
  local -A MOD_COUNT=()
  while IFS=$'\t' read -r mod _ _ _; do
    [ -z "$mod" ] && continue
    MOD_COUNT["$mod"]=$((${MOD_COUNT["$mod"]:-0} + 1))
  done < <(printf '%s' "$raw" | grep -v '^$')

  local mod_order
  mod_order=$(
    for key in "${!MOD_COUNT[@]}"; do
      # sort key: 0 for real modules, 1 for Other → Other sinks to the bottom
      local tier=0
      [ "$key" = "Other" ] && tier=1
      printf '%d\t%d\t%s\n' "$tier" "${MOD_COUNT[$key]}" "$key"
    done | sort -t$'\t' -k1,1n -k2,2rn -k3,3 | cut -f3-
  )

  # 2. For each module, render its sub-heading + sorted bullets into one block.
  #    Modules are kept atomic when possible: a block flows into the current
  #    embed if it fits, otherwise starts a new continuation embed. If a single
  #    module block exceeds the cap on its own, it's split mid-list.
  local max=4000  # leaves slack under the 4096 hard cap
  local embeds_json='[]'
  local cur_desc=""
  local first=1

  flush_embed() {
    local is_last="$1"
    local embed
    if [ "$first" -eq 1 ]; then
      if [ "$is_last" -eq 1 ]; then
        embed=$(jq -n --arg title "$title" --argjson color "$color" --arg desc "$cur_desc" --arg footer "$footer" --arg ts "$TIMESTAMP" \
          '{title: $title, color: $color, description: $desc, footer: {text: $footer}, timestamp: $ts}')
      else
        embed=$(jq -n --arg title "$title" --argjson color "$color" --arg desc "$cur_desc" \
          '{title: $title, color: $color, description: $desc}')
      fi
      first=0
    else
      if [ "$is_last" -eq 1 ]; then
        embed=$(jq -n --argjson color "$color" --arg desc "$cur_desc" --arg footer "$footer" --arg ts "$TIMESTAMP" \
          '{color: $color, description: $desc, footer: {text: $footer}, timestamp: $ts}')
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

    # Extract this module's bullets, sorted by priority asc then age desc.
    local bullets
    bullets=$(printf '%s' "$raw" | grep -v '^$' | awk -F'\t' -v m="$mod" '$1==m' | sort -t$'\t' -k2,2n -k3,3rn | cut -f4-)

    # Try to keep the whole module block together. Trailing blank line adds
    # breathing room between modules in Discord's rendering.
    local block="${header}${bullets}"$'\n\n'
    if [ $(( ${#cur_desc} + ${#block} )) -le "$max" ]; then
      cur_desc="${cur_desc}${block}"
      continue
    fi

    # Block doesn't fit. Flush current embed (if non-empty), then try the block
    # alone. If it still doesn't fit, emit the header + as many bullets as fit
    # per continuation embed.
    if [ -n "$cur_desc" ]; then
      flush_embed 0
    fi

    if [ ${#block} -le "$max" ]; then
      cur_desc="$block"
      continue
    fi

    # Oversized module: header + bullets split across embeds.
    cur_desc="$header"
    while IFS= read -r b; do
      [ -z "$b" ] && continue
      local line="${b}"$'\n'
      if [ $(( ${#cur_desc} + ${#line} )) -gt "$max" ]; then
        flush_embed 0
        # Repeat header as a "(cont.)" on continuation embeds.
        cur_desc="**${emoji} ${mod}** · ${count} _(cont.)_"$'\n'"${line}"
      else
        cur_desc="${cur_desc}${line}"
      fi
    done <<< "$bullets"
  done <<< "$mod_order"

  [ -n "$cur_desc" ] && flush_embed 1

  # Discord allows up to 10 embeds per message. In practice we rarely get
  # close, but clamp defensively and warn if we do.
  local n
  n=$(jq 'length' <<< "$embeds_json")
  if [ "$n" -gt 10 ]; then
    echo "Warning: ${title} exceeded 10 embeds (${n}); truncating to 10" >&2
    embeds_json=$(jq '.[0:10]' <<< "$embeds_json")
  fi
  printf '%s' "$embeds_json"
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
BUGS_EMBEDS=$(build_category_embeds "🐛 Known Bugs" "$COLOR_BUGS" "$BUGS" "$count_bugs" "$stale_bugs" "$assigned_bugs")
write_payload .release/discord-issuelog-v2-payload-bugs.json "$BUGS_EMBEDS"

# --- Features ---
if [ "$count_features" -gt 0 ]; then
  FEATURES_EMBEDS=$(build_category_embeds "✨ Feature Requests" "$COLOR_FEATURES" "$FEATURES" "$count_features" "$stale_features" "$assigned_features")
  write_payload .release/discord-issuelog-v2-payload-features.json "$FEATURES_EMBEDS"
fi

# --- Improvements ---
if [ "$count_improvements" -gt 0 ]; then
  IMPROVEMENTS_EMBEDS=$(build_category_embeds "🔧 Improvements" "$COLOR_IMPROVEMENTS" "$IMPROVEMENTS" "$count_improvements" "$stale_improvements" "$assigned_improvements")
  write_payload .release/discord-issuelog-v2-payload-improvements.json "$IMPROVEMENTS_EMBEDS"
fi

# --- Ideas ---
if [ "$count_ideas" -gt 0 ]; then
  IDEAS_EMBEDS=$(build_category_embeds "💡 Ideas" "$COLOR_IDEAS" "$IDEAS" "$count_ideas" "$stale_ideas" "$assigned_ideas")
  write_payload .release/discord-issuelog-v2-payload-ideas.json "$IDEAS_EMBEDS"
fi

# --- Uncategorized (issues without a bug/feature/improvement/idea label) ---
# Surfaced so triagers can label them; skipped when empty.
if [ "$count_uncategorized" -gt 0 ]; then
  UNCAT_EMBEDS=$(build_category_embeds "❓ Uncategorized" "$COLOR_UNCAT" "$UNCATEGORIZED" "$count_uncategorized" "$stale_uncategorized" "$assigned_uncategorized")
  write_payload .release/discord-issuelog-v2-payload-uncategorized.json "$UNCAT_EMBEDS"
fi

# Show generated files (helpful when running locally / in CI logs)
for f in .release/discord-issuelog-v2-payload-*.json; do
  [ -f "$f" ] && jq . "$f"
done
