#!/usr/bin/env bash

# Ultrawide helper:
# - single window on 32:9 display => centered floating window
# - multi window => standard tiling with dynamic spacing

sleep "${1:-0.10}"

if ! command -v yabai >/dev/null 2>&1 || ! command -v jq >/dev/null 2>&1; then
  exit 0
fi

display_json="$(yabai -m query --displays --display 2>/dev/null)"
space_json="$(yabai -m query --spaces --space 2>/dev/null)"
[ -z "$display_json" ] || [ -z "$space_json" ] && exit 0

display_width="$(echo "$display_json" | jq -r '.frame.w')"
display_height="$(echo "$display_json" | jq -r '.frame.h')"
space_index="$(echo "$space_json" | jq -r '.index')"

[ -z "$display_width" ] || [ -z "$display_height" ] && exit 0
[ "$display_height" -eq 0 ] && exit 0

is_ultrawide="$(awk -v w="$display_width" -v h="$display_height" 'BEGIN { if ((w/h) >= 3.0 && w >= 3800) print 1; else print 0 }')"
[ "$is_ultrawide" -ne 1 ] && exit 0

window_ids="$(yabai -m query --windows --space \
  | jq -r '.[] | select(."is-minimized" == false and ."is-hidden" == false) | .id')"
window_count="$(echo "$window_ids" | sed '/^$/d' | wc -l | tr -d ' ')"

set_space_layout() {
  local top="$1"
  local bottom="$2"
  local left="$3"
  local right="$4"
  local gap="$5"

  yabai -m config --space "$space_index" top_padding "$top"
  yabai -m config --space "$space_index" bottom_padding "$bottom"
  yabai -m config --space "$space_index" left_padding "$left"
  yabai -m config --space "$space_index" right_padding "$right"
  yabai -m config --space "$space_index" window_gap "$gap"
}

if [ "$window_count" -eq 1 ]; then
  window_id="$(echo "$window_ids" | head -n 1)"
  is_floating="$(yabai -m query --windows --window "$window_id" | jq -r '."is-floating"')"
  if [ "$is_floating" != "true" ]; then
    yabai -m window "$window_id" --toggle float
  fi

  # Full vertical span, centered horizontally on 32:9.
  yabai -m window "$window_id" --grid 1:24:4:0:16:1
  # Keep the same vertical border feel as your global config.
  set_space_layout 6 8 0 0 0
elif [ "$window_count" -ge 2 ]; then
  for window_id in $window_ids; do
    is_floating="$(yabai -m query --windows --window "$window_id" | jq -r '."is-floating"')"
    if [ "$is_floating" = "true" ]; then
      yabai -m window "$window_id" --toggle float
    fi
  done

  if [ "$window_count" -le 3 ]; then
    set_space_layout 12 14 52 52 16
  else
    set_space_layout 8 10 24 24 10
  fi

  yabai -m space --balance
else
  set_space_layout 12 14 52 52 16
fi
