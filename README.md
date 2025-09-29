# 🚀 Elias's Enhanced Dotfiles

A comprehensive and beautifully crafted Hyprland setup with advanced features, robust architecture, and excellent performance optimization.

## ✨ Features

- **🎨 Beautiful Catppuccin Theme** - Consistent theming across all applications
- **⚡ High Performance** - Optimized for smooth desktop experience
- **🔧 Advanced Scripts** - Comprehensive management and automation tools
- **📊 System Monitoring** - Real-time performance tracking and alerting
- **🔄 Theme Switching** - Easy theme management with multiple variants
- **🛡️ Robust Architecture** - Proper error handling, logging, and validation
- **💾 Backup System** - Automatic configuration backups and restoration
- **🎮 Gaming Optimized** - Special performance profiles for gaming
- **🔍 Health Monitoring** - Comprehensive system health checks

## 📁 Structure

```
dotfiles/
├── hypr/                    # Hyprland configuration
│   └── hyprland.conf       # Main Hyprland config with advanced features
├── waybar/                  # Status bar configuration
│   ├── config.jsonc        # Waybar configuration
│   ├── style.css          # Waybar styling
│   └── scripts/           # Waybar modules
├── kitty/                   # Terminal configuration
│   └── kitty.conf         # Kitty terminal config
├── wofi/                    # Application launcher
│   ├── wofi.conf          # Wofi configuration
│   └── style.css          # Wofi styling
├── mako/                    # Notifications
│   └── config             # Mako notification config
├── nvim/                    # Neovim configuration
│   ├── init.lua           # Enhanced Neovim config
│   └── lazy-lock.json     # Plugin lockfile
└── scripts/                 # Management scripts
    ├── lib/               # Script libraries
    │   ├── logger.sh      # Logging system
    │   └── config.sh      # Configuration management
    ├── dotfiles-manager.sh        # Main management script
    ├── enhanced-theme-switcher.sh # Advanced theme switching
    ├── hypr-utils.sh             # Hyprland utilities
    ├── performance-optimizer.sh   # Performance tuning
    ├── system-monitor.sh         # System monitoring
    ├── wallpaper.sh              # Wallpaper management
    └── wofi-launcher.sh          # Application launcher
```

## 🚀 Quick Start

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/dotfiles.git ~/dotfiles
   cd ~/dotfiles
   ```

2. **Deploy configurations:**
   ```bash
   ./scripts/dotfiles-manager.sh deploy
   ```

3. **Apply theme:**
   ```bash
   ./scripts/dotfiles-manager.sh theme apply catppuccin-mocha
   ```

### Key Bindings

#### Window Management
- `Super + Return` - Open terminal (Kitty)
- `Super + Q` - Close window
- `Super + F` - Toggle fullscreen
- `Super + V` - Toggle floating
- `Super + Arrow Keys` - Move focus
- `Super + Shift + Arrow Keys` - Move windows
- `Super + Ctrl + Arrow Keys` - Resize windows

#### Applications
- `Super + R` - Application launcher
- `Super + Shift + R` - Run command
- `Super + Tab` - Window switcher
- `Super + E` - File manager
- `Super + B` - Firefox
- `Super + C` - VS Code

#### System
- `Super + Space` - Power menu
- `Super + Shift + Space` - Screenshot menu
- `Super + W` - Random wallpaper
- `Super + G` - Toggle game mode
- `Super + T` - Theme switcher
- `Super + I` - System health check
- `Super + L` - Lock screen

#### Group Management
- `Super + K` - Toggle group
- `Super + H/L` - Navigate group tabs
- `Super + Ctrl + H/J/K/L` - Move into group

## 🛠️ Management Tools

### Dotfiles Manager
The main management tool for your entire setup:

```bash
# Deploy all configurations
./scripts/dotfiles-manager.sh deploy

# Apply themes
./scripts/dotfiles-manager.sh theme list
./scripts/dotfiles-manager.sh theme apply catppuccin-mocha

# Backup and restore
./scripts/dotfiles-manager.sh backup
./scripts/dotfiles-manager.sh restore

# Sync with git
./scripts/dotfiles-manager.sh sync

# Validate configurations
./scripts/dotfiles-manager.sh validate

# System health check
./scripts/dotfiles-manager.sh health
```

### Hyprland Utilities
Comprehensive Hyprland management:

```bash
# System health and diagnostics
hypr-utils.sh health
hypr-utils.sh core        # Check core services
hypr-utils.sh files       # Check config files
hypr-utils.sh system      # System snapshot

# Configuration management
hypr-utils.sh validate    # Validate configs
hypr-utils.sh backup      # Backup configs
hypr-utils.sh restore     # Restore configs
hypr-utils.sh reload      # Reload Hyprland

# Control functions
hypr-utils.sh power      # Power menu
hypr-utils.sh volume     # Volume control
hypr-utils.sh screenshot # Screenshot menu
hypr-utils.sh gamemode   # Toggle game mode
```

### Performance Optimizer
Optimize system performance:

```bash
# Analyze current performance
performance-optimizer.sh analyze

# Set performance profiles
performance-optimizer.sh profile gaming      # Gaming mode
performance-optimizer.sh profile performance # Max performance
performance-optimizer.sh profile balanced    # Balanced
performance-optimizer.sh profile conservative # Power saving

# Comprehensive optimization
performance-optimizer.sh optimize --all

# Component-specific optimization
performance-optimizer.sh gpu      # GPU settings
performance-optimizer.sh memory   # Memory optimization
performance-optimizer.sh disk     # I/O optimization
performance-optimizer.sh services # System services
```

### System Monitor
Real-time system monitoring:

```bash
# Show current status
system-monitor.sh status

# Start monitoring daemon
system-monitor.sh daemon

# View historical data
system-monitor.sh history 24    # Last 24 hours

# Configure thresholds
system-monitor.sh config
```

### Theme Switcher
Advanced theme management:

```bash
# Interactive theme menu
enhanced-theme-switcher.sh menu

# Apply specific theme
enhanced-theme-switcher.sh catppuccin-mocha

# List available themes
enhanced-theme-switcher.sh list

# Show current theme
enhanced-theme-switcher.sh current
```

## 🎨 Available Themes

- **catppuccin-mocha** - Dark purple theme (default)
- **catppuccin-macchiato** - Medium dark theme
- **catppuccin-frappe** - Light dark theme
- **catppuccin-latte** - Light theme
- **dark-blue** - Dark blue theme
- **light-minimal** - Minimal light theme
- **cyberpunk** - Neon cyberpunk theme

## 📊 Waybar Modules

### Built-in Modules
- **Workspaces** - Hyprland workspace indicator
- **Window** - Active window title
- **Clock** - Time and date with calendar
- **CPU** - CPU usage indicator
- **Memory** - RAM usage
- **Disk** - Disk space usage
- **Temperature** - CPU temperature
- **Network** - Network connectivity
- **Audio** - Volume control
- **System Tray** - System tray icons

### Custom Modules
- **GPU Monitor** - NVIDIA GPU usage and temperature
- **Weather** - Current weather information
- **Updates** - Available system updates
- **Media Player** - Currently playing media
- **DND Toggle** - Do Not Disturb toggle
- **Theme Switcher** - Quick theme switching
- **Idle Inhibitor** - Screen timeout control

## 💻 Neovim Configuration

Enhanced Neovim setup with:

### Themes & UI
- **Catppuccin** theme matching system
- **Lualine** status line
- **Bufferline** buffer tabs
- **Nvim-tree** file explorer
- **Which-key** keybinding help

### Language Support
- **LSP** - Language Server Protocol
- **Mason** - LSP installer
- **Treesitter** - Syntax highlighting
- **Completion** - Auto-completion with snippets
- **Formatting** - Code formatting with null-ls

### Development Tools
- **Telescope** - Fuzzy finder
- **Git integration** - Gitsigns + Fugitive
- **Debugging** - DAP support
- **Trouble** - Diagnostics panel
- **Auto-pairs** - Bracket completion
- **Surround** - Text object manipulation

### Key Bindings (Neovim)
- `<leader>e` - Toggle file explorer
- `<leader>ff` - Find files
- `<leader>fg` - Live grep
- `<leader>fb` - Buffer list
- `<Tab>` - Next buffer
- `<S-Tab>` - Previous buffer
- `<leader>w` - Save file
- `<leader>q` - Quit

## 🔧 Configuration

### Environment Variables
```bash
# Performance tuning
export DOTFILES_LOG_LEVEL=2      # Logging level (0-3)

# Theme system
export WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
```

### Performance Profiles

#### Conservative
- Power saving CPU governor
- Reduced GPU performance
- Battery optimizations

#### Balanced (Default)
- Schedutil CPU governor
- Balanced GPU performance
- Desktop optimizations

#### Performance
- Performance CPU governor
- High GPU performance
- All power saving disabled

#### Gaming
- Maximum CPU/GPU performance
- Kernel parameter optimization
- Process priority tuning

## 📋 Dependencies

### Required Packages
```bash
# Core desktop
hyprland waybar mako wofi kitty

# System utilities  
swww grim slurp wl-clipboard
playerctl brightnessctl gammastep

# Development
neovim git nodejs npm python pip

# Optional but recommended
firefox thunar pavucontrol
nm-applet blueman-applet
polkit-gnome
```

### Installation (Arch Linux)
```bash
# Core packages
sudo pacman -S hyprland waybar mako wofi kitty
sudo pacman -S swww grim slurp wl-clipboard
sudo pacman -S playerctl brightnessctl gammastep
sudo pacman -S neovim git nodejs npm python python-pip

# Optional packages
sudo pacman -S firefox thunar pavucontrol
sudo pacman -S network-manager-applet blueman
sudo pacman -S polkit-gnome

# AUR packages (using yay)
yay -S bibata-cursor-theme-ice
```

## 🚨 Troubleshooting

### Common Issues

#### Waybar not starting
```bash
# Check waybar configuration
./scripts/hypr-utils.sh validate

# Restart waybar
pkill waybar && waybar &
```

#### Theme not applying
```bash
# Validate theme files
./scripts/dotfiles-manager.sh validate

# Force theme reapplication
./scripts/enhanced-theme-switcher.sh catppuccin-mocha
```

#### Performance issues
```bash
# Analyze performance
./scripts/performance-optimizer.sh analyze

# Apply gaming profile
./scripts/performance-optimizer.sh profile gaming
```

#### Configuration errors
```bash
# Full health check
./scripts/hypr-utils.sh health

# Restore from backup
./scripts/hypr-utils.sh restore
```

### Log Files
- Main log: `~/.local/share/dotfiles/logs/dotfiles.log`
- System monitor: `~/.local/share/system-monitor/metrics.csv`
- Hyprland: Check journalctl for Hyprland logs

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📜 License

MIT License - see LICENSE file for details.

## 🙏 Acknowledgments

- [Hyprland](https://hyprland.org/) - Amazing Wayland compositor
- [Catppuccin](https://catppuccin.com/) - Beautiful color schemes
- [Waybar](https://github.com/Alexays/Waybar) - Highly customizable status bar
- Community contributors and testers

---

**Made with ❤️ for the Linux desktop community**