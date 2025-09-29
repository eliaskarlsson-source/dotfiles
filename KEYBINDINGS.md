# Keybindings Reference

## Hyprland Window Management

### Basic Operations
| Key Combination | Action |
|----------------|--------|
| `Super + Return` | Open terminal (Kitty) |
| `Super + Q` | Close active window |
| `Super + F` | Toggle fullscreen (normal) |
| `Super + Shift + F` | Toggle fullscreen (fake) |
| `Super + V` | Toggle floating mode |
| `Super + M` | Exit Hyprland |
| `Super + Alt + M` | Emergency exit |

### Window Navigation
| Key Combination | Action |
|----------------|--------|
| `Super + Left` | Move focus left |
| `Super + Right` | Move focus right |
| `Super + Up` | Move focus up |
| `Super + Down` | Move focus down |
| `Alt + Tab` | Cycle to next window |
| `Alt + Shift + Tab` | Cycle to previous window |

### Window Movement
| Key Combination | Action |
|----------------|--------|
| `Super + Shift + Left` | Move window left |
| `Super + Shift + Right` | Move window right |
| `Super + Shift + Up` | Move window up |
| `Super + Shift + Down` | Move window down |

### Window Resizing
| Key Combination | Action |
|----------------|--------|
| `Super + Ctrl + Left` | Resize window left (-20px) |
| `Super + Ctrl + Right` | Resize window right (+20px) |
| `Super + Ctrl + Up` | Resize window up (-20px) |
| `Super + Ctrl + Down` | Resize window down (+20px) |

### Mouse Actions
| Action | Function |
|--------|----------|
| `Super + Left Click + Drag` | Move window |
| `Super + Right Click + Drag` | Resize window |

## Applications

### Core Applications
| Key Combination | Action |
|----------------|--------|
| `Super + Return` | Terminal (Kitty) |
| `Super + E` | File manager (Thunar) |
| `Super + B` | Web browser (Firefox) |
| `Super + C` | Code editor (VS Code) |
| `Super + D` | Discord |
| `Super + S` | Spotify |
| `Super + N` | Notes (Obsidian) |
| `Super + Shift + S` | Steam |
| `Super + A` | Audio control (PulseAudio) |
| `Super + Shift + E` | Edit dotfiles in VS Code |

### Launchers and Menus
| Key Combination | Action |
|----------------|--------|
| `Super + R` | Application launcher (apps mode) |
| `Super + Shift + R` | Run command launcher |
| `Super + Tab` | Window switcher |

## Workspaces

### Workspace Navigation
| Key Combination | Action |
|----------------|--------|
| `Super + 1-9` | Switch to workspace 1-9 |
| `Super + 0` | Switch to workspace 10 |
| `Super + Minus` | Toggle special workspace |
| `Super + bracketleft` | Focus left monitor |
| `Super + bracketright` | Focus right monitor |

### Moving Windows to Workspaces
| Key Combination | Action |
|----------------|--------|
| `Super + Shift + 1-9` | Move window to workspace 1-9 |
| `Super + Shift + 0` | Move window to workspace 10 |
| `Super + Shift + Minus` | Move window to special workspace |
| `Super + Shift + X` | Move window to special (silent) |
| `Super + Shift + bracketleft` | Move workspace to left monitor |
| `Super + Shift + bracketright` | Move workspace to right monitor |

## Group Management

### Group Operations
| Key Combination | Action |
|----------------|--------|
| `Super + K` | Toggle group (create/destroy) |
| `Super + Shift + K` | Toggle group lock |
| `Super + H` | Previous window in group |
| `Super + L` | Next window in group |

### Adding to Groups
| Key Combination | Action |
|----------------|--------|
| `Super + Ctrl + H` | Move window into group (left) |
| `Super + Ctrl + L` | Move window into group (right) |
| `Super + Ctrl + K` | Move window into group (up) |
| `Super + Ctrl + J` | Move window into group (down) |
| `Super + Alt + H` | Move window out of group |
| `Super + Alt + L` | Move window out of group |

## Advanced Window Management

### Special Operations
| Key Combination | Action |
|----------------|--------|
| `Super + X` | Pin window |
| `Super + J` | Toggle split (dwindle) |
| `Super + P` | Enable pseudo mode |
| `Super + Shift + V` | Pin window (alternative) |
| `Super + Shift + Tab` | Cycle previous window |
| `Super + Ctrl + F` | Make all windows in workspace float |

## System Controls

### System Actions
| Key Combination | Action |
|----------------|--------|
| `Super + Space` | Power menu |
| `Super + Shift + Space` | Screenshot menu |
| `Super + L` | Lock screen |
| `Super + I` | System health check |
| `Super + G` | Toggle game mode |
| `Super + T` | Theme switcher menu |
| `Super + Shift + T` | Apply Catppuccin Mocha theme |
| `Super + Ctrl + W` | Random wallpaper |
| `Super + Backspace` | Reload Hyprland config |

### Wallpaper Controls
| Key Combination | Action |
|----------------|--------|
| `Super + W` | Random wallpaper |
| `Super + Shift + Right` | Next wallpaper |
| `Super + Shift + Left` | Previous wallpaper |

## Media Controls

### Audio & Media
| Key Combination | Action |
|----------------|--------|
| `XF86AudioRaiseVolume` | Volume up (+5%) |
| `XF86AudioLowerVolume` | Volume down (-5%) |
| `XF86AudioMute` | Toggle mute |
| `XF86AudioMicMute` | Toggle microphone mute |
| `XF86AudioPlay` | Play/pause media |
| `XF86AudioPause` | Play/pause media |
| `XF86AudioNext` | Next track |
| `XF86AudioPrev` | Previous track |

## Neovim Keybindings

### File Operations
| Key Combination | Action |
|----------------|--------|
| `<leader>e` | Toggle file explorer |
| `<leader>E` | Focus file explorer |
| `<leader>w` | Save file |
| `<leader>wa` | Save all files |
| `<leader>q` | Quit |
| `<leader>qa` | Quit all |
| `Ctrl + s` | Save file |

### Navigation & Search
| Key Combination | Action |
|----------------|--------|
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep |
| `<leader>fb` | Buffer list |
| `<leader>fh` | Help tags |
| `<leader>fr` | Recent files |
| `<leader>fc` | Colorschemes |

### Buffer Management
| Key Combination | Action |
|----------------|--------|
| `Tab` | Next buffer |
| `Shift + Tab` | Previous buffer |
| `<leader>bd` | Delete buffer |
| `<leader>ba` | Close other buffers |

### Window Management
| Key Combination | Action |
|----------------|--------|
| `<leader>sv` | Vertical split |
| `<leader>sh` | Horizontal split |
| `<leader>se` | Equal splits |
| `<leader>sx` | Close split |
| `Ctrl + h/j/k/l` | Navigate windows |

### Git Integration
| Key Combination | Action |
|----------------|--------|
| `<leader>gs` | Git status |
| `<leader>gc` | Git commit |
| `<leader>gp` | Git push |
| `<leader>gl` | Git log |

### LSP & Development
| Key Combination | Action |
|----------------|--------|
| `gd` | Go to definition |
| `gr` | Go to references |
| `gi` | Go to implementation |
| `K` | Hover documentation |
| `<leader>rn` | Rename symbol |
| `<leader>ca` | Code action |
| `<leader>f` | Format code |
| `[d` | Previous diagnostic |
| `]d` | Next diagnostic |

### Debugging
| Key Combination | Action |
|----------------|--------|
| `<leader>db` | Toggle breakpoint |
| `<leader>dc` | Continue debugging |
| `<leader>di` | Step into |
| `<leader>do` | Step over |
| `<leader>du` | Toggle DAP UI |

### Diagnostics
| Key Combination | Action |
|----------------|--------|
| `<leader>xx` | Open Trouble |
| `<leader>xd` | Document diagnostics |
| `<leader>xw` | Workspace diagnostics |

## Script Commands

### Dotfiles Manager
```bash
# Configuration deployment
dotfiles-manager.sh deploy
dotfiles-manager.sh validate
dotfiles-manager.sh backup
dotfiles-manager.sh restore

# Theme management
dotfiles-manager.sh theme list
dotfiles-manager.sh theme apply <name>
dotfiles-manager.sh theme current

# System maintenance
dotfiles-manager.sh sync
dotfiles-manager.sh health
dotfiles-manager.sh clean
```

### Performance Optimizer
```bash
# Analysis and profiles
performance-optimizer.sh analyze
performance-optimizer.sh profile <name>
performance-optimizer.sh optimize --all

# Component optimization
performance-optimizer.sh gpu <mode>
performance-optimizer.sh memory
performance-optimizer.sh disk
performance-optimizer.sh services
```

### System Monitor
```bash
# Monitoring commands
system-monitor.sh status
system-monitor.sh daemon
system-monitor.sh stop
system-monitor.sh history <hours>
system-monitor.sh config
```

### Hyprland Utilities
```bash
# Health and diagnostics
hypr-utils.sh health
hypr-utils.sh core
hypr-utils.sh files
hypr-utils.sh system

# Configuration management
hypr-utils.sh validate
hypr-utils.sh backup
hypr-utils.sh restore
hypr-utils.sh reload

# Control functions
hypr-utils.sh power
hypr-utils.sh volume
hypr-utils.sh screenshot
hypr-utils.sh gamemode
```

---

**Legend:**
- `Super` = Windows/Cmd key
- `<leader>` = Space key (in Neovim)
- Numbers in ranges (1-9) mean any number in that range
- `+` means keys pressed simultaneously
- Commands are run in terminal