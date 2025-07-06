#!/usr/bin/env sh


# focus window after active space changes
yabai -m signal --add event=space_changed \
  action="yabai -m window --focus \$(yabai -m query --windows --space | jq .[0].id)"

# focus window after active display changes
yabai -m signal --add event=display_changed \
  action="yabai -m window --focus \$(yabai -m query --windows --space | jq .[0].id)"

# restart to adjust for display removals
yabai -m signal --add event=display_removed action="sleep 10 && yabai --restart-service sketchybar --reload"

# restart to adjust for display additions
yabai -m signal --add event=display_added \
  action="sleep 10 && yabai --restart-service && sleep 10 && sketchybar --reload"
