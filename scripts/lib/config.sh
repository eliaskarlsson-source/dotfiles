#!/bin/bash
# Configuration management library
# Handles configuration file operations, validation, and management

# Source the logger library
source "$(dirname "${BASH_SOURCE[0]}")/logger.sh"

# Configuration directories
readonly CONFIG_DIR="$HOME/.config"
readonly DOTFILES_DIR="$HOME/dotfiles"
readonly BACKUP_DIR="$HOME/.local/share/dotfiles/backups"

# Ensure backup directory exists
mkdir -p "$BACKUP_DIR"

# Validate configuration file syntax
validate_config() {
    local file="$1"
    local file_type="${2:-auto}"
    local script_name="${3:-$(basename "$0")}"
    
    if ! file_exists "$file"; then
        log_error "Configuration file not found: $file" "$script_name"
        return 1
    fi
    
    # Auto-detect file type if not specified
    if [ "$file_type" = "auto" ]; then
        case "${file##*.}" in
            "conf") file_type="hypr" ;;
            "json"|"jsonc") file_type="json" ;;
            "css") file_type="css" ;;
            "lua") file_type="lua" ;;
            "sh") file_type="shell" ;;
            *) file_type="generic" ;;
        esac
    fi
    
    log_debug "Validating $file as $file_type" "$script_name"
    
    case "$file_type" in
        "hypr"|"hyprland")
            # Basic Hyprland config validation
            if ! grep -q "^general\s*{" "$file"; then
                log_warn "Hyprland config might be missing general section" "$script_name"
            fi
            ;;
        "json"|"jsonc")
            if command_exists jq; then
                if ! jq empty "$file" >/dev/null 2>&1; then
                    log_error "Invalid JSON syntax in $file" "$script_name"
                    return 1
                fi
            else
                log_warn "jq not available, skipping JSON validation" "$script_name"
            fi
            ;;
        "css")
            # Basic CSS validation - check for balanced braces
            local open_braces=$(grep -o "{" "$file" | wc -l)
            local close_braces=$(grep -o "}" "$file" | wc -l)
            if [ "$open_braces" -ne "$close_braces" ]; then
                log_error "Unbalanced braces in CSS file: $file" "$script_name"
                return 1
            fi
            ;;
        "lua")
            if command_exists lua; then
                if ! lua -l "$file" -e "" >/dev/null 2>&1; then
                    log_error "Lua syntax error in $file" "$script_name"
                    return 1
                fi
            else
                log_warn "lua not available, skipping Lua validation" "$script_name"
            fi
            ;;
        "shell")
            if ! bash -n "$file" >/dev/null 2>&1; then
                log_error "Shell script syntax error in $file" "$script_name"
                return 1
            fi
            ;;
        "generic")
            # Basic file readability check
            if ! [ -r "$file" ]; then
                log_error "Cannot read file: $file" "$script_name"
                return 1
            fi
            ;;
    esac
    
    log_success "Configuration file validation passed: $file" "$script_name"
    return 0
}

# Backup configuration file with timestamp
backup_config() {
    local source_file="$1"
    local script_name="${2:-$(basename "$0")}"
    
    if ! file_exists "$source_file"; then
        log_error "Source file not found for backup: $source_file" "$script_name"
        return 1
    fi
    
    local filename=$(basename "$source_file")
    local backup_path="$BACKUP_DIR/${filename}.backup.$(date +%Y%m%d_%H%M%S)"
    
    if cp "$source_file" "$backup_path"; then
        log_info "Configuration backed up to: $backup_path" "$script_name"
        return 0
    else
        log_error "Failed to backup configuration: $source_file" "$script_name"
        return 1
    fi
}

# Deploy configuration file with validation and backup
deploy_config() {
    local source_file="$1"
    local target_file="$2"
    local file_type="${3:-auto}"
    local script_name="${4:-$(basename "$0")}"
    
    # Validate source file
    if ! validate_config "$source_file" "$file_type" "$script_name"; then
        return 1
    fi
    
    # Backup existing target if it exists
    if file_exists "$target_file"; then
        if ! backup_config "$target_file" "$script_name"; then
            log_warn "Failed to backup existing config, continuing anyway" "$script_name"
        fi
    fi
    
    # Create target directory if needed
    local target_dir=$(dirname "$target_file")
    if ! dir_exists "$target_dir"; then
        if mkdir -p "$target_dir"; then
            log_info "Created directory: $target_dir" "$script_name"
        else
            log_error "Failed to create directory: $target_dir" "$script_name"
            return 1
        fi
    fi
    
    # Copy file
    if cp "$source_file" "$target_file"; then
        log_success "Deployed configuration: $source_file -> $target_file" "$script_name"
        return 0
    else
        log_error "Failed to deploy configuration: $source_file -> $target_file" "$script_name"
        return 1
    fi
}

# Restart service if configuration changed
restart_service_if_changed() {
    local service_name="$1"
    local config_file="$2"
    local script_name="${3:-$(basename "$0")}"
    
    # Check if service is running
    if ! systemctl --user is-active --quiet "$service_name" 2>/dev/null; then
        if ! pgrep -x "$service_name" >/dev/null 2>&1; then
            log_info "Service $service_name is not running, skipping restart" "$script_name"
            return 0
        fi
    fi
    
    log_info "Restarting $service_name due to configuration change" "$script_name"
    
    # Try systemctl first, then fallback to pkill/start
    if systemctl --user restart "$service_name" 2>/dev/null; then
        log_success "Restarted $service_name via systemctl" "$script_name"
    elif pkill -x "$service_name" && sleep 1 && "$service_name" &>/dev/null &; then
        log_success "Restarted $service_name via pkill/restart" "$script_name"
    else
        log_error "Failed to restart $service_name" "$script_name"
        return 1
    fi
    
    return 0
}

# Get configuration diff
get_config_diff() {
    local file1="$1"
    local file2="$2"
    local script_name="${3:-$(basename "$0")}"
    
    if ! file_exists "$file1" || ! file_exists "$file2"; then
        log_error "One or both files do not exist for diff comparison" "$script_name"
        return 1
    fi
    
    if command_exists diff; then
        diff -u "$file1" "$file2" || true
    else
        log_warn "diff command not available" "$script_name"
        return 1
    fi
}

# Clean old backups (keep last 10 for each config)
clean_old_backups() {
    local script_name="${1:-$(basename "$0")}"
    
    if ! dir_exists "$BACKUP_DIR"; then
        return 0
    fi
    
    log_info "Cleaning old configuration backups" "$script_name"
    
    # For each unique config file, keep only the 10 most recent backups
    find "$BACKUP_DIR" -name "*.backup.*" -type f | \
    sed 's/\.backup\..*$//' | sort -u | \
    while read -r base_name; do
        find "$BACKUP_DIR" -name "$(basename "$base_name").backup.*" -type f | \
        sort -r | tail -n +11 | \
        xargs -r rm -f
    done
    
    log_success "Cleaned old configuration backups" "$script_name"
}

# Validate all dotfiles configurations
validate_all_configs() {
    local script_name="${1:-$(basename "$0")}"
    local error_count=0
    
    log_info "Validating all dotfiles configurations" "$script_name"
    
    # Hyprland
    if file_exists "$DOTFILES_DIR/hypr/hyprland.conf"; then
        validate_config "$DOTFILES_DIR/hypr/hyprland.conf" "hypr" "$script_name" || ((error_count++))
    fi
    
    # Waybar
    if file_exists "$DOTFILES_DIR/waybar/config.jsonc"; then
        validate_config "$DOTFILES_DIR/waybar/config.jsonc" "jsonc" "$script_name" || ((error_count++))
    fi
    
    # Kitty
    if file_exists "$DOTFILES_DIR/kitty/kitty.conf"; then
        validate_config "$DOTFILES_DIR/kitty/kitty.conf" "generic" "$script_name" || ((error_count++))
    fi
    
    # Scripts
    for script in "$DOTFILES_DIR"/scripts/*.sh; do
        if file_exists "$script"; then
            validate_config "$script" "shell" "$script_name" || ((error_count++))
        fi
    done
    
    if [ "$error_count" -eq 0 ]; then
        log_success "All configuration files are valid" "$script_name"
        return 0
    else
        log_error "Found $error_count configuration errors" "$script_name"
        return 1
    fi
}

# Export functions
export -f validate_config backup_config deploy_config restart_service_if_changed
export -f get_config_diff clean_old_backups validate_all_configs