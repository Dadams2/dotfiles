#!/bin/bash

# Script to ensure each display has exactly 7 spaces
# Monitors display changes and balances spaces accordingly

SPACES_PER_DISPLAY=4

get_display_count() {
    yabai -m query --displays | jq 'length'
}

get_spaces_count_for_display() {
    local display_index=$1
    yabai -m query --spaces | jq "[.[] | select(.display == $display_index)] | length"
}

create_spaces_for_display() {
    local display_index=$1
    local current_spaces=$2
    local needed_spaces=$((SPACES_PER_DISPLAY - current_spaces))
    
    echo "Creating $needed_spaces spaces for display $display_index"
    for ((i=1; i<=needed_spaces; i++)); do
        yabai -m space --create $display_index
    done
}

remove_excess_spaces() {
    local display_index=$1
    local current_spaces=$2
    local excess_spaces=$((current_spaces - SPACES_PER_DISPLAY))
    
    echo "Removing $excess_spaces excess spaces from display $display_index"
    
    local empty_space_ids=($(yabai -m query --spaces | jq -r ".[] | select(.display == $display_index and (.windows | length) == 0) | .id" | sort -n))
    
    local spaces_to_remove=0
    if [ ${#empty_space_ids[@]} -gt 0 ]; then
        spaces_to_remove=$((excess_spaces < ${#empty_space_ids[@]} ? excess_spaces : ${#empty_space_ids[@]}))
    fi
    
    echo "Found ${#empty_space_ids[@]} empty spaces, will remove $spaces_to_remove"
    
    for ((i=0; i<spaces_to_remove; i++)); do
        local space_id=${empty_space_ids[$i]}
        if [ -n "$space_id" ]; then
            echo "Destroying empty space $space_id"
            yabai -m space $space_id --destroy 2>/dev/null
        fi
    done
    
    local remaining_excess=$((excess_spaces - spaces_to_remove))
    if [ $remaining_excess -gt 0 ]; then
        echo "Warning: Could not remove $remaining_excess spaces because they contain windows"
    fi
}

balance_spaces() {
    local display_count=$(get_display_count)
    echo "Balancing spaces across $display_count displays"
    
    local display_indices=($(yabai -m query --displays | jq -r '.[].index'))
    
    for display_index in "${display_indices[@]}"; do
        local current_spaces=$(get_spaces_count_for_display $display_index)
        echo "Display $display_index has $current_spaces spaces"
        
        if [ "$current_spaces" -lt "$SPACES_PER_DISPLAY" ]; then
            create_spaces_for_display $display_index $current_spaces
        elif [ "$current_spaces" -gt "$SPACES_PER_DISPLAY" ]; then
            remove_excess_spaces $display_index $current_spaces
        else
            echo "Display $display_index already has the correct number of spaces"
        fi
    done
}

get_display_config_hash() {
    yabai -m query --displays | jq -c 'sort_by(.index) | [.[] | {index: .index, id: .id, uuid: .uuid}]' | shasum -a 256 | cut -d' ' -f1
}

monitor_displays() {
    local last_display_config=$(get_display_config_hash)
    local last_display_count=$(get_display_count)
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Starting display monitor with $last_display_count displays"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Initial display config hash: $last_display_config"
    
    while true; do
        sleep 1
        local current_display_config=$(get_display_config_hash)
        local current_display_count=$(get_display_count)
        
        if [ "$current_display_config" != "$last_display_config" ]; then
            echo "$(date '+%Y-%m-%d %H:%M:%S') - Display configuration changed!"
            echo "$(date '+%Y-%m-%d %H:%M:%S') - Display count: $last_display_count -> $current_display_count"
            echo "$(date '+%Y-%m-%d %H:%M:%S') - Config hash: $last_display_config -> $current_display_config"
            
            sleep 2
            balance_spaces
            balance_spaces
            
            last_display_config=$current_display_config
            last_display_count=$current_display_count
        fi
    done
}

main() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Starting balance_spaces_between_displays.sh"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Target: $SPACES_PER_DISPLAY spaces per display"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - PID: $$"
    
    if ! pgrep -x "yabai" > /dev/null; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Error: yabai is not running"
        exit 1
    fi
    
    if ! command -v jq &> /dev/null; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Error: jq is required but not installed"
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Install with: brew install jq"
        exit 1
    fi
    
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Performing initial space balance..."
    balance_spaces
    
    if [[ "$1" == "--monitor" ]] || [[ -n "$PM2_HOME" ]] || [[ -n "$pm_id" ]]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Starting display monitor..."
        monitor_displays
    else
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Balance complete. Use --monitor flag to run continuously."
    fi
}

cleanup() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Stopping display monitor..."
    exit 0
}

trap cleanup SIGINT SIGTERM

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi