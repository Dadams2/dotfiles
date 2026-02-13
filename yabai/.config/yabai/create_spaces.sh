#!/usr/bin/env bash

# Simple wrapper script called by yabai signals
# Calls the main balance_displays.sh script

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BALANCE_SCRIPT="$SCRIPT_DIR/balance_displays.sh"

if [ -f "$BALANCE_SCRIPT" ]; then
    "$BALANCE_SCRIPT"
else
    echo "Error: balance_displays.sh not found at $BALANCE_SCRIPT"
    exit 1
fi
