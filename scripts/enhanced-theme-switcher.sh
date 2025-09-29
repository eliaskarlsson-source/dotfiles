#!/bin/bash

# Enhanced Theme Switcher for Hyprland
# Switches between Catppuccin variants and other themes

WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
CURRENT_THEME_FILE="$HOME/.cache/current-theme"

# Theme definitions
declare -A THEMES=(
    ["catppuccin-mocha"]="Catppuccin Mocha (Dark Purple)"
    ["catppuccin-macchiato"]="Catppuccin Macchiato (Medium)"
    ["catppuccin-frappe"]="Catppuccin Frappe (Light)"
    ["catppuccin-latte"]="Catppuccin Latte (Light)"
    ["dark-blue"]="Dark Blue"
    ["light-minimal"]="Light Minimal"
    ["cyberpunk"]="Cyberpunk Neon"
)

# Color schemes
get_colors() {
    case "$1" in
        "catppuccin-mocha")
            echo "background=1e1e2e surface0=313244 surface1=45475a surface2=585b70 overlay0=6c7086 text=cdd6f4 blue=89b4fa mauve=cba6f7 pink=f5c2e7 red=f38ba8 peach=fab387 yellow=f9e2af green=a6e3a1 teal=94e2d5 sky=89dceb sapphire=74c7ec lavender=b4befe"
            ;;
        "catppuccin-macchiato")
            echo "background=24273a surface0=363a4f surface1=494d64 surface2=5b6078 overlay0=6e738d text=cad3f5 blue=8aadf4 mauve=c6a0f6 pink=f5bde6 red=ed8796 peach=f5a97f yellow=eed49f green=a6da95 teal=8bd5ca sky=91d7e3 sapphire=7dc4e4 lavender=b7bdf8"
            ;;
        "catppuccin-frappe")
            echo "background=303446 surface0=414559 surface1=51576d surface2=626880 overlay0=737994 text=c6d0f5 blue=8caaee mauve=ca9ee6 pink=f4b8e4 red=e78284 peach=ef9f76 yellow=e5c890 green=a6d189 teal=81c8be sky=99d1db sapphire=85c1dc lavender=babbf1"
            ;;
        "catppuccin-latte")
            echo "background=eff1f5 surface0=ccd0da surface1=bcc0cc surface2=acb0be overlay0=9ca0b0 text=4c4f69 blue=1e66f5 mauve=8839ef pink=ea76cb red=d20f39 peach=fe640b yellow=df8e1d green=40a02b teal=179299 sky=04a5e5 sapphire=209fb5 lavender=7287fd"
            ;;
        "dark-blue")
            echo "background=0f1419 surface0=1a252f surface1=253340 surface2=304050 overlay0=3d4f5f text=e6e1cf blue=39bae6 mauve=7aa2f7 pink=bb9af7 red=f7768e peach=ff9e64 yellow=e0af68 green=9ece6a teal=73daca sky=2ac3de sapphire=39bae6 lavender=bb9af7"
            ;;
        "light-minimal")
            echo "background=ffffff surface0=f5f5f5 surface1=eeeeee surface2=e0e0e0 overlay0=bdbdbd text=212121 blue=1976d2 mauve=7b1fa2 pink=c2185b red=d32f2f peach=f57c00 yellow=fbc02d green=388e3c teal=00796b sky=0288d1 sapphire=0277bd lavender=5e35b1"
            ;;
        "cyberpunk")
            echo "background=0a0e27 surface0=16213e surface1=1a2332 surface2=233047 overlay0=2d3748 text=00f5ff blue=00f5ff mauve=ff00ff pink=ff1493 red=ff073a peach=ff8c00 yellow=ffff00 green=39ff14 teal=00ffff sky=87ceeb sapphire=0080ff lavender=dda0dd"
            ;;
        *)
            # Default to catppuccin-mocha
            echo "background=1e1e2e surface0=313244 surface1=45475a surface2=585b70 overlay0=6c7086 text=cdd6f4 blue=89b4fa mauve=cba6f7 pink=f5c2e7 red=f38ba8 peach=fab387 yellow=f9e2af green=a6e3a1 teal=94e2d5 sky=89dceb sapphire=74c7ec lavender=b4befe"
            ;;
    esac
}

apply_waybar_theme() {
    local theme="$1"
    local colors=$(get_colors "$theme")
    
    # Parse colors into variables
    eval $colors
    # Ensure directory exists
    mkdir -p "$HOME/.config/waybar"
    
    cat > "$HOME/.config/waybar/style.css" << EOF
/* Waybar Theme: $theme */
* {
    border: none;
    border-radius: 0;
    font-family: "JetBrainsMono Nerd Font", monospace;
    font-size: 13px;
    min-height: 0;
}

window#waybar {
    background: alpha(#$background, 0.9);
    color: #$text;
    transition-property: background-color;
    transition-duration: .5s;
    border-bottom: 3px solid alpha(#$mauve, 0.5);
}

button {
    box-shadow: inset 0 -3px transparent;
    border: none;
    border-radius: 0;
}

#workspaces button {
    padding: 0 8px;
    background-color: transparent;
    color: #$overlay0;
    border-bottom: 3px solid transparent;
}

#workspaces button:hover {
    background: alpha(#$surface1, 0.8);
    color: #$text;
}

#workspaces button.active {
    color: #$mauve;
    border-bottom: 3px solid #$mauve;
}

#workspaces button.urgent {
    color: #$red;
    border-bottom: 3px solid #$red;
}

#clock,
#battery,
#cpu,
#memory,
#disk,
#temperature,
#backlight,
#network,
#pulseaudio,
#tray,
#mode,
#idle_inhibitor {
    padding: 0 12px;
    color: #$text;
    background: alpha(#$surface0, 0.8);
    margin: 2px 1px;
    border-radius: 8px;
}

#window {
    padding: 0 12px;
    color: #$blue;
    font-weight: bold;
}

#clock {
    color: #$lavender;
    background: alpha(#$surface1, 0.8);
}

#battery {
    color: #$green;
}

#battery.charging {
    color: #$yellow;
}

#battery.warning:not(.charging) {
    color: #$peach;
}

#battery.critical:not(.charging) {
    color: #$red;
    animation-name: blink;
    animation-duration: 0.5s;
    animation-timing-function: linear;
    animation-iteration-count: infinite;
    animation-direction: alternate;
}

#cpu {
    color: #$blue;
}

#memory {
    color: #$pink;
}

#network {
    color: #$teal;
}

#network.disconnected {
    color: #$red;
}

#pulseaudio {
    color: #$yellow;
}

#pulseaudio.muted {
    color: #$red;
}

#backlight {
    color: #$peach;
}

@keyframes blink {
    to {
        background-color: #$red;
        color: #$background;
    }
}

tooltip {
    border-radius: 8px;
    background: alpha(#$surface0, 0.95);
    color: #$text;
    border: 2px solid #$mauve;
}
EOF
    
    # Restart waybar if it's running
    if pgrep -x waybar > /dev/null; then
        pkill waybar
        waybar &
    fi
}

apply_wofi_theme() {
    local theme="$1"
    local colors=$(get_colors "$theme")
    
    # Parse colors into variables
    eval $colors
    # Ensure directory exists
    mkdir -p "$HOME/.config/wofi"
    
    # Update wofi style with theme colors
    cat > "$HOME/.config/wofi/style.css" << EOF
/* Enhanced Wofi Theme: $theme */
window {
    margin: 0;
    border: 2px solid alpha(#$mauve, 0.8);
    border-radius: 12px;
    background: alpha(#$background, 0.95);
    backdrop-filter: blur(10px);
    font-family: "JetBrainsMono Nerd Font", monospace;
    animation: slideIn 0.2s cubic-bezier(0.25, 0.46, 0.45, 0.94);
}

@keyframes slideIn {
    from {
        opacity: 0;
        transform: translateY(-20px) scale(0.95);
    }
    to {
        opacity: 1;
        transform: translateY(0) scale(1);
    }
}

#input {
    all: unset;
    min-height: 36px;
    padding: 8px 16px;
    margin: 12px;
    border: 2px solid alpha(#$surface1, 0.5);
    border-radius: 8px;
    background: alpha(#$surface0, 0.8);
    color: #$text;
    font-size: 14px;
    font-weight: 500;
    transition: all 0.2s ease;
}

#input:focus {
    border-color: #$mauve;
    background: alpha(#$surface1, 0.9);
    box-shadow: 0 0 0 2px alpha(#$mauve, 0.2);
}

#input image {
    color: #$overlay0;
    margin-right: 8px;
}

#inner-box {
    margin: 8px 12px 12px 12px;
    border-radius: 8px;
    background: transparent;
}

#outer-box {
    margin: 0;
    border-radius: 12px;
    background: transparent;
}

#scroll {
    border: none;
    border-radius: 8px;
    background: transparent;
}

#img {
    margin-right: 12px;
    background: transparent;
    border-radius: 6px;
}

#text {
    color: #$text;
    font-size: 14px;
    font-weight: 500;
}

#text:selected {
    color: #$background;
    font-weight: 600;
}

#entry {
    background: transparent;
    border: none;
    border-radius: 8px;
    margin: 2px;
    padding: 8px 12px;
    transition: all 0.15s ease;
}

#entry:hover {
    background: alpha(#$surface1, 0.6);
    transform: translateX(4px);
}

#entry:selected {
    background: linear-gradient(135deg, #$mauve, #$blue);
    transform: translateX(6px);
    box-shadow: 0 4px 12px alpha(#$mauve, 0.3);
}

#entry:selected #text {
    color: #$background;
    text-shadow: 0 1px 2px rgba(0,0,0,0.3);
}

#entry:hover #text {
    color: #$text;
}

#entry.urgent {
    background: alpha(#$red, 0.8);
    color: #$background;
}

#entry.urgent #text {
    color: #$background;
    font-weight: bold;
}

/* Custom scrollbar */
scrollbar {
    width: 6px;
}

scrollbar track {
    background: alpha(#$surface0, 0.5);
    border-radius: 3px;
}

scrollbar thumb {
    background: alpha(#$mauve, 0.7);
    border-radius: 3px;
}

scrollbar thumb:hover {
    background: #$mauve;
}
EOF
}

apply_mako_theme() {
    local theme="$1"
    local colors=$(get_colors "$theme")
    
    # Parse colors into variables  
    eval $colors
    # Ensure directory exists
    mkdir -p "$HOME/.config/mako"
    
    cat > "$HOME/.config/mako/config" << EOF
# Mako notification daemon configuration
# Theme: $theme

# Position and dimensions
anchor=top-right
width=350
height=100
margin=10
padding=15
border-size=2
border-radius=8

# Timeout settings
default-timeout=3000
ignore-timeout=0

# Theme colors
background-color=#$background
text-color=#$text
border-color=#$blue
progress-color=#$green

# Typography
font=JetBrains Mono Nerd Font 14
markup=1
format=<b>%s</b>\\n%b

# Behavior
sort=-time
layer=overlay
max-history=100
max-visible=5

# Icons
icons=1
max-icon-size=48
icon-path=/usr/share/icons/Papirus-Dark

# Grouping
group-by=app-name

# Actions
actions=1
on-button-left=dismiss
on-button-middle=none
on-button-right=dismiss-all
on-touch=dismiss

# Urgency-specific overrides
[urgency=low]
background-color=#$surface1
border-color=#$overlay0
default-timeout=3000

[urgency=normal]
background-color=#$background
border-color=#$blue
default-timeout=3000

[urgency=critical]
background-color=#$red
text-color=#$background
border-color=#$red
default-timeout=0
EOF

    # Restart mako if it's running
    if pgrep -x mako > /dev/null; then
        pkill mako
        mako &
    fi
}

set_wallpaper() {
    local theme="$1"
    local wallpaper_file=""
    
    # Create wallpaper directory if it doesn't exist
    mkdir -p "$WALLPAPER_DIR"
    
    # Look for theme-specific wallpaper
    if [ -f "$WALLPAPER_DIR/$theme.jpg" ]; then
        wallpaper_file="$WALLPAPER_DIR/$theme.jpg"
    elif [ -f "$WALLPAPER_DIR/$theme.png" ]; then
        wallpaper_file="$WALLPAPER_DIR/$theme.png"
    elif [ -f "$WALLPAPER_DIR/$theme.jpeg" ]; then
        wallpaper_file="$WALLPAPER_DIR/$theme.jpeg"
    elif [ -f "$WALLPAPER_DIR/$theme.webp" ]; then
        wallpaper_file="$WALLPAPER_DIR/$theme.webp"
    else
        # Fall back to any wallpaper in the directory
        wallpaper_file=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" -o -iname "*.webp" \) | head -1)
    fi
    
    if [ -n "$wallpaper_file" ] && [ -f "$wallpaper_file" ]; then
        # Use swww if available, otherwise hyprpaper
        if command -v swww > /dev/null; then
            # Ensure swww daemon is running
            if ! pgrep -x swww-daemon > /dev/null; then
                swww-daemon &
                sleep 1
            fi
            swww img "$wallpaper_file" --transition-fps 60 --transition-type wipe --transition-duration 1
        elif command -v hyprpaper > /dev/null; then
            # Update hyprpaper config
            echo "preload = $wallpaper_file" > "$HOME/.config/hypr/hyprpaper.conf"
            echo "wallpaper = ,$wallpaper_file" >> "$HOME/.config/hypr/hyprpaper.conf"
            
            # Restart hyprpaper
            pkill hyprpaper 2>/dev/null
            hyprpaper &
        fi
        
        # Record current wallpaper for status tools
        echo "$wallpaper_file" > "$HOME/.cache/current-wallpaper"

        echo "Wallpaper set to: $wallpaper_file"
    else
        echo "No wallpaper found for theme $theme"
    fi
}

show_theme_menu() {
    local theme_list=""
    for theme in "${!THEMES[@]}"; do
        theme_list="$theme_list$theme: ${THEMES[$theme]}\n"
    done
    
    selected=$(echo -e "$theme_list" | wofi --conf "$HOME/.config/wofi/wofi.conf" --style "$HOME/.config/wofi/style.css" --dmenu --prompt="Select Theme")
    
    if [ -n "$selected" ]; then
        theme=$(echo "$selected" | cut -d':' -f1)
        apply_theme "$theme"
    fi
}

apply_theme() {
    local theme="$1"
    
    if [ -z "${THEMES[$theme]}" ]; then
        echo "Unknown theme: $theme"
        echo "Available themes:"
        for t in "${!THEMES[@]}"; do
            echo "  $t: ${THEMES[$t]}"
        done
        return 1
    fi
    
    echo "Applying theme: ${THEMES[$theme]}"
    
    # Apply all theme components
    apply_waybar_theme "$theme"
    apply_wofi_theme "$theme"  
    apply_mako_theme "$theme"
    set_wallpaper "$theme"
    
    # Save current theme
    echo "$theme" > "$CURRENT_THEME_FILE"
    
    # Send notification
    notify-send "Theme Switcher" "Applied theme: ${THEMES[$theme]}" --icon=preferences-desktop-theme
    
    echo "Theme applied successfully!"
}

get_current_theme() {
    if [ -f "$CURRENT_THEME_FILE" ]; then
        cat "$CURRENT_THEME_FILE"
    else
        echo "catppuccin-mocha"
    fi
}

show_help() {
    echo "Enhanced Theme Switcher"
    echo "Usage: $0 [theme|menu|current|list|help]"
    echo ""
    echo "Commands:"
    echo "  menu     - Show interactive theme selector"
    echo "  current  - Show current theme"
    echo "  list     - List available themes"
    echo "  help     - Show this help"
    echo ""
    echo "Available themes:"
    for theme in "${!THEMES[@]}"; do
        echo "  $theme - ${THEMES[$theme]}"
    done
}

# Main logic
case "${1:-menu}" in
    "menu")
        show_theme_menu
        ;;
    "current")
        current=$(get_current_theme)
        echo "Current theme: $current (${THEMES[$current]})"
        ;;
    "list")
        echo "Available themes:"
        for theme in "${!THEMES[@]}"; do
            current=$(get_current_theme)
            if [ "$theme" = "$current" ]; then
                echo "* $theme - ${THEMES[$theme]} (current)"
            else
                echo "  $theme - ${THEMES[$theme]}"
            fi
        done
        ;;
    "help"|"-h"|"--help")
        show_help
        ;;
    *)
        apply_theme "$1"
        ;;
esac