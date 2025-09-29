#!/bin/bash
set -euo pipefail

# Unified Waybar Modules Script
# Combines weather, updates, gpu, and dnd functionality into a single script
# Usage: waybar-modules.sh [weather|updates|gpu|dnd] [args...]

# --- WEATHER MODULE ---
weather_module() {
    local CACHE_FILE="$HOME/.cache/waybar_weather"
    local CACHE_DURATION=1800  # 30 minutes
    
    # Get location (you can hardcode your city here)
    local CITY="Stockholm"  # Change this to your city
    local API_KEY=""  # Optional: Get a free API key from openweathermap.org
    
    get_weather() {
        if [ -n "$API_KEY" ]; then
            # Using OpenWeatherMap API (more accurate but requires API key)
            curl -sf "http://api.openweathermap.org/data/2.5/weather?q=$CITY&appid=$API_KEY&units=metric" | \
            jq -r '.main.temp as $temp | .weather[0].main as $desc | .weather[0].icon as $icon | 
                   "\($temp | round)°C \($desc)"'
        else
            # Using wttr.in (free but less reliable)
            curl -sf "http://wttr.in/$CITY?format=%t+%C" 2>/dev/null | sed 's/+//g'
        fi
    }
    
    get_weather_icon() {
        local weather_desc="$1"
        case "$weather_desc" in
            *"Clear"*|*"Sunny"*) echo "☀️" ;;
            *"Cloud"*|*"Overcast"*) echo "☁️" ;;
            *"Rain"*|*"Drizzle"*) echo "🌧️" ;;
            *"Snow"*|*"Blizzard"*) echo "❄️" ;;
            *"Thunder"*|*"Storm"*) echo "⛈️" ;;
            *"Fog"*|*"Mist"*) echo "🌫️" ;;
            *"Wind"*) echo "💨" ;;
            *) echo "🌤️" ;;
        esac
    }
    
    # Check if cache file exists and is recent
    if [ -f "$CACHE_FILE" ]; then
        cache_age=$(($(date +%s) - $(stat -c %Y "$CACHE_FILE")))
        if [ $cache_age -lt $CACHE_DURATION ]; then
            cat "$CACHE_FILE"
            return 0
        fi
    fi
    
    # Get fresh weather data
    weather_data=$(get_weather)
    
    if [ -n "$weather_data" ] && [ "$weather_data" != "Unknown location" ]; then
        icon=$(get_weather_icon "$weather_data")
        
        # Create JSON output for Waybar
        echo "{\"text\":\"$icon $weather_data\", \"tooltip\":\"Weather in $CITY\"}" | tee "$CACHE_FILE"
    else
        echo "{\"text\":\"🌍 N/A\", \"tooltip\":\"Weather data unavailable\"}"
    fi
}

# --- UPDATES MODULE ---
updates_module() {
    check_updates() {
        if command -v checkupdates > /dev/null; then
            # Arch Linux with checkupdates
            updates=$(checkupdates 2>/dev/null | wc -l)
        elif command -v pacman > /dev/null; then
            # Fallback for pacman
            updates=$(pacman -Qu 2>/dev/null | wc -l)
        else
            echo "0"
            return
        fi
        
        echo "$updates"
    }
    
    updates_count=$(check_updates)
    
    if [ "$updates_count" -gt 0 ]; then
        echo "{\"text\":\"$updates_count\", \"tooltip\":\"$updates_count package updates available\", \"class\":\"updates-available\"}"
    else
        echo "{\"text\":\"\", \"tooltip\":\"System is up to date\", \"class\":\"up-to-date\"}"
    fi
}

# --- GPU MODULE ---
gpu_module() {
    if ! command -v nvidia-smi >/dev/null 2>&1; then
        echo '{"text":"GPU N/A","tooltip":"nvidia-smi not found"}'
        return 0
    fi
    
    IFS=',' read -r UTIL TEMP NAME < <(nvidia-smi --query-gpu=utilization.gpu,temperature.gpu,name --format=csv,noheader,nounits | head -n1 | sed 's/ %, /,/g' | sed 's/ C, /,/g') || true
    
    UTIL=${UTIL// /}
    TEMP=${TEMP// /}
    NAME=${NAME:-GPU}
    
    CLASS="normal"
    if [ "${TEMP:-0}" -ge 80 ]; then
        CLASS="hot"
    elif [ "${TEMP:-0}" -ge 70 ]; then
        CLASS="warm"
    fi
    
    echo "{\"text\":\"${UTIL}% ${TEMP}°C\",\"tooltip\":\"${NAME}\\nUtil: ${UTIL}%\\nTemp: ${TEMP}°C\",\"class\":\"${CLASS}\"}"
}

# --- DND MODULE ---
dnd_module() {
    local STATE_FILE="$HOME/.cache/dnd-state"
    
    ensure_state() {
        # Always sync state with actual mako process status
        if pgrep -x mako >/dev/null 2>&1; then
            echo on > "$STATE_FILE"
        else
            echo off > "$STATE_FILE"
        fi
    }
    
    print_status() {
        ensure_state
        state=$(cat "$STATE_FILE")
        if [ "$state" = "on" ]; then
            echo '{"text":"󰂚","tooltip":"Do Not Disturb: Off (notifications shown)","class":"dnd-off"}'
        else
            echo '{"text":"󰂛","tooltip":"Do Not Disturb: On (notifications suppressed)","class":"dnd-on"}'
        fi
    }
    
    toggle() {
        ensure_state
        state=$(cat "$STATE_FILE")
        if [ "$state" = "on" ]; then
            # Turn DND on -> show notification first, then kill mako
            notify-send -u low "DND Enabled" "Notifications muted" || true
            sleep 0.5  # Give notification time to appear
            pkill -x mako || true
            echo off > "$STATE_FILE"
        else
            # Turn DND off -> restart mako, then notify
            (mako &>/dev/null &)
            echo on > "$STATE_FILE"
            sleep 0.5  # Give mako time to start
            notify-send -u low "DND Disabled" "Notifications active" || true
        fi
        print_status
    }
    
    case "${2:-status}" in
        toggle) toggle ;;
        status|*) print_status ;;
    esac
}

# --- MEDIA MODULE ---
media_module() {
    local status=$(playerctl status 2>/dev/null || echo "No players")
    
    if [ "$status" = "No players" ] || [ -z "$status" ]; then
        echo '{"text":"","tooltip":"No media playing","class":"stopped"}'
        return 0
    fi
    
    local title=$(playerctl metadata title 2>/dev/null || echo "Unknown")
    local artist=$(playerctl metadata artist 2>/dev/null || echo "Unknown Artist")
    local player=$(playerctl metadata --format "{{playerName}}" 2>/dev/null || echo "Player")
    
    # Limit text length
    if [ ${#title} -gt 30 ]; then
        title="${title:0:27}..."
    fi
    if [ ${#artist} -gt 25 ]; then
        artist="${artist:0:22}..."
    fi
    
    local icon=""
    local class="playing"
    
    case "$status" in
        "Playing")
            icon="󰐊"
            class="playing"
            ;;
        "Paused")
            icon="󰏤"
            class="paused"
            ;;
        "Stopped")
            icon="󰓛"
            class="stopped"
            ;;
        *)
            icon="󰎈"
            class="unknown"
            ;;
    esac
    
    local text=""
    if [ "$title" != "Unknown" ] && [ "$artist" != "Unknown Artist" ]; then
        text="$icon $artist - $title"
    elif [ "$title" != "Unknown" ]; then
        text="$icon $title"
    else
        text="$icon $player"
    fi
    
    echo "{\"text\":\"$text\",\"tooltip\":\"$player: $artist - $title\\nStatus: $status\",\"class\":\"$class\"}"
}

# --- MAIN LOGIC ---
show_help() {
    echo "Waybar Modules Script"
    echo "Usage: $0 [module] [args...]"
    echo ""
    echo "Modules:"
    echo "  weather  - Get weather information"
    echo "  updates  - Check for system updates"
    echo "  gpu      - Get GPU status (NVIDIA)"
    echo "  dnd      - Do Not Disturb toggle/status"
    echo "  media    - Media player information"
    echo ""
    echo "DND Actions:"
    echo "  $0 dnd status - Show current DND status (default)"
    echo "  $0 dnd toggle - Toggle DND on/off"
}

case "${1:-help}" in
    weather)
        weather_module
        ;;
    updates)
        updates_module
        ;;
    gpu)
        gpu_module
        ;;
    dnd)
        dnd_module "$@"
        ;;
    media)
        media_module
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo "Unknown module: $1"
        show_help
        exit 1
        ;;
esac