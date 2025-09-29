# Installation Guide

This guide will walk you through setting up the enhanced dotfiles on your system.

## Prerequisites

### System Requirements
- **Operating System:** Arch Linux (or Arch-based distribution)
- **Desktop Environment:** Wayland compositor (Hyprland)
- **Hardware:** Modern GPU (NVIDIA recommended for gaming optimizations)
- **Memory:** At least 4GB RAM (8GB+ recommended)
- **Storage:** 10GB free space for full setup

### Before Installation
1. **Backup existing configurations:**
   ```bash
   mkdir -p ~/backup-$(date +%Y%m%d)
   cp -r ~/.config ~/backup-$(date +%Y%m%d)/
   ```

2. **Update your system:**
   ```bash
   sudo pacman -Syu
   ```

## Step 1: Install Dependencies

### Core System Packages
```bash
# Wayland and Hyprland
sudo pacman -S hyprland xdg-desktop-portal-hyprland

# Status bar and notifications
sudo pacman -S waybar mako

# Application launcher and wallpapers
sudo pacman -S wofi swww

# Terminal and file manager
sudo pacman -S kitty thunar

# Screenshot and clipboard
sudo pacman -S grim slurp wl-clipboard

# Audio and media
sudo pacman -S pipewire pipewire-pulse pipewire-alsa
sudo pacman -S playerctl pavucontrol

# System utilities
sudo pacman -S brightnessctl gammastep
sudo pacman -S polkit-gnome networkmanager
sudo pacman -S bluez bluez-utils blueman

# Development tools
sudo pacman -S neovim git nodejs npm python python-pip
sudo pacman -S base-devel curl wget unzip
```

### Optional Packages
```bash
# Web browser and applications
sudo pacman -S firefox discord

# Fonts
sudo pacman -S ttf-jetbrains-mono-nerd noto-fonts noto-fonts-emoji

# System monitoring
sudo pacman -S htop btop lm_sensors
```

### AUR Packages
Install an AUR helper if you don't have one:
```bash
# Install yay (AUR helper)
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd .. && rm -rf yay
```

Install AUR packages:
```bash
# Cursor theme
yay -S bibata-cursor-theme-ice

# Additional applications (optional)
yay -S spotify obsidian-bin visual-studio-code-bin
```

## Step 2: Clone and Setup Dotfiles

### Clone Repository
```bash
# Clone to home directory
git clone https://github.com/yourusername/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Make scripts executable
chmod +x scripts/*.sh
```

### Initial Configuration
```bash
# Create necessary directories
mkdir -p ~/.config
mkdir -p ~/.local/share/dotfiles/{logs,backups}
mkdir -p ~/Pictures/Wallpapers
mkdir -p ~/scripts

# Deploy configurations
./scripts/dotfiles-manager.sh deploy
```

## Step 3: Enable Services

### System Services
```bash
# Enable NetworkManager
sudo systemctl enable --now NetworkManager

# Enable Bluetooth (optional)
sudo systemctl enable --now bluetooth

# Enable audio services
systemctl --user enable --now pipewire
systemctl --user enable --now pipewire-pulse
```

### User Services (Optional)
Create systemd user services for auto-starting components:

```bash
# Create user service directory
mkdir -p ~/.config/systemd/user

# Waybar service
cat > ~/.config/systemd/user/waybar.service << 'EOF'
[Unit]
Description=Waybar status bar
After=graphical-session.target

[Service]
ExecStart=/usr/bin/waybar
Restart=on-failure

[Install]
WantedBy=default.target
EOF

# Mako service
cat > ~/.config/systemd/user/mako.service << 'EOF'
[Unit]
Description=Mako notification daemon
After=graphical-session.target

[Service]
ExecStart=/usr/bin/mako
Restart=on-failure

[Install]
WantedBy=default.target
EOF

# Enable services
systemctl --user enable waybar.service
systemctl --user enable mako.service
```

## Step 4: Configure Graphics

### NVIDIA Setup (if applicable)
```bash
# Install NVIDIA drivers
sudo pacman -S nvidia nvidia-utils nvidia-settings

# Enable DRM kernel mode setting
sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="/&nvidia-drm.modeset=1 /' /etc/default/grub
sudo grub-mkconfig -o /boot/grub/grub.cfg

# Configure Xorg for Wayland
echo "WLR_NO_HARDWARE_CURSORS=1" >> ~/.config/hypr/hyprland.conf
```

### AMD Setup (if applicable)
```bash
# Install AMD drivers
sudo pacman -S mesa vulkan-radeon libva-mesa-driver mesa-vdpau

# Enable early KMS
echo "MODULES=(amdgpu)" | sudo tee -a /etc/mkinitcpio.conf
sudo mkinitcpio -P
```

## Step 5: Theme and Wallpapers

### Apply Default Theme
```bash
# Apply Catppuccin Mocha theme
./scripts/enhanced-theme-switcher.sh catppuccin-mocha
```

### Add Wallpapers
```bash
# Download sample wallpapers (optional)
mkdir -p ~/Pictures/Wallpapers
cd ~/Pictures/Wallpapers

# Add your wallpapers here or download some
wget https://github.com/catppuccin/wallpapers/raw/main/landscapes/tropic_island_morning.png
wget https://github.com/catppuccin/wallpapers/raw/main/landscapes/mountain.png

# Set initial wallpaper
cd ~/dotfiles
./scripts/wallpaper.sh --random
```

## Step 6: Neovim Setup

### Install Neovim Plugins
```bash
# Start Neovim to trigger plugin installation
nvim +q

# Or manually install lazy.nvim
git clone --filter=blob:none --branch=stable \
  https://github.com/folke/lazy.nvim.git \
  ~/.local/share/nvim/lazy/lazy.nvim
```

### Configure LSP Servers
After starting Neovim for the first time:
1. Run `:Mason` to open the package manager
2. Install desired language servers:
   - `lua_ls` for Lua
   - `pyright` for Python
   - `ts_ls` for TypeScript/JavaScript
   - `bashls` for Bash

## Step 7: Performance Optimization

### Apply Performance Profile
```bash
# Analyze current performance
./scripts/performance-optimizer.sh analyze

# Apply balanced profile (recommended for most users)
./scripts/performance-optimizer.sh profile balanced

# For gaming systems
./scripts/performance-optimizer.sh profile gaming

# Comprehensive optimization
./scripts/performance-optimizer.sh optimize --all
```

### Enable System Monitoring
```bash
# Start system monitoring daemon
./scripts/system-monitor.sh daemon
```

## Step 8: Verification

### Health Check
Run comprehensive health check:
```bash
./scripts/hypr-utils.sh health
```

### Test Components
1. **Hyprland:** Press `Super + Return` to open terminal
2. **Waybar:** Check if status bar is visible
3. **Notifications:** Test with `notify-send "Test" "Hello World"`
4. **Launcher:** Press `Super + R` to open application launcher
5. **Theme:** Press `Super + T` to open theme switcher

### Common Issues and Solutions

#### Waybar not starting
```bash
# Check configuration
./scripts/dotfiles-manager.sh validate

# Check logs
journalctl --user -u waybar.service -f

# Manual restart
pkill waybar && waybar &
```

#### Notifications not working
```bash
# Check mako service
systemctl --user status mako.service

# Restart mako
systemctl --user restart mako.service
```

#### Theme not applying
```bash
# Validate theme files
./scripts/enhanced-theme-switcher.sh list

# Reapply theme
./scripts/enhanced-theme-switcher.sh catppuccin-mocha
```

## Step 9: Final Configuration

### Environment Variables
Add to `~/.bashrc` or `~/.zshrc`:
```bash
# Wayland environment
export XDG_CURRENT_DESKTOP=Hyprland
export XDG_SESSION_TYPE=wayland
export XDG_SESSION_DESKTOP=Hyprland

# NVIDIA specific (if applicable)
export WLR_NO_HARDWARE_CURSORS=1
export LIBVA_DRIVER_NAME=nvidia
export GBM_BACKEND=nvidia-drm
export __GLX_VENDOR_LIBRARY_NAME=nvidia

# Qt/GTK themes
export QT_QPA_PLATFORM=wayland
export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
export GTK_THEME=Adwaita:dark

# Dotfiles configuration
export DOTFILES_LOG_LEVEL=2
```

### Login Manager Configuration
If using SDDM:
```bash
# Install SDDM theme (optional)
sudo pacman -S sddm-kcm

# Configure SDDM for Wayland
sudo mkdir -p /etc/sddm.conf.d
echo "[General]
DisplayServer=wayland" | sudo tee /etc/sddm.conf.d/wayland.conf
```

## Step 10: Backup and Maintenance

### Create Initial Backup
```bash
# Create comprehensive backup
./scripts/dotfiles-manager.sh backup
```

### Regular Maintenance
Add to crontab for automated maintenance:
```bash
crontab -e
# Add these lines:
0 2 * * * ~/scripts/dotfiles-manager.sh backup >/dev/null 2>&1
0 3 * * 0 ~/scripts/dotfiles-manager.sh clean >/dev/null 2>&1
```

## Troubleshooting

### Log Locations
- **Main logs:** `~/.local/share/dotfiles/logs/dotfiles.log`
- **Hyprland logs:** `journalctl --user -u hyprland.service`
- **System logs:** `journalctl -xe`

### Reset to Defaults
If something goes wrong:
```bash
# Restore default configs
./scripts/hypr-utils.sh restore

# Or reset performance settings
./scripts/performance-optimizer.sh restore
```

### Getting Help
1. Check the logs for error messages
2. Run health check: `./scripts/hypr-utils.sh health`
3. Validate configurations: `./scripts/dotfiles-manager.sh validate`
4. Refer to the main README.md for detailed documentation

## Next Steps

After successful installation:
1. **Customize keybindings** in `hypr/hyprland.conf`
2. **Add your applications** to waybar configuration
3. **Install additional themes** or create your own
4. **Configure backup schedule** for your preferences
5. **Explore advanced features** in the documentation

Congratulations! You now have a fully configured, high-performance Hyprland desktop environment.