# Quickshell Config

A personal Quickshell desktop configuration built for Hyprland. It provides a compact panel bar, app launcher, notifications, and power menu with a single shell entry point.

## Features

- **Top status bar** with workspaces, clock, update status, media info, tray, network, Bluetooth, battery, and sound controls
- **App launcher** with search and keyboard navigation
- **Notification popups and center** for desktop notifications
- **Power menu** for logout, shutdown, reboot, and suspend actions
- **Multi-monitor support** with independent panels per display
- **Screenshot utility** with region/window selection and dimming overlay
- **Extra helper script** for Minecraft server status checks

## Project layout

- `shell.qml` — main Quickshell entry point
- `Bar/` — status bar implementation and blocks
- `AppLauncher/` — searchable application launcher UI
- `Notifications/` — notification popup and handling
- `PowerMenu/` — power actions and menu UI
- `Polkit/` — authentication integration
- `Screenshot/` — screenshot utility with region/window selection
- `services/` — application/service logic used by the UI
- `scripts/` — helper scripts, including `mcserver.py`

## Requirements

### Core Dependencies

- `hyprland` — Wayland compositor and window manager
- `quickshell` — Qt-based shell/compositor UI layer
- `qt6-base` — Qt 6 libraries
- `dbus` — D-Bus session daemon

### System Services

- `pipewire` `wireplumber` — Audio control and management
- `upower` — Battery and power information
- `bluez` — Bluetooth controls
- `polkit` — Authentication for privileged actions
- `dunst` or similar — Notification daemon

### Optional Components

The following Arch Linux packages are required for specific features:

- `iwd` — Wi-Fi connectivity and `iwctl` command for the Wi-Fi panel
- `pacman-contrib` — Provides `checkupdates` for repository update checks
- `paru` — AUR helper for AUR updates and package management
- `kitty` — Terminal emulator for launching package updates
- `python` — Python runtime for helper scripts
- `python-mcstatus` — Optional, for Minecraft server status checks (enable in `services/ServerStatus.qml`)
- `grim` — Screenshot capture tool for Wayland
- `wl-clipboard` — Provides `wl-copy` for clipboard integration
- `imagemagick` — Provides `magick` for image manipulation
- `libnotify` — Provides `notify-send` for desktop notifications

Media players must support MPRIS D-Bus interface for media controls in the status bar.

## Usage

1. Place this directory in your Quickshell config location.
2. Ensure Quickshell is started in your Hyprland session.
3. Use the configured keyboard shortcuts and bar controls to open the launcher, notifications, and power menu.

## Notes

This configuration is a personal setup and is intended as a base for customization. The styling and controls are intentionally minimal and easy to adjust for your own workflow.
