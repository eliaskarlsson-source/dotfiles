#!/bin/bash
# System Monitor - Real-time system monitoring for Hyprland setup

# Get script directory and source libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -f "$SCRIPT_DIR/lib/logger.sh" ]; then
    source "$SCRIPT_DIR/lib/logger.sh"
    init_logging "system-monitor"
else
    log_info() { echo -e "\033[0;34mℹ INFO:\033[0m $1"; }
    log_success() { echo -e "\033[0;32m✓ SUCCESS:\033[0m $1"; }
    log_error() { echo -e "\033[0;31m✗ ERROR:\033[0m $1" >&2; }
    log_warn() { echo -e "\033[1;33m⚠ WARN:\033[0m $1" >&2; }
fi

# Configuration
readonly MONITOR_CONFIG="$HOME/.config/system-monitor.conf"
readonly MONITOR_DATA="$HOME/.local/share/system-monitor"
readonly THRESHOLDS_FILE="$MONITOR_DATA/thresholds.conf"

# Default thresholds
DEFAULT_CPU_THRESHOLD=80
DEFAULT_MEMORY_THRESHOLD=85
DEFAULT_DISK_THRESHOLD=90
DEFAULT_TEMPERATURE_THRESHOLD=75

# Ensure data directory exists
mkdir -p "$MONITOR_DATA"

# Load configuration
load_config() {
    if [ -f "$MONITOR_CONFIG" ]; then
        source "$MONITOR_CONFIG"
    fi
    
    # Set defaults if not configured
    CPU_THRESHOLD=${CPU_THRESHOLD:-$DEFAULT_CPU_THRESHOLD}
    MEMORY_THRESHOLD=${MEMORY_THRESHOLD:-$DEFAULT_MEMORY_THRESHOLD}
    DISK_THRESHOLD=${DISK_THRESHOLD:-$DEFAULT_DISK_THRESHOLD}
    TEMPERATURE_THRESHOLD=${TEMPERATURE_THRESHOLD:-$DEFAULT_TEMPERATURE_THRESHOLD}
    MONITOR_INTERVAL=${MONITOR_INTERVAL:-5}
    NOTIFICATION_COOLDOWN=${NOTIFICATION_COOLDOWN:-300}
}

# Save current metrics
save_metrics() {
    local timestamp=$(date +%s)
    local cpu_usage="$1"
    local memory_usage="$2"
    local disk_usage="$3"
    local temperature="$4"
    
    echo "$timestamp,$cpu_usage,$memory_usage,$disk_usage,$temperature" >> "$MONITOR_DATA/metrics.csv"
    
    # Keep only last 1000 entries
    tail -n 1000 "$MONITOR_DATA/metrics.csv" > "$MONITOR_DATA/metrics.csv.tmp"
    mv "$MONITOR_DATA/metrics.csv.tmp" "$MONITOR_DATA/metrics.csv"
}

# Get CPU usage
get_cpu_usage() {
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1 | sed 's/us,//')
    echo "${cpu_usage:-0}"
}

# Get memory usage
get_memory_usage() {
    local memory_usage=$(free | grep Mem | awk '{printf("%.1f", ($3/$2) * 100.0)}')
    echo "${memory_usage:-0}"
}

# Get disk usage
get_disk_usage() {
    local disk_usage=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
    echo "${disk_usage:-0}"
}

# Get temperature
get_temperature() {
    local temp=0
    
    # Try different temperature sources
    if [ -f "/sys/class/thermal/thermal_zone0/temp" ]; then
        local temp_raw=$(cat /sys/class/thermal/thermal_zone0/temp)
        temp=$((temp_raw / 1000))
    elif command -v sensors >/dev/null 2>&1; then
        temp=$(sensors | grep -i "core 0" | awk '{print $3}' | sed 's/+//g' | sed 's/°C//g' | cut -d'.' -f1 | head -1)
    fi
    
    echo "${temp:-0}"
}

# Check if notification cooldown has expired
can_notify() {
    local metric="$1"
    local cooldown_file="$MONITOR_DATA/.cooldown_$metric"
    local current_time=$(date +%s)
    
    if [ -f "$cooldown_file" ]; then
        local last_notification=$(cat "$cooldown_file")
        local time_diff=$((current_time - last_notification))
        
        if [ "$time_diff" -lt "$NOTIFICATION_COOLDOWN" ]; then
            return 1
        fi
    fi
    
    echo "$current_time" > "$cooldown_file"
    return 0
}

# Send notification
send_notification() {
    local title="$1"
    local message="$2"
    local urgency="${3:-normal}"
    local icon="${4:-dialog-warning}"
    
    if command -v notify-send >/dev/null 2>&1; then
        notify-send -u "$urgency" -i "$icon" "$title" "$message" --app-name="System Monitor"
    fi
    
    log_warn "$title: $message"
}

# Check thresholds and alert
check_thresholds() {
    local cpu="$1"
    local memory="$2"
    local disk="$3"
    local temperature="$4"
    
    # CPU threshold
    if (( $(echo "$cpu > $CPU_THRESHOLD" | bc -l) )); then
        if can_notify "cpu"; then
            send_notification "High CPU Usage" "CPU usage is at ${cpu}% (threshold: ${CPU_THRESHOLD}%)" "critical" "cpu"
        fi
    fi
    
    # Memory threshold
    if (( $(echo "$memory > $MEMORY_THRESHOLD" | bc -l) )); then
        if can_notify "memory"; then
            send_notification "High Memory Usage" "Memory usage is at ${memory}% (threshold: ${MEMORY_THRESHOLD}%)" "critical" "memory"
        fi
    fi
    
    # Disk threshold
    if [ "$disk" -gt "$DISK_THRESHOLD" ]; then
        if can_notify "disk"; then
            send_notification "Low Disk Space" "Disk usage is at ${disk}% (threshold: ${DISK_THRESHOLD}%)" "critical" "drive-harddisk"
        fi
    fi
    
    # Temperature threshold
    if [ "$temperature" -gt "$TEMPERATURE_THRESHOLD" ]; then
        if can_notify "temperature"; then
            send_notification "High Temperature" "CPU temperature is at ${temperature}°C (threshold: ${TEMPERATURE_THRESHOLD}°C)" "critical" "temperature"
        fi
    fi
}

# Display current status
show_status() {
    local cpu=$(get_cpu_usage)
    local memory=$(get_memory_usage)
    local disk=$(get_disk_usage)
    local temperature=$(get_temperature)
    local uptime=$(uptime -p | sed 's/up //')
    local load=$(uptime | awk -F'load average:' '{print $2}')
    
    clear
    echo "=================================="
    echo "       System Monitor Status      "
    echo "=================================="
    echo "Time: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "Uptime: $uptime"
    echo "Load Average:$load"
    echo ""
    echo "CPU Usage:      ${cpu}%"
    echo "Memory Usage:   ${memory}%"
    echo "Disk Usage:     ${disk}%"
    echo "Temperature:    ${temperature}°C"
    echo ""
    echo "Thresholds:"
    echo "CPU:            ${CPU_THRESHOLD}%"
    echo "Memory:         ${MEMORY_THRESHOLD}%"
    echo "Disk:           ${DISK_THRESHOLD}%"
    echo "Temperature:    ${TEMPERATURE_THRESHOLD}°C"
    echo ""
    echo "Press Ctrl+C to stop monitoring"
    echo "=================================="
}

# Start monitoring daemon
start_daemon() {
    log_info "Starting system monitoring daemon"
    
    # Check if already running
    local pid_file="$MONITOR_DATA/monitor.pid"
    if [ -f "$pid_file" ]; then
        local existing_pid=$(cat "$pid_file")
        if kill -0 "$existing_pid" 2>/dev/null; then
            log_error "System monitor is already running (PID: $existing_pid)"
            return 1
        fi
    fi
    
    # Start daemon
    echo $$ > "$pid_file"
    
    trap "rm -f $pid_file; exit 0" EXIT INT TERM
    
    while true; do
        local cpu=$(get_cpu_usage)
        local memory=$(get_memory_usage)
        local disk=$(get_disk_usage)
        local temperature=$(get_temperature)
        
        save_metrics "$cpu" "$memory" "$disk" "$temperature"
        check_thresholds "$cpu" "$memory" "$disk" "$temperature"
        
        sleep "$MONITOR_INTERVAL"
    done
}

# Stop monitoring daemon
stop_daemon() {
    local pid_file="$MONITOR_DATA/monitor.pid"
    
    if [ -f "$pid_file" ]; then
        local pid=$(cat "$pid_file")
        if kill "$pid" 2>/dev/null; then
            rm -f "$pid_file"
            log_success "System monitor daemon stopped"
        else
            log_error "Failed to stop system monitor daemon"
            return 1
        fi
    else
        log_warn "System monitor daemon is not running"
    fi
}

# Show historical data
show_history() {
    local hours="${1:-1}"
    local metrics_file="$MONITOR_DATA/metrics.csv"
    
    if [ ! -f "$metrics_file" ]; then
        log_error "No historical data available"
        return 1
    fi
    
    local cutoff_time=$(($(date +%s) - (hours * 3600)))
    
    echo "System Metrics (Last $hours hours):"
    echo "Time,CPU%,Memory%,Disk%,Temp°C"
    echo "================================"
    
    awk -F',' -v cutoff="$cutoff_time" '
        $1 >= cutoff {
            cmd = "date -d @" $1 " +\"%H:%M:%S\""
            cmd | getline time
            close(cmd)
            printf "%s,%s,%s,%s,%s\n", time, $2, $3, $4, $5
        }
    ' "$metrics_file" | tail -20
}

# Configure thresholds
configure_thresholds() {
    echo "Current thresholds:"
    echo "CPU:         $CPU_THRESHOLD%"
    echo "Memory:      $MEMORY_THRESHOLD%"
    echo "Disk:        $DISK_THRESHOLD%"
    echo "Temperature: $TEMPERATURE_THRESHOLD°C"
    echo ""
    
    read -p "Enter new CPU threshold (current: $CPU_THRESHOLD): " new_cpu
    read -p "Enter new Memory threshold (current: $MEMORY_THRESHOLD): " new_memory
    read -p "Enter new Disk threshold (current: $DISK_THRESHOLD): " new_disk
    read -p "Enter new Temperature threshold (current: $TEMPERATURE_THRESHOLD): " new_temp
    
    # Save to config file
    cat > "$MONITOR_CONFIG" << EOF
# System Monitor Configuration
CPU_THRESHOLD=${new_cpu:-$CPU_THRESHOLD}
MEMORY_THRESHOLD=${new_memory:-$MEMORY_THRESHOLD}
DISK_THRESHOLD=${new_disk:-$DISK_THRESHOLD}
TEMPERATURE_THRESHOLD=${new_temp:-$TEMPERATURE_THRESHOLD}
MONITOR_INTERVAL=${MONITOR_INTERVAL}
NOTIFICATION_COOLDOWN=${NOTIFICATION_COOLDOWN}
EOF
    
    log_success "Configuration updated"
}

show_help() {
    echo "System Monitor - Real-time monitoring for Hyprland setup"
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  status     - Show current system status"
    echo "  daemon     - Start monitoring daemon"
    echo "  stop       - Stop monitoring daemon"
    echo "  history    - Show historical data (default: 1 hour)"
    echo "  config     - Configure thresholds"
    echo "  help       - Show this help"
    echo ""
    echo "Examples:"
    echo "  $0 status           - Show current status"
    echo "  $0 daemon           - Start background monitoring"
    echo "  $0 history 24       - Show last 24 hours of data"
}

# Load configuration
load_config

# Main command logic
case "${1:-status}" in
    "status")
        show_status
        ;;
    "daemon")
        start_daemon
        ;;
    "stop")
        stop_daemon
        ;;
    "history")
        show_history "$2"
        ;;
    "config")
        configure_thresholds
        ;;
    "help"|"--help"|"-h")
        show_help
        ;;
    *)
        log_error "Unknown command: $1"
        show_help
        exit 1
        ;;
esac