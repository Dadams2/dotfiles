#!/usr/bin/env bash

# Keep spaces balanced per-display:
# - 1 display  -> 8 spaces
# - 2+ displays -> 4 spaces each

set -u

SINGLE_DISPLAY_SPACES=8
MULTI_DISPLAY_SPACES=4

log() {
  printf '[%s] %s\n' "$(date '+%H:%M:%S')" "$1"
}

require_dependencies() {
  command -v yabai >/dev/null 2>&1 || { echo "yabai not found in PATH"; exit 1; }
  command -v jq >/dev/null 2>&1 || { echo "jq not found in PATH"; exit 1; }
}

get_display_count() {
  yabai -m query --displays | jq 'length'
}

get_target_spaces_per_display() {
  local display_count="$1"
  if [ "$display_count" -eq 1 ]; then
    echo "$SINGLE_DISPLAY_SPACES"
  else
    echo "$MULTI_DISPLAY_SPACES"
  fi
}

get_spaces_count_for_display() {
  local display_index="$1"
  yabai -m query --spaces | jq "[.[] | select(.display == $display_index)] | length"
}

create_spaces_for_display() {
  local display_index="$1"
  local needed="$2"

  [ "$needed" -le 0 ] && return 0
  log "Display $display_index: creating $needed space(s)"
  for _ in $(seq 1 "$needed"); do
    yabai -m space --create "$display_index" >/dev/null 2>&1
    sleep 0.05
  done
}

move_windows_out_of_space() {
  local source_space_id="$1"
  local target_space_id="$2"

  local window_ids
  window_ids=$(yabai -m query --windows --space "$source_space_id" | jq -r '.[].id')
  [ -z "$window_ids" ] && return 0

  for window_id in $window_ids; do
    yabai -m window "$window_id" --space "$target_space_id" >/dev/null 2>&1
  done
}

remove_spaces_for_display() {
  local display_index="$1"
  local to_remove="$2"
  local removed=0

  [ "$to_remove" -le 0 ] && return 0
  log "Display $display_index: removing $to_remove excess space(s)"

  while [ "$removed" -lt "$to_remove" ]; do
    local candidate
    candidate=$(yabai -m query --spaces | jq -r "
      [.[] | select(.display == $display_index)
       | {id: .id, idx: .index, windows: (.windows | length)}]
      | if length == 0 then empty
        else
          sort_by(.windows, -.idx)
          | .[0]
          | \"\(.id):\(.windows)\"
        end
    ")

    [ -z "$candidate" ] && break

    local source_space_id window_count
    IFS=':' read -r source_space_id window_count <<< "$candidate"

    local spaces_left
    spaces_left=$(get_spaces_count_for_display "$display_index")
    [ "$spaces_left" -le 1 ] && break

    if [ "$window_count" -gt 0 ]; then
      local target_space_id
      target_space_id=$(yabai -m query --spaces | jq -r "
        [.[] | select(.display == $display_index and .id != $source_space_id)]
        | sort_by(.index)
        | .[0].id
      ")

      [ -z "$target_space_id" ] || [ "$target_space_id" = "null" ] && break
      move_windows_out_of_space "$source_space_id" "$target_space_id"
      sleep 0.1
    fi

    if yabai -m space "$source_space_id" --destroy >/dev/null 2>&1; then
      removed=$((removed + 1))
      sleep 0.05
    else
      break
    fi
  done
}

balance_spaces() {
  local display_count target
  display_count=$(get_display_count)
  [ "$display_count" -lt 1 ] && return 0

  target=$(get_target_spaces_per_display "$display_count")
  log "Balancing for $display_count display(s), target=$target per display"

  local display_indices
  display_indices=$(yabai -m query --displays | jq -r '.[].index' | sort -n)

  local display_index
  for display_index in $display_indices; do
    local current
    current=$(get_spaces_count_for_display "$display_index")
    if [ "$current" -lt "$target" ]; then
      create_spaces_for_display "$display_index" "$((target - current))"
    elif [ "$current" -gt "$target" ]; then
      remove_spaces_for_display "$display_index" "$((current - target))"
    fi
  done
}

get_display_config_hash() {
  yabai -m query --displays \
    | jq -c 'sort_by(.index) | [.[] | {index: .index, id: .id, uuid: .uuid}]' \
    | shasum -a 256 \
    | cut -d' ' -f1
}

monitor_displays() {
  local last_hash current_hash
  last_hash="$(get_display_config_hash)"
  log "Watching display configuration changes..."

  while true; do
    sleep 1
    current_hash="$(get_display_config_hash)"
    if [ "$current_hash" != "$last_hash" ]; then
      sleep 0.7
      balance_spaces
      # Run twice to settle after hot-plug events.
      balance_spaces
      last_hash="$current_hash"
    fi
  done
}

main() {
  require_dependencies
  balance_spaces

  if [ "${1:-}" = "--monitor" ]; then
    monitor_displays
  fi
}

main "$@"
