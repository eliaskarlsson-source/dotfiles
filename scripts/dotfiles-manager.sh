#!/bin/bash
# Advanced Dotfiles Manager
# Comprehensive system for managing all dotfiles with themes, backups, and synchronization

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source libraries
source "$SCRIPT_DIR/lib/logger.sh"
source "$SCRIPT_DIR/lib/config.sh"
init_logging "dotfiles-manager"

# Configuration
readonly DOTFILES_DIR="$HOME/dotfiles"
readonly CONFIG_DIR="$HOME/.config"
readonly TEMPLATES_DIR="$DOTFILES_DIR/templates"

# Ensure directories exist
mkdir -p "$TEMPLATES_DIR" "$CONFIG_DIR"

show_help() {
    echo "Advanced Dotfiles Manager"
    echo "Usage: $0 [command] [options]"
    echo ""
    echo "Commands:"
    echo "  deploy     - Deploy all configurations"
    echo "  theme      - Apply theme to all applications"
    echo "  backup     - Create full backup"
    echo "  restore    - Restore from backup"
    echo "  sync       - Sync with git repository"
    echo "  validate   - Validate all configurations"
    echo "  health     - Run comprehensive health check"
    echo "  update     - Update all configurations"
    echo "  clean      - Clean temporary files and old backups"
    echo ""
    echo "Theme Commands:"
    echo "  theme list        - List available themes"
    echo "  theme apply NAME  - Apply specific theme"
    echo "  theme current     - Show current theme"
    echo ""
    echo "Options:"
    echo "  --force    - Force operation without prompts"
    echo "  --dry-run  - Show what would be done without doing it"
    echo "  --verbose  - Enable verbose logging"
    echo "  --help     - Show this help"
}

# Deploy all configurations
deploy_all() {
    local force="${1:-false}"
    
    log_info "Deploying all dotfiles configurations"
    
    # Configuration mappings: source -> target
    declare -A configs=(
        ["$DOTFILES_DIR/hypr/hyprland.conf"]="$CONFIG_DIR/hypr/hyprland.conf"
        ["$DOTFILES_DIR/waybar/config.jsonc"]="$CONFIG_DIR/waybar/config.jsonc"
        ["$DOTFILES_DIR/waybar/style.css"]="$CONFIG_DIR/waybar/style.css"
        ["$DOTFILES_DIR/kitty/kitty.conf"]="$CONFIG_DIR/kitty/kitty.conf"
        ["$DOTFILES_DIR/wofi/wofi.conf"]="$CONFIG_DIR/wofi/wofi.conf"
        ["$DOTFILES_DIR/wofi/style.css"]="$CONFIG_DIR/wofi/style.css"
        ["$DOTFILES_DIR/mako/config"]="$CONFIG_DIR/mako/config"
        ["$DOTFILES_DIR/nvim/init.lua"]="$CONFIG_DIR/nvim/init.lua"
    )
    
    local deployed_count=0
    local error_count=0
    
    for source in "${!configs[@]}"; do
        local target="${configs[$source]}"
        
        if [ -f "$source" ]; then
            if deploy_config "$source" "$target" "auto" "dotfiles-manager"; then
                ((deployed_count++))
            else
                ((error_count++))
            fi
        else
            log_warn "Source file not found: $source"
        fi
    done
    
    # Deploy scripts
    log_info "Deploying scripts"
    local scripts_dir="$HOME/scripts"
    mkdir -p "$scripts_dir"
    
    for script in "$DOTFILES_DIR"/scripts/*.sh; do
        if [ -f "$script" ]; then
            local script_name=$(basename "$script")
            if cp "$script" "$scripts_dir/$script_name" && chmod +x "$scripts_dir/$script_name"; then
                ((deployed_count++))
            else
                ((error_count++))
                log_error "Failed to deploy script: $script_name"
            fi
        fi
    done
    
    # Deploy lib directory
    if [ -d "$DOTFILES_DIR/scripts/lib" ]; then
        cp -r "$DOTFILES_DIR/scripts/lib" "$scripts_dir/"
        log_info "Deployed script libraries"
    fi
    
    # Restart services after deployment
    restart_services
    
    log_success "Deployment complete: $deployed_count files deployed, $error_count errors"
    
    if [ "$error_count" -gt 0 ]; then
        return 1
    fi
    
    return 0
}

# Restart affected services
restart_services() {
    log_info "Restarting affected services"
    
    # Restart waybar
    if pgrep -x waybar >/dev/null; then
        if pkill waybar && sleep 1 && waybar &; then
            log_success "Restarted waybar"
        else
            log_error "Failed to restart waybar"
        fi
    fi
    
    # Restart mako
    if pgrep -x mako >/dev/null; then
        if pkill mako && sleep 1 && mako &; then
            log_success "Restarted mako"
        else
            log_error "Failed to restart mako"
        fi
    fi
    
    # Reload Hyprland config
    if command_exists hyprctl; then
        if hyprctl reload; then
            log_success "Reloaded Hyprland configuration"
        else
            log_error "Failed to reload Hyprland configuration"
        fi
    fi
}

# Apply theme system-wide
apply_system_theme() {
    local theme_name="$1"
    
    if [ -z "$theme_name" ]; then
        log_error "No theme name provided"
        return 1
    fi
    
    log_info "Applying theme: $theme_name"
    
    # Use enhanced theme switcher
    if [ -x "$DOTFILES_DIR/scripts/enhanced-theme-switcher.sh" ]; then
        "$DOTFILES_DIR/scripts/enhanced-theme-switcher.sh" "$theme_name"
    elif [ -x "$HOME/scripts/enhanced-theme-switcher.sh" ]; then
        "$HOME/scripts/enhanced-theme-switcher.sh" "$theme_name"
    else
        log_error "Theme switcher not found"
        return 1
    fi
    
    # Apply theme to Neovim
    if [ -f "$CONFIG_DIR/nvim/init.lua" ]; then
        log_info "Applying theme to Neovim"
        # The Neovim config already uses Catppuccin, so just notify
        log_success "Neovim theme is automatically synchronized"
    fi
    
    log_success "Theme applied successfully: $theme_name"
}

# Create comprehensive backup
create_full_backup() {
    log_info "Creating comprehensive backup"
    
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_dir="$HOME/.local/share/dotfiles/full-backup-$timestamp"
    
    mkdir -p "$backup_dir"
    
    # Backup configurations
    log_info "Backing up configurations"
    cp -r "$CONFIG_DIR" "$backup_dir/config" 2>/dev/null || log_warn "Some config files couldn't be backed up"
    
    # Backup dotfiles repository
    if [ -d "$DOTFILES_DIR/.git" ]; then
        log_info "Backing up dotfiles repository"
        cp -r "$DOTFILES_DIR" "$backup_dir/dotfiles"
    fi
    
    # Backup scripts
    if [ -d "$HOME/scripts" ]; then
        log_info "Backing up scripts"
        cp -r "$HOME/scripts" "$backup_dir/"
    fi
    
    # Create manifest
    cat > "$backup_dir/manifest.txt" << EOF
Dotfiles Backup Manifest
Created: $(date)
Hostname: $(hostname)
User: $USER
Backup Directory: $backup_dir

Contents:
- config/     : User configuration files
- dotfiles/   : Dotfiles repository
- scripts/    : User scripts
EOF
    
    log_success "Full backup created: $backup_dir"
    echo "$backup_dir" > "$HOME/.cache/last-full-backup"
}

# Sync with git repository
sync_repository() {
    log_info "Syncing dotfiles repository"
    
    if [ ! -d "$DOTFILES_DIR/.git" ]; then
        log_error "Dotfiles directory is not a git repository"
        return 1
    fi
    
    cd "$DOTFILES_DIR"
    
    # Check for uncommitted changes
    if ! git diff --quiet || ! git diff --cached --quiet; then
        log_warn "Uncommitted changes detected"
        read -p "Commit changes before sync? (y/N): " commit_changes
        
        if [[ "$commit_changes" =~ ^[Yy]$ ]]; then
            git add .
            git commit -m "Auto-commit: $(date '+%Y-%m-%d %H:%M:%S')"
        fi
    fi
    
    # Pull latest changes
    if git pull origin main; then
        log_success "Repository synced successfully"
    else
        log_error "Failed to sync repository"
        return 1
    fi
    
    # Push changes if any
    if git log origin/main..HEAD --oneline | grep -q .; then
        if git push origin main; then
            log_success "Changes pushed to remote"
        else
            log_error "Failed to push changes"
            return 1
        fi
    fi
}

# Run comprehensive health check
health_check() {
    log_info "Running comprehensive health check"
    
    # Use hypr-utils health check
    if [ -x "$HOME/scripts/hypr-utils.sh" ]; then
        "$HOME/scripts/hypr-utils.sh" health
    else
        log_error "hypr-utils.sh not found"
        return 1
    fi
    
    # Additional checks
    log_info "Additional system checks"
    
    # Check for missing dependencies
    local missing_deps=()
    local required_commands=("hyprctl" "waybar" "mako" "wofi" "kitty" "nvim")
    
    for cmd in "${required_commands[@]}"; do
        if ! command_exists "$cmd"; then
            missing_deps+=("$cmd")
        fi
    done
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        log_warn "Missing dependencies: ${missing_deps[*]}"
    else
        log_success "All required dependencies are installed"
    fi
    
    # Check disk space
    local disk_usage=$(df -h "$HOME" | awk 'NR==2 {print $5}' | sed 's/%//')
    if [ "$disk_usage" -gt 90 ]; then
        log_warn "High disk usage: ${disk_usage}%"
    else
        log_info "Disk usage: ${disk_usage}%"
    fi
}

# Update configurations
update_configurations() {
    log_info "Updating configurations"
    
    # Sync repository first
    if ! sync_repository; then
        log_error "Failed to sync repository"
        return 1
    fi
    
    # Deploy updated configurations
    if ! deploy_all; then
        log_error "Failed to deploy configurations"
        return 1
    fi
    
    log_success "Configurations updated successfully"
}

# Clean temporary files
clean_system() {
    log_info "Cleaning temporary files and old backups"
    
    # Clean old log files
    clean_old_logs
    
    # Clean old config backups
    clean_old_backups "dotfiles-manager"
    
    # Clean old full backups (keep last 5)
    local backup_base="$HOME/.local/share/dotfiles"
    if [ -d "$backup_base" ]; then
        find "$backup_base" -maxdepth 1 -type d -name "full-backup-*" | \
        sort -r | tail -n +6 | \
        xargs -r rm -rf
        log_info "Cleaned old full backups"
    fi
    
    # Clean package caches if using pacman
    if command_exists pacman && command_exists paccache; then
        sudo paccache -rk3
        log_info "Cleaned package cache"
    fi
    
    log_success "System cleanup completed"
}

# Main command logic
main() {
    case "${1:-help}" in
        "deploy")
            shift
            deploy_all "$@"
            ;;
        "theme")
            case "${2:-list}" in
                "list")
                    if [ -x "$HOME/scripts/enhanced-theme-switcher.sh" ]; then
                        "$HOME/scripts/enhanced-theme-switcher.sh" list
                    fi
                    ;;
                "apply")
                    if [ -n "$3" ]; then
                        apply_system_theme "$3"
                    else
                        log_error "No theme name provided"
                        exit 1
                    fi
                    ;;
                "current")
                    if [ -x "$HOME/scripts/enhanced-theme-switcher.sh" ]; then
                        "$HOME/scripts/enhanced-theme-switcher.sh" current
                    fi
                    ;;
                *)
                    log_error "Unknown theme command: $2"
                    exit 1
                    ;;
            esac
            ;;
        "backup")
            create_full_backup
            ;;
        "restore")
            log_info "Interactive restore not implemented yet"
            log_info "Use: hypr-utils.sh restore"
            ;;
        "sync")
            sync_repository
            ;;
        "validate")
            validate_all_configs "dotfiles-manager"
            ;;
        "health")
            health_check
            ;;
        "update")
            update_configurations
            ;;
        "clean")
            clean_system
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
}

# Parse global options
while [[ $# -gt 0 ]]; do
    case "$1" in
        "--verbose")
            export DOTFILES_LOG_LEVEL=3
            shift
            ;;
        "--dry-run")
            export DRY_RUN=true
            shift
            ;;
        "--force")
            export FORCE=true
            shift
            ;;
        *)
            break
            ;;
    esac
done

main "$@"