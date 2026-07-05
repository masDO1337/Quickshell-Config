pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property Process lock: Process {
        command: ["hyprlock"]
        running: false
    }

    readonly property Process logout: Process {
        command: ["uwsm", "stop"]
        running: false
    }

    readonly property Process reboot: Process {
        command: ["systemctl", "reboot"]
        running: false
    }

    readonly property Process poweroff: Process {
        command: ["systemctl", "poweroff"]
        running: false
    }
}