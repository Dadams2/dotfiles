#!/usr/bin/env bash

# Display utilities

## Get list of displays
getAllDisplays() {
  yabai -m query --displays
}

## Return number of displays
displayCount() {
  yabai -m query --displays | jq -r '. | length'
}

## Returns main display's UUID
getMainDisplayUUID() {
  yabai -m query --displays | jq -r '.[0].uuid'
}

## Print each display's UUID and resolution (for populating UUID constants)
discover_display_uuids() {
  yabai -m query --displays | jq -r '.[] | "Display \(.index): \(.uuid)  (\(.frame.w)x\(.frame.h))"'
}

# The current "main" display
MAIN_DISPLAY=$(getMainDisplayUUID)

# --- Display UUID constants --------------------------------------------------
# Fill these in by running: discover_display_uuids
# Home setup: macbook — ultrawide — iPad
HOME_ULTRAWIDE_UUID="406015BF-2714-42C2-B568-EF6B5DE6C326"
HOME_IPAD_UUID="3DA72DAE-5B7B-4372-B8E3-0E9F2EB82AFB"
HOME_MACBOOK_UUID="37D8832A-2D66-02CA-B9F7-8F30A301B230"

# Work setup: macbook + 2 externals
WORK_MAIN_UUID=""
WORK_LEFT_UUID=""
WORK_MACBOOK_UUID="37D8832A-2D66-02CA-B9F7-8F30A301B230"

# Bar heights
NORMAL_BAR=32
NOTCH_BAR=0

# --- Machine detection -------------------------------------------------------
# Detects environment by checking which external display UUIDs are connected.
# Same laptop plugs into different monitor setups — UUIDs identify the setup.
# Override by exporting MACHINE before sourcing this file.
detect_machine() {
  local connected
  connected="$(yabai -m query --displays 2>/dev/null | jq -r '.[].uuid' 2>/dev/null)"

  # Check home: ultrawide or iPad UUID present
  for uuid in "$HOME_ULTRAWIDE_UUID" "$HOME_IPAD_UUID"; do
    [ -z "$uuid" ] && continue
    if echo "$connected" | grep -qF "$uuid"; then
      echo "home"
      return
    fi
  done

  # Check work: any work-specific external UUID present
  for uuid in "$WORK_MAIN_UUID" "$WORK_LEFT_UUID"; do
    [ -z "$uuid" ] && continue
    if echo "$connected" | grep -qF "$uuid"; then
      echo "work"
      return
    fi
  done

  # No recognized externals — laptop only
  echo "laptop"
}

if [ -z "${MACHINE:-}" ]; then
  MACHINE="$(detect_machine)"
fi
