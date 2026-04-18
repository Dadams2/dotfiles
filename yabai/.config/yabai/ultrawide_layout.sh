#!/usr/bin/env bash

# Ultrawide layout manager:
# - 1 visible window on 32:9 display => float + center at ~67% width
# - 2+ visible windows => unfloat + tile with BSP padding
# - 0 visible windows => reset padding to defaults
#
# Usage (from signals):
#   ultrawide_layout.sh window <YABAI_WINDOW_ID>   — window created/minimized/deminimized
#   ultrawide_layout.sh destroyed                   — window destroyed (can't query dead window)
#   ultrawide_layout.sh process <YABAI_PROCESS_ID>  — app hidden/visible
#   ultrawide_layout.sh space <SPACE_IDX> [RECENT]  — space changed (covers window moved to space)
#   ultrawide_layout.sh                             — startup / manual run (all ultrawide spaces)

set -u

# --- Constants (tune to taste) -------------------------------------------
ULTRAWIDE_RATIO=3.0
ULTRAWIDE_MIN_WIDTH=3800
PAD_SINGLE="6:8:0:0"    # top:bottom:left:right for centered single window
GAP_SINGLE=0
PAD_MULTI="6:8:8:8"     # matches yabairc defaults for tiling
GAP_MULTI=6
DEBOUNCE_FILE="/tmp/yabai-ultrawide.seq"
DEBOUNCE_MS=50  # milliseconds to wait for signals to settle

# --- Helpers --------------------------------------------------------------

log() {
  printf '[%s] ultrawide: %s\n' "$(date '+%H:%M:%S')" "$1"
}

require_dependencies() {
  command -v yabai >/dev/null 2>&1 || { log "yabai not found"; exit 1; }
  command -v jq   >/dev/null 2>&1 || { log "jq not found";    exit 1; }
}

# Debounce: each invocation writes a unique token, waits briefly, then checks
# if it's still the latest. Only the last invocation in a burst proceeds.
debounce() {
  local token="$$.$RANDOM"
  echo "$token" > "$DEBOUNCE_FILE"
  sleep "0.$(printf '%03d' $DEBOUNCE_MS)"
  local latest
  latest="$(cat "$DEBOUNCE_FILE" 2>/dev/null)"
  [ "$latest" != "$token" ] && exit 0
}

# Check if a display is ultrawide. Reads from pre-fetched $all_displays_json.
# Sets is_ultrawide=1/0 and display_width/display_height as side effects.
check_display_ultrawide() {
  local display_index="$1"
  local display_info
  display_info="$(echo "$all_displays_json" | jq -r --argjson idx "$display_index" '
    .[] | select(.index == $idx) |
    (.frame.w | floor) as $w |
    (.frame.h | floor) as $h |
    (if $h > 0 and ($w / $h) >= '"$ULTRAWIDE_RATIO"' and $w >= '"$ULTRAWIDE_MIN_WIDTH"'
     then "1" else "0" end) as $uw |
    "\($w):\($h):\($uw)"
  ')" || return 1

  [ -z "$display_info" ] && return 1
  IFS=':' read -r display_width display_height is_ultrawide <<< "$display_info"
}

# Apply ultrawide layout logic to a specific space index.
layout_space() {
  local space_index="$1"

  # Query windows on the target space
  local windows_json
  windows_json="$(yabai -m query --windows --space "$space_index" 2>/dev/null)" || return 0

  # Extract visible count, floating IDs, and all visible IDs in one jq pass
  local window_info
  window_info="$(echo "$windows_json" | jq -r '
    [.[] | select(."is-minimized" == false and ."is-hidden" == false)] as $vis |
    ($vis | length) as $cnt |
    ([$vis[] | select(."is-floating" == true) | .id] | map(tostring) | join(" ")) as $float_ids |
    ([$vis[] | .id] | map(tostring) | join(" ")) as $all_ids |
    "\($cnt)|\($float_ids)|\($all_ids)"
  ')" || return 0

  local window_count floating_ids all_ids
  IFS='|' read -r window_count floating_ids all_ids <<< "$window_info"

  log "space=${space_index} display=${display_width}x${display_height} windows=${window_count}"

  if [ "$window_count" -eq 0 ]; then
    # No visible windows — reset to default padding
    yabai -m space "$space_index" --padding "abs:${PAD_MULTI}"
    yabai -m space "$space_index" --gap "abs:${GAP_MULTI}"

  elif [ "$window_count" -eq 1 ]; then
    # Single window — float + center
    local wid="${all_ids%% *}"

    # Only toggle float if not already floating
    if [[ ! " $floating_ids " =~ " $wid " ]]; then
      # Window may still be settling after a space move — retry once
      if ! yabai -m window "$wid" --toggle float 2>/dev/null; then
        sleep 0.05
        yabai -m window "$wid" --toggle float 2>/dev/null
      fi
    fi

    # Center at ~67% width: grid 1:24:4:0:16:1
    yabai -m window "$wid" --grid 1:24:4:0:16:1 2>/dev/null

    yabai -m space "$space_index" --padding "abs:${PAD_SINGLE}"
    yabai -m space "$space_index" --gap "abs:${GAP_SINGLE}"

  else
    # 2+ windows — unfloat any floating, tile with BSP
    local had_floating=0
    if [ -n "$floating_ids" ]; then
      had_floating=1
      for fid in $floating_ids; do
        yabai -m window "$fid" --toggle float 2>/dev/null
      done
    fi

    yabai -m space "$space_index" --padding "abs:${PAD_MULTI}"
    yabai -m space "$space_index" --gap "abs:${GAP_MULTI}"

    # Only rebalance when normalizing a prior single-window floating state.
    # Running balance on every space/display focus change reshuffles the tree.
    if [ "$had_floating" -eq 1 ]; then
      yabai -m space "$space_index" --balance
    fi
  fi
}

# --- Resolve target space(s) from signal arguments -----------------------

# Given a window ID, find which space it's on and which display that space is on.
# Returns "space_index:display_index" or empty string.
resolve_window() {
  local wid="$1"
  yabai -m query --windows --window "$wid" 2>/dev/null \
    | jq -r '"\(.space):\(.display)"'
}

# Given a process ID, find all spaces that have windows from that process.
# Returns newline-separated "space_index:display_index" pairs.
resolve_process() {
  local pid="$1"
  yabai -m query --windows 2>/dev/null \
    | jq -r --argjson pid "$pid" '
      [.[] | select(.pid == $pid) | "\(.space):\(.display)"] | unique | .[]
    '
}

# Find all spaces on all ultrawide displays (for startup/destroyed events).
resolve_all_ultrawide_spaces() {
  yabai -m query --spaces 2>/dev/null \
    | jq -r '.[].index'
}

# --- Main -----------------------------------------------------------------

main() {
  require_dependencies
  debounce

  local mode="${1:-}"
  local target_id="${2:-}"

  # Fetch all displays once (used by check_display_ultrawide)
  all_displays_json="$(yabai -m query --displays 2>/dev/null)" || exit 0
  local display_width="" display_height="" is_ultrawide=""

  # Collect space:display pairs to process
  local pairs=""

  case "$mode" in
    window)
      # window_created, window_minimized, window_deminimized
      [ -z "$target_id" ] && exit 0
      pairs="$(resolve_window "$target_id")" || exit 0
      [ -z "$pairs" ] || [ "$pairs" = "null:null" ] && exit 0
      ;;
    process)
      # application_hidden, application_visible
      [ -z "$target_id" ] && exit 0
      pairs="$(resolve_process "$target_id")" || exit 0
      ;;
    space)
      # space_changed — re-evaluate both current and previous space
      # $target_id = current space index, $3 = recent space index
      local recent_space="${3:-}"
      local spaces_json
      spaces_json="$(yabai -m query --spaces 2>/dev/null)" || exit 0
      pairs=""
      if [ -n "$target_id" ]; then
        local p
        p="$(echo "$spaces_json" | jq -r --argjson idx "$target_id" \
          '.[] | select(.index == $idx) | "\(.index):\(.display)"')"
        [ -n "$p" ] && pairs="$p"
      fi
      if [ -n "$recent_space" ] && [ "$recent_space" != "$target_id" ]; then
        local p
        p="$(echo "$spaces_json" | jq -r --argjson idx "$recent_space" \
          '.[] | select(.index == $idx) | "\(.index):\(.display)"')"
        [ -n "$p" ] && pairs="${pairs:+$pairs
}$p"
      fi
      ;;
    destroyed)
      # window_destroyed — window is gone, check all ultrawide spaces
      local all_spaces
      all_spaces="$(resolve_all_ultrawide_spaces)" || exit 0
      # Build pairs by looking up which display each space is on
      local spaces_json
      spaces_json="$(yabai -m query --spaces 2>/dev/null)" || exit 0
      pairs="$(echo "$spaces_json" | jq -r '.[] | "\(.index):\(.display)"')"
      ;;
    *)
      # Startup / manual — check all spaces on all displays
      local spaces_json
      spaces_json="$(yabai -m query --spaces 2>/dev/null)" || exit 0
      pairs="$(echo "$spaces_json" | jq -r '.[] | "\(.index):\(.display)"')"
      ;;
  esac

  [ -z "$pairs" ] && exit 0

  # Process each unique space:display pair
  local seen_spaces=""
  while IFS=':' read -r space_index display_index; do
    [ -z "$space_index" ] || [ -z "$display_index" ] && continue
    [ "$space_index" = "null" ] || [ "$display_index" = "null" ] && continue

    # Skip duplicates
    case " $seen_spaces " in
      *" $space_index "*) continue ;;
    esac
    seen_spaces="$seen_spaces $space_index"

    # Check if this display is ultrawide
    check_display_ultrawide "$display_index" || continue
    [ "$is_ultrawide" != "1" ] && continue

    layout_space "$space_index"
  done <<< "$pairs"
}

main "$@"
