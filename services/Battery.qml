pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property int percentage: 0
    property bool charging: false
    property string status: "Unknown"

    Process {
        id: batteryProc
        command: ["bash", "-c", `
        BAT=$(find /sys/class/power_supply -maxdepth 1 -name "BAT*" | head -n1)
        if [ -n "$BAT" ]; then
            cat "$BAT/capacity"
            cat "$BAT/status"
        fi
        `]

        stdout: SplitParser {
            property int lineNumber: 0

            onRead: line => {
                if (lineNumber === 0)
                    root.percentage = parseInt(line)
                else if (lineNumber === 1) {
                    root.status = line
                    root.charging = line === "Charging"
                }
                lineNumber++
            }
        }

        onStarted: stdout.lineNumber = 0
    }

    Timer {
        interval: 10000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: batteryProc.running = true
    }
}