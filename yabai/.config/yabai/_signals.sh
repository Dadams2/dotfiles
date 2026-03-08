#!/usr/bin/env sh


# focus window after active space changes
# yabai -m signal --add event=space_changed \
#   action="yabai -m window --focus \$(yabai -m query --windows --space | jq .[0].id)"

# # focus window after active display changes
# yabai -m signal --add event=display_changed \
#   action="yabai -m window --focus \$(yabai -m query --windows --space | jq .[0].id)"

# # restart to adjust for display removals
# yabai -m signal --add event=display_removed action="sleep 10 && yabai --restart-service sketchybar --reload"

# # restart to adjust for display additions
# yabai -m signal --add event=display_added \
#   action="sleep 10 && yabai --restart-service && sleep 10 && sketchybar --reload"

# ultrawide layout — re-evaluate when visible window count changes

UW_SCRIPT="$HOME/.config/yabai/ultrawide_layout.sh"

yabai -m signal --add label=uw_window_created \
  event=window_created action="$UW_SCRIPT window \$YABAI_WINDOW_ID"
yabai -m signal --add label=uw_window_destroyed \
  event=window_destroyed action="$UW_SCRIPT destroyed"
yabai -m signal --add label=uw_window_minimized \
  event=window_minimized action="$UW_SCRIPT window \$YABAI_WINDOW_ID"
yabai -m signal --add label=uw_window_deminimized \
  event=window_deminimized action="$UW_SCRIPT window \$YABAI_WINDOW_ID"
yabai -m signal --add label=uw_app_hidden \
  event=application_hidden action="$UW_SCRIPT process \$YABAI_PROCESS_ID"
yabai -m signal --add label=uw_app_visible \
  event=application_visible action="$UW_SCRIPT process \$YABAI_PROCESS_ID"
yabai -m signal --add label=uw_space_changed \
  event=space_changed action="$UW_SCRIPT space \$YABAI_SPACE_INDEX \$YABAI_RECENT_SPACE_INDEX"

# run once at startup
"$UW_SCRIPT" &
