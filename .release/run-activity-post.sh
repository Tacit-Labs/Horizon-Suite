#!/bin/bash
set -e
# Posts a single Discord embed per GitHub activity event.
#
# Reads the event payload from $GITHUB_EVENT_PATH and the event name from
# $GITHUB_EVENT_NAME. Posts to $WEBHOOK_URL (the DISCORD_WEBHOOK_ACTIVITY
# secret). Each event is its own message — no editing, no deleting; the channel
# is a permanent activity log.
#
# Supported events:
#   issues:               opened, closed, reopened
#   pull_request:         opened, closed (merged vs unmerged), reopened, review_requested
#   pull_request_review:  submitted (approved / changes_requested / commented)
#
# Behavior notes:
#   - Bot authors (login ending in [bot]) are skipped — keeps the channel signal-only.
#   - Assignees on PR opened and the requested reviewer on review_requested are
#     @mentioned via .github/discord-user-map.json. Unmapped logins fall back to
#     plain "@github-login" text.
#   - Self-assignment doesn't @mention (avoids pinging the author).
#   - Drafts post but are tagged "(draft)" in the title.

EVENT_PATH="${GITHUB_EVENT_PATH:?GITHUB_EVENT_PATH is required}"
EVENT_NAME="${GITHUB_EVENT_NAME:?GITHUB_EVENT_NAME is required}"
REPO="${GITHUB_REPOSITORY:-Tacit-Labs/Horizon-Suite}"
MAP_FILE="${DISCORD_USER_MAP_FILE:-.github/discord-user-map.json}"

if [ ! -r "$EVENT_PATH" ]; then
  echo "Event payload not readable: $EVENT_PATH" >&2
  exit 1
fi
if [ -z "${WEBHOOK_URL:-}" ]; then
  echo "::notice::Activity feed skipped: WEBHOOK_URL is not set."
  exit 0
fi

ACTION=$(jq -r '.action // ""' "$EVENT_PATH")
SENDER=$(jq -r '.sender.login // ""' "$EVENT_PATH")

# --- Bot filter ---
# Sender is who triggered the event (e.g. who clicked "merge"). For an
# author-driven post we also need the author of the issue/PR. Both are checked.
is_bot() {
  case "$1" in
    *"[bot]") return 0 ;;
    "") return 1 ;;
    *) return 1 ;;
  esac
}
if is_bot "$SENDER"; then
  echo "Skipping bot-triggered event (sender=$SENDER)"
  exit 0
fi

# --- Discord user-id lookup ---
# Returns the Discord ID for a GitHub login, or empty string when unmapped.
discord_id_for() {
  local login="$1"
  [ -z "$login" ] && return 0
  if [ ! -r "$MAP_FILE" ]; then
    return 0
  fi
  jq -r --arg k "$login" '.[$k] // ""' "$MAP_FILE" 2>/dev/null
}

# Builds a single mention chunk: <@123456> if mapped, plain @login otherwise.
mention_for() {
  local login="$1"
  [ -z "$login" ] && return 0
  local id
  id=$(discord_id_for "$login")
  if [ -n "$id" ]; then
    printf '<@%s>' "$id"
  else
    printf '@%s' "$login"
  fi
}

# Joins assignee/reviewer logins into one space-separated mention string.
# `skip_login` (arg 2) suppresses self-mention when the author == assignee.
mentions_for_logins() {
  local skip_login="$1"; shift
  local out=""
  local login
  for login in "$@"; do
    [ -z "$login" ] && continue
    [ "$login" = "$skip_login" ] && continue
    if [ -n "$out" ]; then out="${out} "; fi
    out="${out}$(mention_for "$login")"
  done
  printf '%s' "$out"
}

# Truncates a string to N chars, appending an ellipsis when cut.
trim() {
  local s="$1" max="$2"
  if [ "${#s}" -le "$max" ]; then
    printf '%s' "$s"
  else
    printf '%s…' "${s:0:max-1}"
  fi
}

# --- Color palette (decimal) ---
COLOR_OPENED=3447003          # blue
COLOR_DRAFT=9807270           # slate gray
COLOR_CLOSED_DONE=5763719     # green (completed)
COLOR_CLOSED_DROP=9807270     # gray (not_planned / unmerged)
COLOR_MERGED=10181046         # purple
COLOR_REOPENED=16776960       # yellow
COLOR_REVIEW_OK=5763719       # green
COLOR_REVIEW_CHANGES=15105570 # orange
COLOR_REVIEW_COMMENT=3447003  # blue
COLOR_REVIEW_REQ=3447003      # blue

# --- Routing ---
TITLE=""
URL=""
COLOR=""
DESCRIPTION=""
AUTHOR_LOGIN=""
AUTHOR_AVATAR=""
AUTHOR_URL=""
CONTENT=""    # top-level Discord content for @mentions
NUMBER=""

case "$EVENT_NAME" in
  issues)
    case "$ACTION" in
      opened|closed|reopened) ;;
      *) echo "Skipping issues.$ACTION (not in supported set)"; exit 0 ;;
    esac
    AUTHOR_LOGIN=$(jq -r '.issue.user.login // ""' "$EVENT_PATH")
    if is_bot "$AUTHOR_LOGIN"; then
      echo "Skipping bot-authored issue ($AUTHOR_LOGIN)"; exit 0
    fi
    NUMBER=$(jq -r '.issue.number' "$EVENT_PATH")
    ITITLE=$(jq -r '.issue.title' "$EVENT_PATH")
    URL=$(jq -r '.issue.html_url' "$EVENT_PATH")
    AUTHOR_AVATAR=$(jq -r '.issue.user.avatar_url // ""' "$EVENT_PATH")
    AUTHOR_URL=$(jq -r '.issue.user.html_url // ""' "$EVENT_PATH")
    LABELS=$(jq -r '[.issue.labels[].name] | join(", ")' "$EVENT_PATH")
    BODY=$(jq -r '.issue.body // ""' "$EVENT_PATH")
    case "$ACTION" in
      opened)
        TITLE="🆕 Issue #${NUMBER} opened — $(trim "$ITITLE" 200)"
        COLOR=$COLOR_OPENED
        DESCRIPTION=$(trim "$BODY" 600)
        ;;
      closed)
        REASON=$(jq -r '.issue.state_reason // ""' "$EVENT_PATH")
        if [ "$REASON" = "not_planned" ]; then
          TITLE="📕 Issue #${NUMBER} closed (not planned) — $(trim "$ITITLE" 200)"
          COLOR=$COLOR_CLOSED_DROP
        else
          TITLE="✅ Issue #${NUMBER} closed — $(trim "$ITITLE" 200)"
          COLOR=$COLOR_CLOSED_DONE
        fi
        DESCRIPTION="Closed by @${SENDER}"
        ;;
      reopened)
        TITLE="🔁 Issue #${NUMBER} reopened — $(trim "$ITITLE" 200)"
        COLOR=$COLOR_REOPENED
        DESCRIPTION="Reopened by @${SENDER}"
        ;;
    esac
    [ -n "$LABELS" ] && DESCRIPTION="${DESCRIPTION}"$'\n\n'"\`labels:\` ${LABELS}"
    ;;

  pull_request)
    case "$ACTION" in
      opened|closed|reopened|review_requested) ;;
      *) echo "Skipping pull_request.$ACTION (not in supported set)"; exit 0 ;;
    esac
    AUTHOR_LOGIN=$(jq -r '.pull_request.user.login // ""' "$EVENT_PATH")
    if is_bot "$AUTHOR_LOGIN"; then
      echo "Skipping bot-authored PR ($AUTHOR_LOGIN)"; exit 0
    fi
    NUMBER=$(jq -r '.pull_request.number' "$EVENT_PATH")
    PTITLE=$(jq -r '.pull_request.title' "$EVENT_PATH")
    URL=$(jq -r '.pull_request.html_url' "$EVENT_PATH")
    AUTHOR_AVATAR=$(jq -r '.pull_request.user.avatar_url // ""' "$EVENT_PATH")
    AUTHOR_URL=$(jq -r '.pull_request.user.html_url // ""' "$EVENT_PATH")
    BASE=$(jq -r '.pull_request.base.ref // ""' "$EVENT_PATH")
    HEAD=$(jq -r '.pull_request.head.ref // ""' "$EVENT_PATH")
    DRAFT=$(jq -r '.pull_request.draft // false' "$EVENT_PATH")
    BODY=$(jq -r '.pull_request.body // ""' "$EVENT_PATH")
    # Read assignee logins one per line (safe with spaces; logins can't contain them anyway).
    mapfile -t ASSIGNEES < <(jq -r '.pull_request.assignees[].login' "$EVENT_PATH")
    case "$ACTION" in
      opened)
        if [ "$DRAFT" = "true" ]; then
          TITLE="📝 PR #${NUMBER} opened (draft) — $(trim "$PTITLE" 200)"
          COLOR=$COLOR_DRAFT
        else
          TITLE="🚀 PR #${NUMBER} opened — $(trim "$PTITLE" 200)"
          COLOR=$COLOR_OPENED
        fi
        # Build the assignee line. Pings only fire on opened, and only for
        # assignees who aren't the author (skip self-pings).
        if [ "${#ASSIGNEES[@]}" -gt 0 ]; then
          ASSIGNEE_LINE=$(mentions_for_logins "$AUTHOR_LOGIN" "${ASSIGNEES[@]}")
          if [ -n "$ASSIGNEE_LINE" ]; then
            CONTENT="$ASSIGNEE_LINE"
            DESCRIPTION="**Assigned:** ${ASSIGNEE_LINE}"
          else
            DESCRIPTION="**Assigned:** _self-assigned to author_"
          fi
        else
          DESCRIPTION="**Assigned:** _unassigned_"
        fi
        DESCRIPTION="${DESCRIPTION}"$'\n'"**Branch:** \`${HEAD}\` → \`${BASE}\`"
        BODY_TRIM=$(trim "$BODY" 500)
        [ -n "$BODY_TRIM" ] && DESCRIPTION="${DESCRIPTION}"$'\n\n'"${BODY_TRIM}"
        ;;
      closed)
        MERGED=$(jq -r '.pull_request.merged // false' "$EVENT_PATH")
        if [ "$MERGED" = "true" ]; then
          MERGED_BY=$(jq -r '.pull_request.merged_by.login // ""' "$EVENT_PATH")
          TITLE="🟣 PR #${NUMBER} merged — $(trim "$PTITLE" 200)"
          COLOR=$COLOR_MERGED
          if [ -n "$MERGED_BY" ]; then
            DESCRIPTION="Merged by @${MERGED_BY} into \`${BASE}\`"
          else
            DESCRIPTION="Merged into \`${BASE}\`"
          fi
        else
          TITLE="❌ PR #${NUMBER} closed (unmerged) — $(trim "$PTITLE" 200)"
          COLOR=$COLOR_CLOSED_DROP
          DESCRIPTION="Closed without merging by @${SENDER}"
        fi
        ;;
      reopened)
        TITLE="🔁 PR #${NUMBER} reopened — $(trim "$PTITLE" 200)"
        COLOR=$COLOR_REOPENED
        DESCRIPTION="Reopened by @${SENDER}"
        ;;
      review_requested)
        REQ_USER=$(jq -r '.requested_reviewer.login // ""' "$EVENT_PATH")
        REQ_TEAM=$(jq -r '.requested_team.slug // ""' "$EVENT_PATH")
        TITLE="👀 PR #${NUMBER} — review requested — $(trim "$PTITLE" 200)"
        COLOR=$COLOR_REVIEW_REQ
        if [ -n "$REQ_USER" ]; then
          if is_bot "$REQ_USER"; then
            echo "Skipping review_requested for bot reviewer ($REQ_USER)"; exit 0
          fi
          MENTION=$(mention_for "$REQ_USER")
          # Only ping the reviewer when it's not also the author.
          if [ "$REQ_USER" != "$AUTHOR_LOGIN" ]; then
            CONTENT="$MENTION"
          fi
          DESCRIPTION="Review requested from ${MENTION} by @${SENDER}"
        elif [ -n "$REQ_TEAM" ]; then
          DESCRIPTION="Review requested from team \`${REQ_TEAM}\` by @${SENDER}"
        else
          DESCRIPTION="Review requested by @${SENDER}"
        fi
        ;;
    esac
    ;;

  pull_request_review)
    if [ "$ACTION" != "submitted" ]; then
      echo "Skipping pull_request_review.$ACTION (only 'submitted' is handled)"; exit 0
    fi
    REVIEWER=$(jq -r '.review.user.login // ""' "$EVENT_PATH")
    if is_bot "$REVIEWER"; then
      echo "Skipping bot review ($REVIEWER)"; exit 0
    fi
    STATE=$(jq -r '.review.state // ""' "$EVENT_PATH")
    NUMBER=$(jq -r '.pull_request.number' "$EVENT_PATH")
    PTITLE=$(jq -r '.pull_request.title' "$EVENT_PATH")
    URL=$(jq -r '.review.html_url // .pull_request.html_url' "$EVENT_PATH")
    AUTHOR_LOGIN="$REVIEWER"
    AUTHOR_AVATAR=$(jq -r '.review.user.avatar_url // ""' "$EVENT_PATH")
    AUTHOR_URL=$(jq -r '.review.user.html_url // ""' "$EVENT_PATH")
    REVIEW_BODY=$(jq -r '.review.body // ""' "$EVENT_PATH")
    case "$STATE" in
      approved)
        TITLE="✅ PR #${NUMBER} approved — $(trim "$PTITLE" 200)"
        COLOR=$COLOR_REVIEW_OK
        DESCRIPTION="Approved by @${REVIEWER}"
        ;;
      changes_requested)
        TITLE="🟧 PR #${NUMBER} changes requested — $(trim "$PTITLE" 200)"
        COLOR=$COLOR_REVIEW_CHANGES
        DESCRIPTION="Changes requested by @${REVIEWER}"
        ;;
      commented)
        # Skip empty review-comments — GitHub fires this event for every inline
        # comment thread submission, even when there's no top-level body.
        if [ -z "$REVIEW_BODY" ]; then
          echo "Skipping commented review with empty body (likely inline-only)"; exit 0
        fi
        TITLE="💬 PR #${NUMBER} commented — $(trim "$PTITLE" 200)"
        COLOR=$COLOR_REVIEW_COMMENT
        DESCRIPTION="Comment from @${REVIEWER}"
        ;;
      *)
        echo "Skipping review with unknown state ($STATE)"; exit 0
        ;;
    esac
    BODY_TRIM=$(trim "$REVIEW_BODY" 500)
    [ -n "$BODY_TRIM" ] && DESCRIPTION="${DESCRIPTION}"$'\n\n'"${BODY_TRIM}"
    ;;

  *)
    echo "::notice::Unsupported event ($EVENT_NAME) — skipping"
    exit 0
    ;;
esac

if [ -z "$TITLE" ] || [ -z "$URL" ] || [ -z "$COLOR" ]; then
  echo "Routing produced no payload — skipping"; exit 0
fi

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# --- Build the embed and the wrapper message ---
EMBED=$(jq -n \
  --arg title "$TITLE" \
  --arg url "$URL" \
  --arg desc "$DESCRIPTION" \
  --argjson color "$COLOR" \
  --arg author "@${AUTHOR_LOGIN}" \
  --arg author_url "$AUTHOR_URL" \
  --arg author_icon "$AUTHOR_AVATAR" \
  --arg footer "${REPO}" \
  --arg ts "$TIMESTAMP" \
  '{
    title: $title,
    url: $url,
    description: $desc,
    color: $color,
    author: (
      if $author != "@" then
        ({name: $author}
         + (if $author_url != ""  then {url: $author_url}     else {} end)
         + (if $author_icon != "" then {icon_url: $author_icon} else {} end))
      else null end
    ),
    footer: {text: $footer},
    timestamp: $ts
  } | with_entries(select(.value != null))')

PAYLOAD=$(jq -n \
  --arg content "$CONTENT" \
  --argjson embed "$EMBED" \
  '{
    username: "HorizonSuite Activity",
    embeds: [$embed]
  } + (if $content != "" then {
    content: $content,
    allowed_mentions: {parse: ["users"]}
  } else {} end)')

# --- POST to Discord ---
BODY_FILE=$(mktemp)
HTTP=$(curl -sS -o "$BODY_FILE" -w "%{http_code}" -X POST \
  "$WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD")
if [ "$HTTP" -lt 200 ] || [ "$HTTP" -ge 300 ]; then
  echo "Discord POST failed (HTTP ${HTTP}): $(tr -d '\r' < "$BODY_FILE" | head -c 1200)" >&2
  rm -f "$BODY_FILE"
  exit 1
fi
rm -f "$BODY_FILE"
echo "Posted ${EVENT_NAME}.${ACTION} — #${NUMBER}"
