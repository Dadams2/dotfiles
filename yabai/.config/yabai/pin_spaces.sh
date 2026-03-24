#!/usr/bin/env bash

# UUID-based space pinning for yabai
#
# Ensures named spaces are pinned to specific displays identified by UUID.
# Supports multiple environments (home, work, laptop-only) and gracefully
# skips displays that aren't connected.
#
# Usage:
#   pin_spaces.sh          — run manually or at startup
#   pin_spaces.sh           — called by display_added/removed/changed signals

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_displays.sh"

# --- Config ------------------------------------------------------------------
# Each environment defines: UUID → ordered space labels + layouts
# Format: "uuid|label1:layout,label2:layout,..."
# "ANY" means use display index 1 (primary display).


case "$MACHINE" in
  home)
    # macbook (optional) — ultrawide — iPad (optional)
    PIN_DISPLAYS=(
      "$HOME_MACBOOK_UUID|music:float,chat:bsp,notes:bsp,terminal:bsp"
      "$HOME_ULTRAWIDE_UUID|web:bsp,work:bsp,code:bsp,project:bsp"
      "$HOME_IPAD_UUID|plan:bsp,office:bsp,reference:bsp,media:float"
    )
    ;;
  work)
    # macbook (optional) + 2 externals
    PIN_DISPLAYS=(
      "$WORK_MAIN_UUID|web:bsp,work:bsp,code:bsp,project:bsp"
      "$WORK_LEFT_UUID|plan:bsp,office:bsp,reference:bsp,terminal:bsp"
      "$WORK_MACBOOK_UUID|music:float,chat:bsp,notes:bsp,media:float"
    )
    ;;
  *)
    # Single display / laptop-only
    PIN_DISPLAYS=(
      "ANY|music:float,web:bsp,work:bsp,code:bsp,office:bsp,notes:bsp,terminal:bsp"
    )
    ;;
esac

# --- Constants ---------------------------------------------------------------
DEBOUNCE_FILE="/tmp/yabai-pinspaces.seq"
DEBOUNCE_MS=80

# --- Helpers (reused patterns from ultrawide_layout.sh) ----------------------

log() {
  printf '[%s] pin_spaces: %s\n' "$(date '+%H:%M:%S')" "$1"
}

require_dependencies() {
  command -v yabai >/dev/null 2>&1 || { log "yabai not found"; exit 1; }
  command -v jq   >/dev/null 2>&1 || { log "jq not found";    exit 1; }
}

debounce() {
  local token="$$.$RANDOM"
  echo "$token" > "$DEBOUNCE_FILE"
  sleep "0.$(printf '%03d' $DEBOUNCE_MS)"
  local latest
  latest="$(cat "$DEBOUNCE_FILE" 2>/dev/null)"
  [ "$latest" != "$token" ] && exit 0
}

# --- Core algorithm ----------------------------------------------------------

main() {
  require_dependencies
  debounce

  # --- Step 1: Prefetch (exactly 2 yabai queries) ---
  local displays_json spaces_json
  displays_json="$(yabai -m query --displays 2>/dev/null)" || { log "failed to query displays"; exit 1; }
  spaces_json="$(yabai -m query --spaces 2>/dev/null)" || { log "failed to query spaces"; exit 1; }

  # --- Step 2: Build UUID → arrangement index lookup ---
  # Produces lines like: "UUID:INDEX"
  local uuid_map
  uuid_map="$(echo "$displays_json" | jq -r '.[] | "\(.uuid):\(.index)"')"

  # --- Step 3: Diff desired vs actual ---
  # For each PIN_DISPLAYS entry, determine what needs to happen.
  local to_create=""       # "label:target_display" lines
  local to_move=""         # "space_index:target_display" lines
  local to_label=""        # "space_index:label" lines (after create)
  local layout_map=""      # "label:layout" lines
  local total_creates=0
  local total_moves=0

  for entry in "${PIN_DISPLAYS[@]}"; do
    local uuid="${entry%%|*}"
    local specs="${entry#*|}"

    # Resolve UUID to arrangement index
    local target_display=""
    if [ "$uuid" = "ANY" ]; then
      target_display=1
    else
      # Skip empty UUIDs (not configured yet)
      [ -z "$uuid" ] && continue
      target_display="$(echo "$uuid_map" | grep "^${uuid}:" | head -1 | cut -d: -f2)"
    fi

    # Skip if display not connected
    if [ -z "$target_display" ]; then
      log "display $uuid not connected, skipping"
      continue
    fi

    # Process each label:layout spec
    IFS=',' read -ra spec_list <<< "$specs"
    for spec in "${spec_list[@]}"; do
      local label="${spec%%:*}"
      local layout="${spec#*:}"

      # Record layout for later
      layout_map="${layout_map}${label}:${layout}
"

      # Check if space with this label exists
      local space_info
      space_info="$(echo "$spaces_json" | jq -r --arg lbl "$label" '
        .[] | select(.label == $lbl) | "\(.index):\(.display)"
      ')"

      if [ -z "$space_info" ]; then
        # Label doesn't exist — need to create
        to_create="${to_create}${label}:${target_display}
"
        total_creates=$((total_creates + 1))
      else
        local current_index="${space_info%%:*}"
        local current_display="${space_info#*:}"

        if [ "$current_display" != "$target_display" ]; then
          # Exists but on wrong display — queue move
          to_move="${to_move}${current_index}:${target_display}
"
          total_moves=$((total_moves + 1))
        fi
        # Correct display — no-op
      fi
    done
  done

  # --- Step 4: Check if anything to do (creates/moves) ---
  # Note: even if no creates/moves, we still need to check for orphan cleanup
  if [ "$total_creates" -eq 0 ] && [ "$total_moves" -eq 0 ]; then
    log "all spaces pinned (0 creates/moves)"
  fi

  if [ "$total_creates" -gt 0 ] || [ "$total_moves" -gt 0 ]; then
    log "plan: ${total_creates} create(s), ${total_moves} move(s)"
  fi

  # --- Step 5: Batch create missing spaces ---
  if [ "$total_creates" -gt 0 ]; then
    while IFS=: read -r label target_display; do
      [ -z "$label" ] && continue
      log "creating space on display $target_display"
      yabai -m space --create "$target_display" 2>/dev/null
      sleep 0.05
    done <<< "$to_create"

    # Re-query spaces once after all creates
    spaces_json="$(yabai -m query --spaces 2>/dev/null)" || { log "failed to re-query spaces"; exit 1; }

    # Label newly created spaces (unlabeled spaces on target displays)
    # Strategy: find unlabeled spaces on each target display, assign labels in order
    local labels_by_display=""
    while IFS=: read -r label target_display; do
      [ -z "$label" ] && continue
      labels_by_display="${labels_by_display}${target_display}:${label}
"
    done <<< "$to_create"

    # Get unique target displays
    local target_displays
    target_displays="$(echo "$labels_by_display" | grep -v '^$' | cut -d: -f1 | sort -u)"

    for td in $target_displays; do
      # Get labels to assign on this display (in order)
      local labels_for_display
      labels_for_display="$(echo "$labels_by_display" | grep "^${td}:" | cut -d: -f2)"

      # Get unlabeled space indices on this display (sorted descending = newest first)
      local unlabeled
      unlabeled="$(echo "$spaces_json" | jq -r --argjson d "$td" '
        [.[] | select(.display == $d and (.label == "" or .label == null)) | .index]
        | sort | reverse | .[]
      ')"

      # Pair them up
      local label_arr=()
      while IFS= read -r l; do
        [ -z "$l" ] && continue
        label_arr+=("$l")
      done <<< "$labels_for_display"

      local unlabeled_arr=()
      while IFS= read -r u; do
        [ -z "$u" ] && continue
        unlabeled_arr+=("$u")
      done <<< "$unlabeled"

      local i=0
      for lbl in "${label_arr[@]}"; do
        if [ "$i" -lt "${#unlabeled_arr[@]}" ]; then
          local idx="${unlabeled_arr[$i]}"
          log "labeling space $idx as '$lbl'"
          yabai -m space "$idx" --label "$lbl" 2>/dev/null
          i=$((i + 1))
        fi
      done
    done

    # Re-query again for accurate indices before moves
    spaces_json="$(yabai -m query --spaces 2>/dev/null)" || { log "failed to re-query spaces"; exit 1; }
  fi

  # --- Step 6: Move misplaced spaces (descending index to avoid shift issues) ---
  if [ "$total_moves" -gt 0 ]; then
    # Re-resolve moves from current state (indices may have shifted after creates)
    local fresh_moves=""
    for entry in "${PIN_DISPLAYS[@]}"; do
      local uuid="${entry%%|*}"
      local specs="${entry#*|}"

      local target_display=""
      if [ "$uuid" = "ANY" ]; then
        target_display=1
      else
        [ -z "$uuid" ] && continue
        target_display="$(echo "$uuid_map" | grep "^${uuid}:" | head -1 | cut -d: -f2)"
      fi
      [ -z "$target_display" ] && continue

      IFS=',' read -ra spec_list <<< "$specs"
      for spec in "${spec_list[@]}"; do
        local label="${spec%%:*}"
        local space_info
        space_info="$(echo "$spaces_json" | jq -r --arg lbl "$label" '
          .[] | select(.label == $lbl) | "\(.index):\(.display)"
        ')"
        [ -z "$space_info" ] && continue

        local current_index="${space_info%%:*}"
        local current_display="${space_info#*:}"

        if [ "$current_display" != "$target_display" ]; then
          fresh_moves="${fresh_moves}${current_index}:${target_display}
"
        fi
      done
    done

    # Sort by descending index to avoid index-shift issues
    local sorted_moves
    sorted_moves="$(echo "$fresh_moves" | grep -v '^$' | sort -t: -k1 -nr)"

    while IFS=: read -r space_idx target_display; do
      [ -z "$space_idx" ] && continue
      log "moving space $space_idx to display $target_display"
      yabai -m space "$space_idx" --display "$target_display" 2>/dev/null
      sleep 0.05
    done <<< "$sorted_moves"
  fi

  # --- Step 7: Destroy orphan spaces ---
  # When a display disconnects, macOS dumps its spaces onto the remaining display.
  # These orphans have no label (or a label not in our config). Destroy them after
  # relocating any windows they contain.
  spaces_json="$(yabai -m query --spaces 2>/dev/null)" || { log "failed to re-query spaces"; exit 1; }

  # Build set of known labels from config
  local known_labels=""
  for entry in "${PIN_DISPLAYS[@]}"; do
    local specs="${entry#*|}"
    IFS=',' read -ra spec_list <<< "$specs"
    for spec in "${spec_list[@]}"; do
      known_labels="${known_labels} ${spec%%:*}"
    done
  done

  # Find orphan space indices: unlabeled or label not in our config
  local orphan_indices
  orphan_indices="$(echo "$spaces_json" | jq -r --arg known "$known_labels" '
    ($known | split(" ") | map(select(. != ""))) as $labels |
    [.[] | select(
      .label == "" or .label == null or
      (.label as $l | $labels | index($l) | not)
    ) | .index] | sort | reverse | .[]
  ')"

  if [ -n "$orphan_indices" ]; then
    local total_destroyed=0

    for orphan_idx in $orphan_indices; do
      # Never destroy the last space on a display
      local orphan_display
      orphan_display="$(echo "$spaces_json" | jq -r --argjson idx "$orphan_idx" '
        .[] | select(.index == $idx) | .display
      ')"
      local spaces_on_display
      spaces_on_display="$(echo "$spaces_json" | jq --argjson d "$orphan_display" '
        [.[] | select(.display == $d)] | length
      ')"
      if [ "$spaces_on_display" -le 1 ]; then
        log "skipping orphan space $orphan_idx (last space on display $orphan_display)"
        continue
      fi

      # Move any windows to the first labeled space on the same display
      local window_ids
      window_ids="$(yabai -m query --windows --space "$orphan_idx" 2>/dev/null | jq -r '.[].id' 2>/dev/null)"
      if [ -n "$window_ids" ]; then
        # Find a labeled space on the same display to receive windows
        local target_idx
        target_idx="$(echo "$spaces_json" | jq -r --argjson d "$orphan_display" --argjson idx "$orphan_idx" --arg known "$known_labels" '
          ($known | split(" ") | map(select(. != ""))) as $labels |
          [.[] | select(.display == $d and .index != $idx and
            (.label as $l | $labels | index($l) | . != null)
          )] | sort_by(.index) | .[0].index // empty
        ')"

        # Fallback: any other space on any display
        if [ -z "$target_idx" ]; then
          target_idx="$(echo "$spaces_json" | jq -r --argjson idx "$orphan_idx" '
            [.[] | select(.index != $idx)] | sort_by(.index) | .[0].index // empty
          ')"
        fi

        if [ -n "$target_idx" ]; then
          for wid in $window_ids; do
            log "relocating window $wid from orphan space $orphan_idx to space $target_idx"
            yabai -m window "$wid" --space "$target_idx" 2>/dev/null
          done
          sleep 0.05
        fi
      fi

      log "destroying orphan space $orphan_idx"
      if yabai -m space "$orphan_idx" --destroy 2>/dev/null; then
        total_destroyed=$((total_destroyed + 1))
        # Re-query after each destroy since indices shift
        spaces_json="$(yabai -m query --spaces 2>/dev/null)" || break
      fi
    done

    [ "$total_destroyed" -gt 0 ] && log "destroyed $total_destroyed orphan space(s)"
  fi

  # --- Step 8: Apply layouts ---
  # Re-query one final time to get accurate indices
  spaces_json="$(yabai -m query --spaces 2>/dev/null)" || { log "failed to re-query spaces"; exit 1; }
  apply_layouts "$layout_map"

  log "done"
}

# Apply layout config to spaces by label
apply_layouts() {
  local layout_map="$1"
  local spaces_json
  spaces_json="$(yabai -m query --spaces 2>/dev/null)" || return

  while IFS=: read -r label layout; do
    [ -z "$label" ] && continue
    local idx
    idx="$(echo "$spaces_json" | jq -r --arg lbl "$label" '
      .[] | select(.label == $lbl) | .index
    ')"
    [ -z "$idx" ] || [ "$idx" = "null" ] && continue
    yabai -m config --space "$idx" layout "$layout" 2>/dev/null
  done <<< "$layout_map"
}

main "$@"
