#!/bin/bash
set -euo pipefail

# Unified Hyprland Utilities Script
# Combines hypr-control.sh and hypr-health.sh functionality
# Usage: hypr-utils.sh [action]

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source libraries if available
if [ -f "$SCRIPT_DIR/lib/logger.sh" ]; then
    source "$SCRIPT_DIR/lib/logger.sh"
    init_logging "hypr-utils"
else
    # Fallback logging functions
    log_info() { echo -e "\033[0;34mℹ INFO:\033[0m $1"; }
    log_success() { echo -e "\033[0;32m✓ SUCCESS:\033[0m $1"; }
    log_error() { echo -e "\033[0;31m✗ ERROR:\033[0m $1" >&2; }
    log_warn() { echo -e "\033[1;33m⚠ WARN:\033[0m $1" >&2; }
fi

if [ -f "$SCRIPT_DIR/lib/config.sh" ]; then
    source "$SCRIPT_DIR/lib/config.sh"
fi

# Colors for output (legacy support)
BLUE='\033[0;34m'; GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[1;33m'; NC='\033[0m'

# --- CONTROL FUNCTIONS ---

show_help() {
    echo "Hyprland Utilities Script"
    echo "Usage: $0 [action]"
    echo ""
    echo "Control Actions:"
    echo "  power       - Show power menu"
    echo "  volume      - Show volume control"
    echo "  brightness  - Show brightness control"
    echo "  screenshot  - Take screenshot menu"
    echo "  gamemode    - Toggle gamemode"
    echo "  nightlight  - Toggle night light"
    echo "  reload      - Reload Hyprland configuration"
    echo ""
    echo "Health Check Actions:"
    echo "  health      - Full system health report"
    echo "  core        - Check core services only"
    echo "  files       - Check config files only"
    echo "  system      - Show system snapshot"
    echo "  hypr        - Show Hyprland info"
    echo "  gpu         - Show GPU info"
    echo "  packages    - Show package info"
    echo "  services    - Show optional services"
    echo ""
    echo "Maintenance Actions:"
    echo "  validate    - Validate all configuration files"
    echo "  backup      - Backup current configurations"
    echo "  restore     - Interactive restore from backup"
    echo ""
    echo "  help        - Show this help"
}

power_menu() {
    log_info "Opening power menu"
    
    if ! command_exists wofi; then
        log_error "wofi not found, cannot show power menu"
        return 1
    fi
    
    choice=$(echo -e "🔒 Lock\n🚪 Logout\n🔄 Reboot\n⏻ Shutdown\n💤 Suspend" | wofi --show dmenu --prompt "Power Menu" --width 300 --height 250)
    
    case "$choice" in
        "🔒 Lock")
            log_info "Locking screen"
            if command_exists swaylock; then
                hyprctl dispatch exec "swaylock" || log_error "Failed to lock screen"
            else
                log_error "swaylock not found"
            fi
            ;;
        "🚪 Logout")
            log_info "Logging out"
            hyprctl dispatch exit || log_error "Failed to logout"
            ;;
        "🔄 Reboot")
            log_info "Rebooting system"
            systemctl reboot || log_error "Failed to reboot"
            ;;
        "⏻ Shutdown")
            log_info "Shutting down system"
            systemctl poweroff || log_error "Failed to shutdown"
            ;;
        "💤 Suspend")
            log_info "Suspending system"
            systemctl suspend || log_error "Failed to suspend"
            ;;
        "")
            log_info "Power menu cancelled"
            ;;
        *)
            log_warn "Unknown power menu choice: $choice"
            ;;
    esac
}

volume_control() {
    choice=$(echo -e "Mute\nVolume Up\nVolume Down\nMax Volume\nMin Volume" | wofi --show dmenu --prompt "Volume Control")
    
    case "$choice" in
        "Mute")
            pactl set-sink-mute @DEFAULT_SINK@ toggle
            ;;
        "Volume Up")
            pactl set-sink-volume @DEFAULT_SINK@ +5%
            ;;
        "Volume Down")
            pactl set-sink-volume @DEFAULT_SINK@ -5%
            ;;
        "Max Volume")
            pactl set-sink-volume @DEFAULT_SINK@ 100%
            ;;
        "Min Volume")
            pactl set-sink-volume @DEFAULT_SINK@ 0%
            ;;
    esac
}

screenshot_menu() {
    choice=$(echo -e "Full Screen\nSelect Area\nCurrent Window\nSelect Area (Save)\nFull Screen (Save)" | wofi --show dmenu --prompt "Screenshot")
    
    case "$choice" in
        "Full Screen")
            grim - | wl-copy
            ;;
        "Select Area")
            grim -g "$(slurp)" - | wl-copy
            ;;
        "Current Window")
            grim -g "$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')" - | wl-copy
            ;;
        "Select Area (Save)")
            grim -g "$(slurp)" ~/Pictures/Screenshots/$(date +'%Y%m%d-%H%M%S.png')
            ;;
        "Full Screen (Save)")
            grim ~/Pictures/Screenshots/$(date +'%Y%m%d-%H%M%S.png')
            ;;
    esac
}

toggle_gamemode() {
    if hyprctl getoption animations:enabled | grep -q "int: 1"; then
        hyprctl --batch "\
            keyword animations:enabled 0;\
            keyword decoration:drop_shadow 0;\
            keyword decoration:blur:enabled 0;\
            keyword general:gaps_in 0;\
            keyword general:gaps_out 0"
        notify-send "Game Mode" "Enabled - Animations and effects disabled"
    else
        hyprctl --batch "\
            keyword animations:enabled 1;\
            keyword decoration:drop_shadow 1;\
            keyword decoration:blur:enabled 1;\
            keyword general:gaps_in 5;\
            keyword general:gaps_out 10"
        notify-send "Game Mode" "Disabled - Animations and effects enabled"
    fi
}

toggle_nightlight() {
    if pgrep -x "gammastep" > /dev/null; then
        pkill gammastep
        notify-send "Night Light" "Disabled" --icon=weather-clear-night
    else
        gammastep -O 4000 &
        disown
        notify-send "Night Light" "Enabled" --icon=weather-clear-night
    fi
}

# --- HEALTH CHECK FUNCTIONS ---

header() { printf "\n%s\n%s\n" "${BLUE}$1${NC}" "$(printf '%*s' ${#1} '' | tr ' ' '=')"; }
ok(){ echo -e "${GREEN}✓${NC} $1"; }
warn(){ echo -e "${YELLOW}!${NC} $1"; }
err(){ echo -e "${RED}✗${NC} $1"; }

section_core() {
    header "Core Services"
    for p in Hyprland waybar swww-daemon mako; do
        if pgrep -x "$p" >/dev/null 2>&1; then 
            ok "$p running"
        else 
            err "$p not running"
        fi
    done
}

section_files() {
    header "Config Files"
    for f in \
        "$HOME/.config/hypr/hyprland.conf" \
        "$HOME/.config/waybar/config.jsonc" \
        "$HOME/.config/waybar/style.css" \
        "$HOME/.config/wofi/wofi.conf" \
        "$HOME/.config/mako/config"
    do
        if [ -f "$f" ]; then
            ok "$(basename "$f")"
        else
            err "$(basename "$f") missing"
        fi
    done
}

section_system() {
    header "System Snapshot"
    host=$(hostname)
    kern=$(uname -r)
    up=$(uptime -p | sed 's/up //')
    cpu=$(lscpu | awk -F: '/Model name/ {gsub(/^[ ]+/,"",$2); print $2; exit}')
    mem_used=$(free -h | awk '/^Mem:/ {print $3}')
    mem_tot=$(free -h | awk '/^Mem:/ {print $2}')
    disk=$(df -h / | awk 'NR==2 {print $3"/"$2" ("$5")"}')
    if command -v nvidia-smi >/dev/null; then 
        gpu=$(nvidia-smi --query-gpu=name --format=csv,noheader | head -1)
    fi
    
    echo "Host: $host"
    echo "Kernel: $kern"
    echo "Uptime: $up"
    echo "CPU: $cpu"
    echo "Memory: $mem_used / $mem_tot"
    echo "Disk: $disk"
    [ -n "${gpu:-}" ] && echo "GPU: $gpu"
}

section_hypr() {
    header "Hyprland"
    if ! command -v hyprctl >/dev/null; then 
        err "hyprctl not found"
        return
    fi
    
    echo "Version: $(hyprctl version | head -n1)"
    ws=$(hyprctl activewindow -j 2>/dev/null | jq -r '.workspace.id' 2>/dev/null || echo N/A)
    wins=$(hyprctl clients -j 2>/dev/null | jq length 2>/dev/null || echo 0)
    title=$(hyprctl activewindow -j 2>/dev/null | jq -r '.title' 2>/dev/null || echo N/A)
    echo "Workspace: $ws"
    echo "Windows: $wins"
    echo "Active: $title"
}

section_packages() {
    header "Packages"
    if command -v pacman >/dev/null; then
        total=$(pacman -Q | wc -l)
        explicit=$(pacman -Qe | wc -l)
        updates=$(checkupdates 2>/dev/null | wc -l || echo 0)
        echo "Total: $total"
        echo "Explicit: $explicit"
        [ "$updates" -gt 0 ] && echo "Updates: $updates" || echo "Updates: 0"
    fi
}

section_gpu() {
    if command -v nvidia-smi >/dev/null; then
        header "GPU"
        nvidia-smi --query-gpu=name,utilization.gpu,temperature.gpu,memory.used,memory.total --format=csv,noheader,nounits | head -1 | \
        awk -F', ' '{printf "Name: %s\nUtilization: %s%%\nTemperature: %s°C\nMemory: %s/%s MB\n", $1, $2, $3, $4, $5}'
    fi
}

section_services() {
    header "Optional Services"
    for svc in bluetooth docker sshd; do
        if systemctl is-active --quiet "$svc" 2>/dev/null; then
            ok "$svc active"
        else
            warn "$svc inactive"
        fi
    done
}

full_report() {
    section_core
    section_files
    section_system
    section_hypr
    section_gpu
    section_packages
    section_services
}

# --- MAINTENANCE FUNCTIONS ---

reload_hyprland() {
    log_info "Reloading Hyprland configuration"
    
    # Validate config first
    if command -v validate_config >/dev/null 2>&1; then
        if ! validate_config "$HOME/.config/hypr/hyprland.conf" "hypr"; then
            log_error "Configuration validation failed, aborting reload"
            return 1
        fi
    fi
    
    if hyprctl reload; then
        log_success "Hyprland configuration reloaded successfully"
        if command_exists notify-send; then
            notify-send "Hyprland" "Configuration reloaded" --icon=preferences-system
        fi
    else
        log_error "Failed to reload Hyprland configuration"
        return 1
    fi
}

validate_configs() {
    log_info "Validating all configuration files"
    
    if command -v validate_all_configs >/dev/null 2>&1; then
        validate_all_configs "hypr-utils"
    else
        # Fallback validation
        local error_count=0
        
        # Check Hyprland config
        if [ -f "$HOME/.config/hypr/hyprland.conf" ]; then
            if ! bash -n "$HOME/.config/hypr/hyprland.conf" >/dev/null 2>&1; then
                log_error "Hyprland config has syntax issues"
                ((error_count++))
            fi
        fi
        
        # Check waybar config
        if [ -f "$HOME/.config/waybar/config.jsonc" ] && command_exists jq; then
            if ! jq empty "$HOME/.config/waybar/config.jsonc" >/dev/null 2>&1; then
                log_error "Waybar config has JSON syntax issues"
                ((error_count++))
            fi
        fi
        
        if [ "$error_count" -eq 0 ]; then
            log_success "All configuration files are valid"
        else
            log_error "Found $error_count configuration errors"
            return 1
        fi
    fi
}

backup_configs() {
    log_info "Backing up current configurations"
    
    local backup_dir="$HOME/.local/share/dotfiles/backups/manual-$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"
    
    local files_backed_up=0
    
    # Backup main config files
    for config_file in \
        "$HOME/.config/hypr/hyprland.conf" \
        "$HOME/.config/waybar/config.jsonc" \
        "$HOME/.config/waybar/style.css" \
        "$HOME/.config/kitty/kitty.conf" \
        "$HOME/.config/wofi/wofi.conf" \
        "$HOME/.config/wofi/style.css" \
        "$HOME/.config/mako/config"
    do
        if [ -f "$config_file" ]; then
            local target_dir="$backup_dir/$(dirname "${config_file#$HOME/.config/}")"
            mkdir -p "$target_dir"
            if cp "$config_file" "$target_dir/"; then
                ((files_backed_up++))
            else
                log_warn "Failed to backup $config_file"
            fi
        fi
    done
    
    if [ "$files_backed_up" -gt 0 ]; then
        log_success "Backed up $files_backed_up files to $backup_dir"
        echo "$backup_dir" > "$HOME/.cache/last-backup-path"
    else
        log_error "No files were backed up"
        return 1
    fi
}

restore_configs() {
    log_info "Interactive configuration restore"
    
    local backup_base="$HOME/.local/share/dotfiles/backups"
    
    if [ ! -d "$backup_base" ]; then
        log_error "No backup directory found"
        return 1
    fi
    
    # List available backups
    local backups=($(find "$backup_base" -maxdepth 1 -type d -name "*-*" | sort -r))
    
    if [ ${#backups[@]} -eq 0 ]; then
        log_error "No backups found"
        return 1
    fi
    
    log_info "Available backups:"
    for i in "${!backups[@]}"; do
        local backup_name=$(basename "${backups[$i]}")
        local backup_time=$(echo "$backup_name" | grep -o '[0-9_]*$' | tr '_' ' ')
        echo "  $((i+1)). $backup_time"
    done
    
    read -p "Select backup to restore (1-${#backups[@]}): " selection
    
    if [[ "$selection" =~ ^[0-9]+$ ]] && [ "$selection" -ge 1 ] && [ "$selection" -le ${#backups[@]} ]; then
        local selected_backup="${backups[$((selection-1))]}"
        log_info "Restoring from: $(basename "$selected_backup")"
        
        # Create backup of current config before restore
        backup_configs
        
        # Restore files
        if cp -r "$selected_backup"/* "$HOME/.config/"; then
            log_success "Configuration restored successfully"
            log_info "Reloading Hyprland..."
            reload_hyprland
        else
            log_error "Failed to restore configuration"
            return 1
        fi
    else
        log_warn "Invalid selection"
        return 1
    fi
}

# --- MAIN LOGIC ---
case "${1:-help}" in
    # Control actions
    power)
        power_menu
        ;;
    volume)
        volume_control
        ;;
    screenshot)
        screenshot_menu
        ;;
    gamemode)
        toggle_gamemode
        ;;
    nightlight)
        toggle_nightlight
        ;;
    reload)
        reload_hyprland
        ;;
    
    # Health check actions
    health|full|all)
        full_report
        ;;
    core)
        section_core
        ;;
    files)
        section_files
        ;;
    system)
        section_system
        ;;
    hypr)
        section_hypr
        ;;
    gpu)
        section_gpu
        ;;
    packages)
        section_packages
        ;;
    services)
        section_services
        ;;
    
    # Maintenance actions
    validate)
        validate_configs
        ;;
    backup)
        backup_configs
        ;;
    restore)
        restore_configs
        ;;
    
    help|--help|-h)
        show_help
        ;;
    *)
        log_error "Unknown action: $1"
        show_help
        exit 1
        ;;
esac