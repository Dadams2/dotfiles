#!/usr/bin/env sh


# First we append the saved layout of workspace N to workspace M
i3-msg "workspace 1; append_layout ~/.config/i3/workspace_1.json"

# And finally we fill the containers with the programs they had
(firefox &)
(emacs &)
(kitty &)

i3-msg "workspace 7; append_layout ~/.config/i3/workspace_7.json"

(slack &)

i3-msg "workspace 8; append_layout ~/.config/i3/workspace_8.json"

(discord &)
