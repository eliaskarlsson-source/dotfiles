#!/bin/bash
# Logger library for dotfiles scripts
# Provides consistent logging across all scripts

# Colors for different log levels
readonly LOG_RED='\033[0;31m'
readonly LOG_GREEN='\033[0;32m'
readonly LOG_YELLOW='\033[1;33m'
readonly LOG_BLUE='\033[0;34m'
readonly LOG_PURPLE='\033[0;35m'
readonly LOG_CYAN='\033[0;36m'
readonly LOG_WHITE='\033[1;37m'
readonly LOG_NC='\033[0m' # No Color

# Log directory
readonly LOG_DIR="$HOME/.local/share/dotfiles/logs"
readonly LOG_FILE="$LOG_DIR/dotfiles.log"

# Ensure log directory exists
mkdir -p "$LOG_DIR"

# Log levels
readonly LOG_LEVEL_ERROR=0
readonly LOG_LEVEL_WARN=1
readonly LOG_LEVEL_INFO=2
readonly LOG_LEVEL_DEBUG=3

# Default log level (can be overridden by DOTFILES_LOG_LEVEL env var)
DEFAULT_LOG_LEVEL=${DOTFILES_LOG_LEVEL:-$LOG_LEVEL_INFO}

# Get current timestamp
get_timestamp() {
    date '+%Y-%m-%d %H:%M:%S'
}

# Write to log file
write_log_file() {
    local level="$1"
    local message="$2"
    local script_name="${3:-$(basename "$0")}"
    
    echo "[$(get_timestamp)] [$level] [$script_name] $message" >> "$LOG_FILE"
}

# Log error message
log_error() {
    local message="$1"
    local script_name="${2:-$(basename "$0")}"
    
    if [ "$DEFAULT_LOG_LEVEL" -ge "$LOG_LEVEL_ERROR" ]; then
        echo -e "${LOG_RED}✗ ERROR:${LOG_NC} $message" >&2
        write_log_file "ERROR" "$message" "$script_name"
    fi
}

# Log warning message  
log_warn() {
    local message="$1"
    local script_name="${2:-$(basename "$0")}"
    
    if [ "$DEFAULT_LOG_LEVEL" -ge "$LOG_LEVEL_WARN" ]; then
        echo -e "${LOG_YELLOW}⚠ WARN:${LOG_NC} $message" >&2
        write_log_file "WARN" "$message" "$script_name"
    fi
}

# Log info message
log_info() {
    local message="$1"
    local script_name="${2:-$(basename "$0")}"
    
    if [ "$DEFAULT_LOG_LEVEL" -ge "$LOG_LEVEL_INFO" ]; then
        echo -e "${LOG_BLUE}ℹ INFO:${LOG_NC} $message"
        write_log_file "INFO" "$message" "$script_name"
    fi
}

# Log debug message
log_debug() {
    local message="$1"
    local script_name="${2:-$(basename "$0")}"
    
    if [ "$DEFAULT_LOG_LEVEL" -ge "$LOG_LEVEL_DEBUG" ]; then
        echo -e "${LOG_PURPLE}🐛 DEBUG:${LOG_NC} $message"
        write_log_file "DEBUG" "$message" "$script_name"
    fi
}

# Log success message
log_success() {
    local message="$1"
    local script_name="${2:-$(basename "$0")}"
    
    if [ "$DEFAULT_LOG_LEVEL" -ge "$LOG_LEVEL_INFO" ]; then
        echo -e "${LOG_GREEN}✓ SUCCESS:${LOG_NC} $message"
        write_log_file "SUCCESS" "$message" "$script_name"
    fi
}

# Execute command with logging
execute_with_logging() {
    local command="$1"
    local description="${2:-$command}"
    local script_name="${3:-$(basename "$0")}"
    
    log_debug "Executing: $command" "$script_name"
    
    if eval "$command" 2>&1 | tee -a "$LOG_FILE"; then
        log_success "$description completed" "$script_name"
        return 0
    else
        local exit_code=$?
        log_error "$description failed with exit code $exit_code" "$script_name"
        return $exit_code
    fi
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Require command or exit
require_command() {
    local cmd="$1"
    local package="${2:-$cmd}"
    local script_name="${3:-$(basename "$0")}"
    
    if ! command_exists "$cmd"; then
        log_error "Required command '$cmd' not found. Install with: pacman -S $package" "$script_name"
        return 1
    fi
    return 0
}

# Check if file exists
file_exists() {
    [ -f "$1" ]
}

# Check if directory exists
dir_exists() {
    [ -d "$1" ]
}

# Create backup of file
backup_file() {
    local file="$1"
    local script_name="${2:-$(basename "$0")}"
    
    if file_exists "$file"; then
        local backup_file="${file}.backup.$(date +%Y%m%d_%H%M%S)"
        if cp "$file" "$backup_file"; then
            log_info "Created backup: $backup_file" "$script_name"
            return 0
        else
            log_error "Failed to create backup of $file" "$script_name"
            return 1
        fi
    fi
    return 0
}

# Clean old log files (keep last 30 days)
clean_old_logs() {
    find "$LOG_DIR" -name "*.log" -type f -mtime +30 -delete 2>/dev/null || true
}

# Initialize logging
init_logging() {
    local script_name="${1:-$(basename "$0")}"
    
    # Clean old logs on startup
    clean_old_logs
    
    # Log script start
    log_info "=== Starting $script_name ===" "$script_name"
    
    # Set up trap to log script end
    trap "log_info '=== $script_name finished ===' '$script_name'" EXIT
}

# Export functions for use in other scripts
export -f get_timestamp write_log_file log_error log_warn log_info log_debug log_success
export -f execute_with_logging command_exists require_command file_exists dir_exists
export -f backup_file clean_old_logs init_logging