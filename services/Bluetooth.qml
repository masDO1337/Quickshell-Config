pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Bluetooth

Singleton {
    id: root

    readonly property BluetoothAdapter adapter: Bluetooth.defaultAdapter

    readonly property bool available: adapter !== null
    readonly property bool enabled: available && adapter.enabled
    readonly property bool discovering: available && adapter.discovering

    readonly property string statusText: {
        if (!available)
            return "No Bluetooth adapter"

        if (!enabled)
            return "Bluetooth off"

        if (discovering)
            return "Scanning..."

        return adapter.name
    }

    function toggle() {
        if (!available)
            return

        adapter.enabled = !adapter.enabled
    }

    function toggleScan() {
        if (!available || !enabled)
            return

        adapter.discovering = !adapter.discovering
    }

    function toggleDevice(device) {
        if (!device)
            return

        device.connected = !device.connected
    }
}