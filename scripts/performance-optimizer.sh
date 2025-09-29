#!/bin/bash
# Performance Optimizer for Hyprland Setup
# Optimizes system performance for better desktop experience

# Get script directory and source libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -f "$SCRIPT_DIR/lib/logger.sh" ]; then
    source "$SCRIPT_DIR/lib/logger.sh"
    init_logging "performance-optimizer"
else
    log_info() { echo -e "\033[0;34mℹ INFO:\033[0m $1"; }
    log_success() { echo -e "\033[0;32m✓ SUCCESS:\033[0m $1"; }
    log_error() { echo -e "\033[0;31m✗ ERROR:\033[0m $1" >&2; }
    log_warn() { echo -e "\033[1;33m⚠ WARN:\033[0m $1" >&2; }
fi

# Performance profiles
declare -A PERFORMANCE_PROFILES=(
    ["conservative"]="Balanced performance with power saving"
    ["balanced"]="Good balance between performance and efficiency" 
    ["performance"]="Maximum performance, higher power usage"
    ["gaming"]="Optimized for gaming and demanding applications"
)

show_help() {
    echo "Performance Optimizer for Hyprland"
    echo "Usage: $0 [command] [options]"
    echo ""
    echo "Commands:"
    echo "  analyze    - Analyze current system performance"
    echo "  optimize   - Apply comprehensive optimizations"
    echo "  profile    - Set performance profile"
    echo "  gpu        - Optimize GPU settings"
    echo "  memory     - Optimize memory settings"
    echo "  disk       - Optimize disk I/O"
    echo "  network    - Optimize network settings"
    echo "  services   - Optimize system services"
    echo "  restore    - Restore default settings"
    echo ""
    echo "Performance Profiles:"
    for profile in "${!PERFORMANCE_PROFILES[@]}"; do
        echo "  $profile - ${PERFORMANCE_PROFILES[$profile]}"
    done
    echo ""
    echo "Examples:"
    echo "  $0 analyze              - Analyze system performance"
    echo "  $0 profile gaming       - Set gaming performance profile"
    echo "  $0 optimize --all       - Apply all optimizations"
}

# Analyze current performance
analyze_performance() {
    log_info "Analyzing system performance"
    
    echo "=== System Performance Analysis ==="
    
    # CPU information
    echo ""
    echo "CPU Information:"
    local cpu_model=$(lscpu | grep "Model name" | cut -d':' -f2 | xargs)
    local cpu_cores=$(nproc)
    local cpu_freq=$(lscpu | grep "CPU max MHz" | cut -d':' -f2 | xargs)
    echo "  Model: $cpu_model"
    echo "  Cores: $cpu_cores"
    echo "  Max Frequency: ${cpu_freq} MHz"
    
    # Memory information
    echo ""
    echo "Memory Information:"
    local mem_total=$(free -h | grep "Mem:" | awk '{print $2}')
    local mem_available=$(free -h | grep "Mem:" | awk '{print $7}')
    local swap_total=$(free -h | grep "Swap:" | awk '{print $2}')
    echo "  Total: $mem_total"
    echo "  Available: $mem_available"
    echo "  Swap: $swap_total"
    
    # Disk information
    echo ""
    echo "Disk Information:"
    df -h / | tail -n +2 | while read -r filesystem size used avail use_percent mount; do
        echo "  Root: $used / $size ($use_percent used)"
    done
    
    # GPU information
    if command -v nvidia-smi >/dev/null 2>&1; then
        echo ""
        echo "GPU Information:"
        local gpu_name=$(nvidia-smi --query-gpu=name --format=csv,noheader | head -1)
        local gpu_driver=$(nvidia-smi --query-gpu=driver_version --format=csv,noheader | head -1)
        echo "  Name: $gpu_name"
        echo "  Driver: $gpu_driver"
    fi
    
    # Performance metrics
    echo ""
    echo "Current Performance Metrics:"
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
    local mem_usage=$(free | awk '/Mem/{printf("%.1f"), $3/$2*100}')
    local load_avg=$(uptime | awk -F'load average:' '{print $2}')
    echo "  CPU Usage: ${cpu_usage}%"
    echo "  Memory Usage: ${mem_usage}%"
    echo "  Load Average:$load_avg"
    
    # Check for performance issues
    echo ""
    echo "Performance Analysis:"
    
    if (( $(echo "$cpu_usage > 80" | bc -l) )); then
        log_warn "High CPU usage detected (${cpu_usage}%)"
    else
        log_success "CPU usage is normal (${cpu_usage}%)"
    fi
    
    if (( $(echo "$mem_usage > 85" | bc -l) )); then
        log_warn "High memory usage detected (${mem_usage}%)"
    else
        log_success "Memory usage is normal (${mem_usage}%)"
    fi
    
    # Check for swap usage
    local swap_used=$(free | awk '/Swap/{print $3}')
    if [ "$swap_used" -gt 0 ]; then
        log_warn "Swap is being used (may indicate memory pressure)"
    else
        log_success "No swap usage detected"
    fi
}

# Set performance profile
set_performance_profile() {
    local profile="$1"
    
    if [ -z "$profile" ]; then
        echo "Available profiles:"
        for p in "${!PERFORMANCE_PROFILES[@]}"; do
            echo "  $p - ${PERFORMANCE_PROFILES[$p]}"
        done
        return 1
    fi
    
    if [ -z "${PERFORMANCE_PROFILES[$profile]}" ]; then
        log_error "Unknown performance profile: $profile"
        return 1
    fi
    
    log_info "Setting performance profile: $profile"
    
    case "$profile" in
        "conservative")
            set_cpu_governor "powersave"
            set_gpu_performance "auto"
            optimize_for_battery
            ;;
        "balanced")
            set_cpu_governor "schedutil"
            set_gpu_performance "balanced"
            optimize_for_desktop
            ;;
        "performance")
            set_cpu_governor "performance"
            set_gpu_performance "high"
            optimize_for_performance
            ;;
        "gaming")
            set_cpu_governor "performance"
            set_gpu_performance "max"
            optimize_for_gaming
            ;;
    esac
    
    # Save current profile
    echo "$profile" > "$HOME/.cache/current-performance-profile"
    log_success "Performance profile set to: $profile"
}

# Set CPU governor
set_cpu_governor() {
    local governor="$1"
    
    if [ ! -d "/sys/devices/system/cpu/cpu0/cpufreq" ]; then
        log_warn "CPU frequency scaling not available"
        return 1
    fi
    
    log_info "Setting CPU governor to: $governor"
    
    for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        if [ -w "$cpu" ]; then
            echo "$governor" | sudo tee "$cpu" >/dev/null
        fi
    done
    
    log_success "CPU governor set to: $governor"
}

# Set GPU performance
set_gpu_performance() {
    local mode="$1"
    
    if command -v nvidia-smi >/dev/null 2>&1; then
        log_info "Setting NVIDIA GPU performance mode: $mode"
        
        case "$mode" in
            "max")
                sudo nvidia-smi -pm 1  # Enable persistence mode
                sudo nvidia-smi -pl 300  # Set power limit to max
                ;;
            "high")
                sudo nvidia-smi -pm 1
                sudo nvidia-smi -pl 250
                ;;
            "balanced")
                sudo nvidia-smi -pm 1
                sudo nvidia-smi -pl 200
                ;;
            "auto")
                sudo nvidia-smi -pm 0  # Disable persistence mode
                ;;
        esac
    else
        log_warn "NVIDIA GPU not detected or nvidia-smi not available"
    fi
}

# Optimize for battery
optimize_for_battery() {
    log_info "Applying battery optimization settings"
    
    # Set lower screen brightness if possible
    if command -v brightnessctl >/dev/null 2>&1; then
        brightnessctl set 50%
    fi
    
    # Enable power saving features
    echo 'auto' | sudo tee /sys/bus/pci/devices/*/power/control >/dev/null 2>&1 || true
}

# Optimize for desktop
optimize_for_desktop() {
    log_info "Applying desktop optimization settings"
    
    # Enable some performance features while maintaining efficiency
    optimize_memory_settings
    optimize_io_scheduler
}

# Optimize for performance
optimize_for_performance() {
    log_info "Applying maximum performance settings"
    
    optimize_memory_settings
    optimize_io_scheduler
    disable_power_saving
}

# Optimize for gaming
optimize_for_gaming() {
    log_info "Applying gaming optimization settings"
    
    optimize_memory_settings
    optimize_io_scheduler
    disable_power_saving
    optimize_kernel_parameters
    
    # Set process priority for gaming
    if pgrep -x "steam" >/dev/null; then
        sudo renice -10 $(pgrep steam) 2>/dev/null || true
    fi
}

# Optimize memory settings
optimize_memory_settings() {
    log_info "Optimizing memory settings"
    
    # Adjust swappiness
    echo 'vm.swappiness=10' | sudo tee -a /etc/sysctl.d/99-performance.conf >/dev/null
    
    # Optimize dirty page handling
    echo 'vm.dirty_ratio=15' | sudo tee -a /etc/sysctl.d/99-performance.conf >/dev/null
    echo 'vm.dirty_background_ratio=5' | sudo tee -a /etc/sysctl.d/99-performance.conf >/dev/null
    
    # Apply immediately
    sudo sysctl -p /etc/sysctl.d/99-performance.conf >/dev/null 2>&1 || true
    
    log_success "Memory settings optimized"
}

# Optimize I/O scheduler
optimize_io_scheduler() {
    log_info "Optimizing I/O scheduler"
    
    # Set appropriate scheduler for SSDs and HDDs
    for disk in /sys/block/sd* /sys/block/nvme*; do
        if [ -d "$disk" ]; then
            local device=$(basename "$disk")
            local rotational=$(cat "$disk/queue/rotational" 2>/dev/null || echo "1")
            
            if [ "$rotational" = "0" ]; then
                # SSD - use mq-deadline or none
                echo "mq-deadline" | sudo tee "$disk/queue/scheduler" >/dev/null 2>&1 || true
                log_info "Set mq-deadline scheduler for SSD: $device"
            else
                # HDD - use bfq
                echo "bfq" | sudo tee "$disk/queue/scheduler" >/dev/null 2>&1 || true
                log_info "Set bfq scheduler for HDD: $device"
            fi
        fi
    done
}

# Disable power saving features
disable_power_saving() {
    log_info "Disabling power saving features for maximum performance"
    
    # Disable CPU power saving
    echo 'performance' | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor >/dev/null 2>&1 || true
    
    # Disable USB autosuspend
    echo 'on' | sudo tee /sys/bus/usb/devices/*/power/control >/dev/null 2>&1 || true
}

# Optimize kernel parameters
optimize_kernel_parameters() {
    log_info "Optimizing kernel parameters"
    
    # Network optimizations
    cat << EOF | sudo tee -a /etc/sysctl.d/99-performance.conf >/dev/null
# Network performance
net.core.rmem_max=134217728
net.core.wmem_max=134217728
net.ipv4.tcp_rmem=4096 65536 134217728
net.ipv4.tcp_wmem=4096 65536 134217728
net.ipv4.tcp_congestion_control=bbr
EOF
    
    # Apply settings
    sudo sysctl -p /etc/sysctl.d/99-performance.conf >/dev/null 2>&1 || true
}

# Optimize system services
optimize_services() {
    log_info "Optimizing system services"
    
    # Services that can be safely disabled for performance
    local services_to_disable=(
        "bluetooth.service"
        "cups.service"
        "avahi-daemon.service"
    )
    
    for service in "${services_to_disable[@]}"; do
        if systemctl is-enabled "$service" >/dev/null 2>&1; then
            read -p "Disable $service for better performance? (y/N): " disable_service
            if [[ "$disable_service" =~ ^[Yy]$ ]]; then
                sudo systemctl disable "$service"
                sudo systemctl stop "$service"
                log_success "Disabled $service"
            fi
        fi
    done
}

# Comprehensive optimization
comprehensive_optimize() {
    log_info "Running comprehensive system optimization"
    
    # Apply balanced profile by default
    set_performance_profile "balanced"
    
    # Optimize various subsystems
    optimize_memory_settings
    optimize_io_scheduler
    
    # Ask user about service optimization
    read -p "Optimize system services? This may disable some services. (y/N): " opt_services
    if [[ "$opt_services" =~ ^[Yy]$ ]]; then
        optimize_services
    fi
    
    log_success "Comprehensive optimization completed"
    log_info "Reboot recommended for all changes to take effect"
}

# Restore default settings
restore_defaults() {
    log_info "Restoring default performance settings"
    
    # Remove custom sysctl configuration
    sudo rm -f /etc/sysctl.d/99-performance.conf
    
    # Reset CPU governor to default
    set_cpu_governor "schedutil"
    
    # Reset GPU to auto mode
    set_gpu_performance "auto"
    
    # Remove profile cache
    rm -f "$HOME/.cache/current-performance-profile"
    
    log_success "Default settings restored"
    log_info "Reboot recommended for all changes to take effect"
}

# Get current performance profile
get_current_profile() {
    if [ -f "$HOME/.cache/current-performance-profile" ]; then
        cat "$HOME/.cache/current-performance-profile"
    else
        echo "none"
    fi
}

# Main command logic
case "${1:-analyze}" in
    "analyze")
        analyze_performance
        ;;
    "optimize")
        if [ "$2" = "--all" ]; then
            comprehensive_optimize
        else
            echo "Use: $0 optimize --all"
        fi
        ;;
    "profile")
        if [ -n "$2" ]; then
            set_performance_profile "$2"
        else
            echo "Current profile: $(get_current_profile)"
            echo ""
            echo "Available profiles:"
            for profile in "${!PERFORMANCE_PROFILES[@]}"; do
                echo "  $profile - ${PERFORMANCE_PROFILES[$profile]}"
            done
        fi
        ;;
    "gpu")
        set_gpu_performance "${2:-balanced}"
        ;;
    "memory")
        optimize_memory_settings
        ;;
    "disk")
        optimize_io_scheduler
        ;;
    "services")
        optimize_services
        ;;
    "restore")
        restore_defaults
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