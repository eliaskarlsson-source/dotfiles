#!/bin/bash

# Enhanced Wofi Launcher Script
# Provides different modes and better functionality

show_help() {
    echo "Wofi Launcher"
    echo "Usage: $0 [apps|run|window|help]"
}

# Common wofi options
WOFI_OPTS="--conf=$HOME/.config/wofi/wofi.conf --style=$HOME/.config/wofi/style.css"

launch_apps() {
    wofi $WOFI_OPTS --show=drun --prompt="󰀻 Applications"
}

launch_run() {
    wofi $WOFI_OPTS --show=run --prompt="Run Command"
}

launch_window() {
    # Get window list from hyprctl
    windows=$(hyprctl clients -j | jq -r '.[] | "\(.class): \(.title)"' | grep -v "^$")
    
    if [ -z "$windows" ]; then
        notify-send "Window Switcher" "No windows found"
        return
    fi
    
    selected=$(echo "$windows" | wofi $WOFI_OPTS --dmenu --prompt="Switch Window")
    
    if [ -n "$selected" ]; then
        # Extract class and title to focus window
        class=$(echo "$selected" | cut -d':' -f1)
        hyprctl dispatch focuswindow "class:$class"
    fi
}


# Main logic
case "${1:-apps}" in
    "apps"|"drun")
        launch_apps
        ;;
    "run")
        launch_run
        ;;
    "window")
        launch_window
        ;;
    "help"|"-h"|"--help")
        show_help
        ;;
    *)
        echo "Unknown mode: $1"
        show_help
        exit 1
        ;;
esac