#!/usr/bin/env sh

#!/bin/bash

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

# The current "main" display
MAIN_DISPLAY=$(getMainDisplayUUID)

# A list of displays and their properties
HOME_EX_MAIN_UUID=""
HOME_EX_LEFT_UUID=""
HOME_EX_RIGHT_UUID=""
HOME_MACBOOK_UUID=""
NORMAL_BAR=32
NOTCH_BAR=0
HOME_AIR_UUID=""
WORK_MAIN_UUID=""
WORK_LEFT_UUID=""
WORK_MACBOOK_UUID=""
WORK_MACBOOK_UUID_17=""
