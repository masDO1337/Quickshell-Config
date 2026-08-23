# Quickshell Config

A personal Quickshell desktop configuration built for Hyprland. It provides a compact panel bar, app launcher, notifications, and power menu with a single shell entry point.

## Features

- Top status bar with workspaces, clock, update status, media info, tray, network, Bluetooth, battery, and sound controls
- App launcher with search and keyboard navigation
- Notification popups and center
- Power menu for logout, shutdown, reboot, and suspend actions
- Multi-monitor support
- Extra helper script for Minecraft server status checks

## Project layout

- `shell.qml` — main Quickshell entry point
- `Bar/` — status bar implementation and blocks
- `AppLauncher/` — searchable application launcher UI
- `Notifications/` — notification popup and handling
- `PowerMenu/` — power actions and menu UI
- `Polkit/` — authentication integration
- `services/` — application/service logic used by the UI
- `scripts/` — helper scripts, including `mcserver.py`

## Requirements

- A Linux Wayland session running Hyprland
- Quickshell installed and configured to run as your shell/compositor UI layer
- Qt 6, provided by the Quickshell installation
- PipeWire and WirePlumber for the audio controls
- UPower for battery information
- BlueZ for Bluetooth controls
- A D-Bus session with MPRIS-compatible media players for media controls
- A notification service that supports the desktop notifications specification
- A polkit authentication service for privileged actions and Wi-Fi passwords
- `python3` for helper scripts

The following commands are required by specific parts of the configuration:

- `iwctl` and the `iwd` service for the Wi-Fi panel
- `checkupdates` for repository update checks
- `paru` for AUR update checks and package updates
- `kitty` as the terminal used to launch package updates

The Minecraft server block is optional. To enable it, install `mcstatus` for
`python3` and provide the server settings expected by `services/ServerStatus.qml`.

## Usage

1. Place this directory in your Quickshell config location.
2. Ensure Quickshell is started in your Hyprland session.
3. Use the configured keyboard shortcuts and bar controls to open the launcher, notifications, and power menu.

## Notes

This configuration is a personal setup and is intended as a base for customization. The styling and controls are intentionally minimal and easy to adjust for your own workflow.
