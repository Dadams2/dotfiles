#!/usr/bin/env sh


source "$HOME/.config/yabai/_displays.sh"

echo "Main Current Display : $MAIN_DISPLAY"
echo "Workstation Display : $HOME_EX_MAIN_UUID"
display_count=$(yabai -m query --displays | jq '. | length')

# Space Mapper
setup_space() {
  local idx="$1"
  local name="$2"
  local space=
  echo "setup space $idx : $name"

  space=$(yabai -m query --spaces --space "$idx")

  if [ -z "$space" ]; then
    yabai -m space --create
  fi

    if [[ $display_count -gt 1 ]]; then

    echo "You've got big display plans."

    # NOTE: Home Workspace Configuration
    yabai -m space "$idx" --label "$name"
    if [ "$idx" -lt "4" ]; then
      yabai -m space "$idx" --display 1
    elif [ "$idx" -gt "3" ] && [ $idx -lt "7" ]; then
      yabai -m space "$idx" --display 2
    else
      yabai -m space "$idx" --display 3
    fi

  # NOTE: Alternative configurations -------------------------------------

  # Two Displays; external above laptop
  # yabai -m space "$idx" --label "$name"
  # if [[ "$idx" -lt "4" ]]; then
  #   yabai -m space "$idx" --display 1
  # else
  #   yabai -m space "$idx" --display 2
  # fi

  fi
}

# -------------------------------------------------------------------------

# Setup or destroy spaces as needed to match 9
for _ in $(yabai -m query --spaces | jq '.[].index | select(. > 9)'); do
  yabai -m space --destroy 10
done

# Set Up Spaces
setup_space 1 music
setup_space 2 web
setup_space 3 work
setup_space 4 maincode
setup_space 5 code
setup_space 6 project
setup_space 7 plan
setup_space 8 office
setup_space 9 terminal

main_display_padding=(
  top_padding 133
  bottom_padding 133
  left_padding 233
  right_padding 233
)

# If Home Clamshell Open
# if [ "$MAIN_DISPLAY" == "$HOME_MACBOOK_UUID" ] || [ "$MAIN_DISPLAY" == "$WORK_MACBOOK_UUID" ]; then

#   yabai -m config layout float
#   # yabai -m config focus_follows_mouse off

# else

  # Set space padding
  # yabai -m config --space 1 "${main_display_padding[@]}"
  # yabai -m config --space 2 "${main_display_padding[@]}"
  # yabai -m config --space 3 "${main_display_padding[@]}"

  if [[ "$MACHINE" == 'home' ]]; then

    # Set floating spaces
    yabai -m config --space 1 layout float
    yabai -m config --space 2 layout bsp
    yabai -m config --space 3 layout float
    yabai -m config --space 4 layout bsp
    yabai -m config --space 5 layout bsp
    yabai -m config --space 6 layout bsp
    yabai -m config --space 7 layout bsp
    yabai -m config --space 8 layout bsp
    yabai -m config --space 9 layout bsp

  else

    yabai -m config --space 1 layout float
    yabai -m config --space 2 layout bsp
    yabai -m config --space 3 layout float
    yabai -m config --space 4 layout bsp
    yabai -m config --space 5 layout bsp
    yabai -m config --space 6 layout bsp
    yabai -m config --space 7 layout bsp
    yabai -m config --space 8 layout bsp
    yabai -m config --space 9 layout bsp

  fi

fi
