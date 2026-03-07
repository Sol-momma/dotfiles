#!/bin/bash
# Claude Code statusline script
# Line 1: Model | Context% | +added/-removed | git branch
# Line 2: 5h rate limit progress bar
# Line 3: 7d rate limit progress bar

input=$(cat)

# ---------- ANSI Colors (Subtle & Professional) ----------
GREEN=$'\e[38;2;120;180;140m'      # Softer green for success/additions
YELLOW=$'\e[38;2;200;170;110m'     # Muted yellow for warnings
RED=$'\e[38;2;200;120;120m'        # Softer red for errors/deletions
GRAY=$'\e[38;2;140;150;160m'       # Lighter gray for secondary info
BLUE=$'\e[38;2;110;150;190m'       # Subdued blue for labels
CYAN=$'\e[38;2;115;175;185m'       # Muted cyan for branch
PURPLE=$'\e[38;2;160;140;180m'     # Gentle purple for long-term
ORANGE=$'\e[38;2;210;150;100m'     # Warm orange for short-term
RESET=$'\e[0m'
DIM=$'\e[2m'
BOLD=$'\e[1m'

# ---------- Color by percentage ----------
color_for_pct() {
  local pct="$1"
  if [ -z "$pct" ] || [ "$pct" = "null" ]; then
    printf '%s' "$GRAY"
    return
  fi
  local ipct
  ipct=$(printf "%.0f" "$pct" 2>/dev/null || echo "0")
  if [ "$ipct" -ge 80 ]; then
    printf '%s' "$RED"
  elif [ "$ipct" -ge 50 ]; then
    printf '%s' "$YELLOW"
  else
    printf '%s' "$GREEN"
  fi
}

# ---------- Progress bar (20 segments for smoother visualization) ----------
progress_bar() {
  local pct="$1"
  local filled
  filled=$(awk "BEGIN{printf \"%d\", int($pct / 5 + 0.5)}" 2>/dev/null || echo 0)
  [ "$filled" -gt 20 ] 2>/dev/null && filled=20
  [ "$filled" -lt 0 ] 2>/dev/null && filled=0
  local bar=""
  for i in $(seq 1 20); do
    if [ "$i" -le "$filled" ]; then
      bar="${bar}●"
    else
      bar="${bar}○"
    fi
  done
  printf '%s' "$bar"
}

# ---------- Parse stdin (single jq call) ----------
eval "$(echo "$input" | jq -r '
  "model_name=" + (.model.display_name // "Unknown" | @sh),
  "used_pct=" + (.context_window.used_percentage // 0 | tostring),
  "cwd=" + (.cwd // "" | @sh),
  "lines_added=" + (.cost.total_lines_added // 0 | tostring),
  "lines_removed=" + (.cost.total_lines_removed // 0 | tostring),
  "cc_version=" + (.version // "0.0.0" | @sh)
' 2>/dev/null)"

# ---------- Git branch ----------
git_branch=""
if [ -n "$cwd" ] && [ -d "$cwd" ]; then
  git_branch=$(git -C "$cwd" --no-optional-locks rev-parse --abbrev-ref HEAD 2>/dev/null || true)
fi

# ---------- Line stats from stdin ----------
git_stats=""
if [ "$lines_added" -gt 0 ] 2>/dev/null || [ "$lines_removed" -gt 0 ] 2>/dev/null; then
  git_stats="${GREEN}+${lines_added}${RESET} ${RED}-${lines_removed}${RESET}"
fi

# ---------- Rate limit via Haiku probe (cached 360s) ----------
CACHE_FILE="/tmp/claude-usage-cache.json"
CACHE_TTL=360
DEBUG_LOG="/tmp/claude-usage-debug.log"
FIVE_HOUR_UTIL=""
FIVE_HOUR_RESET=""
SEVEN_DAY_UTIL=""
SEVEN_DAY_RESET=""

fetch_usage() {
  local raw access_token headers h5_util h5_reset h7_util h7_reset

  raw=$(security find-generic-password -s "Claude Code-credentials" -w 2>/dev/null || true)
  [ -z "$raw" ] && return 1

  if echo "$raw" | jq -e . >/dev/null 2>&1; then
    access_token=$(echo "$raw" | jq -r '
      .claudeAiOauth.accessToken //
      .accessToken //
      .oauth.accessToken //
      empty
    ' 2>/dev/null)
  fi

  if [ -z "$access_token" ]; then
    access_token=$(printf '%s' "$raw" | python3 - <<'PY'
import sys, re, json

raw = sys.stdin.read().strip()

def try_json_bytes(b):
    try:
        s = b.decode("utf-8", errors="ignore")
        obj = json.loads(s)
        for path in [
            ("claudeAiOauth", "accessToken"),
            ("oauth", "accessToken"),
            ("accessToken",),
        ]:
            cur = obj
            ok = True
            for k in path:
                if isinstance(cur, dict) and k in cur:
                    cur = cur[k]
                else:
                    ok = False
                    break
            if ok and isinstance(cur, str) and cur:
                return cur
    except Exception:
        pass
    return ""

m = re.search(r'(sk-ant-[A-Za-z0-9\-_]+)', raw)
if m:
    print(m.group(1))
    raise SystemExit

hex_like = all(c in "0123456789abcdefABCDEF" for c in raw) and len(raw) % 2 == 0
if hex_like:
    try:
        b = bytes.fromhex(raw)
        token = try_json_bytes(b)
        if token:
            print(token)
            raise SystemExit
        m = re.search(rb'(sk-ant-[A-Za-z0-9\-_]+)', b)
        if m:
            print(m.group(1).decode())
            raise SystemExit
    except Exception:
        pass

m = re.search(r'"accessToken"\s*:\s*"(sk-ant-[^"]+)"', raw)
if m:
    print(m.group(1))
PY
)
  fi

  [ -z "$access_token" ] && return 1

  headers=$(curl -sD- --max-time 8 -o /dev/null \
    -H "Authorization: Bearer ${access_token}" \
    -H "Content-Type: application/json" \
    -H "User-Agent: claude-code/${cc_version:-0.0.0}" \
    -H "anthropic-beta: oauth-2025-04-20" \
    -H "anthropic-version: 2023-06-01" \
    -d '{"model":"claude-haiku-4-5-20251001","max_tokens":1,"messages":[{"role":"user","content":"h"}]}' \
    "https://api.anthropic.com/v1/messages" 2>/dev/null || true)

  [ -z "$headers" ] && return 1

  h5_util=$(printf '%s' "$headers" | grep -i 'anthropic-ratelimit-unified-5h-utilization' | tr -d '\r' | awk '{print $2}')
  h5_reset=$(printf '%s' "$headers" | grep -i 'anthropic-ratelimit-unified-5h-reset' | tr -d '\r' | awk '{print $2}')
  h7_util=$(printf '%s' "$headers" | grep -i 'anthropic-ratelimit-unified-7d-utilization' | tr -d '\r' | awk '{print $2}')
  h7_reset=$(printf '%s' "$headers" | grep -i 'anthropic-ratelimit-unified-7d-reset' | tr -d '\r' | awk '{print $2}')

  if [ -z "$h5_util" ] || [ -z "$h7_util" ]; then
    printf '%s\n' "--- headers begin ---" >> "$DEBUG_LOG"
    printf '%s\n' "$headers" >> "$DEBUG_LOG"
    printf '%s\n' "--- headers end ---" >> "$DEBUG_LOG"
    return 1
  fi

  jq -n \
    --arg h5u "$h5_util" --arg h5r "$h5_reset" \
    --arg h7u "$h7_util" --arg h7r "$h7_reset" \
    '{five_hour_util: $h5u, five_hour_reset: $h5r, seven_day_util: $h7u, seven_day_reset: $h7r}' \
    > "$CACHE_FILE"
  return 0
}

load_usage() {
  local data="$1"
  eval "$(echo "$data" | jq -r '
    "FIVE_HOUR_UTIL=" + (.five_hour_util // empty),
    "FIVE_HOUR_RESET=" + (.five_hour_reset // empty),
    "SEVEN_DAY_UTIL=" + (.seven_day_util // empty),
    "SEVEN_DAY_RESET=" + (.seven_day_reset // empty)
  ' 2>/dev/null)"
}

USE_CACHE=false
if [ -f "$CACHE_FILE" ]; then
  cache_age=$(( $(date +%s) - $(stat -f '%m' "$CACHE_FILE" 2>/dev/null || echo 0) ))
  if [ "$cache_age" -lt "$CACHE_TTL" ]; then
    USE_CACHE=true
  fi
fi

if $USE_CACHE; then
  load_usage "$(cat "$CACHE_FILE")"
else
  if fetch_usage; then
    load_usage "$(cat "$CACHE_FILE")"
  elif [ -f "$CACHE_FILE" ]; then
    load_usage "$(cat "$CACHE_FILE")"
  fi
fi

# Convert utilization (0.0-1.0) to percentage
to_pct() {
  local val="$1"
  if [ -z "$val" ] || [ "$val" = "null" ] || [ "$val" = "0" ]; then
    echo ""
    return
  fi
  awk "BEGIN{printf \"%.0f\", $val * 100}" 2>/dev/null || echo ""
}

FIVE_HOUR_PCT=$(to_pct "$FIVE_HOUR_UTIL")
SEVEN_DAY_PCT=$(to_pct "$SEVEN_DAY_UTIL")

# ---------- Format reset time (from epoch seconds) ----------
format_epoch_time() {
  local epoch="$1"
  local format="$2"
  [ -z "$epoch" ] || [ "$epoch" = "0" ] && echo "" && return
  local result
  result=$(TZ="Asia/Tokyo" date -j -f "%s" "$epoch" "$format" 2>/dev/null || \
           TZ="Asia/Tokyo" date -d "@${epoch}" "$format" 2>/dev/null || echo "")
  echo "$result" | sed 's/AM/am/;s/PM/pm/'
}

five_reset_display=""
if [ -n "$FIVE_HOUR_RESET" ] && [ "$FIVE_HOUR_RESET" != "0" ]; then
  five_reset_display="Resets $(format_epoch_time "$FIVE_HOUR_RESET" "+%-I%p") (Asia/Tokyo)"
fi

seven_reset_display=""
if [ -n "$SEVEN_DAY_RESET" ] && [ "$SEVEN_DAY_RESET" != "0" ]; then
  seven_reset_display="Resets $(format_epoch_time "$SEVEN_DAY_RESET" "+%b %-d at %-I%p") (Asia/Tokyo)"
fi

# ---------- Format context used% ----------
ctx_pct_int=0
if [ -n "$used_pct" ] && [ "$used_pct" != "null" ] && [ "$used_pct" != "0" ]; then
  ctx_pct_int=$(printf "%.0f" "$used_pct" 2>/dev/null || echo 0)
fi

# ---------- Line 1 ----------
SEP="${DIM}${GRAY} │ ${RESET}"
ctx_color=$(color_for_pct "$ctx_pct_int")

line1="${DIM}${BLUE}Model:${RESET} ${model_name}${SEP}${DIM}${ctx_color}Context:${RESET} ${ctx_color}${ctx_pct_int}%${RESET}"

if [ -n "$git_stats" ]; then
  line1+="${SEP}${git_stats}"
fi

if [ -n "$git_branch" ]; then
  line1+="${SEP}${DIM}${CYAN}Branch:${RESET} ${git_branch}"
fi

# ---------- Line 2 (5h) ----------
line2=""
if [ -n "$FIVE_HOUR_PCT" ]; then
  c5=$(color_for_pct "$FIVE_HOUR_PCT")
  bar5=$(progress_bar "$FIVE_HOUR_PCT")
  line2="${ORANGE}Short-term${RESET} ${DIM}${GRAY}[5h]${RESET} ${c5}${bar5} ${FIVE_HOUR_PCT}%${RESET}"
  [ -n "$five_reset_display" ] && line2+="  ${DIM}${GRAY}${five_reset_display}${RESET}"
else
  line2="${ORANGE}Short-term${RESET} ${DIM}${GRAY}[5h] ○○○○○○○○○○○○○○○○○○○○ --%${RESET}"
fi

# ---------- Line 3 (7d) ----------
line3=""
if [ -n "$SEVEN_DAY_PCT" ]; then
  c7=$(color_for_pct "$SEVEN_DAY_PCT")
  bar7=$(progress_bar "$SEVEN_DAY_PCT")
  line3="${PURPLE}Long-term${RESET} ${DIM}${GRAY}[7d]${RESET} ${c7}${bar7} ${SEVEN_DAY_PCT}%${RESET}"
  [ -n "$seven_reset_display" ] && line3+="  ${DIM}${GRAY}${seven_reset_display}${RESET}"
else
  line3="${PURPLE}Long-term${RESET} ${DIM}${GRAY}[7d] ○○○○○○○○○○○○○○○○○○○○ --%${RESET}"
fi

# ---------- Output ----------
printf '%s\n' "$line1"
printf '%s\n' "$line2"
printf '%s' "$line3"