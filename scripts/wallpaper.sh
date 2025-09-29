#!/bin/bash

# Enhanced wallpaper script using swww with better features
# Usage: ./wallpaper.sh [wallpaper_path|--random|--next|--prev]

WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
CURRENT_WALLPAPER_FILE="$HOME/.cache/current_wallpaper"
WALLPAPER_LIST_FILE="$HOME/.cache/wallpaper_list"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Function to print colored output
print_colored() {
    echo -e "${2}${1}${NC}"
}

# Function to create wallpaper list
create_wallpaper_list() {
    if [ ! -d "$WALLPAPER_DIR" ]; then
        print_colored "Wallpaper directory $WALLPAPER_DIR does not exist!" "$RED"
        print_colored "Creating directory..." "$YELLOW"
        mkdir -p "$WALLPAPER_DIR"
        print_colored "Please add some wallpapers to $WALLPAPER_DIR" "$BLUE"
        return 1
    fi
    
    find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.bmp" -o -name "*.webp" \) > "$WALLPAPER_LIST_FILE"
    
    if [ ! -s "$WALLPAPER_LIST_FILE" ]; then
        print_colored "No wallpapers found in $WALLPAPER_DIR" "$RED"
        return 1
    fi
    
    return 0
}

# Function to set wallpaper with swww
set_wallpaper() {
    local wallpaper="$1"
    local transition_type="${2:-wipe}"
    local transition_duration="${3:-1}"
    
    if [ -z "$wallpaper" ]; then
        print_colored "No wallpaper specified" "$RED"
        return 1
    fi
    
    if [ ! -f "$wallpaper" ]; then
        print_colored "Wallpaper file does not exist: $wallpaper" "$RED"
        return 1
    fi
    
    print_colored "Setting wallpaper: $(basename "$wallpaper")" "$BLUE"
    
    # Start swww daemon if not running
    if ! pgrep -x "swww-daemon" > /dev/null; then
        print_colored "Starting swww daemon..." "$YELLOW"
        swww-daemon &
        sleep 2
    fi
    
    # Set wallpaper with swww
    swww img "$wallpaper" --transition-type "$transition_type" --transition-duration "$transition_duration"
    if [ $? -eq 0 ]; then
        echo "$wallpaper" > "$CURRENT_WALLPAPER_FILE"
        print_colored "Wallpaper set successfully!" "$GREEN"
        
        # Send notification
        if command -v notify-send > /dev/null; then
            notify-send "Wallpaper Changed" "$(basename "$wallpaper")" --icon="$wallpaper" --app-name="Wallpaper Manager"
        fi
        return 0
    else
        print_colored "Failed to set wallpaper" "$RED"
        return 1
    fi
}

# Function to get random wallpaper
get_random_wallpaper() {
    if ! create_wallpaper_list; then
        return 1
    fi
    
    shuf -n1 "$WALLPAPER_LIST_FILE"
}

# Function to get next wallpaper
get_next_wallpaper() {
    if ! create_wallpaper_list; then
        return 1
    fi
    
    if [ ! -f "$CURRENT_WALLPAPER_FILE" ]; then
        get_random_wallpaper
        return $?
    fi
    
    local current_wallpaper=$(cat "$CURRENT_WALLPAPER_FILE")
    local next_wallpaper=$(grep -A1 "$current_wallpaper" "$WALLPAPER_LIST_FILE" | tail -n1)
    
    # If we're at the end, wrap to beginning
    if [ "$next_wallpaper" = "$current_wallpaper" ] || [ -z "$next_wallpaper" ]; then
        next_wallpaper=$(head -n1 "$WALLPAPER_LIST_FILE")
    fi
    
    echo "$next_wallpaper"
}

# Function to get previous wallpaper
get_prev_wallpaper() {
    if ! create_wallpaper_list; then
        return 1
    fi
    
    if [ ! -f "$CURRENT_WALLPAPER_FILE" ]; then
        get_random_wallpaper
        return $?
    fi
    
    local current_wallpaper=$(cat "$CURRENT_WALLPAPER_FILE")
    local prev_wallpaper=$(grep -B1 "$current_wallpaper" "$WALLPAPER_LIST_FILE" | head -n1)
    
    # If we're at the beginning, wrap to end
    if [ "$prev_wallpaper" = "$current_wallpaper" ] || [ -z "$prev_wallpaper" ]; then
        prev_wallpaper=$(tail -n1 "$WALLPAPER_LIST_FILE")
    fi
    
    echo "$prev_wallpaper"
}

# Show help
show_help() {
    echo "Enhanced Wallpaper Manager"
    echo "Usage: $0 [OPTIONS] [WALLPAPER_PATH]"
    echo ""
    echo "OPTIONS:"
    echo "  --random, -r     Set a random wallpaper"
    echo "  --next, -n       Set next wallpaper in sequence"
    echo "  --prev, -p       Set previous wallpaper in sequence"
    echo "  --help, -h       Show this help message"
    echo ""
    echo "WALLPAPER_PATH:"
    echo "  Path to a specific wallpaper file"
    echo ""
    echo "If no options are provided, a random wallpaper will be set."
}

# Main logic
case "$1" in
    "--random"|"-r")
        wallpaper=$(get_random_wallpaper)
        if [ $? -eq 0 ] && [ -n "$wallpaper" ]; then
            set_wallpaper "$wallpaper" "random" "2"
        fi
        ;;
    "--next"|"-n")
        wallpaper=$(get_next_wallpaper)
        if [ $? -eq 0 ] && [ -n "$wallpaper" ]; then
            set_wallpaper "$wallpaper" "grow" "1.5"
        fi
        ;;
    "--prev"|"-p")
        wallpaper=$(get_prev_wallpaper)
        if [ $? -eq 0 ] && [ -n "$wallpaper" ]; then
            set_wallpaper "$wallpaper" "outer" "1.5"
        fi
        ;;
    "--help"|"-h")
        show_help
        ;;
    "")
        # No arguments - set random wallpaper
        wallpaper=$(get_random_wallpaper)
        if [ $? -eq 0 ] && [ -n "$wallpaper" ]; then
            set_wallpaper "$wallpaper"
        fi
        ;;
    *)
        # Specific wallpaper provided
        set_wallpaper "$1"
        ;;
esac
