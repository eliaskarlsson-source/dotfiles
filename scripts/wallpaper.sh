#!/bin/bash

# Simple and reliable wallpaper script using swww
# Usage: ./wallpaper.sh [wallpaper_path]

WALLPAPER_DIR="$HOME/Pictures/Wallpapers"

# Function to set wallpaper with swww
set_wallpaper() {
    local wallpaper="$1"
    
    if [ -z "$wallpaper" ]; then
        echo "No wallpaper specified"
        return 1
    fi
    
    if [ ! -f "$wallpaper" ]; then
        echo "Wallpaper file does not exist: $wallpaper"
        return 1
    fi
    
    echo "Setting wallpaper: $wallpaper"
    
    # Start swww daemon if not running
    if ! pgrep -x "swww-daemon" > /dev/null; then
        echo "Starting swww daemon..."
        swww-daemon &
        sleep 2
    fi
    
    # Set wallpaper with swww
    swww img "$wallpaper" --transition-type wipe --transition-duration 1
    if [ $? -eq 0 ]; then
        echo "Wallpaper set successfully!"
        return 0
    else
        echo "Failed to set wallpaper"
        return 1
    fi
}

# If a specific wallpaper is provided as argument
if [ $# -gt 0 ]; then
    set_wallpaper "$1"
    exit $?
fi

# Otherwise, get a random wallpaper
if [ ! -d "$WALLPAPER_DIR" ]; then
    echo "Wallpaper directory $WALLPAPER_DIR does not exist!"
    echo "Creating directory..."
    mkdir -p "$WALLPAPER_DIR"
    echo "Please add some wallpapers to $WALLPAPER_DIR"
    exit 1
fi

# Get a random wallpaper from the directory
WALLPAPER=$(find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.bmp" \) | shuf -n1)

if [ -z "$WALLPAPER" ]; then
    echo "No wallpapers found in $WALLPAPER_DIR"
    echo "Please add some wallpapers to $WALLPAPER_DIR"
    exit 1
fi

set_wallpaper "$WALLPAPER"
