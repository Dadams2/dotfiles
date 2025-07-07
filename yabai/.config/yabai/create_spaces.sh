#!/bin/bash

# Simple wrapper script called by yabai signals
# Calls the main redistribute_spaces.sh script

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REDISTRIBUTE_SCRIPT="$SCRIPT_DIR/redistribute_spaces.sh"

if [ -f "$REDISTRIBUTE_SCRIPT" ]; then
    "$REDISTRIBUTE_SCRIPT" redistribute
else
    echo "Error: redistribute_spaces.sh not found at $REDISTRIBUTE_SCRIPT"
    exit 1
fi
