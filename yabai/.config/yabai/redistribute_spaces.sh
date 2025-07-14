#!/bin/bash

# Enhanced script to redistribute spaces equally across displays
# Handles 1-3 displays and integrates with SketchyBar

# Configuration
MIN_SPACES_PER_DISPLAY=3
MAX_TOTAL_SPACES=10

# Colors for logging
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() {
    echo -e "${BLUE}[$(date '+%H:%M:%S')]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[$(date '+%H:%M:%S')] WARNING:${NC} $1"
}

error() {
    echo -e "${RED}[$(date '+%H:%M:%S')] ERROR:${NC} $1"
}

success() {
    echo -e "${GREEN}[$(date '+%H:%M:%S')] SUCCESS:${NC} $1"
}

# Check dependencies
check_dependencies() {
    if ! command -v yabai &> /dev/null; then
        error "yabai is not installed or not in PATH"
        exit 1
    fi
    
    if ! pgrep -x "yabai" > /dev/null; then
        error "yabai is not running"
        exit 1
    fi
    
    if ! command -v jq &> /dev/null; then
        error "jq is required but not installed. Install with: brew install jq"
        exit 1
    fi
}

# Get display information
get_display_info() {
    yabai -m query --displays | jq -r '.[] | "\(.index):\(.id):\(.uuid)"'
}

get_display_count() {
    yabai -m query --displays | jq 'length'
}

get_all_spaces() {
    yabai -m query --spaces | jq -c '.[]'
}

get_spaces_by_display() {
    local display_index=$1
    yabai -m query --spaces | jq -c ".[] | select(.display == $display_index)"
}

get_total_space_count() {
    yabai -m query --spaces | jq 'length'
}

# Calculate optimal distribution
calculate_distribution() {
    local display_count=$1
    local total_spaces=$2
    
    if [ $display_count -eq 0 ]; then
        echo "0 0 0"
        return
    fi
    
    # Enforce maximum total spaces
    if [ $total_spaces -gt $MAX_TOTAL_SPACES ]; then
        total_spaces=$MAX_TOTAL_SPACES
    fi
    
    # Always aim for maximum spaces distributed evenly
    local target_total=$MAX_TOTAL_SPACES
    local base_spaces=$((target_total / display_count))
    local remainder=$((target_total % display_count))
    
    # Ensure we don't go below minimum per display
    if [ $base_spaces -lt $MIN_SPACES_PER_DISPLAY ]; then
        base_spaces=$MIN_SPACES_PER_DISPLAY
        target_total=$((base_spaces * display_count))
        remainder=0
        
        # If minimum requirement exceeds maximum, use maximum and distribute evenly
        if [ $target_total -gt $MAX_TOTAL_SPACES ]; then
            target_total=$MAX_TOTAL_SPACES
            base_spaces=$((target_total / display_count))
            remainder=$((target_total % display_count))
        fi
    fi
    
    echo "$base_spaces $remainder $target_total"
}

# Move windows from a space before destroying it
move_windows_from_space() {
    local space_id=$1
    local target_space_id=$2
    
    local window_ids=$(yabai -m query --windows --space $space_id | jq -r '.[].id')
    
    if [ -n "$window_ids" ] && [ "$window_ids" != "null" ]; then
        log "Moving windows from space $space_id to space $target_space_id"
        for window_id in $window_ids; do
            yabai -m window $window_id --space $target_space_id 2>/dev/null
        done
    fi
}

# Create spaces on a display
create_spaces_on_display() {
    local display_index=$1
    local count=$2
    
    log "Creating $count spaces on display $display_index"
    for ((i=1; i<=count; i++)); do
        yabai -m space --create $display_index
        if [ $? -eq 0 ]; then
            log "Created space $i on display $display_index"
        else
            warn "Failed to create space $i on display $display_index"
        fi
    done
}

# Remove excess spaces from a display
remove_spaces_from_display() {
    local display_index=$1
    local count=$2
    
    log "Removing $count spaces from display $display_index"
    
    # Get spaces on this display, sorted by index (newest first)
    local space_data=($(yabai -m query --spaces | jq -r ".[] | select(.display == $display_index) | \"\(.id):\(.index):\((.windows | length))\"" | sort -t: -k2 -nr))
    
    local removed=0
    for space_info in "${space_data[@]}"; do
        if [ $removed -ge $count ]; then
            break
        fi
        
        IFS=':' read -r space_id space_index window_count <<< "$space_info"
        
        # Skip if this is the only space on the display
        local spaces_on_display=$(yabai -m query --spaces | jq "[.[] | select(.display == $display_index)] | length")
        if [ $spaces_on_display -le 1 ]; then
            warn "Cannot remove space $space_id - it's the only space on display $display_index"
            continue
        fi
        
        # If space has windows, move them to another space on the same display
        if [ $window_count -gt 0 ]; then
            local target_space_id=$(yabai -m query --spaces | jq -r ".[] | select(.display == $display_index and .id != $space_id) | .id" | head -n 1)
            if [ -n "$target_space_id" ] && [ "$target_space_id" != "null" ]; then
                move_windows_from_space $space_id $target_space_id
            fi
        fi
        
        # Remove the space
        yabai -m space $space_id --destroy 2>/dev/null
        if [ $? -eq 0 ]; then
            log "Removed space $space_id (index $space_index) from display $display_index"
            ((removed++))
        else
            warn "Failed to remove space $space_id from display $display_index"
        fi
    done
    
    return $removed
}

# Remove excess spaces globally when total exceeds maximum
remove_excess_spaces_globally() {
    local current_total=$(get_total_space_count)
    local excess=$((current_total - MAX_TOTAL_SPACES))
    
    if [ $excess -le 0 ]; then
        return 0
    fi
    
    log "Total spaces ($current_total) exceeds maximum ($MAX_TOTAL_SPACES). Removing $excess spaces..."
    
    # Get all spaces sorted by: empty spaces first, then by newest (highest index)
    # Also avoid removing currently focused space
    local current_space=$(yabai -m query --spaces --space | jq -r '.index' 2>/dev/null || echo "")
    local space_data=($(yabai -m query --spaces | jq -r ".[] | select(.index != $current_space) | \"\(.id):\(.index):\((.windows | length)):\(.display)\"" | sort -t: -k3,3n -k2,2nr))
    
    local removed=0
    for space_info in "${space_data[@]}"; do
        if [ $removed -ge $excess ]; then
            break
        fi
        
        IFS=':' read -r space_id space_index window_count display_index <<< "$space_info"
        
        # Skip if this is the only space on its display
        local spaces_on_display=$(yabai -m query --spaces | jq "[.[] | select(.display == $display_index)] | length")
        if [ $spaces_on_display -le 1 ]; then
            continue
        fi
        
        # Skip if this space is currently visible
        local is_visible=$(yabai -m query --spaces | jq -r ".[] | select(.id == $space_id) | .\"is-visible\"")
        if [ "$is_visible" = "true" ]; then
            continue
        fi
        
        # If space has windows, move them to the first space on the same display
        if [ $window_count -gt 0 ]; then
            local target_space_id=$(yabai -m query --spaces | jq -r ".[] | select(.display == $display_index and .id != $space_id) | .id" | head -n 1)
            if [ -n "$target_space_id" ] && [ "$target_space_id" != "null" ]; then
                move_windows_from_space $space_id $target_space_id
                # Wait a bit for windows to move
                sleep 0.2
            fi
        fi
        
        # Try to remove the space
        if yabai -m space $space_id --destroy 2>/dev/null; then
            log "Globally removed excess space $space_id (index $space_index) from display $display_index"
            ((removed++))
            # Wait a bit between removals to avoid race conditions
            sleep 0.1
        else
            warn "Failed to remove excess space $space_id from display $display_index"
        fi
    done
    
    success "Removed $removed excess spaces globally"
    return $removed
}

# Redistribute spaces across all displays
redistribute_spaces() {
    log "Starting space redistribution..."
    
    local display_count=$(get_display_count)
    local total_spaces=$(get_total_space_count)
    
    log "Current setup: $display_count displays, $total_spaces total spaces"
    
    if [ $display_count -eq 0 ]; then
        error "No displays found!"
        return 1
    fi
    
    # First, remove excess spaces if total exceeds maximum
    if [ $total_spaces -gt $MAX_TOTAL_SPACES ]; then
        remove_excess_spaces_globally
        total_spaces=$(get_total_space_count)
        log "After removing excess spaces: $total_spaces total spaces"
    fi
    
    # Calculate optimal distribution
    read base_spaces remainder target_total <<< $(calculate_distribution $display_count $total_spaces)
    
    log "Target distribution: $base_spaces base spaces per display, $remainder displays get +1 extra"
    log "Target total spaces: $target_total"
    
    # Get display indices
    local display_indices=($(yabai -m query --displays | jq -r '.[].index' | sort -n))
    
    # First pass: adjust each display to target count
    for i in "${!display_indices[@]}"; do
        local display_index=${display_indices[$i]}
        local current_spaces=$(yabai -m query --spaces | jq "[.[] | select(.display == $display_index)] | length")
        
        # Calculate target for this display (first 'remainder' displays get +1)
        local target_spaces=$base_spaces
        if [ $i -lt $remainder ]; then
            target_spaces=$((base_spaces + 1))
        fi
        
        log "Display $display_index: $current_spaces → $target_spaces spaces"
        
        if [ $current_spaces -lt $target_spaces ]; then
            local needed=$((target_spaces - current_spaces))
            create_spaces_on_display $display_index $needed
        elif [ $current_spaces -gt $target_spaces ]; then
            local excess=$((current_spaces - target_spaces))
            remove_spaces_from_display $display_index $excess
        fi
    done
    
    # Final check: ensure we haven't exceeded maximum
    local final_total=$(get_total_space_count)
    if [ $final_total -gt $MAX_TOTAL_SPACES ]; then
        warn "Final total ($final_total) still exceeds maximum. Removing excess..."
        remove_excess_spaces_globally
    fi
    
    # Update SketchyBar
    update_sketchybar
    
    success "Space redistribution complete!"
}

# Update SketchyBar to reflect changes
update_sketchybar() {
    if command -v sketchybar &> /dev/null; then
        log "Updating SketchyBar..."
        sketchybar --trigger space_change
        sketchybar --trigger display_change
        sketchybar --trigger windows_on_spaces
        sleep 0.5
        sketchybar --update
        success "SketchyBar updated"
    else
        warn "SketchyBar not found, skipping update"
    fi
}

# Display current status
show_status() {
    log "Current Display and Space Status:"
    echo
    
    local displays=$(yabai -m query --displays)
    local spaces=$(yabai -m query --spaces)
    
    echo "$displays" | jq -r '.[] | "Display \(.index): \(.frame.w)x\(.frame.h) (\(.id))"'
    echo
    
    local display_indices=($(echo "$displays" | jq -r '.[].index' | sort -n))
    
    for display_index in "${display_indices[@]}"; do
        echo "Display $display_index spaces:"
        echo "$spaces" | jq -r ".[] | select(.display == $display_index) | \"  Space \(.index): \(.id) (\(.windows | length) windows)\""
    done
    
    local total_spaces=$(echo "$spaces" | jq 'length')
    local display_count=$(echo "$displays" | jq 'length')
    echo
    echo "Total: $display_count displays, $total_spaces/$MAX_TOTAL_SPACES spaces"
    
    if [ $total_spaces -gt $MAX_TOTAL_SPACES ]; then
        echo -e "${RED}⚠ Warning: Total spaces exceeds maximum limit!${NC}"
    elif [ $total_spaces -eq $MAX_TOTAL_SPACES ]; then
        echo -e "${YELLOW}📊 At maximum space limit${NC}"
    else
        echo -e "${GREEN}✓ Within space limits${NC}"
    fi
}

# Monitor for display changes
monitor_displays() {
    log "Starting display monitor..."
    
    local last_display_config=""
    
    while true; do
        local current_config=$(yabai -m query --displays | jq -c 'sort_by(.index)')
        
        if [ "$current_config" != "$last_display_config" ]; then
            if [ -n "$last_display_config" ]; then
                log "Display configuration changed!"
                sleep 2  # Wait for system to stabilize
                redistribute_spaces
            fi
            last_display_config="$current_config"
        fi
        
        sleep 1
    done
}

# Main function
main() {
    local action=${1:-redistribute}
    
    case $action in
        "redistribute"|"balance")
            check_dependencies
            redistribute_spaces
            ;;
        "status"|"show")
            check_dependencies
            show_status
            ;;
        "monitor")
            check_dependencies
            redistribute_spaces  # Initial balance
            monitor_displays
            ;;
        "help"|"-h"|"--help")
            echo "Usage: $0 [redistribute|status|monitor|help]"
            echo
            echo "Commands:"
            echo "  redistribute  Redistribute spaces equally across displays (default)"
            echo "  status        Show current display and space status"
            echo "  monitor       Run continuously and redistribute on display changes"
            echo "  help          Show this help message"
            ;;
        *)
            error "Unknown command: $action"
            echo "Use '$0 help' for usage information"
            exit 1
            ;;
    esac
}

# Cleanup function
cleanup() {
    log "Shutting down monitor..."
    exit 0
}

trap cleanup SIGINT SIGTERM

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
