#!/usr/bin/env bash

# Refresh SketchyBar window/space icons after Yabai events.

DELAY="${1:-0.15}"
sleep "$DELAY"

if command -v sketchybar >/dev/null 2>&1; then
  sketchybar --trigger windows_on_spaces
  sketchybar --update
fi
